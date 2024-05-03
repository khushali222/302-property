import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/signup2_screen.dart';

// class Signup extends StatefulWidget {
//   const Signup({super.key});
//
//   @override
//   State<Signup> createState() => _SignupState();
// }
//
// class _SignupState extends State<Signup> {
//   bool isActive = true;
//   int current_step  =-1;
//   // Signup({required this.current_step});
//   int stepNumber = 0;
//   int currentStep = 0;
//   List<Step> steps = [
//     Step(title: Text('About You'), content: AboutYouForm()),
//     Step(title: Text('Customize Trial'), content: CustomizeTrialForm()),
//     Step(title: Text('Final Form'), content: FinalForm()),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return
//       SafeArea(
//         child: Scaffold(
//           body:
//           SingleChildScrollView(
//             child: Container( // or SizedBox, or wrap with MediaQuery
//               height: MediaQuery.of(context).size.height, // or any fixed height
//               child:
//               Column(
//                 children: [
//                   SizedBox(
//                     height: 90,
//                   ),
//                   Image(
//                     image: AssetImage('assets/images/logo.png'),
//                     height: 30,
//                     width: 200,
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   //welcome
//                   Text("Welcome to 302 Rentals",
//                     style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   //login text
//                   Text("Signup for free tiral account",
//                     style: TextStyle(color: Colors.black),),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   //first name
//                   Row(
//                     children: [
//                       SizedBox(width: MediaQuery.of(context).size.width *.099,),
//                       Container(
//                         height: 50,
//                         width: MediaQuery.of(context).size.width * 0.8,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           // color: Colors.blueGrey[50]
//                           color: Color.fromRGBO(196, 196, 196, .3),
//                         ),
//                         child: Stack(
//                           children: [
//                             Positioned.fill(
//                               child: TextField(
//                                 cursorColor: Color.fromRGBO(21, 43, 81, 1),
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.all(10),
//                                   prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
//                                   hintText: "First Name",
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: 25,),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 25,
//                   ),
//                   //last name
//                   Row(
//                     children: [
//                       SizedBox(width: MediaQuery.of(context).size.width *.099,),
//                       Container(
//                         height: 50,
//                         width: MediaQuery.of(context).size.width * 0.8,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           // color: Colors.blueGrey[50],
//                           color: Color.fromRGBO(196, 196, 196, .3),
//                         ),
//                         child: Stack(
//                           children: [
//                             Positioned.fill(
//                               child: TextField(
//                                 cursorColor: Color.fromRGBO(21, 43, 81, 1),
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.all(10),
//                                   prefixIcon: Icon(Icons.person_outline_outlined,size: 22,color: Colors.grey,),
//                                   hintText: "Last Name",
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: 25,),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 25,
//                   ),
//                   //Buisiness email
//                   Row(
//                     children: [
//                       SizedBox(width: MediaQuery.of(context).size.width *.099,),
//                       Container(
//                         height: 50,
//                         width: MediaQuery.of(context).size.width * 0.8,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           // color: Colors.blueGrey[50]
//                           color: Color.fromRGBO(196, 196, 196, .3),
//                         ),
//                         child: Stack(
//                           children: [
//                             Positioned.fill(
//                               child: TextField(
//                                 cursorColor: Color.fromRGBO(21, 43, 81, 1),
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.all(10),
//                                   prefixIcon: Icon(Icons.email_outlined,size: 22,color: Colors.grey,),
//                                   hintText: "Buisiness Email",
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: 25,),
//                     ],
//                   ),
//                   Spacer(),
//                   //Create your free tiral
//                   GestureDetector(
//                     onTap: (){
//                       Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup2()));
//                     },
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * .06,
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Center(child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("Create your free tiral ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
//                         ],
//                       )),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   //Ragister now
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: current_step == 0 ? Colors.black : Colors.grey,
//                     ),
//                     child: Center(
//                       child: Text(
//                         "1",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 2,),
//                   Container(
//                     width: 80,
//                     height: 2,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(width: 2,),
//                   Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: current_step == 1 ? Colors.blue : Colors.grey,
//                     ),
//                     child: Center(
//                       child: Text(
//                         "2",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 2,),
//                   SizedBox(width: 2,),
//                   Container(
//                     width: 80,
//                     height: 2,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(width: 2,),
//                   Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: current_step == 2? Colors.blue : Colors.grey,
//                     ),
//                     child: Center(
//                       child: Text(
//                         "3",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                 ],
//               ),
//
//                   SizedBox(
//                     height: 90,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//         ),
//       );
//   }
//
// }
//
// class AboutYouForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       child: Text('About You Form'),
//     );
//   }
// }
//
// class CustomizeTrialForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       child: Text('Customize Trial Form'),
//     );
//   }
// }
//
// class FinalForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       child: Text('Final Form'),
//     );
//   }
// }
class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  int currentStep = 0;

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(height: 90),
                Image(
                  image: AssetImage('assets/images/logo.png'),
                  height: 30,
                  width: 200,
                ),
                SizedBox(height: 20),
                Text(
                  "Welcome to 302 Rentals",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  "Signup for free trial account",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20),
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
                                  Icons.person_outline_outlined,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                hintText: "First Name",
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
                //last name
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
                                  Icons.person_outline_outlined,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                hintText: "Last Name",
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
                //Buisiness email
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
                                hintText: "Buisiness Email",
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
                Spacer(),
                //Create your free tiral
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Signup2()));
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
                          "Create your free tiral ",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Step content

                SizedBox(height: 20),
                // Step indicators
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     for (int i = 0; i < steps.length; i++)
                //       GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             currentStep = i;
                //           });
                //         },
                //         child: Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: Container(
                //             width: 30,
                //             height: 30,
                //             decoration: BoxDecoration(
                //               shape: BoxShape.circle,
                //               color: currentStep == i ? Colors.blue : Colors.grey,
                //             ),
                //             child: Center(
                //               child: Text(
                //                 (i + 1).toString(),
                //                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    steps.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          currentStep = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentStep == index
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (currentStep != -1) steps[currentStep].content,

                SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
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
