import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'NetworkProvider.dart';

/// Wires a screen to the app-wide connection state so it reloads itself when
/// the connection comes back, instead of keeping its own connectivity flag.
///
/// Replaces the per-screen `_connectivityResult` + `checkInternet()` pair that
/// is currently copied across ~58 screens. Each of those copies asks the
/// plugin independently, so one screen recovering never helped the next — the
/// reason a full app restart was the only reliable fix.
///
/// Usage — add the mixin, implement [reloadOnNetworkRestored], and gate the
/// body on [isOnline]:
///
/// ```dart
/// class _MyScreenState extends State<MyScreen> with NetworkAwareState {
///   @override
///   Future<void> reloadOnNetworkRestored() async {
///     setState(() => _future = fetchMyData());
///   }
///
///   @override
///   Widget build(BuildContext context) => Scaffold(
///         body: isOnline
///             ? _content()
///             : NoInternetView(onRetry: retryNetwork),
///       );
/// }
/// ```
///
/// [initState] and [dispose] are handled here; a screen overriding either must
/// call `super`.
mixin NetworkAwareState<T extends StatefulWidget> on State<T> {
  VoidCallback? _dropReload;

  /// Re-issue this screen's own data load. Called automatically when the
  /// connection returns, and by [retryNetwork] when the user asks.
  Future<void> reloadOnNetworkRestored();

  /// True while the app believes it has a working connection. Reads from the
  /// shared provider rather than probing here, so every screen agrees.
  bool get isOnline => context.watch<CheckConnection>().isConnected;

  /// What a Retry control calls: verify for real, and reload on success.
  ///
  /// Returns false when we are still offline, so the caller can tell the user
  /// rather than silently doing nothing.
  Future<bool> retryNetwork() async {
    final online = await context.read<CheckConnection>().recheck();
    if (!online || !mounted) return online;
    await reloadOnNetworkRestored();
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Deferred: context is not safe to read during initState itself.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dropReload = context
          .read<CheckConnection>()
          .registerReload(() async {
        if (!mounted) return;
        await reloadOnNetworkRestored();
      });
    });
  }

  @override
  void dispose() {
    _dropReload?.call();
    super.dispose();
  }
}
