import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// App-wide answer to "are we online?", plus the hook a screen uses to reload
/// itself when the connection comes back.
///
/// WHY THERE IS NO CONNECTIVITY PROBE HERE
/// Three were tried and all three reported "offline" on a working network:
/// `Connectivity().checkConnectivity()` (a cached result that stays `none`
/// after the network returns), a raw DNS lookup, and an HTTP HEAD that
/// succeeded from the host terminal while failing inside the app. Since this
/// one flag blocks the ENTIRE app, a false negative locks the user out of
/// something that works — the worst outcome available. So the only evidence
/// accepted is a real request failing ([reportNetworkFailure]).
///
/// Consumed by [NetworkGuard], mounted once from `MaterialApp.builder`, which
/// paints the offline state over every route. Individual screens still carry
/// their own legacy connectivity flags; those are now redundant.
class CheckConnection extends ChangeNotifier {
  /// The app-wide instance, for callers with no BuildContext — the HTTP
  /// wrappers report request failures through this. Set on construction;
  /// there is only ever the one created in main.dart.
  static CheckConnection? instance;

  /// Optimistic by default and by design — see the class comment.
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Optimistic recovery loop while offline — see [_scheduleOptimisticRecovery].
  Timer? _offlineRecheck;

  /// Broadcast so several listeners can watch at once.
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  StreamSubscription<ConnectivityResult>? _sub;

  /// Screens that asked to be reloaded when the connection returns, in the
  /// order they were pushed. Only the last one — the screen actually in front
  /// of the user — is reloaded; see [_notifyRestored].
  final List<_ReloadEntry> _reloadStack = [];

  CheckConnection() {
    instance = this;
    // FAIL-OPEN, by hard-won lesson. Every synthetic signal available here has
    // produced false "offline" verdicts on a working network: the plugin's
    // cached result, a raw DNS lookup, and even an HTTP probe that succeeds
    // from the same machine's terminal. Blocking the whole app on any of them
    // locks users out of a working app. So nothing synthetic ever takes this
    // offline — only [reportNetworkFailure], a REAL request failing at the
    // socket level, does. A connectivity event is used solely as good news:
    // the OS says a network appeared, so lift the block and let the app's own
    // requests be the judge again.
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) _apply(true);
    });
  }

  // ── Recovery announcements ──────────────────────────────────────────────
  //
  // This counter carries ONLY good news, and that is the whole point of it.
  // It goes up when a request SUCCEEDS after something had failed, and it can
  // never block anything: screens compare it against the value they last
  // loaded at, and re-issue their own load when they next become visible.
  //
  // Blocking deliberately stays LOCAL — a screen shows the offline state only
  // when its own request failed. So a wrong value here costs at most one
  // unnecessary reload, where a shared "we are offline" flag would have locked
  // every screen in the app at once.
  int _successGeneration = 0;
  int get successGeneration => _successGeneration;

  /// True once a request has failed and no request has succeeded since. Only
  /// used to recognise the NEXT success as a recovery worth announcing.
  bool _sawFailure = false;

  /// Counts request failures. Like [successGeneration] this is an
  /// ANNOUNCEMENT, not a verdict: it says "a request just failed", and each
  /// screen decides for itself what to do about it. Only the screen the user
  /// is actually looking at reacts, so one failure can never black out the app.
  int _failureGeneration = 0;
  int get failureGeneration => _failureGeneration;

  /// A request failed at the socket level. On its own this blocks nothing.
  void noteRequestFailed() {
    _sawFailure = true;
    _failureGeneration++;
    notifyListeners();
  }

  /// A request succeeded. Announced only when something had failed since the
  /// last announcement, so ordinary traffic does not rebuild listening
  /// screens — the notification means "we just came back", nothing else.
  void noteRequestSucceeded() {
    if (!_sawFailure) return;
    _sawFailure = false;
    _successGeneration++;
    notifyListeners();
  }

  /// For the HTTP wrappers: a request just failed at the socket level. This is
  /// the ONLY signal allowed to take the app offline — it is direct evidence,
  /// where every probe we tried produced false alarms.
  void reportNetworkFailure() {
    noteRequestFailed();
    _apply(false);
  }

  /// Optimistic recovery loop: while offline, periodically lift the block so
  /// the visible screen's own requests can try again. If we are genuinely
  /// offline they fail in seconds and [reportNetworkFailure] restores the
  /// block; if the network is back, the app simply works again — no probe in
  /// the loop to get it wrong.
  void _scheduleOptimisticRecovery() {
    _offlineRecheck ??= Timer.periodic(
      const Duration(seconds: 15),
      (_) => _apply(true),
    );
  }

  void _apply(bool online) {
    // Keep the recovery loop consistent with the state even when the state
    // itself did not change (e.g. repeated failure reports).
    if (!online) {
      _scheduleOptimisticRecovery();
    } else {
      _offlineRecheck?.cancel();
      _offlineRecheck = null;
    }
    if (_isConnected == online) return;
    final cameBack = !_isConnected && online;
    _isConnected = online;
    if (!_connectivityController.isClosed) {
      _connectivityController.add(online);
    }
    notifyListeners();
    if (cameBack) _notifyRestored();
  }

  /// What a "Retry" control calls: lift the block and let the screen's own
  /// reload be the test. If we are genuinely offline that reload fails within
  /// seconds and [reportNetworkFailure] brings the block straight back; if the
  /// network is back, the app just works. Deliberately NO probe here — every
  /// probe variant tried (plugin cache, DNS lookup, HTTP HEAD) produced false
  /// "offline" verdicts on a working network and stranded the user instead.
  Future<bool> recheck() async {
    _apply(true);
    return true;
  }

  /// Register a reload for the screen currently being built.
  ///
  /// Call from `initState` and invoke the returned function from `dispose`:
  ///
  /// ```dart
  /// _dropReload = context.read<CheckConnection>().registerReload(() async {
  ///   await _loadMyData();
  /// });
  /// ```
  ///
  /// Only the most recently registered screen is reloaded when the connection
  /// returns, so pushing a detail page does not re-fire every list behind it.
  VoidCallback registerReload(Future<void> Function() onRestored) {
    final entry = _ReloadEntry(onRestored);
    _reloadStack.add(entry);
    return () => _reloadStack.remove(entry);
  }

  /// Reload just the screen in front of the user. Reloading the whole stack
  /// would fire a request per screen for pages nobody is looking at.
  void _notifyRestored() {
    if (_reloadStack.isEmpty) return;
    final top = _reloadStack.last;
    // Errors here belong to the screen's own load path, which reports them
    // itself; swallow so one screen cannot break the provider.
    top.onRestored().catchError((_) {});
  }

  @override
  void dispose() {
    if (identical(instance, this)) instance = null;
    _offlineRecheck?.cancel();
    _sub?.cancel();
    _reloadStack.clear();
    _connectivityController.close();
    super.dispose();
  }
}

class _ReloadEntry {
  final Future<void> Function() onRestored;
  _ReloadEntry(this.onRestored);
}
