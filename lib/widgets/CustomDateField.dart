import 'package:flutter/material.dart';

class CustomDateField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(DateTime?)? onDateSelected;
  final IconData? prefixIcon;
  final bool readOnly;

  CustomDateField({
    Key? key,
    this.controller,
    required this.hintText,
    this.readOnly = true,
    this.validator,
    this.onDateSelected,
    this.prefixIcon,
  }) : super(key: key);

  @override
  CustomDateFieldState createState() => CustomDateFieldState();
}

class CustomDateFieldState extends State<CustomDateField> {
  String? _errorMessage;
  DateTime? _selectedDate;

  Future<void> _pickDate(
      BuildContext context, FormFieldState<String> state) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color.fromRGBO(21, 43, 83, 1),
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1),
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
        widget.controller?.text =
            _selectedDate!.toLocal().toString().split(' ')[0];
        _errorMessage = widget.validator != null
            ? widget.validator!(widget.controller?.text)
            : null;
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(_selectedDate);
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
          return widget.validator!(value);
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(4, 4),
                      blurRadius: 3,
                    ),
                  ],
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
                    suffixIconConstraints: BoxConstraints(
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
                    suffixIcon: IconButton(
                      padding: EdgeInsets.symmetric(vertical: 1),
                      iconSize: 20,
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(context, state),
                    ),
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
