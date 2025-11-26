import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constant/constant.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

import '../../../../Model/vendor.dart';
import '../../../repository/vendor_repository.dart';
import '../../../../widgets/titleBar.dart';
import '../../../widgets/custom_drawer.dart';

// class Add_vendor extends StatefulWidget {
//   const Add_vendor({super.key});
//
//   @override
//   State<Add_vendor> createState() => _Add_vendorState();
// }
//
// class _Add_vendorState extends State<Add_vendor> {
//   final TextEditingController firstName = TextEditingController();
//
//   final TextEditingController lastName = TextEditingController();
//
//   final TextEditingController phoneNumber = TextEditingController();
//   bool obsecure = true;
//   final TextEditingController workNumber = TextEditingController();
//
//   final TextEditingController email = TextEditingController();
//
//   final TextEditingController alterEmail = TextEditingController();
//   GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//   final TextEditingController passWord = TextEditingController();
//   bool isLoading = false;
//   bool formValid = false;
//   final VendorRepository vendorRepository =
//       VendorRepository(baseUrl: 'https://yourapiurl.com');
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget_302_Staff.App_Bar(context: context),
//       backgroundColor: Colors.white,
//       drawer: CustomDrawerStaff(
//         currentpage: "Vendor",
//         dropdown: true,
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth > 500) {
//             return Form(
//               key: _formkey,
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 25,
//                       ),
//                       titleBar(
//                         width: MediaQuery.of(context).size.width * .98,
//                         title: 'Add Vendor',
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Container(
//                           padding: const EdgeInsets.all(16.0),
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10.0),
//                               border: Border.all(
//                                 color: Color.fromRGBO(21, 43, 103, 1),
//                               )),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Vendor Name *',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey)),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               CustomTextField(
//                                 keyboardType: TextInputType.text,
//                                 hintText: 'Enter vendor name',
//                                 controller: firstName,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'please enter the vendor name';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               /* SizedBox(
//                           height: 10,
//                         ),
//                         Text('Last Name *',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         CustomTextField(
//                           keyboardType: TextInputType.text,
//                           hintText: 'Enter last name',
//                           controller: lastName,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'please enter the last name';
//                             }
//                             return null;
//                           },
//                         ),*/
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Text('Phone Number *',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey)),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               CustomTextField(
//                                 // keyboardType: TextInputType.numberWithOptions(
//                                 //     signed: true, decimal: true),
//                                 keyboardType: TextInputType.number,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly,
//                                   LengthLimitingTextInputFormatter(10),
//                                   PhoneNumberFormatter(),
//                                 ],
//                                 phone: true,
//                                 hintText: 'Enter phone number',
//                                 controller: phoneNumber,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'please enter the phone number';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               /*  SizedBox(
//                           height: 10,
//                         ),
//                         Text('Work Number',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         CustomTextField(
//                           keyboardType: TextInputType.number,
//                           hintText: 'Enter work number',
//                           controller: workNumber,
//                         ),*/
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Text('Email *',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey)),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               CustomTextField(
//                                 keyboardType: TextInputType.emailAddress,
//                                 hintText: 'Enter Email',
//                                 controller: email,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'please enter email';
//                                   }
//                                   return null;
//                                 },
//                                 email: true,
//                               ),
//                               /* SizedBox(
//                           height: 10,
//                         ),
//                         Text('Alternative Email',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         CustomTextField(
//                           keyboardType: TextInputType.emailAddress,
//                           hintText: 'Enter alternative email',
//                           controller: alterEmail,
//                         ),*/
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Text('Password *',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey)),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: CustomTextField(
//                                       keyboardType: TextInputType.text,
//                                       obscureText: obsecure,
//                                       hintText: 'Enter password',
//                                       controller: passWord,
//                                       validator: (value) {
//                                         if (value == null) {
//                                           return 'please enter password';
//                                         }
//                                         return null;
//                                       },
//                                       pass: true,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                       width:
//                                           10), // Add some space between the widgets
//                                   InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         obsecure = !obsecure;
//                                       });
//                                     },
//                                     child: Container(
//                                       width: 38,
//                                       height: 50,
//                                       child: Center(
//                                         child: FaIcon(
//                                           !obsecure
//                                               ? FontAwesomeIcons.eyeSlash
//                                               : FontAwesomeIcons.eye,
//                                           size: 20,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black26,
//                                             offset: Offset(1.2, 1.2),
//                                             blurRadius: 3.0,
//                                             spreadRadius: 1.0,
//                                           ),
//                                         ],
//                                         border: Border.all(
//                                             width: 0, color: Colors.white),
//                                         borderRadius:
//                                             BorderRadius.circular(6.0),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 16,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(0.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       height: 50,
//                                       width: 150,
//                                       decoration: BoxDecoration(
//                                         borderRadius:
//                                             BorderRadius.circular(8.0),
//                                       ),
//                                       child: ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor:
//                                               blueColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8.0),
//                                           ),
//                                         ),
//                                         onPressed: () async {
//                                           setState(() {
//                                             formValid = true;
//                                           });
//                                           if (_formkey.currentState!
//                                               .validate()) {
//                                             setState(() {
//                                               formValid = false;
//                                             });
//
//                                             await addTenant();
//                                           }
//                                         },
//                                         child: isLoading
//                                             ? Center(
//                                                 child: SpinKitFadingCircle(
//                                                   color: Colors.white,
//                                                   size: 55.0,
//                                                 ),
//                                               )
//                                             : Text(
//                                                 'Add Vendor',
//                                                 style: TextStyle(
//                                                     color: Color(0xFFf7f8f9)),
//                                               ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 8,
//                                     ),
//                                     Container(
//                                         height: 50,
//                                         width: 120,
//                                         decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(8.0)),
//                                         child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                                 backgroundColor:
//                                                     Color(0xFFffffff),
//                                                 shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8.0))),
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             child: Text(
//                                               'Cancel',
//                                               style: TextStyle(
//                                                   color: Color(0xFF748097)),
//                                             )))
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           } else {
//             return Form(
//               key: _formkey,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: 25,
//                     ),
//                     titleBar(
//                       width: MediaQuery.of(context).size.width * .95,
//                       title: 'Add Vendor',
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Container(
//                         padding: const EdgeInsets.all(16.0),
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10.0),
//                             border: Border.all(
//                               color: Color.fromRGBO(21, 43, 103, 1),
//                             )),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Vendor Name *',
//                                 style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey)),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             CustomTextField(
//                               keyboardType: TextInputType.text,
//                               hintText: 'Enter vendor name',
//                               controller: firstName,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'please enter the vendor name';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             /* SizedBox(
//                         height: 10,
//                       ),
//                       Text('Last Name *',
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey)),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       CustomTextField(
//                         keyboardType: TextInputType.text,
//                         hintText: 'Enter last name',
//                         controller: lastName,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'please enter the last name';
//                           }
//                           return null;
//                         },
//                       ),*/
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Text('Phone Number *',
//                                 style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey)),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             CustomTextField(
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(10),
//                                 PhoneNumberFormatter(),
//                               ],
//                               // keyboardType: TextInputType.numberWithOptions(
//                               //     signed: true, decimal: true),
//                               hintText: 'Enter phone number',
//                               controller: phoneNumber,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'please enter the phone number';
//                                 }
//                                 return null;
//                               },
//                               phone: true,
//                             ),
//                             /*  SizedBox(
//                         height: 10,
//                       ),
//                       Text('Work Number',
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey)),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       CustomTextField(
//                         keyboardType: TextInputType.number,
//                         hintText: 'Enter work number',
//                         controller: workNumber,
//                       ),*/
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Text('Email *',
//                                 style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey)),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             CustomTextField(
//                               keyboardType: TextInputType.emailAddress,
//                               hintText: 'Enter Email',
//                               controller: email,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'please enter email';
//                                 }
//                                 return null;
//                               },
//                               email: true,
//                             ),
//                             /* SizedBox(
//                         height: 10,
//                       ),
//                       Text('Alternative Email',
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey)),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       CustomTextField(
//                         keyboardType: TextInputType.emailAddress,
//                         hintText: 'Enter alternative email',
//                         controller: alterEmail,
//                       ),*/
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Text('Password *',
//                                 style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey)),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: CustomTextField(
//                                     keyboardType: TextInputType.text,
//                                     obscureText: obsecure,
//                                     hintText: 'Enter password',
//                                     controller: passWord,
//                                     validator: (value) {
//                                       if (value == null) {
//                                         return 'please enter password';
//                                       }
//                                       return null;
//                                     },
//                                     pass: true,
//                                   ),
//                                 ),
//                                 SizedBox(
//                                     width:
//                                         10), // Add some space between the widgets
//                                 InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       obsecure = !obsecure;
//                                     });
//                                   },
//                                   child: Container(
//                                     width: 38,
//                                     height: 50,
//                                     child: Center(
//                                       child: FaIcon(
//                                         !obsecure
//                                             ? FontAwesomeIcons.eyeSlash
//                                             : FontAwesomeIcons.eye,
//                                         size: 20,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black26,
//                                           offset: Offset(1.2, 1.2),
//                                           blurRadius: 3.0,
//                                           spreadRadius: 1.0,
//                                         ),
//                                       ],
//                                       border: Border.all(
//                                           width: 0, color: Colors.white),
//                                       borderRadius: BorderRadius.circular(6.0),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 16,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(0.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     height: 50,
//                                     width: 120,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                     ),
//                                     child: ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                             blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8.0),
//                                         ),
//                                       ),
//                                       onPressed: () async {
//                                         setState(() {
//                                           formValid = true;
//                                         });
//                                         if (_formkey.currentState!.validate()) {
//                                           setState(() {
//                                             formValid = false;
//                                           });
//
//                                           await addTenant();
//                                         }
//                                       },
//                                       child: isLoading
//                                           ? Center(
//                                               child: SpinKitFadingCircle(
//                                                 color: Colors.white,
//                                                 size: 55.0,
//                                               ),
//                                             )
//                                           : Text(
//                                               'Add Vendor',
//                                               style: TextStyle(
//                                                   color: Color(0xFFf7f8f9),
//                                               fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 8,
//                                   ),
//                                   Container(
//                                       height: 50,
//                                       width: 120,
//                                       decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(8.0)),
//                                       child: ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                               backgroundColor:
//                                                   Color(0xFFffffff),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           8.0))),
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                           },
//                                           child: Text(
//                                             'Cancel',
//                                             style: TextStyle(
//                                                 color: Color(0xFF748097)),
//                                           )))
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Future<void> addTenant() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String adminId = prefs.getString("adminId")!;
//
//     final vendor = Vendor(
//       adminId: adminId,
//       vendorName: firstName.text,
//       vendorPhoneNumber: phoneNumber.text,
//       vendorEmail: email.text,
//       vendorPassword: passWord.text,
//     );
//
//     final success = await vendorRepository.addVendor(vendor);
//     if (success) {
//       //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vendor added successfully')));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to add vendor')));
//     }
//     setState(() {
//       isLoading = false;
//     });
//
//     if (success) {
//       print('Form is valid');
//       Fluttertoast.showToast(msg: "Vendor added successfully");
//       Navigator.of(context).pop(true);
//     } else {
//       print('Form is invalid');
//     }
//   }
// }
//
// class CustomTextField extends StatefulWidget {
//   final String hintText;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final bool obscureText;
//   final Function(String)? onChanged;
//   final Function(String)? onChanged2;
//   final Widget? suffixIcon;
//   final IconData? prefixIcon;
//   final void Function()? onSuffixIconPressed;
//   final void Function()? onTap;
//   final bool readOnnly;
//   final bool? email;
//   final bool? phone;
//   final bool? pass;
//   final List<TextInputFormatter>? inputFormatters;
//
//   CustomTextField({
//     Key? key,
//     this.controller,
//     required this.hintText,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.emailAddress,
//     this.readOnnly = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.onSuffixIconPressed,
//     this.onTap,
//     this.onChanged,
//     this.onChanged2,
//     this.email,
//     this.pass,
//     this.phone,
//     this.inputFormatters
//     // Initialize onTap
//   }) : super(key: key);
//
//   @override
//   CustomTextFieldState createState() => CustomTextFieldState();
// }
//
// class CustomTextFieldState extends State<CustomTextField> {
//   String? _errorMessage;
//   TextEditingController _textController =
//       TextEditingController(); // Add this line
//
//   late FocusNode _focusNode;
//   @override
//   void dispose() {
//     _textController.dispose(); // Dispose the controller when not needed anymore
//     super.dispose();
//     _focusNode.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _textController = widget.controller ?? TextEditingController();
//     _focusNode = FocusNode();
//   }
//
//   KeyboardActionsConfig _buildConfig(BuildContext context) {
//     return KeyboardActionsConfig(
//       actions: [
//         KeyboardActionsItem(
//           focusNode: _focusNode,
//           toolbarButtons: [
//             (node) {
//               return GestureDetector(
//                 onTap: () {
//                   if (widget.onChanged2 != null) {
//                     widget.onChanged2!(_textController.text);
//                   }
//                   node.unfocus(); // Dismiss the keyboard
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.all(14.0),
//                   child: Text(
//                     "Done",
//                     style: TextStyle(
//                         color: Colors.blue, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               );
//             },
//           ],
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final shouldUseKeyboardActions =
//         widget.keyboardType == TextInputType.number;
//     Widget textfield = Stack(
//       clipBehavior: Clip.none,
//       children: <Widget>[
//         FormField<String>(
//           validator: (value) {
//             if (widget.controller!.text.isEmpty) {
//               setState(() {
//                 _errorMessage = 'Please ${widget.hintText}';
//               });
//               return '';
//             } else if (widget.phone != null) {
//               String formattedPhoneNumber = widget.controller!.text
//                   .replaceAll(RegExp(r'\D'), '');
//
//               // Removed the empty check
//               if (formattedPhoneNumber.length != 10) {
//                 setState(() {
//                   _errorMessage = "Phone number must be 10 digits";
//                 });
//                 return '';
//               }
//             }else if (widget.pass != null) {
//               String? validationMessage = ValidatePassword(widget.controller!.text);
//               if (validationMessage != null) {
//                 setState(() {
//                   _errorMessage =
//                       validationMessage;
//                 });
//                 return '';
//               }
//             }
//             else if (widget.email != null) {
//               if (!EmailValidator.validate(widget.controller!.text)) {
//                 setState(() {
//                   _errorMessage = "Email is not valid";
//                 });
//                 return '';
//               }
//             }
//             setState(() {
//               _errorMessage = null;
//             });
//             return null;
//           },
//           builder: (FormFieldState<String> state) {
//             return Column(
//               children: <Widget>[
//                 Container(
//                   height: 50,
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8.0),
//                     //border: Border.all(color: blueColor),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         offset: Offset(4, 4),
//                         blurRadius: 3,
//                       ),
//                     ],
//                   ),
//                   child: TextFormField(
//                     onTap: widget.onTap,
//                     obscureText: widget.obscureText,
//                     readOnly: widget.readOnnly,
//                     keyboardType: widget.keyboardType,
//                     focusNode: _focusNode,
//                     inputFormatters:widget.inputFormatters ?? [],
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         state.validate();
//                       }
//                       return null;
//                     },
//                     controller: widget.controller,
//                     decoration: InputDecoration(
//                       suffixIcon: widget.suffixIcon,
//                       hintStyle:
//                           TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
//                       border: InputBorder.none,
//                       hintText: widget.hintText,
//                     ),
//                   ),
//                 ),
//                 if (state.hasError)
//                   SizedBox(height: 24), // Reserve space for error message
//               ],
//             );
//           },
//         ),
//         if (_errorMessage != null)
//           Positioned(
//             top: 60,
//             left: 8,
//             child: Text(
//               _errorMessage!,
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 12.0,
//               ),
//             ),
//           ),
//       ],
//     );
//     return shouldUseKeyboardActions
//         ? SizedBox(
//             height: 60,
//             width: MediaQuery.of(context).size.width * .98,
//             child: KeyboardActions(
//               config: _buildConfig(context),
//               child: textfield,
//             ),
//           )
//         : textfield;
//   }
// }

