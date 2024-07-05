import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/addApplicant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../widgets/drawer_tiles.dart';

class Applicants_table extends StatefulWidget {
  const Applicants_table({super.key});

  @override
  State<Applicants_table> createState() => _Applicants_tableState();
}

class _Applicants_tableState extends State<Applicants_table> {
  Widget build(BuildContext context) {
    return Scaffold(
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
                  selectedSubtopic: "Applicants"),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Applicants"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Applicants"),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          //add propertytype
          Padding(
            padding: const EdgeInsets.only(left: 13, right: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    // if (rentalCount < propertyCountLimit) {
                    //   final result = await Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //           builder: (context) => AddTenant()));
                    //   if (result == true) {
                    //     setState(() {
                    //       futureTenants = TenantsRepository().fetchTenants();
                    //       //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                    //     });
                    //   }
                    // } else {
                    //   _showAlertforLimit(context);
                    // }
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddApplicant()));
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width < 500)
                        ? 40
                        : MediaQuery.of(context).size.width * 0.065,
                    // height:  MediaQuery.of(context).size.width * 0.07,
                    // height:  40,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add Applicant",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.034,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width < 500) SizedBox(width: 6),
                if (MediaQuery.of(context).size.width > 500)
                  SizedBox(width: 22),
              ],
            ),
          ),
          SizedBox(height: 10),
          //propertytype
          // Padding(
          //   padding: const EdgeInsets.all(5.0),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(5.0),
          //     child: Container(
          //       height: (MediaQuery.of(context).size.width < 500) ? 50 : 60,
          //       padding: EdgeInsets.only(top: 8, left: 10),
          //       width: MediaQuery.of(context).size.width * .91,
          //       margin: const EdgeInsets.only(
          //           bottom: 6.0), //Same as `blurRadius` i guess
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(5.0),
          //         color: Color.fromRGBO(21, 43, 81, 1),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey,
          //             offset: Offset(0.0, 1.0), //(x,y)
          //             blurRadius: 6.0,
          //           ),
          //         ],
          //       ),
          //       child: Text(
          //         "Tenants",
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           // fontSize:22,
          //           fontSize: MediaQuery.of(context).size.width < 500
          //               ? 22
          //               : MediaQuery.of(context).size.width * 0.035,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          titleBar(
            width: MediaQuery.of(context).size.width * .91,
            title: 'Applicants',
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
