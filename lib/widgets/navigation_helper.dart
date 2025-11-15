import 'package:flutter/material.dart';

class NavigationHelper {
  /// Checks if the current route matches the target route
  static bool isCurrentRoute(BuildContext context, String targetRoute) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return currentRoute == targetRoute;
  }

  /// Gets the current route name
  static String? getCurrentRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  /// Checks if the current widget type matches the target widget type
  static bool isCurrentWidget(BuildContext context, Widget targetWidget) {
    final currentWidget = ModalRoute.of(context)?.settings.arguments;
    return currentWidget.runtimeType == targetWidget.runtimeType;
  }

  /// Simple navigation that just closes drawer if on same screen
  static Future<void> navigateWithValidation(
    BuildContext context,
    Widget targetWidget,
    String routeName,
  ) async {
    // Check if we're already on the same screen
    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null) {
      final currentWidget = currentRoute.settings.arguments;
      if (currentWidget != null &&
          currentWidget.runtimeType == targetWidget.runtimeType) {
        // Close drawer if open and return
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
        }
        return;
      }
    }

    // Navigate to the new screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => targetWidget,
        settings: RouteSettings(name: routeName, arguments: targetWidget),
      ),
    );
  }

  /// Navigate with validation for routes that use WidgetBuilder
  static Future<void> navigateWithValidationBuilder(
    BuildContext context,
    WidgetBuilder builder,
    String routeName,
  ) async {
    // Check if we're already on the same screen by route name
    if (isCurrentRoute(context, routeName)) {
      // Close drawer if open and return
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.of(context).pop();
      }
      return;
    }

    // Navigate to the new screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: builder,
        settings: RouteSettings(name: routeName),
      ),
    );
  }
}
