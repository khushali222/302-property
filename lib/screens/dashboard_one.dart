import 'package:flutter/material.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

class Dashboard_one extends StatefulWidget {
  const Dashboard_one({super.key});

  @override
  State<Dashboard_one> createState() => _Dashboard_oneState();
}

class _Dashboard_oneState extends State<Dashboard_one> {
  List<IconData> icons = [
    Icons.home,
    Icons.work,
    Icons.shopping_cart,
    Icons.school,
    Icons.restaurant,

  ];

  List<String> texts = ["150", "200", "100", "180", "250"];
  List<String> titles = ["Properties", "Tanants", "Applicants", "Vendors", "Work order"];
  List<Color>  colorc = [
    Color.fromRGBO(21, 43, 81, 1),
    Color.fromRGBO(40, 60, 95, 1),
    Color.fromRGBO(50, 75, 119, 1),
    Color.fromRGBO(60, 89, 142, 1),
    Color.fromRGBO(90, 134, 213, 1),

  ];
  List<Color> colors = [
   // Color.fromRGBO(40, 60, 95, 1),
   //  Colors.green,
   //  Colors.blue,
   //  Colors.orange,
   //  Colors.purple,
   //  Colors.red,
    Color.fromRGBO(21, 43, 81, 1),
    Color.fromRGBO(40, 60, 95, 1),
    Color.fromRGBO(50, 75, 119, 1),
    Color.fromRGBO(60, 89, 142, 1),
    Color.fromRGBO(90, 134, 213, 1),
  ];
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: widget_302.App_Bar(),
      body: ListView(
        children: [
          Material(
            elevation: 4,
            child: Divider(
              color: Colors.transparent,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          //welcome
          Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Text(
                "Hello Lou ,Welcome back",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.04),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          //my dashboard
          Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Text(
                "My Dashboard",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.05),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     SizedBox(
          //       width: width * 0.1,
          //     ),
          //     Material(
          //       elevation: 3,
          //       borderRadius: BorderRadius.circular(10),
          //       child: Container(
          //         width: MediaQuery.of(context).size.width * .25,
          //         height: MediaQuery.of(context).size.width * .25,
          //         decoration: BoxDecoration(
          //           color: Color.fromRGBO(21, 43, 81, 1),
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Center(
          //             child: Text(
          //               "Buy",
          //               style: TextStyle(color: Colors.white),
          //             )),
          //       ),
          //     ),
          //     SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
          //     Material(
          //       elevation: 3,
          //       borderRadius: BorderRadius.circular(10),
          //       child: Container(
          //         width: MediaQuery.of(context).size.width * .25,
          //         height: MediaQuery.of(context).size.width * .25,
          //         decoration: BoxDecoration(
          //           color: Color.fromRGBO(21, 43, 81, 1),
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Center(
          //             child: Text(
          //               "Buy",
          //               style: TextStyle(color: Colors.white),
          //             )),
          //       ),
          //     ),
          //     SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
          //     Material(
          //       elevation: 3,
          //       borderRadius: BorderRadius.circular(10),
          //       child: Container(
          //         width: MediaQuery.of(context).size.width * .25,
          //         height: MediaQuery.of(context).size.width * .25,
          //         decoration: BoxDecoration(
          //           color: Color.fromRGBO(21, 43, 81, 1),
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Center(
          //             child: Text(
          //               "Buy",
          //               style: TextStyle(color: Colors.white),
          //             )),
          //       ),
          //     ),
          //     SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
          //     Material(
          //       elevation: 3,
          //       borderRadius: BorderRadius.circular(10),
          //       child: Container(
          //         width: MediaQuery.of(context).size.width * .25,
          //         height: MediaQuery.of(context).size.width * .25,
          //         decoration: BoxDecoration(
          //           color: Color.fromRGBO(21, 43, 81, 1),
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Center(
          //             child: Text(
          //               "Buy",
          //               style: TextStyle(color: Colors.white),
          //             )),
          //       ),
          //     ),
          //     SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
          //     Material(
          //       elevation: 3,
          //       borderRadius: BorderRadius.circular(10),
          //       child: Container(
          //         width: MediaQuery.of(context).size.width * .25,
          //         height: MediaQuery.of(context).size.width * .25,
          //         decoration: BoxDecoration(
          //           color: Color.fromRGBO(21, 43, 81, 1),
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Center(
          //             child: Text(
          //               "Buy",
          //               style: TextStyle(color: Colors.white),
          //             )),
          //       ),
          //     ),
          //     SizedBox(
          //       width: width * 0.1,
          //     ),
          //   ],
          // ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Tablet layout - horizontal
                return Padding(
                  padding: const EdgeInsets.only(left: 80, right: 80,top: 20),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: MediaQuery.of(context).size.width * 0.02,
                    runSpacing: MediaQuery.of(context).size.width * 0.02,
                    children: List.generate(
                      5,
                      (index) => SizedBox(
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: colorc[index],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:
                            Column(
                              children: [
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Material(
                                      elevation: 5,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: colors[
                                          index], // Access color based on index
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            icons[
                                            index], // Access icon based on index
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Text(
                                      texts[
                                      index], // Access text based on index
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Text(
                                      titles[index],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Phone layout - vertical
                return Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: MediaQuery.of(context).size.width * 0.02,
                        runSpacing: MediaQuery.of(context).size.width * 0.02,
                        children: List.generate(
                          5, // Assuming you have 6 items
                          (index) {
                            return Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 95,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: colorc[index],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Material(
                                          elevation: 5,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              color: colors[
                                                  index], // Access color based on index
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                icons[
                                                    index], // Access icon based on index
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Text(
                                          texts[
                                              index], // Access text based on index
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Text(
                                          titles[index],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .37,
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.03,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    )),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20,),
                                  Text(
                                    "Due rent for the month",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                             SizedBox(height: 25,),
                              Text(
                                "1200",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * .37,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                        Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      )),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20,),
                                    Text(
                                      "Total collected amount",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 9,fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 25,),
                                Text(
                                  "2500",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .37,
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                      Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.03,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    )),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20,),
                                  Text(
                                    "Total past due amount",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 25,),
                              Text(
                                "1000",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
              ),


              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * .37,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                        Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      )),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20,),
                                    Text(
                                      "Last month collected amount",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 9,fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 25,),
                                Text(
                                  "1800",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    height: MediaQuery.of(context).size.height * .2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Container(
                        //   height:  MediaQuery.of(context).size.height * 0.03,
                        //
                        //   decoration: BoxDecoration(
                        //       color: Color.fromRGBO(21, 43, 81, 1),
                        //       borderRadius: BorderRadius.only(
                        //         topLeft: Radius.circular(10),
                        //         topRight:Radius.circular(10),
                        //       )
                        //   ),
                        // ),
                      ],
                    )),
              ),
              SizedBox(
                width: width * 0.1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
