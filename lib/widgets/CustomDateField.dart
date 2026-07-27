import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constant/constant.dart';
import '../provider/dateProvider.dart';
import 'clearable_date_picker.dart';

class CustomDateField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(DateTime?)? onDateSelected;
  final IconData? prefixIcon;
  final bool readOnly;
  final void Function(dynamic)? onChanged;
  final Color? borderColor;
  final double borderRadius;

  /// Opt-in for OPTIONAL date fields: uses the picker dialog with a "Clear"
  /// action and shows an "X" suffix while the field has a value. Leave false
  /// for required fields (default keeps the old behavior unchanged).
  final bool clearable;

  CustomDateField({
    Key? key,
    this.controller,
    required this.hintText,
    this.readOnly = true,
    this.validator,
    this.onDateSelected,
    this.prefixIcon,
    this.onChanged,
    this.borderColor,
    this.borderRadius = 5,
    this.clearable = false,
  }) : super(key: key);

  @override
  CustomDateFieldState createState() => CustomDateFieldState();
}

class CustomDateFieldState extends State<CustomDateField> {
  String? _errorMessage;
  DateTime? _selectedDate;

  void _clear(FormFieldState<String> state) {
    setState(() {
      _selectedDate = null;
      widget.controller?.clear();
      _errorMessage = null;
    });
    if (widget.onDateSelected != null) widget.onDateSelected!(null);
    if (widget.onChanged != null) widget.onChanged!(null);
    state.didChange('');
  }

  Future<void> _pickDate(
      BuildContext context, FormFieldState<String> state) async {
    if (widget.clearable) {
      final ClearableDatePickerResult? result = await showClearableDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (result == null) return; // cancelled — keep the current value
      if (result.cleared) {
        _clear(state);
        return;
      }
      setState(() {
        _selectedDate = result.date;
        final dateProvider = Provider.of<DateProvider>(context, listen: false);
        widget.controller?.text =
            dateProvider.formatCurrentDate(_selectedDate!.toString());
        _errorMessage = widget.validator != null
            ? widget.validator!(widget.controller?.text)
            : null;
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(_selectedDate);
      }
      if (widget.onChanged != null) {
        widget.onChanged!(_selectedDate);
      }
      state.didChange(widget.controller?.text);
      return;
    }
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      // lastDate:  DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: blueColor,
            colorScheme: ColorScheme.light(
              primary: blueColor,
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final dateProvider = Provider.of<DateProvider>(context, listen: false);
        widget.controller?.text =
            dateProvider.formatCurrentDate(_selectedDate!.toString());
        _errorMessage = widget.validator != null
            ? widget.validator!(widget.controller?.text)
            : null;
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(_selectedDate);
      }
      if (widget.onChanged != null) {
        widget.onChanged!(_selectedDate);
      }
      // Notify the FormField state of the change
      state.didChange(widget.controller?.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (value) {
        if (widget.validator != null) {
          final error = widget.validator!(value);
          if (error != null) {
            setState(() {
              _errorMessage = error;
            });
          }
          return error;
        } else if ((widget.controller?.text ?? '').isEmpty) {
          setState(() {
            _errorMessage = 'Please select a date';
          });
          return _errorMessage;
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 55,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: widget.borderColor ?? Colors.grey),
              ),
                child: TextFormField(
                  readOnly: widget.readOnly,
                  controller: widget.controller,
                  onTap: () {
                    if (widget.readOnly) {
                      _pickDate(context, state);
                    }
                  },
                  decoration: InputDecoration(
                    // contentPadding: EdgeInsets.all(8.0),
                    // contentPadding: EdgeInsets.symmetric(),
                    suffixIconConstraints: widget.clearable
                        ? BoxConstraints(
                            maxWidth: 56,
                            maxHeight: 20,
                            minHeight: 20,
                            minWidth: 20)
                        : BoxConstraints(
                            maxWidth: 20,
                            maxHeight: 20,
                            minHeight: 20,
                            minWidth: 20),
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(widget.prefixIcon)
                        : null,
                    hintStyle:
                        TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    suffixIcon: widget.clearable
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if ((widget.controller?.text ?? '').isNotEmpty)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  iconSize: 18,
                                  tooltip: 'Clear date',
                                  icon: Icon(Icons.close,
                                      color: Colors.grey),
                                  onPressed: () => _clear(state),
                                ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 20,
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _pickDate(context, state),
                              ),
                            ],
                          )
                        : IconButton(
                            padding: EdgeInsets.symmetric(vertical: 1),
                            iconSize: 20,
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _pickDate(context, state),
                          ),
                  ),
                ),
              ),
            if (state.hasError || _errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text(
                  state.errorText ?? _errorMessage ?? '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
