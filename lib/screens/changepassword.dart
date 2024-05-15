import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart'as http;
import 'package:three_zero_two_property/screens/login_screen.dart';

class Changepassword extends StatefulWidget {
  final String email;
  const Changepassword({super.key, required this.email});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  bool passworderror = false;
  bool confirmpassworderror = false;
  bool loading = false;

  String passwordmessage = "";
  String confirmpasswordmessage = "";
  bool visiable_password = true;

  final formKey = GlobalKey<FormState>();
  void changePassword() async {
    setState(() {
      loading = true; // Set loading to true while changing password
    });

    final response = await http.put(
      Uri.parse('http://192.168.1.32:4000/api/admin/app/reset_password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'email': widget.email,
        'password': password.text,
      }),
    );
    setState(() {
      loading = false; // Set loading to false after receiving response
    });
    print(response.body);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["message"] == "Password Updated Successfully") {
        print(jsonData);
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Login_Screen()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password updated successfully")),
        );
      } else {
        // Handle other successful responses or display an error message
      }
    } else {
      // Handle HTTP error responses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                height: MediaQuery.of(context).size.height * 0.02,
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
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              // Login text
              Center(
                child: Text(
                  "change Password ?",
                  style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width * 0.034),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                  Expanded(
                    child: Container(
                      height:50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.02),
                        color: Color.fromRGBO(196, 196, 196, 0.3),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width *
                                      0.00),
                              child: Center(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      passworderror = false;
                                    });
                                  },
                                  obscureText: true,
                                  controller: password,
                                  cursorColor:
                                  Color.fromRGBO(21, 43, 81, 1),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10),
                                    enabledBorder: passworderror
                                        ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                        : InputBorder.none,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.asset(
                                          'assets/icons/pasword.png'),

                                    ),
                                    hintText: "Password",
                                    suffixIcon:
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          visiable_password = !visiable_password;
                                        });
                                      },
                                      child: Icon(
                                        visiable_password
                                            ? Icons.remove_red_eye_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey,
                                      ),
                                    ),

                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                ],
              ),
              passworderror
                  ? Center(
                  child: Text(
                    passwordmessage,
                    style: TextStyle(color: Colors.red),
                  ))
                  : Container(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                  Expanded(
                    child: Container(
                      height:50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.02),
                        color: Color.fromRGBO(196, 196, 196, 0.3),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width *
                                      0.00),
                              child: Center(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      confirmpassworderror = false;
                                    });
                                  },
                                  obscureText: true,
                                  controller: confirmpassword,
                                  cursorColor:
                                  Color.fromRGBO(21, 43, 81, 1),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10),
                                    enabledBorder: confirmpassworderror
                                        ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                        : InputBorder.none,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.asset(
                                          'assets/icons/pasword.png'),
                                    ),
                                    hintText: "Confirmpassword",
                                    suffixIcon:
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          visiable_password = !visiable_password;
                                        });
                                      },
                                      child: Icon(
                                        visiable_password
                                            ? Icons.remove_red_eye_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey,
                                      ),
                                    ),

                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                ],
              ),
              confirmpassworderror
                  ? Center(
                  child: Text(
                    confirmpasswordmessage,
                    style: TextStyle(color: Colors.red),
                  ))
                  : Container(),

              Spacer(),
              // Login button
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              GestureDetector(
                onTap: () {
                  if (password.text.isEmpty) {
                    setState(() {
                      passworderror = true;
                      passwordmessage = "Password is required";
                    });
                  }
                  else if (password.text.length < 8) {
                    setState(() {
                      passworderror = true;
                      passwordmessage = "Password must have 8 Characters";
                    });
                  }
                  else if (!RegExp(
                      r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                      .hasMatch(password.text)) {
                    setState(() {
                      passworderror = true;
                      passwordmessage =
                      'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
                    });
                  }
                  else {
                    setState(() {
                      passworderror = false;
                    });
                  }
                  if (confirmpassword.text.isEmpty) {
                    setState(() {
                      confirmpassworderror = true;
                      confirmpasswordmessage = "Confirm password is required";
                    });
                  }
                  else if (confirmpassword.text != password.text) {
                    setState(() {
                      confirmpassworderror = true;
                      confirmpasswordmessage = "Both password is not match";
                    });
                  }
                  else {
                    setState(() {
                      confirmpassworderror = false;
                    });
                  }
                  if (!passworderror && !confirmpassworderror) {
                    changePassword();
                  }
                  },
                // onTap: () {
                //   // Validate form fields
                //   if (formKey.currentState!.validate()) {
                //     // If form is valid, call changePassword function
                //     changePassword();
                //   } else {
                //     // If form is not valid, show errors for empty fields
                //     setState(() {
                //       // Check if password field is empty
                //       if (password.text.isEmpty) {
                //         passworderror = true;
                //         passwordmessage = "Please enter password";
                //       } else {
                //         passworderror = false;
                //       }
                //       // Check if confirm password field is empty
                //       if (confirmpassword.text.isEmpty) {
                //         confirmpassworderror = true;
                //         confirmpasswordmessage = "Please enter confirm password";
                //       } else {
                //         confirmpassworderror = false;
                //       }
                //     });
                //   }
                // },
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child:
                      loading
                          ? SpinKitFadingCircle(
                        color: Colors.black,
                        size: 50.0,
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Change password",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.045
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              GestureDetector(
                onTap: () {

                },
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black)
                    ),
                    child: Center(
                      child: loading
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.045
                            ),
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
