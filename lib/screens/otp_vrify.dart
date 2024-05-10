// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
//
// class otp_verify extends StatefulWidget {
//   const otp_verify({super.key});
//
//   @override
//   State<otp_verify> createState() => _otp_verifyState();
// }
//
// class _otp_verifyState extends State<otp_verify> {
//   final pinController = TextEditingController();
//   final focusNode = FocusNode();
//   final formKey = GlobalKey<FormState>();
//   bool loading = false;
//   bool allfield = false;
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     const focusedBorderColor = Colors.black;
//     const fillColor = Color.fromRGBO(243, 246, 249, 0);
//     const borderColor = Colors.grey;
//     final defaultPinTheme = PinTheme(
//       width: MediaQuery.of(context).size.width * 0.15,
//       height: MediaQuery.of(context).size.width * 0.15,
//       textStyle: const TextStyle(
//         fontSize: 22,
//         color: Color.fromRGBO(30, 60, 87, 1),
//       ),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: borderColor),
//       ),
//     );
//     return SafeArea(
//       child: Scaffold(
//         body: Form(
//           key: formKey,
//           child: ListView(
//             children: [
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.1,
//               ),
//               Image(
//                 image: AssetImage('assets/images/logo.png'),
//                 height: MediaQuery.of(context).size.height * 0.05,
//                 width: MediaQuery.of(context).size.width * 0.9,
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.03,
//               ),
//               // Welcome
//               Center(
//                 child: Text(
//                   "Welcome to 302 Rentals",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: MediaQuery.of(context).size.width * 0.05,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.04,
//               ),
//               Center(
//                 child: Text(
//                   " Otp Verification",
//                   style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width * 0.048),
//                 ),
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.09
//               ),
//               Pinput(
//                 controller:pinController,
//                 androidSmsAutofillMethod:
//                 AndroidSmsAutofillMethod.smsUserConsentApi,
//                 listenForMultipleSmsOnAndroid: true,
//                 defaultPinTheme: defaultPinTheme,
//                 separatorBuilder: (index) => const SizedBox(width: 8),
//                 hapticFeedbackType: HapticFeedbackType.lightImpact,
//                 onCompleted: (pin) {
//                   debugPrint('onCompleted: $pin');
//                   setState(() {
//                     allfield = true;
//                   });
//                 },
//                 // validator: (s) {
//                 //   return s == widget.otp ? null : 'OTP is incorrect';
//                 // },
//                 onChanged: (value) {
//                   if(allfield == true){
//                     setState(() {
//                       allfield = false;
//                     });
//                   }
//                   debugPrint('onChanged: $value');
//                 },
//
//                 focusedPinTheme: defaultPinTheme.copyWith(
//                   decoration: defaultPinTheme.decoration!.copyWith(
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: focusedBorderColor),
//                   ),
//                 ),
//                 submittedPinTheme: defaultPinTheme.copyWith(
//                   decoration: defaultPinTheme.decoration!.copyWith(
//                     color: fillColor,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: focusedBorderColor),
//                   ),
//                 ),
//                 errorPinTheme: defaultPinTheme.copyBorderWith(
//                   border: Border.all(color: Colors.redAccent),
//                 ),
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.1,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Don't Recive Otp? ",
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: MediaQuery.of(context).size.width * 0.04
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//
//                     },
//                     child: Container(
//                       child: Text(
//                         "Resend Otp",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                             fontSize: MediaQuery.of(context).size.width * 0.037
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.07,
//               ),
//               GestureDetector(
//                 onTap: ()  {
//
//                 },
//                 child: Center(
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.06,
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(
//                       child: loading
//                           ? CircularProgressIndicator(
//                         color: Colors.white,
//                       )
//                           : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Verify Now",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: MediaQuery.of(context).size.width * 0.04
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
