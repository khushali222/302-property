import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/signup_screen.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body:
        ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Image(
              image: AssetImage('assets/images/logo.png'),
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.9,
              alignment: Alignment.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to 302 Rentals",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.05),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "Please login here...",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
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
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(17.0),
                                          child: Image.asset(
                                              'assets/icons/email.png'
                                          ),
                                        ),
                                        hintText: "Email",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
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
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon:  Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                            'assets/icons/pasword.png',),
                                        ),
                                        hintText: "Password",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
              SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                  Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.height * 0.03,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Text(
                          "Remember me ",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, color: Colors.black),
                        ),
                        Spacer(),
                        Text(
                          "Forgot password?",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, color: Colors.blue),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                      ],
                    ),
                  // Spacer(),
                      // Login button
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.025,
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right_outlined,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width * 0.055,
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
                    // Register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account ? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                          },
                          child: Container(
                            child: Text(
                              "Register now",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: MediaQuery.of(context).size.width * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),

      ),

    );
  }
}
