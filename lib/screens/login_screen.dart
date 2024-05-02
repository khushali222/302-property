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
        body: SingleChildScrollView(
          child: Container(
            // or SizedBox, or wrap with MediaQuery
            height: MediaQuery.of(context).size.height, // or any fixed height
            child: Column(
              children: [
                SizedBox(
                  height: 90,
                ),
                Image(
                  image: AssetImage('assets/images/logo.png'),
                  height: 30,
                  width: 200,
                ),
                SizedBox(
                  height: 20,
                ),
                //welcome
                Text(
                  "Welcome to 302 Rentals",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                //login text
                Text(
                  "Please login here...",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 20,
                ),
                //email
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .099,
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // color: Colors.blueGrey[50]
                        color: Color.fromRGBO(196, 196, 196, .3),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: TextField(
                              cursorColor: Color.fromRGBO(21, 43, 81, 1),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                hintText: "Email",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                //password
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .099,
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // color: Colors.blueGrey[50],
                        color: Color.fromRGBO(196, 196, 196, .3),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: TextField(
                              cursorColor: Color.fromRGBO(21, 43, 81, 1),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                                prefixIcon: Icon(
                                  Icons.lock_open,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                hintText: "Password",
                                suffixIcon: Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                //forgot password
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .099,
                    ),
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.grey,
                          )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Remember me ",
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Spacer(),
                    Text(
                      "Forgot password?",
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .099,
                    ),
                  ],
                ),
                Spacer(),
                //login button
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup()));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * .06,
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
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                //Ragister now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ? ",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){

                      },
                        child: Text(
                      "Ragister now",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    )),
                  ],
                ),
                SizedBox(
                  height: 90,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
