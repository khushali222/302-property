import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../constant/constant.dart';
import '../../../model/LeaseLedgerModel.dart';
import '../../../model/LeaseSummary.dart';
import '../../../repository/lease.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/titleBar.dart';
import 'addcard/AddCard.dart';

class RecurringPayment extends StatefulWidget {
  String leaseId;
  RecurringPayment({super.key, required this.leaseId});

  @override
  State<RecurringPayment> createState() => _RecurringPaymentState();
}

class _RecurringPaymentState extends State<RecurringPayment> {
  late Future<LeaseLedger?> _leaseLedgerFuture;
  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    // TODO: implement initState

    _leaseLedgerFuture = LeaseRepository().fetchLeaseLedger(widget.leaseId);
    for (int i = 0; i < _tenants.length; i++) {
      _controllers.add([TextEditingController()]); // Start with one controller per tenant
    }
    super.initState();
  }

  ConnectivityResult? _connectivityResult;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }



  void addRow(int tenantIndex) {
    setState(() {

      _controllers[tenantIndex].add(TextEditingController());
    });
  }

  void deleteTextField(int tenantIndex, int textFieldIndex) {
    setState(() {
      _controllers[tenantIndex].removeAt(textFieldIndex);
    });
  }

  List<Tenant> _tenants = [
    Tenant(
      name: 'John Doe',
    ),
    Tenant(
      name: 'Eric Smith',
    ),
    Tenant(
      name: 'Bob Smith',
    ),
  ];

  List<List<TextEditingController>> _controllers = [];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Rent Roll",
        dropdown: true,
      ),
      body: FutureBuilder<LeaseLedger?>(
        future: _leaseLedgerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
            //   SpinKitFadingCircle(
            //   color: blueColor,
            //   size: 40.0,
            // );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final leaseLedger = snapshot.data!;
            final tenants =
                leaseLedger.data?.map((item) => item.tenantData).toList() ?? [];

            //final data = leaseLedger.data!.toList();
            return
              ListView.builder(
              itemCount: _tenants.length,
              itemBuilder: (context, tenantIndex) {
                return Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            _tenants[tenantIndex].name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: blueColor),
                          ),
                          // Spacer(),
                          // Align(
                          //                             alignment: Alignment.centerRight,
                          //                             child: IconButton(
                          //                               icon: Icon(Icons.close),
                          //                               onPressed: () {
                          //                                 deleteRow(index);
                          //                               },
                          //                             ),
                          //                           ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      for (int textFieldIndex = 0; textFieldIndex < _controllers[tenantIndex].length; textFieldIndex++) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              deleteTextField(tenantIndex, textFieldIndex);
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 15, right: 15),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  hintText: 'Enter Amount',
                                  controller: _controllers[tenantIndex][textFieldIndex],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 15, right: 15),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  hintText: 'Enter Amount',
                                  controller: _controllers[tenantIndex][textFieldIndex],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          addRow(tenantIndex);
                          print("hello");
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Icon(
                              Icons.add,
                              color: Colors.green,
                              size: 30,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              "Add Row",
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 16
                                          : 17),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: (){
                            for (int tenantIndex = 0; tenantIndex < _tenants.length; tenantIndex++) {
                              List<String> values = [];
                              for (var controller in _controllers[tenantIndex]) {
                                values.add(controller.text);
                              }
                              print('tenant ${_tenants[tenantIndex].name}: $values');

                            }
                          },
                          child: Text("Save",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
                    ],
                  ),
                );
              },
            );
            //   ListView(
            //   scrollDirection: Axis.vertical,
            //   children: [
            //     SizedBox(
            //       height: 25,
            //     ),
            //     titleBar(
            //       width: MediaQuery.of(context).size.width * .88,
            //       title: 'Rent Roll',
            //     ),
            //     SizedBox(
            //       height: 25,
            //     ),
            //     Padding(
            //       padding: EdgeInsets.only(
            //           left: MediaQuery.of(context).size.width < 500 ? 25 : 55,
            //           right: MediaQuery.of(context).size.width < 500 ? 25 : 55),
            //       child: Material(
            //         elevation: 6,
            //         borderRadius: BorderRadius.circular(10),
            //         child: Container(
            //           // height: MediaQuery.of(context).size.height * .43,
            //           width: MediaQuery.of(context).size.width * .99,
            //           decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(10),
            //               border: Border.all(
            //                 color: blueColor,
            //               )),
            //           child: Column(
            //             children: [
            //               SizedBox(
            //                 height: 10,
            //               ),
            //               Row(
            //                 children: [
            //                   SizedBox(
            //                     width: 15,
            //                   ),
            //                   Text(
            //                     "Configure Recurring Payment",
            //                     style: TextStyle(
            //                         fontWeight: FontWeight.bold,
            //                         color: blueColor,
            //                         fontSize:
            //                             MediaQuery.of(context).size.width < 500
            //                                 ? 19
            //                                 : 22),
            //                   ),
            //                 ],
            //               ),
            //               SizedBox(
            //                 height: 20,
            //               ),
            //               Row(
            //                 children: [
            //                   SizedBox(
            //                     width: 15,
            //                   ),
            //                   Text(
            //                     "Total  Rent Amount : ",
            //                     style: TextStyle(
            //                         color: blueColor,
            //                         // fontWeight: FontWeight.bold,
            //                         fontSize:
            //                             MediaQuery.of(context).size.width < 500
            //                                 ? 16
            //                                 : 18),
            //                   ),
            //                   SizedBox(
            //                     width: 10,
            //                   ),
            //                   Text(
            //                     "\$ ${leaseLedger.data?.first.totalAmount?.toStringAsFixed(2)}",
            //                     style: TextStyle(
            //                         color: blueColor,
            //                         // fontWeight: FontWeight.bold,
            //                         fontSize:
            //                             MediaQuery.of(context).size.width < 500
            //                                 ? 16
            //                                 : 18),
            //                   ),
            //                 ],
            //               ),
            //               SizedBox(
            //                 height: 5,
            //               ),
            //               Row(
            //                 children: [
            //                   SizedBox(
            //                     width: 15,
            //                   ),
            //                   Text(
            //                     "Rmaining Balance   : ",
            //                     style: TextStyle(
            //                         color: blueColor,
            //                         // fontWeight: FontWeight.bold,
            //                         fontSize:
            //                             MediaQuery.of(context).size.width < 500
            //                                 ? 16
            //                                 : 18),
            //                   ),
            //                   SizedBox(
            //                     width: 10,
            //                   ),
            //                 ],
            //               ),
            //               SizedBox(
            //                 height: 10,
            //               ),
            //               // ...rows.asMap().entries.map((entry) {
            //               //   int index = entry.key;
            //               //   Map<String, dynamic> row = entry.value;
            //               //   return Padding(
            //               //     padding: const EdgeInsets.all(10.0),
            //               //     child: Container(
            //               //       decoration: BoxDecoration(
            //               //         color: Colors.white,
            //               //         borderRadius: BorderRadius.circular(15),
            //               //       ),
            //               //       child: Column(
            //               //         crossAxisAlignment:
            //               //             CrossAxisAlignment.stretch,
            //               //         children: [
            //               //           Align(
            //               //             alignment: Alignment.centerRight,
            //               //             child: IconButton(
            //               //               icon: Icon(Icons.close),
            //               //               onPressed: () {
            //               //                 deleteRow(index);
            //               //               },
            //               //             ),
            //               //           ),
            //               //           Row(
            //               //             children: [
            //               //               SizedBox(
            //               //                 width: 10,
            //               //               ),
            //               //               Text(
            //               //                 "BoB Smith",
            //               //                 style: TextStyle(
            //               //                     fontWeight: FontWeight.bold,
            //               //                     fontSize: 15,
            //               //                     color: blueColor),
            //               //               ),
            //               //             ],
            //               //           ),
            //               //           SizedBox(
            //               //             height: 5,
            //               //           ),
            //               //           Row(
            //               //             children: [
            //               //               Expanded(
            //               //                 child: Padding(
            //               //                   padding: const EdgeInsets.only(
            //               //                     left: 8,
            //               //                     right: 8,
            //               //                   ),
            //               //                   child: CustomTextField(
            //               //                     validator: (value) {
            //               //                       if (value == null ||
            //               //                           value.isEmpty) {
            //               //                         return 'Please enter amount';
            //               //                       }
            //               //                       return null;
            //               //                     },
            //               //                     amount_check: !rows[index]
            //               //                             ["newfield"]
            //               //                         ? true
            //               //                         : null,
            //               //                     max_amount: rows[index]
            //               //                             ["charge_amount"]
            //               //                         .toString(),
            //               //                     error_mess:
            //               //                         "Amount must be less than or equal to balance",
            //               //                     keyboardType:
            //               //                         TextInputType.number,
            //               //                     hintText: 'Enter Amount',
            //               //                     controller: controllers[index],
            //               //                     // onChanged: (value) =>
            //               //                     //     updateAmount(index, value),
            //               //                   ),
            //               //                 ),
            //               //               ),
            //               //               Expanded(
            //               //                 child: Padding(
            //               //                   padding: const EdgeInsets.only(
            //               //                     left: 8,
            //               //                     right: 8,
            //               //                   ),
            //               //                   child: CustomTextField(
            //               //                     validator: (value) {
            //               //                       if (value == null ||
            //               //                           value.isEmpty) {
            //               //                         return 'Please enter amount';
            //               //                       }
            //               //                       return null;
            //               //                     },
            //               //                     amount_check: !rows[index]
            //               //                             ["newfield"]
            //               //                         ? true
            //               //                         : null,
            //               //                     max_amount: rows[index]
            //               //                             ["charge_amount"]
            //               //                         .toString(),
            //               //                     error_mess:
            //               //                         "Amount must be less than or equal to balance",
            //               //                     keyboardType:
            //               //                         TextInputType.number,
            //               //                     hintText: 'Enter Amount',
            //               //                     controller: controllers[index],
            //               //                     // onChanged: (value) =>
            //               //                     //     updateAmount(index, value),
            //               //                   ),
            //               //                 ),
            //               //               ),
            //               //             ],
            //               //           ),
            //               //         ],
            //               //       ),
            //               //     ),
            //               //   );
            //               // }).toList(),
            //
            //
            //
            //               GestureDetector(
            //                 onTap: () async {
            //                   addRow();
            //                 },
            //                 child: Row(
            //                   children: [
            //                     SizedBox(
            //                       width: 15,
            //                     ),
            //                     Icon(
            //                       Icons.add,
            //                       color: Colors.green,
            //                       size: 30,
            //                     ),
            //                     SizedBox(
            //                       width: 6,
            //                     ),
            //                     Text(
            //                       "Add Row",
            //                       style: TextStyle(
            //                           color: blueColor,
            //                           fontWeight: FontWeight.bold,
            //                           fontSize:
            //                               MediaQuery.of(context).size.width <
            //                                       500
            //                                   ? 16
            //                                   : 17),
            //                     ),
            //                     // GestureDetector(
            //                     //   onTap: () async {
            //                     //     addRow();
            //                     //   },
            //                     //   child: ClipRRect(
            //                     //     borderRadius: BorderRadius.circular(5.0),
            //                     //     child: Container(
            //                     //       height: MediaQuery.of(context).size.width < 500
            //                     //           ? 40
            //                     //           : 50,
            //                     //       // width: MediaQuery.of(context).size.width * .36,
            //                     //       width: MediaQuery.of(context).size.width < 500
            //                     //           ? 90
            //                     //           : 100,
            //                     //       decoration: BoxDecoration(
            //                     //         borderRadius: BorderRadius.circular(5.0),
            //                     //         color: blueColor,
            //                     //         boxShadow: [
            //                     //           BoxShadow(
            //                     //             color: Colors.grey,
            //                     //             offset: Offset(0.0, 1.0), //(x,y)
            //                     //             blurRadius: 6.0,
            //                     //           ),
            //                     //         ],
            //                     //       ),
            //                     //       child: Center(
            //                     //         child: isLoading
            //                     //             ? SpinKitFadingCircle(
            //                     //           color: Colors.white,
            //                     //           size: 25.0,
            //                     //         )
            //                     //             : Text(
            //                     //           "Add Row",
            //                     //           style: TextStyle(
            //                     //               color: Colors.white,
            //                     //               fontWeight: FontWeight.bold,
            //                     //               fontSize: MediaQuery.of(context)
            //                     //                   .size
            //                     //                   .width <
            //                     //                   500
            //                     //                   ? 14
            //                     //                   : 17),
            //                     //         ),
            //                     //       ),
            //                     //     ),
            //                     //   ),
            //                     // ),
            //                   ],
            //                 ),
            //               ),
            //
            //               SizedBox(
            //                 height: 10,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(height: 15),
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.end,
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         GestureDetector(
            //           onTap: () {
            //             Navigator.pop(context);
            //           },
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(5.0),
            //             child: Container(
            //               height: 45,
            //               width: 100,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(5.0),
            //                 color: Colors.white,
            //                 border: Border.all(color: blueColor),
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: Colors.grey,
            //                     offset: Offset(0.0, 1.0), //(x,y)
            //                     blurRadius: 6.0,
            //                   ),
            //                 ],
            //               ),
            //               child: Center(
            //                 child: isLoading
            //                     ? SpinKitFadingCircle(
            //                         color: Colors.white,
            //                         size: 25.0,
            //                       )
            //                     : Text(
            //                         "Cancel",
            //                         style: TextStyle(
            //                             color: blueColor,
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 16),
            //                       ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            //         GestureDetector(
            //           onTap: () async {},
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(5.0),
            //             child: Container(
            //               height: 45,
            //               width: 100,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(5.0),
            //                 color: blueColor,
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: Colors.grey,
            //                     offset: Offset(0.0, 1.0), // (x,y)
            //                     blurRadius: 6.0,
            //                   ),
            //                 ],
            //               ),
            //               child: Center(
            //                 child: isLoading
            //                     ? SpinKitFadingCircle(
            //                         color: Colors.white,
            //                         size: 25.0,
            //                       )
            //                     : Text(
            //                         "Disable",
            //                         style: TextStyle(
            //                           color: Colors.white,
            //                           fontWeight: FontWeight.bold,
            //                           fontSize: 16,
            //                         ),
            //                       ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         SizedBox(
            //           width: MediaQuery.of(context).size.width * 0.03,
            //         ),
            //         GestureDetector(
            //           onTap: () async {},
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(5.0),
            //             child: Container(
            //               height: 45.0,
            //               width: 100,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(5.0),
            //                 color: blueColor,
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: Colors.grey,
            //                     offset: Offset(0.0, 1.0), // (x,y)
            //                     blurRadius: 6.0,
            //                   ),
            //                 ],
            //               ),
            //               child: Center(
            //                 child: isLoading
            //                     ? SpinKitFadingCircle(
            //                         color: Colors.white,
            //                         size: 25.0,
            //                       )
            //                     : Text(
            //                         "Save",
            //                         style: TextStyle(
            //                           color: Colors.white,
            //                           fontWeight: FontWeight.bold,
            //                           fontSize: 16,
            //                         ),
            //                       ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         SizedBox(
            //           width: 25,
            //         ),
            //       ],
            //     ),
            //   ],
            // );
          }
        },
      ),
    );
  }
}

class Tenant {
  String name;
  Tenant({
    required this.name,
  });
}
