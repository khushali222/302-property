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
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:three_zero_two_property/constant/constant.dart';

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
//   late TextEditingController _controller;
//   bool _autoValidate = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FormField<String>(
//       validator: (value) {
//         if (_autoValidate) {
//           return widget.validator?.call(value);
//         }
//         return null;
//       },
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
//                   controller: _controller,
//                   onChanged: (value) {
//                     state.didChange(value);
//                     if (widget.validator != null) {
//                       setState(() {
//                         _autoValidate = true;
//                       });
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
//
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
//
//   @override
//   NewCustomTextFieldState createState() => NewCustomTextFieldState();
// }
//
// class NewCustomTextFieldState extends State<NewCustomTextField> {
//   late TextEditingController _controller;
//   bool _autoValidate = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController();
//   }
//
//   void validateField() {
//     setState(() {
//       _autoValidate = true;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FormField<String>(
//       validator: (value) {
//         if (_autoValidate) {
//           return widget.validator?.call(value);
//         }
//         return null;
//       },
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
//                   controller: _controller,
//                   onChanged: (value) {
//                     state.didChange(value);
//                     if (widget.validator != null) {
//                       setState(() {
//                         _autoValidate = true;
//                       });
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

class NewCustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final Function(String)? onChanged2;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final String? label;
  final bool readOnnly;
  final bool? amount_check;
  final String? max_amount;
  final String? error_mess;
  final bool? optional;
  final bool? email;
  final bool? pass;
  final bool? phone;
  final bool? worknum;
  final bool? phonenum;
  final bool? businessnum;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? otherController;
  final TextEditingController? businessController;
  final TextEditingController? telephoneController;
  final TextEditingController? alterController;
  final TextEditingController? emrgencyController;
  final TextEditingController? emailController;
  final bool? samephonenumber;

  NewCustomTextField(
      {Key? key,
      this.onChanged,
      this.controller,
      required this.hintText,
      this.obscureText = false,
      this.keyboardType = TextInputType.emailAddress,
      this.readOnnly = false,
      this.prefixIcon,
      this.suffixIcon,
      this.validator,
      this.onSuffixIconPressed,
      this.label,
      this.onTap,
      this.onChanged2,
      this.amount_check,
      this.max_amount,
      this.error_mess,
      this.optional = false,
      this.email,
      this.pass,
      this.phone,
      this.inputFormatters,
      this.worknum,
      this.phonenum,
      this.businessnum,
      this.otherController, // For work number comparison
      this.businessController,
      this.telephoneController,
      this.alterController,
      this.emrgencyController,
      this.emailController,
      this.samephonenumber = false
      // Initialize onTap
      })
      : super(key: key);

  @override
  NewCustomTextFieldState createState() => NewCustomTextFieldState();
}

