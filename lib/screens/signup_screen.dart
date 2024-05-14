import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/screens/signup2_screen.dart';
import 'package:http/http.dart'as http;

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  int currentStep = 0;
  bool loading = false;
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();

  bool firstnameerror = false;
  bool lastnameerror = false;
  bool emailerror = false;

  String firstnamemessage = "";
  String lastnamemessage = "";
  String emailmessage = "";

  List<Step> steps = [
    Step(title: Text('About You'), content: AboutYouForm()),
    Step(title: Text('Customize Trial'), content: CustomizeTrialForm()),
    Step(title: Text('Final Form'), content: FinalForm()),
  ];
  int i = 0;

  void nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }


  Future<void> _checkEmailVerified(String email) async {
    setState(() {
      loading = true;
    });
    final url = Uri.parse('https://saas.cloudrentalmanager.com/api/admin/check_email');
    final response = await http.post(url, body: {'email': email});
    print(response.statusCode);
      final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
          print(jsonData);
          setState(() {
              emailerror = false;
              emailmessage = 'email is verified';
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Signup2(
                    firstname: firstname.text,
                    lastname: lastname.text,
                    email: email,
                  )));
          Fluttertoast.showToast(msg: "added succesfully");
          setState(() {
            loading = false;
          });
    } else if (jsonData["statusCode"] == 401) {
      print("already use");
      setState(() {
        emailerror = true;
        emailmessage = 'Email is already in use';
      });
    }else {
      Fluttertoast.showToast(msg: jsonData["message"]);
      setState(() {
        emailerror = true;
        emailmessage = 'Email is not verified';
        loading = false;
      });
    }
  }
  // Future<void> loginsubmit() async {
  //   setState(() {
  //     loading = true;
  //   });
  //   final response = await http.post(
  //       Uri.parse('https://saas.cloudrentalmanager.com/api/admin/login'),
  //       body: {"email": email.text});
  //   print(response.statusCode);
  //   final jsonData = json.decode(response.body);
  //   if (jsonData["statusCode"] == 200) {
  //     print(jsonData);
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => Dashboard()));
  //
  //     setState(() {
  //       loading = false;
  //     });
  //   } else {
  //     Fluttertoast.showToast(msg: jsonData["message"]);
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
        //   SafeArea(
        //   child: Scaffold(
        //     body: SingleChildScrollView(
        //       child: Container(
        //         height: MediaQuery.of(context).size.height,
        //         child: Column(
        //           children: [
        //             SizedBox(height: 90),
        //             Image(
        //               image: AssetImage('assets/images/logo.png'),
        //               height: 40,
        //               width: width * .9,
        //             ),
        //             SizedBox(height: 20),
        //             Text(
        //               "Welcome to 302 Rentals",
        //               style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 19),
        //             ),
        //             SizedBox(height: 10),
        //             Text(
        //               "Signup for free trial account",
        //               style: TextStyle(color: Colors.black),
        //             ),
        //             SizedBox(height: 20),
        //         Row(
        //                 children: [
        //                   SizedBox(width: MediaQuery.of(context).size.width *.099,),
        //                   Container(
        //                     height: 50,
        //                     width: MediaQuery.of(context).size.width * 0.8,
        //                     decoration: BoxDecoration(
        //                       borderRadius: BorderRadius.circular(10),
        //                       // color: Colors.blueGrey[50]
        //                       color: Color.fromRGBO(196, 196, 196, .3),
        //                     ),
        //                     child: Stack(
        //                       children: [
        //                         Positioned.fill(
        //                           child: TextField(
        //                             cursorColor: Color.fromRGBO(21, 43, 81, 1),
        //                             decoration: InputDecoration(
        //                               border: InputBorder.none,
        //                               contentPadding: EdgeInsets.all(10),
        //                               prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
        //                               hintText: "First Name",
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                   SizedBox(width: 25,),
        //                 ],
        //               ),
        //               SizedBox(
        //                 height: 25,
        //               ),
        //               //last name
        //               Row(
        //                 children: [
        //                   SizedBox(width: MediaQuery.of(context).size.width *.099,),
        //                   Container(
        //                     height: 50,
        //                     width: MediaQuery.of(context).size.width * 0.8,
        //                     decoration: BoxDecoration(
        //                       borderRadius: BorderRadius.circular(10),
        //                       // color: Colors.blueGrey[50],
        //                       color: Color.fromRGBO(196, 196, 196, .3),
        //                     ),
        //                     child: Stack(
        //                       children: [
        //                         Positioned.fill(
        //                           child: TextField(
        //                             cursorColor: Color.fromRGBO(21, 43, 81, 1),
        //                             decoration: InputDecoration(
        //                               border: InputBorder.none,
        //                               contentPadding: EdgeInsets.all(10),
        //                               prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
        //                               hintText: "Last Name",
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                   SizedBox(width: 25,),
        //                 ],
        //               ),
        //               SizedBox(
        //                 height: 25,
        //               ),
        //               //Buisiness email
        //               Row(
        //                 children: [
        //                   SizedBox(width: MediaQuery.of(context).size.width *.099,),
        //                   Container(
        //                     height: 50,
        //                     width: MediaQuery.of(context).size.width * 0.8,
        //                     decoration: BoxDecoration(
        //                       borderRadius: BorderRadius.circular(10),
        //                       // color: Colors.blueGrey[50]
        //                       color: Color.fromRGBO(196, 196, 196, .3),
        //                     ),
        //                     child: Stack(
        //                       children: [
        //                         Positioned.fill(
        //                           child: TextField(
        //                             cursorColor: Color.fromRGBO(21, 43, 81, 1),
        //                             decoration: InputDecoration(
        //                               border: InputBorder.none,
        //                               contentPadding: EdgeInsets.all(10),
        //                               prefixIcon: Icon(Icons.email_outlined,size: 22,color: Colors.grey,),
        //                               hintText: "Buisiness Email",
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                   SizedBox(width: 25,),
        //                 ],
        //               ),
        //               Spacer(),
        //               //Create your free tiral
        //               GestureDetector(
        //                 onTap: (){
        //                   Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup2()));
        //                 },
        //                 child: Container(
        //                   height: MediaQuery.of(context).size.height * .06,
        //                   width: MediaQuery.of(context).size.width * 0.8,
        //                   decoration: BoxDecoration(
        //                     color: Colors.black,
        //                     borderRadius: BorderRadius.circular(10),
        //                   ),
        //                   child: Center(child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       Text("Create your free tiral ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        //                     ],
        //                   )),
        //                 ),
        //               ),
        //               SizedBox(
        //                 height: 20,
        //               ),
        //             // Step content
        //
        //             SizedBox(height: 20),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: List.generate(
        //                 steps.length * 2 - 1,
        //                     (index) {
        //                   final stepIndex = index ~/ 2;
        //                   if (index.isOdd) {
        //                     // Add a vertical divider
        //                     return Container(
        //                       width: 80,
        //                       height: 2,
        //                       color: currentStep > stepIndex ? Colors.blue : Colors.grey,
        //                     );
        //
        //                   } else {
        //                     // Add the step circle
        //                     return GestureDetector(
        //                       onTap: () {
        //                         setState(() {
        //                           currentStep = stepIndex;
        //                         });
        //                       },
        //                       child: Padding(
        //                         padding: const EdgeInsets.all(8.0),
        //                         child: Container(
        //                           width: 30,
        //                           height: 30,
        //                           decoration: BoxDecoration(
        //                             shape: BoxShape.circle,
        //                             color: _getCircleColor(stepIndex),
        //                           ),
        //                           child: Center(
        //                             child: Text(
        //                               (stepIndex + 1).toString(),
        //                               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     );
        //                   }
        //                 },
        //               ),
        //             ),
        //
        //             SizedBox(height: 20),
        //             if (currentStep != -1) steps[currentStep].content,
        //
        //             SizedBox(height: 90),
        //           ],
        //         ),
        //       ),
        //     ),
        //
        //   ),
        // );
        SafeArea(
      child: Scaffold(
        body: ListView(
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
              height: MediaQuery.of(context).size.height * 0.025,
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
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Center(
              child: Text(
                "Signup for free trial account",
                style: TextStyle(color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.036
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(196, 196, 196, .3),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                firstnameerror = false;
                              });
                            },
                            controller: firstname,
                            cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            decoration: InputDecoration(
                              enabledBorder: firstnameerror
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                  : InputBorder.none,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              prefixIcon: Container(
                                  height: 20,
                                  width: 20,
                                  padding: EdgeInsets.all(13),
                                  child: Image.asset(
                                      "assets/icons/user_icon.png")),
                              hintText: "First Name",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            firstnameerror
                ? Center(
                    child: Text(
                    firstnamemessage,
                    style: TextStyle(color: Colors.red),
                  ))
                : Container(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),
            // Last name
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(196, 196, 196, .3),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                lastnameerror = false;
                              });
                            },
                            controller: lastname,
                            cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            decoration: InputDecoration(
                              enabledBorder: lastnameerror
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                  : InputBorder.none,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              prefixIcon: Container(
                                  height: 20,
                                  width: 20,
                                  padding: EdgeInsets.all(13),
                                  child: Image.asset(
                                      "assets/icons/user_icon.png")),
                              hintText: "Last Name",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            lastnameerror
                ? Center(
                    child: Text(
                    lastnamemessage,
                    style: TextStyle(color: Colors.red),
                  ))
                : Container(),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),
            // Business email
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(196, 196, 196, .3),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                emailerror = false;
                              });
                            },
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: emailerror
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                  : InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              prefixIcon: Container(
                                  height: 20,
                                  width: 20,
                                  padding: EdgeInsets.all(13),
                                  child: Image.asset(
                                      "assets/icons/email_icon.png")),
                              hintText: "Business Email",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            emailerror
                ? Center(
                    child: Text(
                    emailmessage,
                    style: TextStyle(color: Colors.red),
                  ))
                : Container(),

            Spacer(),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.098,
            ),
            GestureDetector(
              onTap: () async {
                if (firstname.text.isEmpty) {
                  setState(() {
                    firstnameerror = true;
                    firstnamemessage = "Firstname is required";
                  });
                } else {
                  setState(() {
                    firstnameerror = false;
                    //firstnamemessage = "Firstname is required";
                  });
                }
                if (lastname.text.isEmpty) {
                  setState(() {
                    lastnameerror = true;
                    lastnamemessage = "Lastname is required";
                  });
                } else {
                  setState(() {
                    lastnameerror = false;
                    //firstnamemessage = "Firstname is required";
                  });
                }
                if (email.text.isEmpty) {
                  setState(() {
                    emailerror = true;
                    emailmessage = "Email is required";
                  });
                } else if (!EmailValidator.validate(email.text)) {
                  setState(() {
                    emailerror = true;
                    emailmessage = "Email is not valid";
                  });
                } else {
                  await _checkEmailVerified(email.text);
                }
                if (!firstnameerror == false &&
                    !lastnameerror == false &&
                    !emailerror == false) {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Signup2(
                  //               firstname: firstname.text,
                  //               lastname: lastname.text,
                  //               email: email.text,
                  //             )));
                }
                //  print(EmailValidator.validate(email.text));
                /*
       */
              },
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                  Center(
                    child: loading?CircularProgressIndicator(color: Colors.white,):
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Create your free trial",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width *
                                  0.035),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: Center(
                        child: Text(
                          "1",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text('About you',
                        style: TextStyle(fontSize: 10, fontFamily: 'muslish')),
                  ],
                ),
                SizedBox(
                  width: 2,
                ),
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 2,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 15,
                    )
                  ],
                ),
                SizedBox(
                  width: 2,
                ),
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: Text(
                          "2",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Customize Trial',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontFamily: 'muslish'),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 2,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 15,
                    )
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: Text(
                          "3",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text("Final",
                        style: TextStyle(fontSize: 10, fontFamily: 'muslish'))
                  ],
                ),
              ],
            ),

            /*  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                steps.length * 2 - 1,
                (index) {
                  final stepIndex = index ~/ 2;
                  if (index.isOdd) {
                    // Add a vertical divider
                    return Container(
                      width: 80,
                      height: 2,
                      color:
                          currentStep > stepIndex ? Colors.blue : Colors.grey,
                    );
                  } else {
                    // Add the step circle
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentStep = stepIndex;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getCircleColor(stepIndex),
                          ),
                          child: Center(
                            child: Text(
                              (stepIndex + 1).toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            if (currentStep != -1) steps[currentStep].content,
          */ // SizedBox(height: 90),
          ],
        ),
      ),
    );
  }


  Color _getCircleColor(int stepIndex) {
    if (currentStep >= stepIndex) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }
}

class AboutYouForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('About You Form'),
    );
  }
}

class CustomizeTrialForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('Customize Trial Form'),
    );
  }
}

class FinalForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('Final Form'),
    );
  }
}
