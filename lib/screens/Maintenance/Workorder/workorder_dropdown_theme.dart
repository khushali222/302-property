import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

/// Shared dropdown styling for work order screens (matches Property / Unit fields).
class WorkorderDropdownTheme {
  WorkorderDropdownTheme._();

  static const Color _borderColor = Color(0xFFCED4DA);
  static const double _borderWidth = 1.5;

  /// Form fields that use a fixed control width (Property, Unit, etc.).
  static ButtonStyleData formButtonStyle() => ButtonStyleData(
        height: 45,
        width: 160,
        padding: const EdgeInsets.only(left: 14, right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          border: Border.all(
            color: _borderColor,
            width: _borderWidth,
          ),
        ),
        elevation: 0,
      );

  /// Full-width dropdowns (category, status, inline rows, etc.).
  static ButtonStyleData fullWidthButtonStyle() => ButtonStyleData(
        height: 45,
        padding: const EdgeInsets.only(left: 14, right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          border: Border.all(
            color: _borderColor,
            width: _borderWidth,
          ),
        ),
        elevation: 0,
      );

  static const IconStyleData iconStyle = IconStyleData(
    icon: Icon(Icons.arrow_drop_down),
    iconSize: 24,
    iconEnabledColor: Color(0xFFb0b6c3),
    iconDisabledColor: Colors.grey,
  );

  static DropdownStyleData panelStyle({
    double maxHeight = 300,
    Offset offset = const Offset(0, -5),
    double? width,
  }) =>
      DropdownStyleData(
        maxHeight: maxHeight,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        offset: offset,
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(6),
          thickness: MaterialStateProperty.all(6),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      );

  static const MenuItemStyleData menuItemStyle = MenuItemStyleData(
    height: 40,
    padding: EdgeInsets.only(left: 14, right: 14),
  );
}
