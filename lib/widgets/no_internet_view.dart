import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:three_zero_two_property/constant/constant.dart';

/// The app's standard offline state, in one place.
///
/// The animation and both lines of copy are exactly what every screen has
/// shown until now, so adopting this widget changes nothing visually.
///
/// Pass [onRetry] to make it refreshable: the content is wrapped in a
/// [RefreshIndicator] over a scrollable, so a swipe down re-runs the screen's
/// own load — the same gesture and spinner the Admin dashboard already uses.
/// A muted hint line is shown in that case, because the gesture is otherwise
/// invisible to a user who is stuck here. Omit [onRetry] and the view stays
/// the plain message it has always been.
class NoInternetView extends StatelessWidget {
  final Future<void> Function()? onRetry;

  /// Sized to sit INSIDE a tab, card or table area rather than take over the
  /// screen. The full-size version centres a 200px animation and assumes it
  /// owns the page; dropped into one tab of a summary screen that reads as
  /// broken, because the rest of the page is fine and still visible around it.
  /// Same message, same Retry, a fraction of the height.
  final bool compact;

  const NoInternetView({super.key, this.onRetry, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) return _compact(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/no_internet.json',
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
        const Text(
          'No Internet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Check your internet connection',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 20),
          // Same navy refresh button the report screens already use for their
          // request-failure state, so the offline state now offers the visible
          // control QA asked for rather than only the swipe gesture.
          ElevatedButton.icon(
            onPressed: () => onRetry!(),
            icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
            label: const Text(
              'Retry',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: navyClr,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'or swipe down',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ],
    );

    if (onRetry == null) {
      return SizedBox(
        width: double.infinity,
        child: Center(child: content),
      );
    }

    return LayoutBuilder(builder: (context, outer) {
      // Placed inside another scrollable, height is unbounded. RefreshIndicator
      // needs its OWN scroll view, and nesting those asserted on an infinite
      // height. Same look, minus the swipe gesture — the Retry button is still
      // there, which is what matters.
      if (!outer.maxHeight.isFinite) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(child: content),
        );
      }
      return RefreshIndicator(
      onRefresh: onRetry!,
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 2.0,
      // The gesture only registers over a scrollable, and the min-height box
      // keeps the message centred on screens taller than the content.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            // maxHeight is INFINITE when this is placed inside another
            // scrollable — dropping it straight into minHeight asserted
            // ("BoxConstraints forces an infinite height") and then repeated
            // every frame until the screen was left. Fall back to no minimum
            // there: the content simply sizes itself instead of stretching.
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 0.0,
            ),
            child: Center(child: content),
          ),
        ),
      ),
      );
    });
  }

  /// The inline variant: an icon instead of the animation, one line of text and
  /// a text-button Retry, so it fits a tab without pushing the layout around.
  Widget _compact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      // Full width so the message sits centred in the area it is given; without
      // it the column shrank to its content and drifted to the left edge.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No internet connection',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => onRetry!(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: navyClr),
            ),
          ],
        ],
      ),
    );
  }
}
