import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/tenants.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../model/rentalOwner.dart';

import '../../../model/tenants.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';

class Tenant_summary extends StatefulWidget {
  String tenantId;
  Tenant_summary({super.key, required this.tenantId});
  @override
  State<Tenant_summary> createState() => _Tenant_summaryState();
}

class _Tenant_summaryState extends State<Tenant_summary> {
  final TenantsRepository repo = TenantsRepository();

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
        child: FutureBuilder<List<Tenant>>(
          future: TenantsRepository().fetchTenantsummery(widget.tenantId),
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
              List<Tenant> tenantsummery = snapshot.data ?? [];
              print("tenant${tenantsummery}");
              print("Leangth of the tenant${snapshot.data!.length}");
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
                        children: [
                          Text(
                            '${tenantsummery.first.tenantFirstName }',
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Tenant',
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
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Edit_rentalowners(
                              //             rentalOwner:
                              //                 rentalownersummery.first)));
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
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
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
                              const SizedBox(
                                height: 10,
                              ),
                              //phonenumber
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.tenantFirstName}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //homenumber
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.tenantPhoneNumber}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //office number
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.tenantEmail}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //primary email

                              const SizedBox(
                                height: 12,
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
                  //Personal information
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
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
                              const SizedBox(
                                height: 10,
                              ),
                              //first name
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Birth Date",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  // Text(
                                  //   '${rentalownersummery.isNotEmpty && rentalownersummery.first.rentalOwnerName != null ? rentalownersummery.first.rentalOwnerName : 'N/A'}',
                                  // ),
                                  Text(
                                    '${tenantsummery.first.tenantBirthDate}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //company name
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "TaxPayer Id",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.taxPayerId}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //street address
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Comments",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      '${tenantsummery.first.comments}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //enter city
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
//Emergency Contact
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
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
                                    "Emergency Contact",
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
                              const SizedBox(
                                height: 10,
                              ),
                              //first name
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Contact Name",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  // Text(
                                  //   '${rentalownersummery.isNotEmpty && rentalownersummery.first.rentalOwnerName != null ? rentalownersummery.first.rentalOwnerName : 'N/A'}',
                                  // ),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.name}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //company name
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Relation With Tenants",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.relation}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //street address
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Emergency Email",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.email}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Emergency Phone",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.phoneNumber}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),

                              //enter city
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
//Emergency Contact
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
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
                              left: 10, right: 10, top: 15, bottom: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Lease Details",
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
                              SizedBox(
                                height: 10,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Table(
                                  defaultColumnWidth: IntrinsicColumnWidth(),
                                  border: TableBorder.all(color: Colors.black),
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(),
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Status',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Start - End',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Property',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Type',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Rent',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal: BorderSide.none),
                                      ),
                                      children: [
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                'asdjfakds',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: Center(
                                                child: Text(
                                              'asdfjhk',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: Center(
                                                child: Text(
                                              'adsfjhaksd',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: Center(
                                                child: Text(
                                              'skdfjha',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: Center(
                                                child: Text(
                                              'adsfkjha',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              );
            }
          },
        ),
      ),
      // FutureBuilder<RentalOwnerSummey>(
      //   future: RentalOwnerService().fetchRentalOwnerSummary(rentalOwnerId),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return CircularProgressIndicator();
      //     } else if (snapshot.hasError) {
      //       return Text('Error: ${snapshot.error}');
      //     } else if (!snapshot.hasData || snapshot.data == null) {
      //       return Text('No data available');
      //     } else {
      //       RentalOwnerSummey rentalOwner = snapshot.data!;
      //       return ListView(
      //         children: [
      //           ListTile(
      //             title: Text(rentalOwner.rentalOwnerName ?? 'No Name'),
      //             subtitle: Text(rentalOwner.rentalOwnerPrimaryEmail ?? 'No Email'),
      //             trailing: Text(rentalOwner.rentalOwnerPhoneNumber ?? 'No Phone'),
      //           ),
      //           // Add more ListTile widgets or other UI elements as needed
      //         ],
      //       );
      //     }
      //   },
      // ),
    );
  }
}
