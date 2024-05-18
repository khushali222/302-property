import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'changepassword.dart';

class otp_verify extends StatefulWidget {
  final String email;
  const otp_verify({super.key,required this.email});

  @override
  State<otp_verify> createState() => _otp_verifyState();
}

class _otp_verifyState extends State<otp_verify> {
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  int otp = 0;
  void verifyOTP(int otp) async {
    setState(() {
      loading = true; // Set loading to true while verifying OTP
    });

    final response = await http.post(
      Uri.parse('http://192.168.1.32:4000/api/admin/verifyOTP'),
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
        MaterialPageRoute(builder: (context) => Changepassword(email: widget.email)),
      );
    Fluttertoast.showToast(msg: "OTP sent successfully");
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

    final response = await http.post(
      Uri.parse('http://192.168.1.32:4000/api/admin/sendOTP'),
      body: {'email': email},
    );

    setState(() {
      loading = false; // Hide loading indicator after receiving response
    });

    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => otp_verify(email: email,)),
      );
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              // Welcome
              Center(
                child: Text(
                  "Welcome to 302 Rentals",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Center(
                child: Text(
                  " Otp Verification",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.048),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.09),
              OtpTextField(
                fieldHeight: 50,
                fieldWidth: 50,
                numberOfFields: 6,
                enabledBorderColor: Colors.grey,
                disabledBorderColor: Colors.black,
                cursorColor: Colors.black,
                // borderColor: Color(0xFF512DA8),
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(10),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Adjust padding if necessary
                textStyle: TextStyle(fontSize: 20),
                onCodeChanged: (String code) {
                  otp = int.parse(code); // Update OTP variable as user types
                },
                onSubmit: (String verificationCode) {
                  setState(() {
                    otp = int.parse(verificationCode);
                  });
                }, // end onSubmit
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't Recive Otp? ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                  GestureDetector(
                    onTap: () {
                      sendOTP(widget.email);
                    },
                    child: Container(
                      child: Text(
                        "Resend Otp",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
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
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: loading
                          ? SpinKitFadingCircle(
                        color: Colors.black,
                        size: 50.0,
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
