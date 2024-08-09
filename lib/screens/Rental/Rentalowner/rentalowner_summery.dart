import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/RentalOwnersData.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';
import 'Edit_RentalOwners.dart';

class ResponsiveRentalSummary extends StatefulWidget {
  String rentalOwnersid;
  ResponsiveRentalSummary({super.key, required this.rentalOwnersid});
  @override
  State<ResponsiveRentalSummary> createState() =>
      _ResponsiveRentalSummaryState();
}

class _ResponsiveRentalSummaryState extends State<ResponsiveRentalSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return RentalownersSummeryForTablet(
              rentalOwnersid: widget.rentalOwnersid,
            );
          } else {
            return RentalownersSummeryForMobile(
              rentalOwnersid: widget.rentalOwnersid,
            );
          }
        },
      ),
    );
  }
}

class RentalownersSummeryForMobile extends StatefulWidget {
  String rentalOwnersid;
  RentalownersSummeryForMobile({super.key, required this.rentalOwnersid});
  @override
  State<RentalownersSummeryForMobile> createState() =>
      _RentalownersSummeryForMobileState();
}

class _RentalownersSummeryForMobileState
    extends State<RentalownersSummeryForMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
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
                                height:
                                    MediaQuery.of(context).size.height * .045,
                                width: MediaQuery.of(context).size.width * .15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: const Color.fromRGBO(21, 43, 81, 1),
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
                                            MediaQuery.of(context).size.width *
                                                .034),
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
                                height:
                                    MediaQuery.of(context).size.height * .045,
                                width: MediaQuery.of(context).size.width * .15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: const Color.fromRGBO(21, 43, 81, 1),
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
                                    "Back",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .034),
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
                          color: const Color.fromRGBO(21, 43, 81, 1),
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
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Personal Information",
                                    style: TextStyle(
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
                              ),
                              Divider(
                                color: blueColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Table(
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.rentalOwnerFirstName ?? '').isEmpty ? '' : rentalownersummery.first.rentalOwnerFirstName} ${(rentalownersummery.first.rentalOwnerLastName ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerLastName}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                        ),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Company Name',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.rentalOwnerCompanyName ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerCompanyName}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                        ),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Street Address',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.streetAddress ?? '').isEmpty ? 'N/A' : rentalownersummery.first.streetAddress}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'City',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.city ?? '').isEmpty ? 'N/A' : rentalownersummery.first.city}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'State',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.state ?? '').isEmpty ? 'N/A' : rentalownersummery.first.state}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Country',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.country ?? '').isEmpty ? 'N/A' : rentalownersummery.first.country}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Zip',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.postalCode ?? '').isEmpty ? 'N/A' : rentalownersummery.first.postalCode}',
                                        style: TextStyle(
                                            fontSize: 15,
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
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Contact Information",
                                    style: TextStyle(
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
                              ),
                              Divider(
                                color: blueColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Table(
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Phone Number',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.rentalOwnerPhoneNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerPhoneNumber}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Home Number',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.rentalOwnerHomeNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerHomeNumber}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Business Number',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.rentalOwnerBusinessNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerBusinessNumber}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'E-mail',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.rentalOwnerPrimaryEmail ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerPrimaryEmail}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Alternative E-mail',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.rentalOwnerAlternateEmail ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerAlternateEmail}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Country',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.country ?? '').isEmpty ? 'N/A' : rentalownersummery.first.country}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Zip',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.postalCode ?? '').isEmpty ? 'N/A' : rentalownersummery.first.postalCode}',
                                        style: TextStyle(
                                            fontSize: 15,
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
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Management Agreement",
                                    style: TextStyle(
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
                              ),
                              Divider(
                                color: blueColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Table(
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Start Date',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                       formatDate3( '${(rentalownersummery.first.startDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.startDate}'),
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'End Date',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        formatDate3('${(rentalownersummery.first.endDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.endDate}'),
                                        style: TextStyle(
                                            fontSize: 15,
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
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "1099-NEC Tax Filling Information ",
                                    style: TextStyle(
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
                              ),
                              Divider(
                                color: blueColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Table(
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Tax Identify Type',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.textIdentityType ?? '').isEmpty ? 'N/A' : rentalownersummery.first.textIdentityType}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Tax PayerId',
                                        style: TextStyle(
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        '${(rentalownersummery.first.textIdentityType ?? '').isEmpty ? 'N/A' : rentalownersummery.first.textIdentityType}',
                                        style: TextStyle(
                                            fontSize: 15,
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
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class RentalownersSummeryForTablet extends StatefulWidget {
  String rentalOwnersid;
  RentalownersSummeryForTablet({super.key, required this.rentalOwnersid});
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
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
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
                                  color: const Color.fromRGBO(21, 43, 81, 1),
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
                                  color: const Color.fromRGBO(21, 43, 81, 1),
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
                          color: const Color.fromRGBO(21, 43, 81, 1),
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
                                  color: const Color.fromRGBO(21, 43, 81, 1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 25, top: 20, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Personal Information",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1),
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
                                    color: const Color.fromRGBO(21, 43, 81, 1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 25, top: 20, bottom: 30),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "Contact Information",
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
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
                                  color: const Color.fromRGBO(21, 43, 81, 1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 25, top: 20, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Management Agreement",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1),
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
                                            formatDate3('${(rentalownersummery.first.startDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.startDate}'),
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
                                            formatDate3('${(rentalownersummery.first.endDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.endDate}'),
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
                                    color: const Color.fromRGBO(21, 43, 81, 1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 10, top: 20, bottom: 30),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "1099-NEC Tax Filling Information",
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
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