class NewCustomTextFieldState extends State<NewCustomTextField> {
  String? _errorMessage;
  TextEditingController _textController =
      TextEditingController(); // Add this line
  late FocusNode _focusNode;
  @override
  void dispose() {
    //  _textController.dispose(); // Dispose the controller when not needed anymore
    super.dispose();
    _focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  if (widget.onChanged2 != null) {
                    widget.onChanged2!(_textController.text);
                  }
                  node.unfocus(); // Dismiss the keyboard
                },
                child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    "Done",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  // void _validatePhoneNumber(String value) {
  //   String formattedPhoneNumber = value.replaceAll(RegExp(r'\D'), '');
  //
  //   // Check if phone number is exactly 10 digits
  //   if (formattedPhoneNumber.length != 10) {
  //     setState(() {
  //       _errorMessage = "Phone number must be 10 digits";
  //     });
  //   } else if (widget.otherController != null  ) {
  //     if(widget.businessController != null ){
  //       if (widget.otherController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'work and business cannot be the same';
  //         });
  //       }
  //      else if (widget.businessController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'Phone and business cannot be the same';
  //         });
  //       }
  //       else if (widget.telephoneController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'Phone and telephone cannot be the same';
  //         });
  //       }
  //       else {
  //         setState(() {
  //           _errorMessage = null; // Clear error message when the number is valid
  //         });
  //       }
  //     }
  //     else{
  //       if (widget.otherController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'Phone number and work number cannot be the same';
  //         });
  //       } else {
  //         setState(() {
  //           _errorMessage = null; // Clear error message when the number is valid
  //         });
  //       }
  //     }
  //     // Compare with the work number
  //
  //   } else {
  //     setState(() {
  //       _errorMessage = null; // Clear error message for valid phone numbers
  //     });
  //   }
  // }
  void _validatePhoneNumber(String value) {
    String formattedPhoneNumber = value.replaceAll(RegExp(r'\D'), '');

    // Check if phone number is exactly 10 digits
    if (formattedPhoneNumber.length != 10) {
      setState(() {
        _errorMessage = "Phone number must be 10 digits";
      });
    } else {
      // Validate uniqueness across all phone number controllers
      if (widget.telephoneController != null &&
          widget.telephoneController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else if (widget.otherController != null &&
          widget.otherController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else if (widget.businessController != null &&
          widget.businessController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else {
        setState(() {
          _errorMessage = null; // Clear error message when the number is valid
        });
      }
    }
  }

  void _validateEmail(String value) {
    // Validate email format using EmailValidator
    if (!EmailValidator.validate(value)) {
      setState(() {
        _errorMessage = "Email is not valid";
      });
    } else {
      // Check if email is not the same as another email (example: other controllers)
      if (widget.alterController != null &&
          widget.alterController?.text == value) {
        setState(() {
          _errorMessage = 'Email cannot be the same';
        });
      } else if (widget.emrgencyController != null &&
          widget.emrgencyController?.text == value) {
        setState(() {
          _errorMessage = 'Email cannot be the same';
        });
      } else if (widget.emailController != null &&
          widget.emailController?.text == value) {
        setState(() {
          _errorMessage = 'Email cannot be the same';
        });
      } else {
        setState(() {
          _errorMessage = null; // Clear error message when email is valid
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldUseKeyboardActions =
        widget.keyboardType == TextInputType.number;
    Widget textfield = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: widget.optional!
              ? (value) {
                  print("work same callling  ${widget.samephonenumber}");
                  if (widget.controller!.text.isEmpty) {
                    return null;
                  } else if (widget.phone != null) {
                    // String formattedPhoneNumber =
                    //     widget.controller!.text.replaceAll(RegExp(r'\D'), '');
                    //
                    // // Removed the empty check
                    // if (formattedPhoneNumber.length != 10) {
                    //   setState(() {
                    //     _errorMessage = "Phone number must be 10 digits";
                    //   });
                    //   return '';
                    // }
                    //   if (widget.samephonenumber != null && widget.samephonenumber ==true ) {
                    //       print("Same Work Number calling");
                    //       setState(() {
                    //         _errorMessage = ' number cannot be the same';
                    //       });
                    //
                    //
                    //   return '';
                    // }else {
                    //   // Clear error message if phone number is valid
                    //   setState(() {
                    //     _errorMessage = null;
                    //   });
                    // }
                    _validatePhoneNumber(widget.controller!.text);
                    return '';
                  } else if (widget.email != null) {
                    // if (!EmailValidator.validate(widget.controller!.text)) {
                    //   setState(() {
                    //     _errorMessage = "Email is not valid";
                    //   });
                    //   return '';
                    // }
                    _validateEmail(widget.controller!.text);

                    // Return an empty string or handle accordingly
                    return '';
                  } else if (widget.amount_check != null &&
                      double.parse(widget.controller!.text) >
                          double.parse(widget.max_amount!))
                    setState(() {
                      _errorMessage = '${widget.error_mess}';
                    });
                  return null;
                }
              : (value) {
                  if (widget.controller!.text.isEmpty) {
                    setState(() {
                      if (widget.label == null)
                        _errorMessage = 'Please ${widget.hintText}';
                      else
                        _errorMessage = 'Please ${widget.label}';
                    });
                    return '';
                  } else if (widget.phone != null) {
                    // Check if it's a phone number
                    String formattedPhoneNumber =
                        widget.controller!.text.replaceAll(RegExp(r'\D'), '');

                    if (formattedPhoneNumber.length != 10) {
                      setState(() {
                        _errorMessage = "Phone number must be 10 digits";
                      });
                      return '';
                    }
                    if (widget.samephonenumber != null &&
                        widget.samephonenumber!) {
                      setState(() {
                        _errorMessage =
                            'Phone number and work number cannot be the same';
                      });
                      return '';
                    } else {
                      // Clear error message if phone number is valid
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  } else if (widget.email != null) {
                    if (!EmailValidator.validate(widget.controller!.text)) {
                      setState(() {
                        _errorMessage = "Email is not valid";
                      });
                      return '';
                    }
                    //   _validateEmail(widget.controller!.text);
                    //
                    //   // Return an empty string or handle accordingly
                    //   return '';
                  } else if (widget.pass != null) {
                    String? validationMessage =
                        ValidatePassword(widget.controller!.text);
                    if (validationMessage != null) {
                      setState(() {
                        _errorMessage = validationMessage;
                      });
                      return '';
                    }
                  } else if (widget.amount_check != null &&
                      double.parse(widget.controller!.text) >
                          double.parse(widget.max_amount!))
                    setState(() {
                      _errorMessage = '${widget.error_mess}';
                    });
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: _errorMessage != null
                            ? Colors.red
                            : Colors.transparent,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(4, 4),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      child: TextFormField(
                        /*    onFieldSubmitted: (value){
                          if(value.isNotEmpty){

                            if(widget.amount_check != null){
                              if(int.parse(value) > int.parse(widget.max_amount!)){
                                setState(() {
                                  _errorMessage = '${widget.error_mess}';
                                });
                              }
                            }
                            else{
                              setState(() {
                                _errorMessage = null;
                              });
                            }

                          }
                          print(value);
                          widget.onChanged2;
                        },*/
                        onFieldSubmitted: widget.onChanged2,
                        onChanged: (value) {
                          //  print("object calin $value");
                          if (value.isNotEmpty) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                          if (widget.onChanged != null)
                            widget.onChanged!(value);
//print("callllll");
                        },
                        inputFormatters: widget.inputFormatters ?? [],
                        focusNode: _focusNode,
                        onTap: () {
                          if (widget.onTap != null) {
                            widget.onTap!();
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                        obscureText: widget.obscureText,
                        readOnly: widget.readOnnly,
                        keyboardType: widget.keyboardType,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            state.validate();
                          }
                          return null;
                        },
                        controller: widget.controller,
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
                ),
                if (state.hasError && _errorMessage != null ||
                    widget.amount_check != null)
                  SizedBox(height: 24),
                // Reserve space for error message
              ],
            );
          },
        ),
        if (_errorMessage != null)
          Positioned(
            top: 60,
            left: 8,
            right: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16.0,
                ),
                SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                    maxLines: (widget.pass ?? false) ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    return shouldUseKeyboardActions
        ? SizedBox(
            height: _errorMessage != null
                ? 95
                : 60, // Increased height for multi-line errors
            width: MediaQuery.of(context).size.width * .98,
            child: KeyboardActions(
              config: _buildConfig(context),
              child: textfield,
            ),
          )
        : textfield;
  }
}
