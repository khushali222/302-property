import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constant.dart';
import '../provider/NetworkProvider.dart';

/// App-wide offline blocker, mounted once from `MaterialApp.builder` so it sits
/// above every route.
///
/// Replaces the "each screen decides for itself" arrangement: a screen no
/// longer needs its own connectivity flag, its own offline widget, or its own
/// retry. One place owns it.
///
/// The blocked screen stays MOUNTED underneath — this is a [Stack] overlay, not
/// a replacement — so when the connection returns the user is exactly where
/// they were, with their scroll position, page number and filters intact.
class NetworkGuard extends StatelessWidget {
  final Widget child;

  const NetworkGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<CheckConnection>().isConnected;
    // Covers the whole screen. The header the user sees while offline is a
    // non-interactive REPLICA drawn inside the overlay, not the real app bar:
    // leaving the real one visible kept the hamburger tappable, and the
    // drawer then slid in UNDER the overlay and tore the layout — a doubled
    // app bar with a strip of drawer beside it.
    // StackFit.expand is required, not cosmetic: a Stack hands non-positioned
    // children LOOSE constraints, while MaterialApp.builder previously passed
    // the navigator tight ones. Without this every screen in the app would be
    // laid out against different constraints than before.
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (!online) const _OfflineBlocker(),
      ],
    );
  }
}

class _OfflineBlocker extends StatefulWidget {
  const _OfflineBlocker();

  @override
  State<_OfflineBlocker> createState() => _OfflineBlockerState();
}

class _OfflineBlockerState extends State<_OfflineBlocker> {
  bool _checking = false;
  bool _stillOffline = false;

  /// Shown in the replica header, read from the same preferences the real app
  /// bar uses so the two match.
  String _companyName = '';
  String _fullName = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      // Built exactly as the real app bar builds it — "first last" from the
      // same two preferences — so the label can't diverge from the header the
      // user sees when online. Whether it renders as initials or in full is a
      // width decision, made at paint time below, again matching the app bar.
      final first = (prefs.getString('first_name') ?? '').trim();
      final last = (prefs.getString('last_name') ?? '').trim();
      final combined = [
        if (first.isNotEmpty) first,
        if (last.isNotEmpty) last,
      ].join(' ');
      setState(() {
        _companyName = prefs.getString('companyName') ?? '';
        _fullName = combined.isNotEmpty ? combined : 'L';
      });
    });
  }

  /// A NON-INTERACTIVE copy of the app bar, drawn inside the overlay.
  ///
  /// The real app bar cannot be left showing: keeping it tappable let the
  /// drawer slide in UNDER the fixed overlay and tear the layout. Drawing a
  /// replica up here keeps the app looking like itself while offline —
  /// same white bar, hairline elevation, centred company name, same 60/80
  /// height split — with nothing behind it that can move.
  Widget _replicaHeader(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final statusBar = MediaQuery.of(context).padding.top;
    final barHeight = width < 500 ? 60.0 : 80.0;
    return Material(
      elevation: 1,
      color: Colors.white,
      child: Container(
        height: statusBar + barHeight,
        padding: EdgeInsets.only(top: statusBar, left: 16, right: 16),
        child: Row(
          children: [
            // Same three affordances as the real bar — drawn, not live, so
            // nothing here can open the drawer and slide under the overlay.
            const Icon(Icons.menu, size: 26, color: Colors.black),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _companyName.isNotEmpty ? _companyName : 'Company Name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            FaIcon(FontAwesomeIcons.bell, size: 20, color: blueColor),
            const SizedBox(width: 16),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _avatarLabel(width),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width > 500 ? 16 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mirrors the app bar's own rule: initials on a narrow screen, the full
  /// name on a wide one.
  String _avatarLabel(double width) {
    if (_fullName.isEmpty) return '--';
    if (width >= 500) return _fullName;
    final parts = _fullName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '--';
  }

  Future<void> _retry() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _stillOffline = false;
    });
    final online = await context.read<CheckConnection>().recheck();
    if (!mounted) return;
    // When we are back online the provider flips its flag and this whole
    // overlay is removed, so only the still-offline case needs handling.
    setState(() {
      _checking = false;
      _stillOffline = !online;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Opaque, and its own Material, because this sits above the app's routes
    // and cannot inherit their scaffold. Being hit-testable is what stops taps
    // reaching the screen underneath.
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          _replicaHeader(context),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/no_internet.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                    const Text(
                      'No Internet',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Check your internet connection',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _checking ? null : _retry,
                        icon: _checking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.refresh,
                                size: 18, color: Colors.white),
                        label: Text(
                          _checking ? 'Checking…' : 'Retry',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyClr,
                          disabledBackgroundColor: navyClr.withOpacity(0.7),
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (_stillOffline) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Still no connection. Please check and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
