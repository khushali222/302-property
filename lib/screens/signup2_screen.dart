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
    // return
    //   SafeArea(
    //     child: Scaffold(
    //       body:
    //       ListView(
    //         children: [
    //           SizedBox(
    //             height: 50,
    //           ),
    //           Image(
    //             image: AssetImage('assets/images/logo.png'),
    //             height: 40,
    //             width: width * .9,
    //           ),
    //           SizedBox(
    //             height: 20,
    //           ),
    //           //welcome
    //           Center(
    //             child: Text("Welcome to 302 Rentals",
    //               style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 19),),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           //login text
    //           Center(
    //             child: Text("Signup for free tiral account",
    //               style: TextStyle(color: Colors.black),),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Row(
    //             children: [
    //               SizedBox(width: MediaQuery.of(context).size.width *.099,),
    //               Container(
    //                 height: 50,
    //                 width: MediaQuery.of(context).size.width * 0.8,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(10),
    //                   // color: Colors.blueGrey[50]
    //                   color: Color.fromRGBO(196, 196, 196, .3),
    //                 ),
    //                 child: Stack(
    //                   children: [
    //                     Positioned.fill(
    //                       child: TextField(
    //                         cursorColor: Color.fromRGBO(21, 43, 81, 1),
    //                         decoration: InputDecoration(
    //                           border: InputBorder.none,
    //                           contentPadding: EdgeInsets.all(10),
    //                           prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
    //                           hintText: "Alex",
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(width: 25,),
    //             ],
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //
    //           Row(
    //             children: [
    //               SizedBox(width: MediaQuery.of(context).size.width *.099,),
    //               Container(
    //                 height: 50,
    //                 width: MediaQuery.of(context).size.width * 0.8,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(10),
    //                   // color: Colors.blueGrey[50]
    //                   color: Color.fromRGBO(196, 196, 196, .3),
    //                 ),
    //                 child: Stack(
    //                   children: [
    //                     Positioned.fill(
    //                       child: TextField(
    //                         cursorColor: Color.fromRGBO(21, 43, 81, 1),
    //                         decoration: InputDecoration(
    //                           border: InputBorder.none,
    //                           contentPadding: EdgeInsets.all(10),
    //                           prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
    //                           hintText: "Williams",
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(width: 25,),
    //             ],
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Row(
    //             children: [
    //               SizedBox(width: MediaQuery.of(context).size.width *.099,),
    //               Container(
    //                 height: 50,
    //                 width: MediaQuery.of(context).size.width * 0.8,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(10),
    //                   // color: Colors.blueGrey[50]
    //                   color: Color.fromRGBO(196, 196, 196, .3),
    //                 ),
    //                 child: Stack(
    //                   children: [
    //                     Positioned.fill(
    //                       child: TextField(
    //                         cursorColor: Color.fromRGBO(21, 43, 81, 1),
    //                         decoration: InputDecoration(
    //                           border: InputBorder.none,
    //                           contentPadding: EdgeInsets.all(10),
    //                           prefixIcon: Icon(Icons.email_outlined,size: 22,color: Colors.grey,),
    //                           hintText: "Email",
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(width: 25,),
    //             ],
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Row(
    //             children: [
    //               SizedBox(width: MediaQuery.of(context).size.width *.099,),
    //               Container(
    //                 height: 50,
    //                 width: MediaQuery.of(context).size.width * 0.8,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(10),
    //                   // color: Colors.blueGrey[50]
    //                   color: Color.fromRGBO(196, 196, 196, .3),
    //                 ),
    //                 child: Stack(
    //                   children: [
    //                     Positioned.fill(
    //                       child: TextField(
    //                         cursorColor: Color.fromRGBO(21, 43, 81, 1),
    //                         decoration: InputDecoration(
    //                           border: InputBorder.none,
    //                           contentPadding: EdgeInsets.all(10),
    //                           prefixIcon: Icon(Icons.home,size: 22,color: Colors.grey,),
    //                           hintText: "Company Name",
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(width: 25,),
    //             ],
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Row(
    //             children: [
    //               SizedBox(width: MediaQuery.of(context).size.width *.099,),
    //               Container(
    //                 height: 50,
    //                 width: MediaQuery.of(context).size.width * 0.8,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(10),
    //                   // color: Colors.blueGrey[50]
    //                   color: Color.fromRGBO(196, 196, 196, .3),
    //                 ),
    //                 child: Stack(
    //                   children: [
    //                     Positioned.fill(
    //                       child: TextField(
    //                         cursorColor: Color.fromRGBO(21, 43, 81, 1),
    //                         decoration: InputDecoration(
    //                           border: InputBorder.none,
    //                           contentPadding: EdgeInsets.all(10),
    //                           prefixIcon: Icon(Icons.phone,size: 22,color: Colors.grey,),
    //                           hintText: "Phone Number",
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(width: 25,),
    //             ],
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Row(
    //             children: [
    //               SizedBox(width: MediaQuery.of(context).size.width *.099,),
    //               Container(
    //                 height: 50,
    //                 width: MediaQuery.of(context).size.width * 0.8,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(10),
    //                   // color: Colors.blueGrey[50]
    //                   color: Color.fromRGBO(196, 196, 196, .3),
    //                 ),
    //                 child: Stack(
    //                   children: [
    //                     Positioned.fill(
    //                       child: TextField(
    //                         cursorColor: Color.fromRGBO(21, 43, 81, 1),
    //                         decoration: InputDecoration(
    //                           border: InputBorder.none,
    //                           contentPadding: EdgeInsets.all(10),
    //                           prefixIcon: Icon(Icons.lock,size: 22,color: Colors.grey,),
    //                           suffixIcon: Icon(Icons.remove_red_eye_outlined,color: Colors.grey,size: 22),
    //                           hintText: "Password",
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(width: 25,),
    //             ],
    //           ),
    //           SizedBox(
    //             height: 20,
    //           ),
    //
    //           Row(
    //             children: [
    //               SizedBox(
    //                 width: MediaQuery.of(context).size.width * .099,
    //               ),
    //               Container(
    //                 height: 15,
    //                 width: 15,
    //                 decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(5),
    //                     border: Border.all(
    //                       color: Colors.grey,
    //                     )),
    //               ),
    //               SizedBox(
    //                 width: 10,
    //               ),
    //               Text(
    //                 "i have read and accept 302 properties term and condition ",
    //                 style: TextStyle(fontSize: 9, color: Colors.black),
    //               ),
    //               SizedBox(
    //                 width: MediaQuery.of(context).size.width * .099,
    //               ),
    //             ],
    //           ),
    //           SizedBox(
    //             height: 20,
    //           ),
    //           GestureDetector(
    //             onTap: () {
    //             //  Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
    //             },
    //             child: Center(
    //               child: Container(
    //                 height: MediaQuery.of(context).size.height * 0.06,
    //                 width: MediaQuery.of(context).size.width * 0.8,
    //                 decoration: BoxDecoration(
    //                   color: Colors.black,
    //                   borderRadius: BorderRadius.circular(10),
    //                 ),
    //                 child: Center(
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       Text("Create your free tiral ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //           // SizedBox(
    //           //   height: height * .001,
    //           // ),
    //         ],
    //       ),
    //
    //     ),
    //   );
    return SafeArea(
      child: Scaffold(
        body: ListView(
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
                    "Signup for free trial account",
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
                                              0.04),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Icon(
                                            Icons.person_outline_outlined,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            color: Colors.grey),
                                        hintText: "Williams",
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
                                              0.04),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Icon(
                                            Icons.person_outline_outlined,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            color: Colors.grey),
                                        hintText: "Williams",
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
                                              0.04),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Icon(
                                            Icons.person_outline_outlined,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            color: Colors.grey),
                                        hintText: "Williams",
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
                                              0.04),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Icon(
                                            Icons.person_outline_outlined,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            color: Colors.grey),
                                        hintText: "Williams",
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
                                              0.04),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Icon(
                                            Icons.person_outline_outlined,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            color: Colors.grey),
                                        hintText: "Williams",
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
                                              0.04),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Icon(
                                            Icons.person_outline_outlined,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            color: Colors.grey),
                                        hintText: "Williams",
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
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Text(
                        "I have read and accept 302 properties term and condition ",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.024,
                            color: Colors.black),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup2()));
                    },
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
                              "Create your free trial",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035),
                            ),
                          ],
                        ),
                      ),
                    ),
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
