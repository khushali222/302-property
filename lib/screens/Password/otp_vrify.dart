import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import '../../constant/constant.dart';
import 'changepassword.dart';

class otp_verify extends StatefulWidget {
  final String admin_id;
  final String role;
  String userId;

  final String email;
   otp_verify({super.key,required this.email,required this.admin_id, required this.role,required this.userId});

  @override
  State<otp_verify> createState() => _otp_verifyState();
}

class _otp_verifyState extends State<otp_verify> {
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  int otp = 0;

  // Full code currently shown in the boxes. Kept as a String so a partially
  // filled code can be detected before submitting.
  String otpCode = '';
  void verifyOTP(int otp) async {
    setState(() {
      loading = true; // Set loading to true while verifying OTP
    });

    final response = await apiPost(
      Uri.parse('${Api_url}/api/admin/verifyOTP'),
      headers:{
    'Content-Type': 'application/json',
    },// Your OTP verification API endpoint
      body: jsonEncode(<String, dynamic>{
        'email': widget.email,
        'otp': otp,
      })
    );
    setState(() {
      loading = false; // Set loading to false after receiving response
    });
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Changepassword(email: widget.email,admin_id: widget.admin_id,role: widget.role,user_id: widget.userId,)),
      );
    Fluttertoast.showToast(msg: "OTP verify successfully");
    } else {
      // Handle error case here, for example:
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(jsonData["message"]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  void sendOTP(String email) async {
    setState(() {
      loading = true; // Show loading indicator while sending OTP
    });

    final response = await apiPost(
      Uri.parse('$Api_url/api/admin/sendOTP'),
      // Resend must send the same identifying fields as the initial send
      // (forgotpassword.dart) — the server looks up the user by role + user_id
      // (+ admin_id); email alone returns "Email not found".
      body: {
        'email': email,
        'admin_id': widget.admin_id,
        'role': widget.role,
        'user_id': widget.userId,
      },
    );

    setState(() {
      loading = false; // Hide loading indicator after receiving response
    });

    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
     /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => otp_verify(email: email,)),
      );*/
      Fluttertoast.showToast(msg: "OTP sent successfully");
      setState(() {
        loading = false;
      });
    } else {
      Fluttertoast.showToast(msg: jsonData["message"]);
      setState(() {
        loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.9,
              ),
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.03,
              // ),
              // // Welcome
              // Center(
              //   child: Text(
              //     "Welcome to 302 Rentals",
              //     style: TextStyle(
              //       color: Colors.black,
              //       fontWeight: FontWeight.bold,
              //       fontSize: MediaQuery.of(context).size.width * 0.05,
              //     ),
              //   ),
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Center(
                child: Text(
                  " OTP Verification",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.048),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.09),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _OtpBoxes(
                  fieldHeight: 50,
                  fieldWidth: 50,
                  numberOfFields: 6,
                  // Both callbacks hand back the FULL joined code, so `otp`
                  // always mirrors what the user can see in the boxes.
                  onChanged: (String code) {
                    otpCode = code;
                    otp = int.tryParse(code) ?? 0;
                  },
                  onCompleted: (String code) {
                    otpCode = code;
                    otp = int.tryParse(code) ?? 0;
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the OTP ? ",
                    style: TextStyle(
                        color: Color(0xFF152B51),
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                  GestureDetector(
                    onTap: () {
                      sendOTP(widget.email);
                    },
                    child: Container(
                      child: Text(
                        " Resend OTP",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:  Color(0xFF152B51),
                            fontSize:
                                MediaQuery.of(context).size.width * 0.037),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),
              GestureDetector(
                onTap: () {
                  // Guard the partial code: the screen has no field validators,
                  // so validate() alone would let an incomplete OTP be posted.
                  if (otpCode.length < 6) {
                    Fluttertoast.showToast(
                        msg: "Please enter the complete 6-digit OTP");
                    return;
                  }
                  if (formKey.currentState!.validate()) {
                    // All fields are valid, proceed with OTP verification
                    verifyOTP(otp);
                  }
                },
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color:  Color(0xFF152B51),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: loading
                          ? SpinKitFadingCircle(
                        color: Colors.white,
                        size: 40.0,
                      )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Verify Now",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six single-digit OTP boxes.
///
/// Replaces `OtpTextField` from the `flutter_otp_text_field` package. The
/// installed 1.4.0+2 build sets `maxLength` to the number of fields, so one box
/// could hold the whole code, and its backspace listener moved focus back even
/// when the box still had a digit. Backspacing to correct an entry therefore
/// dropped the caret into an already-filled box and the next keystroke appended
/// there ("38" in one box), after which the package's paste handler rewrote the
/// boxes from index 0 and the row collapsed.
///
/// Rules enforced here:
///  * one digit per box, digits only;
///  * focusing or tapping a box selects its digit, so typing replaces it
///    instead of appending;
///  * backspace clears the focused box; on an already-empty box it steps back
///    one box and clears that — never more than one digit per press;
///  * a pasted code spreads one digit per box from the box it was pasted into;
///  * callbacks report the full joined code.
class _OtpBoxes extends StatefulWidget {
  final int numberOfFields;
  final double fieldWidth;
  final double fieldHeight;

  /// Fires on every edit with the full joined code (may be partial).
  final ValueChanged<String> onChanged;

  /// Fires once every box holds a digit.
  final ValueChanged<String> onCompleted;

  const _OtpBoxes({
    required this.onChanged,
    required this.onCompleted,
    this.numberOfFields = 6,
    this.fieldWidth = 50,
    this.fieldHeight = 50,
  });

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  // Separate nodes for the key listeners so they never compete for focus with
  // the fields themselves.
  late final List<FocusNode> _keyNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
        widget.numberOfFields, (_) => TextEditingController());
    _focusNodes = List.generate(widget.numberOfFields, (_) => FocusNode());
    _keyNodes = List.generate(widget.numberOfFields, (_) => FocusNode());

    for (int i = 0; i < widget.numberOfFields; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          _selectAll(i);
          // The field can push the caret back to the end while it is settling
          // into focus, which would let the next keystroke append. Re-apply the
          // selection once that has happened.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _focusNodes[i].hasFocus) _selectAll(i);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final node in _keyNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Puts the caret across the existing digit so the next keystroke overwrites
  /// it rather than adding a second character to the box.
  void _selectAll(int index) {
    final controller = _controllers[index];
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _notify() {
    final code = _code;
    widget.onChanged(code);
    if (code.length == widget.numberOfFields) {
      widget.onCompleted(code);
    }
  }

  void _handleChanged(String value, int index) {
    if (value.length > 1) {
      _distribute(value, index);
      return;
    }

    if (value.isNotEmpty) {
      if (index + 1 < widget.numberOfFields) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _notify();
  }

  /// Spreads a multi-character insert (a paste, or an appended keystroke on a
  /// device where the selection did not take) one digit per box, starting at
  /// the box it arrived in.
  void _distribute(String value, int startIndex) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    int target = startIndex;
    for (final digit in digits.split('')) {
      if (target >= widget.numberOfFields) break;
      _controllers[target].text = digit;
      target++;
    }

    if (target >= widget.numberOfFields) {
      _focusNodes[widget.numberOfFields - 1].unfocus();
    } else {
      _focusNodes[target].requestFocus();
    }
    _notify();
  }

  void _handleKey(KeyEvent event, int index) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey != LogicalKeyboardKey.backspace) return;

    // A box that still holds a digit is left to the field itself, so one press
    // removes exactly one digit. Only the already-empty case is handled here.
    if (_controllers[index].text.isNotEmpty) return;
    if (index == 0) return;

    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
    _notify();
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(width: 2.0, color: color),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildBox(int index) {
    return Container(
      width: widget.fieldWidth,
      height: widget.fieldHeight,
      margin: const EdgeInsets.only(right: 8.0),
      child: KeyboardListener(
        focusNode: _keyNodes[index],
        onKeyEvent: (event) => _handleKey(event, index),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 20),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onTap: () => _selectAll(index),
          onChanged: (value) => _handleChanged(value, index),
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            border: _border(const Color(0xFFE7E7E7)),
            enabledBorder: _border(Colors.grey),
            focusedBorder: _border(const Color(0xFF4F44FF)),
            disabledBorder: _border(Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          List.generate(widget.numberOfFields, (index) => _buildBox(index)),
    );
  }
}