class Add_vendor extends StatefulWidget {
  const Add_vendor({super.key});

  @override
  State<Add_vendor> createState() => _Add_vendorState();
}

class _Add_vendorState extends State<Add_vendor> {
  final TextEditingController firstName = TextEditingController();

  final TextEditingController lastName = TextEditingController();

  final TextEditingController phoneNumber = TextEditingController();
  bool obsecure = true;
  bool conobsecure = true;
  final TextEditingController workNumber = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController alterEmail = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController passWord = TextEditingController();
  final TextEditingController conpassWord = TextEditingController();
  bool isLoading = false;
  bool formValid = false;
  final VendorRepository vendorRepository =
      VendorRepository(baseUrl: 'https://yourapiurl.com');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Vendor",
        dropdown: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      titleBar(
                        width: MediaQuery.of(context).size.width * .98,
                        title: 'Add Vendor',
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: const Color.fromRGBO(21, 43, 103, 1),
                              )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vendor Name *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                keyboardType: TextInputType.text,
                                hintText: 'Enter vendor name',
                                controller: firstName,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'please enter the vendor name';
                                  }
                                  return null;
                                },
                              ),
                              /* SizedBox(
                          height: 10,
                        ),
                        Text('Last Name *',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        SizedBox(
                          height: 10,
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.text,
                          hintText: 'Enter last name',
                          controller: lastName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter the last name';
                            }
                            return null;
                          },
                        ),*/
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Phone Number *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                keyboardType: TextInputType.number,
                                // keyboardType: TextInputType.numberWithOptions(
                                //     signed: true, decimal: true),
                                hintText: 'Enter phone number',
                                controller: phoneNumber,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                  PhoneNumberFormatter(),
                                ],
                                phone: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'please enter the phone number';
                                  }
                                  return null;
                                },
                              ),
                              /*  SizedBox(
                          height: 10,
                        ),
                        Text('Work Number',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        SizedBox(
                          height: 10,
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.number,
                          hintText: 'Enter work number',
                          controller: workNumber,
                        ),*/
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Email *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'Enter Email',
                                controller: email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'please enter email';
                                  }
                                  return null;
                                },
                                email: true,
                              ),
                              /* SizedBox(
                          height: 10,
                        ),
                        Text('Alternative Email',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        SizedBox(
                          height: 10,
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'Enter alternative email',
                          controller: alterEmail,
                        ),*/
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Password *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      keyboardType: TextInputType.text,
                                      obscureText: obsecure,
                                      hintText: 'Enter password',
                                      controller: passWord,
                                      validator: (value) {
                                        if (value == null) {
                                          return 'please enter password';
                                        }
                                        return null;
                                      },
                                      pass: true,
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Add some space between the widgets
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        obsecure = !obsecure;
                                      });
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 50,
                                      child: Center(
                                        child: FaIcon(
                                          !obsecure
                                              ? FontAwesomeIcons.eyeSlash
                                              : FontAwesomeIcons.eye,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(1.2, 1.2),
                                            blurRadius: 3.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              //confirm password
                              const Text('Confirm Password *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      keyboardType: TextInputType.text,
                                      obscureText: conobsecure,
                                      hintText: 'Enter confirm password',
                                      controller: conpassWord,
                                      validator: (value) {
                                        if (value == null) {
                                          return 'please enter confirm password';
                                        }
                                        return null;
                                      },
                                      pass: true,
                                      passwordController: passWord,
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Add some space between the widgets
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        conobsecure = !conobsecure;
                                      });
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 50,
                                      child: Center(
                                        child: FaIcon(
                                          !conobsecure
                                              ? FontAwesomeIcons.eyeSlash
                                              : FontAwesomeIcons.eye,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(1.2, 1.2),
                                            blurRadius: 3.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: blueColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            formValid = true;
                                          });
                                          if (_formkey.currentState!
                                              .validate()) {
                                            setState(() {
                                              formValid = false;
                                            });

                                            await addTenant();
                                          }
                                        },
                                        child: isLoading
                                            ? const Center(
                                                child: SpinKitFadingCircle(
                                                  color: Colors.white,
                                                  size: 55.0,
                                                ),
                                              )
                                            : const Text(
                                                'Add Vendor',
                                                style: TextStyle(
                                                    color: Color(0xFFf7f8f9)),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                        height: 50,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFffffff),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0))),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Color(0xFF748097)),
                                            )))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    // titleBar(
                    //   width: MediaQuery.of(context).size.width * .95,
                    //   title: 'Add Vendor',
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 50.0,
                          padding: EdgeInsets.only(top: 9, left: 10),
                          width: MediaQuery.of(context).size.width * .99,
                          margin: const EdgeInsets.only(bottom: 6.0),
                          //Same as `blurRadius` i guess
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: blueColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Text(
                            "Add Vendor",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 18
                                        : 20),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color.fromRGBO(21, 43, 103, 1),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vendor Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter vendor name',
                              controller: firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the vendor name';
                                }
                                return null;
                              },
                            ),
                            /* SizedBox(
                        height: 10,
                      ),
                      Text('Last Name *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        hintText: 'Enter last name',
                        controller: lastName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter the last name';
                          }
                          return null;
                        },
                      ),*/
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Phone Number *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              // keyboardType: TextInputType.numberWithOptions(
                              //     signed: true, decimal: true),
                              keyboardType: TextInputType.number,
                              hintText: 'Enter phone number',
                              controller: phoneNumber,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                PhoneNumberFormatter(),
                              ],
                              phone: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the phone number';
                                }
                                return null;
                              },
                            ),
                            /*  SizedBox(
                        height: 10,
                      ),
                      Text('Work Number',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.number,
                        hintText: 'Enter work number',
                        controller: workNumber,
                      ),*/
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Email *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter Email',
                              controller: email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter email';
                                }
                                return null;
                              },
                              email: true,
                            ),
                            /* SizedBox(
                        height: 10,
                      ),
                      Text('Alternative Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter alternative email',
                        controller: alterEmail,
                      ),*/
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Password *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.text,
                                    obscureText: obsecure,
                                    hintText: 'Enter password',
                                    controller: passWord,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'please enter password';
                                      }
                                      return null;
                                    },
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          obsecure = !obsecure;
                                        });
                                      },
                                      child: Icon(
                                        !obsecure
                                            ? CupertinoIcons.eye_slash_fill
                                            : CupertinoIcons.eye_fill,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    pass: true,
                                  ),
                                ),
                                // const SizedBox(
                                //     width:
                                //         10), // Add some space between the widgets
                                // InkWell(
                                //   onTap: () {
                                //     setState(() {
                                //       obsecure = !obsecure;
                                //     });
                                //   },
                                //   child: Container(
                                //     width: 38,
                                //     height: 50,
                                //     child: Center(
                                //       child: FaIcon(
                                //         !obsecure
                                //             ? FontAwesomeIcons.eyeSlash
                                //             : FontAwesomeIcons.eye,
                                //         size: 20,
                                //         color: Colors.black,
                                //       ),
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       boxShadow: [
                                //         const BoxShadow(
                                //           color: Colors.black26,
                                //           offset: Offset(1.2, 1.2),
                                //           blurRadius: 3.0,
                                //           spreadRadius: 1.0,
                                //         ),
                                //       ],
                                //       border: Border.all(
                                //           width: 0, color: Colors.white),
                                //       borderRadius: BorderRadius.circular(6.0),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //confirm password
                            const Text('Confirm Password *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.text,
                                    obscureText: conobsecure,
                                    hintText: 'Enter confirm password',
                                    controller: conpassWord,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'please enter confirm password';
                                      }
                                      return null;
                                    },
                                    pass: true,
                                    passwordController: passWord,
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          conobsecure = !conobsecure;
                                        });
                                      },
                                      child: Icon(
                                        !conobsecure
                                            ? CupertinoIcons.eye_slash_fill
                                            : CupertinoIcons.eye_fill,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                // const SizedBox(
                                //     width:
                                //         10), // Add some space between the widgets
                                // InkWell(
                                //   onTap: () {
                                //     setState(() {
                                //       conobsecure = !conobsecure;
                                //     });
                                //   },
                                //   child: Container(
                                //     width: 38,
                                //     height: 50,
                                //     child: Center(
                                //       child: FaIcon(
                                //         !conobsecure
                                //             ? FontAwesomeIcons.eyeSlash
                                //             : FontAwesomeIcons.eye,
                                //         size: 20,
                                //         color: Colors.black,
                                //       ),
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       boxShadow: [
                                //         const BoxShadow(
                                //           color: Colors.black26,
                                //           offset: Offset(1.2, 1.2),
                                //           blurRadius: 3.0,
                                //           spreadRadius: 1.0,
                                //         ),
                                //       ],
                                //       border: Border.all(
                                //           width: 0, color: Colors.white),
                                //       borderRadius: BorderRadius.circular(6.0),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(
                              height: 35,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          formValid = true;
                                        });
                                        if (_formkey.currentState!.validate()) {
                                          setState(() {
                                            formValid = false;
                                          });

                                          await addTenant();
                                        }
                                      },
                                      child: isLoading
                                          ? const Center(
                                              child: SpinKitFadingCircle(
                                                color: Colors.white,
                                                size: 55.0,
                                              ),
                                            )
                                          : const Text(
                                              'Add Vendor',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFf7f8f9)),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Container(
                                      height: 50,
                                      width: 120,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFffffff),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0))),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Color(0xFF748097)),
                                          )))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> addTenant() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString("adminId")!;

    final vendor = Vendor(
      adminId: adminId,
      vendorName: firstName.text.trim(),
      vendorPhoneNumber: phoneNumber.text.trim(),
      vendorEmail: email.text.trim(),
      vendorPassword: passWord.text.trim(),
    );

    final success = await vendorRepository.addVendor(vendor);
    if (success) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vendor added successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to add vendor')));
    }
    setState(() {
      isLoading = false;
    });

    if (success) {
      print('Form is valid');
      Fluttertoast.showToast(msg: "Vendor added successfully");
      Navigator.of(context).pop(true);
    } else {
      print('Form is invalid');
    }
  }
}

