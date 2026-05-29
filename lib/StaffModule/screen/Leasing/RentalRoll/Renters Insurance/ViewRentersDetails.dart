import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Renters_Insurnce/Edit_insurnce.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../../model/LeaseSummary.dart';
import '../../../../repository/lease.dart';

import '../../../../repository/lease_rental_insurance_repo.dart';
import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';

class ViewRentersDetails extends StatefulWidget {
  final String tenantid;
  final String leaseId;
  final String renters_insurance_id;
  const ViewRentersDetails(
      {required this.tenantid,
      required this.leaseId,
      required this.renters_insurance_id});

  @override
  State<ViewRentersDetails> createState() => _ViewRentersDetailsState();
}

class _ViewRentersDetailsState extends State<ViewRentersDetails> {
  late Future<RentersEdit> _futureRentersDetails;
  @override
  void initState() {
    super.initState();

    _futureRentersDetails = RentersInsuranceService()
        .fetchRentersDetails(widget.renters_insurance_id);
  }

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0),
            child: titleBar(
              width: MediaQuery.of(context).size.width * .91,
              title: "Renter's Insurance Details",
            ),
          ),
          Expanded(
            child: Center(
              child: FutureBuilder<RentersEdit>(
                future: _futureRentersDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 50.0,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text("No data found"));
                  } else {
                    // Data is available
                    RentersEdit rentersData = snapshot.data!;
                    return ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 25, left: 25, top: 10),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 22, right: 22, top: 10, bottom: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "Insurance Information",
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              // fontSize: 18
                                              fontSize: 21),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Divider(
                                      color: blueColor,
                                    ),
                                    //phonenumber
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Table(
                                      children: [
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              'Insurance Company',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${rentersData.insuranceCompany?.isNotEmpty == true ? rentersData.insuranceCompany : "N/A"}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              'Company Phone Number',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              rentersData.insuranceCompanyPhoneNumber !=
                                                          null &&
                                                      rentersData
                                                          .insuranceCompanyPhoneNumber!
                                                          .isNotEmpty
                                                  ? formatPhoneNumber(rentersData
                                                      .insuranceCompanyPhoneNumber!)
                                                  : "N/A",
                                              // '${(tenantsummery.first.tenantPhoneNumber ?? '').isEmpty ? 'N/A' : tenantsummery.first.tenantPhoneNumber}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              'Policy ID',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              rentersData.policyId != null &&
                                                      rentersData
                                                          .policyId!.isNotEmpty
                                                  ? rentersData.policyId!
                                                  : "N/A",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              'Effective Date',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              rentersData.effectiveDate
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? dateProvider.formatCurrentDate(
                                                      '${rentersData?.effectiveDate?.split('T').first}')
                                                  : 'N/A',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              'Expiration Date',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              rentersData.expirationDate
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? dateProvider.formatCurrentDate(
                                                      '${rentersData?.expirationDate?.split('T').first}')
                                                  : 'N/A',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              'Liability Coverage',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              (rentersData.liabilityCoverage !=
                                                          null &&
                                                      rentersData
                                                              .liabilityCoverage! >
                                                          0)
                                                  ? '\$${rentersData.liabilityCoverage}'
                                                  : 'N/A',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                      ],
                                    ),
                                    //primary email
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 25, left: 25, top: 10),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 22, right: 22, top: 10, bottom: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "Tenant Details",
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              // fontSize: 18
                                              fontSize: 21),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Divider(
                                      color: blueColor,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    // Table(
                                    //   children: rentersData.tenantDetails != null && rentersData.tenantDetails!.isNotEmpty
                                    //       ? rentersData.tenantDetails!.map((tenant) {
                                    //     return TableRow(
                                    //       children: [
                                    //         TableCell(
                                    //           child: Padding(
                                    //             padding: EdgeInsets.all(12.0),
                                    //             child: Text(
                                    //               '${tenant.tenantFirstName ?? '-'} ${tenant.tenantLastName ?? '-'}',
                                    //               style: TextStyle(
                                    //                 color: Color(0xFF8A95A8),
                                    //                 fontWeight: FontWeight.bold,
                                    //                 fontSize: 16,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //         TableCell(
                                    //           child: Padding(
                                    //             padding: const EdgeInsets.only(top: 12),
                                    //             child: Text(
                                    //               tenant.tenantEmail ?? '-',
                                    //               style: TextStyle(
                                    //                 fontSize: 15,
                                    //                 fontWeight: FontWeight.bold,
                                    //                 color: blueColor,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     );
                                    //   }).toList()
                                    //       : [
                                    //     TableRow(
                                    //       children: [
                                    //         TableCell(
                                    //           child: Padding(
                                    //             padding: EdgeInsets.all(12.0),
                                    //             child: Text(
                                    //               'N/A',
                                    //               style: TextStyle(
                                    //                 color: Color(0xFF8A95A8),
                                    //                 fontWeight: FontWeight.bold,
                                    //                 fontSize: 16,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //         TableCell(
                                    //           child: Padding(
                                    //             padding: const EdgeInsets.only(top: 12),
                                    //             child: Text(
                                    //               'N/A',
                                    //               style: TextStyle(
                                    //                 fontSize: 15,
                                    //                 fontWeight: FontWeight.bold,
                                    //                 color: blueColor,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ],
                                    // ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: rentersData.tenantDetails !=
                                                  null &&
                                              rentersData
                                                  .tenantDetails!.isNotEmpty
                                          ? rentersData.tenantDetails!
                                              .map((tenant) {
                                              return Container(
                                                width: double.infinity,
                                                margin: EdgeInsets.symmetric(
                                                    vertical:
                                                        8.0), // Space between boxes
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .white, // Background color
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Color(
                                                          0xFF8A95A8)), // Rounded corners
                                                  // boxShadow: [
                                                  //   BoxShadow(
                                                  //     color: Colors.grey
                                                  //         .withOpacity(0.2),
                                                  //     spreadRadius: 2,
                                                  //     blurRadius: 5,
                                                  //   ),
                                                  // ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${tenant.tenantFirstName ?? '-'} ${tenant.tenantLastName ?? '-'}',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Email : ',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '${tenant.tenantEmail ?? ' - '}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: blueColor,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList()
                                          : [
                                              Container(
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  'No Tenants Available',
                                                  style: TextStyle(
                                                    color: Color(0xFF8A95A8),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
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
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                            ),
                            Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Back',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ))),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
