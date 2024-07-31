import 'package:flutter/material.dart';

// class NewCustomEmailField extends StatefulWidget {
//   final String hintText;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final bool obscureText;
//   final Function(String)? onChanged;
//   final Widget? suffixIcon;
//   final IconData? prefixIcon;
//   final void Function()? onSuffixIconPressed;
//   final void Function()? onTap;
//   final bool readOnly;

//   NewCustomEmailField({
//     Key? key,
//     this.onChanged,
//     this.controller,
//     required this.hintText,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.emailAddress,
//     this.readOnly = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.onSuffixIconPressed,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   NewCustomEmailFieldState createState() => NewCustomEmailFieldState();
// }

// class NewCustomEmailFieldState extends State<NewCustomEmailField> {
//   String? _errorMessage;
//   String? _emailValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your email';
//     }
//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     if (!emailRegex.hasMatch(value)) {
//       return 'Please enter a valid email';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FormField<String>(
//       validator: widget.validator,
//       builder: (FormFieldState<String> state) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Material(
//               elevation: 2,
//               borderRadius: BorderRadius.circular(8.0),
//               child: Container(
//                 height: 50,
//                 padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       offset: Offset(4, 4),
//                       blurRadius: 3,
//                     ),
//                   ],
//                 ),
//                 child: TextFormField(
//                   onChanged: (value) {
//                     state.didChange(value);
//                     if (widget.validator != null) {
//                       _errorMessage = widget.validator!(value);
//                     } else {
//                       _errorMessage = _emailValidator(value);
//                     }
//                     state.validate();
//                     setState(() {});
//                     if (widget.onChanged != null) {
//                       widget.onChanged!(value);
//                     }
//                   },
//                   onTap: widget.onTap,
//                   obscureText: widget.obscureText,
//                   readOnly: widget.readOnly,
//                   keyboardType: widget.keyboardType,
//                   controller: widget.controller,
//                   decoration: InputDecoration(
//                     suffixIcon: widget.suffixIcon,
//                     hintStyle:
//                         TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
//                     border: InputBorder.none,
//                     hintText: widget.hintText,
//                   ),
//                 ),
//               ),
//             ),
//             if (state.hasError)
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0, top: 8.0),
//                 child: Text(
//                   state.errorText!,
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 12.0,
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }



class NewCustomEmailField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final bool readOnly;

  NewCustomEmailField({
    Key? key,
    this.onChanged,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSuffixIconPressed,
    this.onTap,
  }) : super(key: key);

  @override
  NewCustomEmailFieldState createState() => NewCustomEmailFieldState();
}

class NewCustomEmailFieldState extends State<NewCustomEmailField> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Validate initial value if it exists
    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
      _errorMessage = _validateEmail(widget.controller!.text);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return _validateEmail(value);
      },
      initialValue: widget.controller?.text,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
                  onChanged: (value) {
                    state.didChange(value);
                    if (widget.validator != null) {
                      _errorMessage = widget.validator!(value);
                    } else {
                      _errorMessage = _validateEmail(value);
                    }
                    state.validate();
                    setState(() {});
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                  onTap: widget.onTap,
                  obscureText: widget.obscureText,
                  readOnly: widget.readOnly,
                  keyboardType: widget.keyboardType,
                  controller: widget.controller,
                  decoration: InputDecoration(
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(widget.prefixIcon)
                        : null,
                    suffixIcon: widget.suffixIcon,
                    hintStyle:
                        TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                    border: InputBorder.none,
                    hintText: widget.hintText,
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
