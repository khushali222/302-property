import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';
import 'Edit_RentalOwners.dart';

class Rentalowners_summery extends StatefulWidget {
  String rentalOwnersid;
  Rentalowners_summery({super.key, required this.rentalOwnersid});
  @override
  State<Rentalowners_summery> createState() => _Rentalowners_summeryState();
}

class _Rentalowners_summeryState extends State<Rentalowners_summery> {
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
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  FaIcon(
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
        child: FutureBuilder<List<RentalOwner>>(
          future: RentalOwnerService()
              .fetchRentalOwnerssummery(widget.rentalOwnersid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Center(
                    child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 40.0,
                )),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<RentalOwner> rentalownersummery = snapshot.data ?? [];
              print(snapshot.data!.length);
              //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
              return ListView(
                scrollDirection: Axis.vertical,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      Column(
                        children: [
                          Text(
                            '${rentalownersummery.first.rentalOwnerName}',
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'RentalOwner',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8A95A8)),
                          ),
                        ],
                      ),
                      Spacer(),
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
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                  boxShadow: [
                                    BoxShadow(
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
                          SizedBox(
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
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                  boxShadow: [
                                    BoxShadow(
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
                      SizedBox(
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
                        padding: EdgeInsets.only(top: 8, left: 10),
                        width: MediaQuery.of(context).size.width * .91,
                        margin: const EdgeInsets.only(bottom: 6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Color.fromRGBO(21, 43, 81, 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: Text(
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
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
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
                                    "Personal Information",
                                    style: TextStyle(
                                        color: Color.fromRGBO(21, 43, 81, 1),
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
                              //first name
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  // Text(
                                  //   '${rentalownersummery.isNotEmpty && rentalownersummery.first.rentalOwnerName != null ? rentalownersummery.first.rentalOwnerName : 'N/A'}',
                                  // ),
                                   Text('${rentalownersummery.first.rentalOwnerName}',style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //company name
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Company Name",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),

                                  Text('${rentalownersummery.first.rentalOwnerCompanyName}',style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //street address
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Street Address",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.streetAddress}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //enter city
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "City",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.city}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),

                              SizedBox(
                                height: 12,
                              ),
                              //emter state
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "State",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.state}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //enter country
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Country",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.country}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //postal code
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Zip Code",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.postalCode}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
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
                  //contact information
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
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
                                        color: Color.fromRGBO(21, 43, 81, 1),
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
                              //phonenumber
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.rentalOwnerPhoneNumber}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //homenumber
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Home Number",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.rentalOwnerHomeNumber}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //office number
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Business Number",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.rentalOwnerBusinessNumber}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //primary email
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "E-mail",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.rentalOwnerPrimaryEmail}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //alternative email
                              Row(
                                children: [
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "Alternative E-mail",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.rentalOwnerAlternateEmail}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
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
                  //management agreement
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
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
                                    "Management Agreement ",
                                    style: TextStyle(
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //start date
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Start Date",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.startDate}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //enddate
                              Row(
                                children: [
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "End Date",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.endDate}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
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
                  //tax payer information
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
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
                                    "1099-NEC Tax Filling Information ",
                                    style: TextStyle(
                                        color: Color.fromRGBO(21, 43, 81, 1),
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
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Tax Identify Type",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.textIdentityType}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "Tax PayerId",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 2),
                                  Text(
                                    '${rentalownersummery.first.taxpayerId}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
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