class CustomTextField extends StatefulWidget {
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
  final bool readOnnly;
  bool? optional;
  final bool? pass;
  final bool? email;
  final bool? phone;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController?
      passwordController; // For confirm password field to compare with

  CustomTextField({
    Key? key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
    this.readOnnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSuffixIconPressed,
    this.onTap,
    this.onChanged,
    this.optional,
    this.onChanged2,
    this.pass,
    this.email, // Initialize onTap
    this.phone,
    this.inputFormatters,
    this.passwordController, // Used when this is a confirm password field
  }) : super(key: key);

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  TextEditingController _textController =
      TextEditingController(); // Add this line

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    // Listen to changes for real-time validation
    if (widget.passwordController != null && widget.controller != null) {
      widget.passwordController!.addListener(_validateConfirmPassword);
      widget.controller!.addListener(_validateConfirmPassword);
    }
  }

  void _validateConfirmPassword() {
    if (widget.passwordController != null && widget.controller != null) {
      setState(() {
        // Trigger validation when either field changes
      });
    }
  }

  @override
  void dispose() {
    if (widget.passwordController != null) {
      widget.passwordController!.removeListener(_validateConfirmPassword);
    }
    if (widget.controller != null) {
      widget.controller!.removeListener(_validateConfirmPassword);
    }
    _textController.dispose(); // Dispose the controller when not needed anymore
    _focusNode.dispose();
    super.dispose();
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
                child: const Padding(
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

  @override
  Widget build(BuildContext context) {
    final shouldUseKeyboardActions =
        widget.keyboardType == TextInputType.number;
    Widget textfield = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: widget.optional != null
              ? null
              : (value) {
                  if (widget.controller!.text.trim().isEmpty) {
                    setState(() {
                      _errorMessage = 'Please ${widget.hintText}';
                    });
                    return '';
                  } else if (widget.phone != null) {
                    String formattedPhoneNumber = widget.controller!.text
                        .trim()
                        .replaceAll(RegExp(r'\D'), '');

                    // Removed the empty check
                    if (formattedPhoneNumber.length != 10) {
                      setState(() {
                        _errorMessage = "Phone number must be 10 digits";
                      });
                      return '';
                    }
                  } else if (widget.email != null) {
                    if (!EmailValidator.validate(
                        widget.controller!.text.trim())) {
                      setState(() {
                        _errorMessage = "Email is not valid";
                      });
                      return '';
                    }
                  } else if (widget.pass != null) {
                    // If passwordController is provided, this is a confirm password field
                    // Skip password strength validation and only check password match
                    if (widget.passwordController != null &&
                        widget.controller != null) {
                      if (widget.controller!.text.trim() !=
                          widget.passwordController!.text.trim()) {
                        setState(() {
                          _errorMessage = "Passwords do not match";
                        });
                        return '';
                      }
                    } else {
                      // Regular password field - validate password strength
                      String? validationMessage =
                          ValidatePassword(widget.controller!.text.trim());
                      if (validationMessage != null) {
                        setState(() {
                          _errorMessage = validationMessage;
                        });
                        return '';
                      }
                    }
                  }

                  setState(() {
                    _errorMessage = null;
                  });

                  return null;
                },
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                Container(
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    //border: Border.all(color: blueColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(4, 4),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    onTap: widget.onTap,
                    obscureText: widget.obscureText,
                    readOnly: widget.readOnnly,
                    keyboardType: widget.keyboardType,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                      // Trigger validation on change for real-time feedback
                      if (widget.passwordController != null ||
                          widget.pass != null) {
                        state.didChange(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        state.validate();
                      }
                      return null;
                    },
                    controller: widget.controller,
                    inputFormatters: widget.inputFormatters ?? [],
                    decoration: InputDecoration(
                      suffixIcon: widget.suffixIcon,
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFFb0b6c3)),
                      border: InputBorder.none,
                      hintText: widget.hintText,
                    ),
                  ),
                ),
                if (state.hasError)
                  const SizedBox(height: 24), // Reserve space for error message
              ],
            );
          },
        ),
        if (_errorMessage != null)
          Positioned(
            top: 60,
            left: 8,
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
    return shouldUseKeyboardActions
        ? SizedBox(
            // height: 60,
            // width: MediaQuery.of(context).size.width * .98,
            height: _errorMessage != null ? 75 : 60,
            width: MediaQuery.of(context).size.width * .98,
            child: KeyboardActions(
              config: _buildConfig(context),
              child: textfield,
            ),
          )
        : textfield;
  }
}
