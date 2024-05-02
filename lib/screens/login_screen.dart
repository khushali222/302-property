import 'package:flutter/material.dart';

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
        body: Column(
          children: [
            SizedBox(
              height: 100,
            ),

            //welcome
            Text("Welcome to 302 Rentals",
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(
              height: 20,
            ),
            //login text
            Text("Please login here...",
              style: TextStyle(color: Colors.black),),
            SizedBox(
              height: 20,
            ),
            //email
            Row(
              children: [
                SizedBox(width: 35,),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                   color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                             prefixIcon: Icon(Icons.email_outlined,size: 22,color: Colors.grey,),
                            hintText: "Email",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 25,),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            //password
            Row(
              children: [
                SizedBox(width: 35,),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                            prefixIcon: Icon(Icons.lock_open,size: 22,color: Colors.grey,),
                            hintText: "Password",
                              suffixIcon: Icon(Icons.remove_red_eye_outlined,color: Colors.grey,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 25,),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            //forgot password
            Row(
              children: [
                SizedBox(width: 36,),
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.grey,

                    )
                  ),
                ),
                SizedBox(width: 10,),
                Text("Remember me ",style: TextStyle(fontSize: 12,color: Colors.black),),
                Spacer(),
                Text("Forgot password?",style: TextStyle(fontSize: 12,color: Colors.blue),),
                SizedBox(width: 40,),
              ],
            ),
            Spacer(),
            //login button
            Container(
              height: MediaQuery.of(context).size.height * .06,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text("Login",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
            ),
            SizedBox(
              height: 20,
            ),
            //Ragister now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ",
                  style: TextStyle(color: Colors.black,),),
                GestureDetector(child: Text("Ragister now",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)),
              ],
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
