import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/RentalOwnersData.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';
import 'Edit_RentalOwners.dart';
import '../../../widgets/custom_drawer.dart';

class ResponsiveRentalSummary extends StatefulWidget {
  RentalOwnerData? rentalowners;
  String rentalOwnersid;
  ResponsiveRentalSummary(
      {super.key, required this.rentalOwnersid, this.rentalowners});
  @override
  State<ResponsiveRentalSummary> createState() =>
      _ResponsiveRentalSummaryState();
}

class _ResponsiveRentalSummaryState extends State<ResponsiveRentalSummary> {
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();

  }
  ConnectivityResult? _connectivityResult ;
  void checkInternet()async{

    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      print(connectiondata);
      _connectivityResult = connectiondata;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _connectivityResult !=ConnectivityResult.none ?
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return RentalownersSummeryForTablet(
              rentalowners: widget.rentalowners,
              rentalOwnersid: widget.rentalOwnersid,
            );
          } else {
            return RentalownersSummeryForMobile(
              rentalowners: widget.rentalowners,
              rentalOwnersid: widget.rentalOwnersid,
            );
          }
        },
      ): SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/no_internet.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            Text(
              'No Internet',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Check your internet connection',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class RentalownersSummeryForMobile extends StatefulWidget {
  RentalOwnerData? rentalowners;
  String rentalOwnersid;
  RentalownersSummeryForMobile(
      {super.key, required this.rentalOwnersid, this.rentalowners});
  @override
  State<RentalownersSummeryForMobile> createState() =>
      _RentalownersSummeryForMobileState();
}

class _RentalownersSummeryForMobileState
    extends State<RentalownersSummeryForMobile> {
  ConnectivityResult? _connectivityResult ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
  }
  void checkInternet()async{

    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });

  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "RentalOwner",
        dropdown: true,
      ),
      body:
      _connectivityResult !=ConnectivityResult.none ?
      Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new_sharp,
                      size: 30,
                    )),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.rentalowners?.rentalOwnername}',
                      style: TextStyle(
                          color: blueColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'RentalOwner',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8A95A8)),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.065),
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Edit_rentalowners(
                                    rentalOwner: widget.rentalowners!)));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * .045,
                          width: MediaQuery.of(context).size.width * .15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color:blueColor,
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width * .034),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: const EdgeInsets.only(top: 6, left: 10),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(bottom: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color:blueColor,
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: const Text(
                    "Summery",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
            ),
            //Personal information
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color:blueColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 15, bottom: 30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                  color:blueColor,
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 18
                                  fontSize: 20),
                            ),
                          ],
                        ),
                        // Divider(
                        //
                        //   color: blueColor,
                        // ),
                        Row(
                          children: [
                            Container(
                              width:
                                  210, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        Table(
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Name : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.rentalOwnername ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnername}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: grey,
                                  ),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Company Name : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.rentalOwnerCompanyName ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerCompanyName}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: grey,
                                  ),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Street Address : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.streetAddress ?? '').isEmpty ? 'N/A' : widget.rentalowners?.streetAddress}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'City : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.city ?? '').isEmpty ? 'N/A' : widget.rentalowners?.city}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'State : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.state ?? '').isEmpty ? 'N/A' : widget.rentalowners?.state}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Country : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.country ?? '').isEmpty ? 'N/A' : widget.rentalowners?.country}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Zip : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.postalCode ?? '').isEmpty ? 'N/A' : widget.rentalowners?.postalCode}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Contact Information",
                              style: TextStyle(
                                  color:blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  210, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        Table(
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Phone Number : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.rentalOwnerPhoneNumber ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerPhoneNumber}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Home Number : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.rentalOwnerHomeNumber ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerHomeNumber}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Business Number : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.rentalOwnerBusinessNumber ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerBusinessNumber}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Email : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.rentalOwnerPrimaryEmail ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerPrimaryEmail}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Alternative Email : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.rentalOwnerAlternateEmail ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerAlternateEmail}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Country : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.country ?? '').isEmpty ? 'N/A' : widget.rentalowners?.country}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Zip : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.postalCode ?? '').isEmpty ? 'N/A' : widget.rentalowners?.postalCode}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Management Agreement",
                              style: TextStyle(
                                color:blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  250, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Table(
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Start Date : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  dateProvider.formatCurrentDate('${widget.rentalowners?.startDate}').isEmpty ? 'N/A' : dateProvider.formatCurrentDate('${widget.rentalowners?.startDate}'),

                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'End Date : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                           dateProvider.formatCurrentDate('${widget.rentalowners?.endDate}').isEmpty ? 'N/A' : dateProvider.formatCurrentDate('${widget.rentalowners?.endDate}'),
    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "1099-NEC Tax Filling Information ",
                              style: TextStyle(
                                color:blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  280, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Table(
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Tax Identify Type : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.textIdentityType ?? '').isEmpty ? 'N/A' : widget.rentalowners?.textIdentityType}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Tax PayerId : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.rentalowners?.textIdentityType ?? '').isEmpty ? 'N/A' : widget.rentalowners?.textIdentityType}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ):SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/no_internet.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            Text(
              'No Internet',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Check your internet connection',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class RentalownersSummeryForTablet extends StatefulWidget {
  RentalOwnerData? rentalowners;
  String rentalOwnersid;
  RentalownersSummeryForTablet(
      {super.key, required this.rentalOwnersid, this.rentalowners});
  @override
  State<RentalownersSummeryForTablet> createState() =>
      _RentalownersSummeryForTabletState();
}

