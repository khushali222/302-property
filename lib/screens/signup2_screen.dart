import 'package:flutter/material.dart';
class Signup2 extends StatefulWidget {
  const Signup2({super.key});

  @override
  State<Signup2> createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
      SafeArea(
        child: Scaffold(
          body:
          SingleChildScrollView(
            child: Container( // or SizedBox, or wrap with MediaQuery
              height: MediaQuery.of(context).size.height, // or any fixed height
              child:
              Column(
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
                  Text("Welcome to 302 Rentals",
                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                  SizedBox(
                    height: 10,
                  ),
                  //login text
                  Text("Signup for free tiral account",
                    style: TextStyle(color: Colors.black),),
                  SizedBox(
                    height: 20,
                  ),
                  //first name
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width *.099,),
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
                                  prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
                                  hintText: "First Name",
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
                    height: 10,
                  ),
                  //last name

                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width *.099,),
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
                                  prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
                                  hintText: "First Name",
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
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width *.099,),
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
                                  prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
                                  hintText: "First Name",
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
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width *.099,),
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
                                  prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
                                  hintText: "First Name",
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
                    height: 10,
                  ),
                  Spacer(),
                  //login button
                  Container(
                    height: MediaQuery.of(context).size.height * .06,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Create your free tiral ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ],
                    )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),

        ),
      );
  }
}
