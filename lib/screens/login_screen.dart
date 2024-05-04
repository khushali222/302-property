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
            // Image(
            //   image: AssetImage('assets/images/logo.png'),
            //   height: MediaQuery.of(context).size.shortestSide < 600 // Check if the device width is less than 600 (typical for tablets)
            //       ? MediaQuery.of(context).size.height * 0.15 // Use a larger size for tablets
            //       : MediaQuery.of(context).size.height * 0.08, // Use a smaller size for phones
            //   width: MediaQuery.of(context).size.width * 0.9,
            //   alignment: Alignment.center,
            // ),
            // Center(
            //   child: LayoutBuilder(
            //     builder: (BuildContext context, BoxConstraints constraints) {
            //       // You can adjust the width and height constraints based on device sizes
            //       double width = constraints.maxWidth * 0.8; // Adjust as needed
            //       double height = constraints.maxHeight * 0.8; // Adjust as needed
            //
            //       return Container(
            //         width: width,
            //         height: height,
            //         child: Image.asset(
            //           'assets/images/logo.png',
            //           fit: BoxFit.contain, // Or any other BoxFit option you prefer
            //         ),
            //       );
            //     },
            //   ),
            // ),
              // FractionallySizedBox(
              //   widthFactor: MediaQuery.of(context).size.width /9,
              //   child: Image(
              //     image: AssetImage('assets/images/logo.png'),
              //   ),
              // ),
            Image(
              image: AssetImage('assets/images/logo.png'),
              height: 34,
              width: width * 0.5,
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
                                      keyboardType: TextInputType.emailAddress,
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15),
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
                                        contentPadding: EdgeInsets.all(15),
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