class _RentalownersSummeryForTabletState
    extends State<RentalownersSummeryForTablet> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "RentalOwner",
        dropdown: true,
      ),
      body: Center(
        child: FutureBuilder<List<RentalOwnerData>>(
          future: RentalOwnerService()
              .fetchRentalOwnerssummery(widget.rentalOwnersid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Center(
                    child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 40.0,
                )),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<RentalOwnerData> rentalownersummery = snapshot.data ?? [];
              print(snapshot.data!.length);
              //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
              return ListView(
                scrollDirection: Axis.vertical,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${rentalownersummery.first.rentalOwnername}',
                            style: TextStyle(
                                fontSize: 18,
                                color: blueColor,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'RentalOwner',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8A95A8)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.065),
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Edit_rentalowners(
                                          rentalOwner:
                                              rentalownersummery.first)));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color:blueColor,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 21),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color:blueColor,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Back",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 21),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.only(top: 8, left: 10),
                        width: MediaQuery.of(context).size.width * .91,
                        margin: const EdgeInsets.only(bottom: 6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color:blueColor,
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Summery",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                  //Personal information
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: screenWidth * 0.45,

                            // width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:blueColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 25, top: 20, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Row(
                                    children: [
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Personal Information",
                                        style: TextStyle(
                                            color:
                                                blueColor,
                                            fontWeight: FontWeight.bold,
                                            // fontSize: 18
                                            fontSize: 21),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Divider(
                                    color: blueColor,
                                  ),
                                  //phonenumber
                                  Table(
                                    children: [
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Name',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(rentalownersummery.first.rentalOwnername ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnername}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Company Name',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(rentalownersummery.first.rentalOwnerCompanyName ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerCompanyName}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Street Address',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(rentalownersummery.first.streetAddress ?? '').isEmpty ? 'N/A' : rentalownersummery.first.streetAddress}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'City',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(rentalownersummery.first.city ?? '').isEmpty ? 'N/A' : rentalownersummery.first.city}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'State',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(rentalownersummery.first.state ?? '').isEmpty ? 'N/A' : rentalownersummery.first.state}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Country',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(rentalownersummery.first.country ?? '').isEmpty ? 'N/A' : rentalownersummery.first.country}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Zip',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(rentalownersummery.first.postalCode ?? '').isEmpty ? 'N/A' : rentalownersummery.first.postalCode}',
                                            style: TextStyle(
                                                fontSize: 18,
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

                      //Personal information
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: screenWidth * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color:blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 25, top: 20, bottom: 30),
                                child: Column(
                                  children: [
                                     Row(
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "Contact Information",
                                          style: TextStyle(
                                              color:
                                                  blueColor,
                                              fontWeight: FontWeight.bold,
                                              // fontSize: 18
                                              fontSize: 21),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Divider(
                                      color: blueColor,
                                    ),
                                    //first name
                                    Table(
                                      children: [
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Phone Number',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(rentalownersummery.first.rentalOwnerPhoneNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerPhoneNumber}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Home Number',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(rentalownersummery.first.rentalOwnerHomeNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerHomeNumber}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Business Number',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(rentalownersummery.first.rentalOwnerBusinessNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerBusinessNumber}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Email',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(rentalownersummery.first.rentalOwnerPrimaryEmail ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerPrimaryEmail}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Alternative Email',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(rentalownersummery.first.rentalOwnerAlternateEmail ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerAlternateEmail}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: screenWidth * 0.45,
                            // width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:blueColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 25, top: 20, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Row(
                                    children: [
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Management Agreement",
                                        style: TextStyle(
                                            color:
                                                blueColor,
                                            fontWeight: FontWeight.bold,
                                            // fontSize: 18
                                            fontSize: 21),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Divider(
                                    color: blueColor,
                                  ),
                                  //phonenumber
                                  Table(
                                    children: [
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Start Date',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            formatDate(
                                                '${(rentalownersummery.first.startDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.startDate}'),
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'End Date',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            formatDate3(
                                                '${(rentalownersummery.first.endDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.endDate}'),
                                            style: TextStyle(
                                                fontSize: 18,
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
                      //Personal information
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: screenWidth * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color:blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 10, top: 20, bottom: 30),
                                child: Column(
                                  children: [
                                     Row(
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "1099-NEC Tax Filling Information",
                                          style: TextStyle(
                                              color:
                                                  blueColor,
                                              fontWeight: FontWeight.bold,
                                              // fontSize: 18
                                              fontSize: 21),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Divider(
                                      color: blueColor,
                                    ),
                                    //first name
                                    Table(
                                      children: [
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Tax Identify Type',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(rentalownersummery.first.textIdentityType ?? '').isEmpty ? 'N/A' : rentalownersummery.first.textIdentityType}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Tax PayerId',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(rentalownersummery.first.texpayerId ?? '').isEmpty ? 'N/A' : rentalownersummery.first.texpayerId}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
