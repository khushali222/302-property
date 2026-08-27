import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import 'NetworkProvider.dart';

/// Watches route transitions so a screen can tell when it becomes visible
/// again. Registered once, in `MaterialApp.navigatorObservers`.
final RouteObserver<PageRoute> appRouteObserver = RouteObserver<PageRoute>();

/// Gives a screen a working Retry button and silent recovery, without the
/// screen having to know anything about connectivity.
///
/// WHY THE SCREEN NO LONGER ASKS THE PHONE
/// Every screen used to call `connectivity_plus` itself. On iOS that reports
/// `none` on a perfectly good network, so screens declared themselves offline
/// while their requests would have succeeded — and, having decided once in
/// `initState`, they stayed that way until the app was restarted. Nothing here
/// asks the plugin. A screen shows the offline state only when its own request
/// actually failed, which is direct evidence rather than a guess.
///
/// WHY RECOVERY IS SHARED BUT BLOCKING IS NOT
/// [CheckConnection.successGeneration] only ever counts UP, and only when a
/// request succeeds. It is an announcement — "traffic is flowing again" — and
/// it cannot block anything. Blocking stays local to the screen that failed,
/// so a wrong answer costs one needless reload instead of locking every screen
/// in the app.
///
/// Usage:
///
/// ```dart
/// class _MyScreenState extends State<MyScreen> with NetworkRetryState {
///   @override
///   Future<void> reloadData() async {
///     setState(() => _future = MyRepo().fetch());   // this screen's own load
///   }
///
///   // ... in build:
///   NoInternetView(onRetry: retryNow)
/// }
/// ```
///
/// A screen overriding [initState], [didChangeDependencies] or [dispose] must
/// call `super`.
mixin NetworkRetryState<T extends StatefulWidget> on State<T>
    implements RouteAware {
  /// The announcement this screen last loaded at. Anything newer means the
  /// connection came back after this screen's data was fetched.
  int _seenGeneration = 0;

  /// Failure announcements already accounted for, so the same failure cannot
  /// be reacted to twice.
  int _seenFailure = 0;

  /// True when THIS screen's own request failed while the user was looking at
  /// it. Deliberately per-screen: the app has no global "we are offline" flag
  /// to get wrong, so one failure can never black out every screen at once.
  bool _offline = false;

  /// A Retry is in flight. Also the double-tap guard: repeated taps while a
  /// retry is still running are ignored rather than stacking requests.
  bool _retrying = false;

  /// Gate a screen's body on this instead of asking `connectivity_plus`.
  /// The plugin answers `none` on a working iOS network, and only updates on
  /// OS events that the simulator frequently never sends — which is why a
  /// screen could sit there showing raw errors with no offline state at all.
  /// A failed request cannot be wrong in that way.
  bool get isOffline => _offline;

  /// Re-issue this screen's own data load. This is the ONLY thing a screen has
  /// to supply — everything else about connectivity lives in this file, so a
  /// later change to the design does not mean editing every screen again.
  Future<void> reloadData();

  int get _currentGeneration => CheckConnection.instance?.successGeneration ?? 0;

  @override
  void initState() {
    super.initState();
    // Loading now, so this screen is current as of these announcements.
    _seenGeneration = _currentGeneration;
    _seenFailure = CheckConnection.instance?.failureGeneration ?? 0;
    CheckConnection.instance?.addListener(_onConnectionEvent);
  }

  /// A request somewhere in the app just failed or just succeeded.
  ///
  /// Only the screen the user is LOOKING AT reacts. A screen sitting in the
  /// background must not flip itself offline, or one stale request would black
  /// out pages the user is not even on — and would fight the Retry button on
  /// the page they are.
  void _onConnectionEvent() {
    if (!mounted) return;
    final conn = CheckConnection.instance;
    if (conn == null) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    if (conn.failureGeneration != _seenFailure) {
      _seenFailure = conn.failureGeneration;
      if (_retrying) {
        // The user asked and it still did not work. Say so — a Retry that
        // silently changes nothing reads as a broken button.
        _retrying = false;
        Fluttertoast.showToast(msg: 'Still no internet connection');
      }
      if (!_offline) setState(() => _offline = true);
      return;
    }
    if (conn.successGeneration != _seenGeneration) {
      // Marked BEFORE any reload is issued, so a reload that fails can never
      // re-enter this branch and retrigger itself.
      _seenGeneration = conn.successGeneration;
      final wasRetrying = _retrying;
      _retrying = false;
      if (!_offline) return;
      // Traffic is flowing again — but this screen is still holding the
      // request that FAILED. Dropping the offline state without re-issuing it
      // just reveals that dead result, which is what made a recovered screen
      // read "No Data Available" instead of showing its rows.
      setState(() => _offline = false);
      // A Retry has already issued the load; reloading here as well would
      // fetch the same data twice.
      if (!wasRetrying) _reloadWhenSettled();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    CheckConnection.instance?.removeListener(_onConnectionEvent);
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Reload once the connection has had a moment to settle.
  ///
  /// The recovery announcement fires on the FIRST request to succeed after a
  /// failure, which is the earliest possible moment — the connection is back
  /// but not necessarily steady. A reload issued on that exact edge came back
  /// non-200 and rendered as an empty list, so the same off/on test showed
  /// rows one time and "No Data Available" the next. This is a settle pause,
  /// not a retry loop: it happens once per recovery, and a reload that still
  /// fails leaves the screen on its offline state with a working Retry.
  Future<void> _reloadWhenSettled() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await reloadData();
  }

  /// Reload, but only if the connection came back since this screen loaded.
  ///
  /// Two guards matter here, and both exist because of how this went wrong
  /// before:
  ///
  /// * The generation is recorded BEFORE the reload is issued, so a reload
  ///   that fails can never re-trigger itself. Failure is not an announcement,
  ///   and only announcements cause reloads — there is no path back into this
  ///   method from a failed request.
  /// * This runs only when the screen becomes visible ([didPopNext]), never on
  ///   the announcement itself, so ten stacked screens cannot all fire their
  ///   requests at the same moment.
  void _reloadIfStale() {
    if (!mounted) return;
    final generation = _currentGeneration;
    if (generation == _seenGeneration) return;
    _seenGeneration = generation;
    reloadData();
  }

  /// What a Retry button calls. Re-issues this screen's load directly — the
  /// same work that opening the screen fresh would do.
  Future<void> retryNow() async {
    if (!mounted || _retrying) return;
    _retrying = true;
    _seenGeneration = _currentGeneration;
    _seenFailure = CheckConnection.instance?.failureGeneration ?? 0;
    try {
      await reloadData();
      // A reload that succeeded will have bumped the counter on its way back;
      // absorb it here so returning to this screen later does not re-fetch
      // data that is already fresh.
      if (mounted) _seenGeneration = _currentGeneration;
    } finally {
      // Cleared HERE, not only when an announcement arrives. Relying on the
      // announcement left this stuck true whenever the reload succeeded
      // WITHOUT producing one — noteRequestSucceeded() stays silent if some
      // other request had already cleared the failure flag — and equally if
      // reloadData() threw. Once stuck, `if (_retrying) return` above swallowed
      // every later tap and the Retry button was dead for good.
      _retrying = false;
    }
  }

  /// The user came back to this screen from one pushed on top of it. This is
  /// the moment the screen becomes visible again, and the only moment a silent
  /// reload is allowed to happen.
  @override
  void didPopNext() => _reloadIfStale();

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}
