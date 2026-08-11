import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

  const NoInternetView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 22),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_downward,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Swipe down to try again',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
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
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
