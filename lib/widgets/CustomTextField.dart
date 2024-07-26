// import 'package:flutter/material.dart';

// class NewCustomTextField extends StatefulWidget {
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

//   NewCustomTextField({
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
//   NewCustomTextFieldState createState() => NewCustomTextFieldState();
// }

// class NewCustomTextFieldState extends State<NewCustomTextField> {
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
//                       state.validate();
//                     }
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
import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Custom Text Field Example'),
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: CustomTextFieldForm(),
//         ),
//       ),
//     );
//   }
// }

// class CustomTextFieldForm extends StatefulWidget {
//   @override
//   _CustomTextFieldFormState createState() => _CustomTextFieldFormState();
// }

// class _CustomTextFieldFormState extends State<CustomTextFieldForm> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _textController;

//   @override
//   void initState() {
//     super.initState();
//     // Simulating an API call by setting the initial value
//     _textController = TextEditingController(text: 'yash');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           NewCustomTextField(
//             controller: _textController,
//             hintText: 'Enter some text',
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter some text';
//               }
//               return null;
//             },
//             onChanged: (value) {
//               // Handle changes if needed
//             },
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Validate the form
//               if (_formKey.currentState!.validate()) {
//                 // If the form is valid, display a snackbar.
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Form is valid!')),
//                 );
//               }
//             },
//             child: Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class NewCustomTextField extends StatefulWidget {
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

  NewCustomTextField({
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
  NewCustomTextFieldState createState() => NewCustomTextFieldState();
}

class NewCustomTextFieldState extends State<NewCustomTextField> {
  late TextEditingController _controller;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (value) {
        if (_autoValidate) {
          return widget.validator?.call(value);
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
                  controller: _controller,
                  onChanged: (value) {
                    state.didChange(value);
                    if (widget.validator != null) {
                      setState(() {
                        _autoValidate = true;
                      });
                      state.validate();
                    }
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                  onTap: widget.onTap,
                  obscureText: widget.obscureText,
                  readOnly: widget.readOnly,
                  keyboardType: widget.keyboardType,
                  decoration: InputDecoration(
                    suffixIcon: widget.suffixIcon,
                    hintStyle:
                        TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                    border: InputBorder.none,
                    hintText: widget.hintText,
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text(
                  state.errorText!,
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
