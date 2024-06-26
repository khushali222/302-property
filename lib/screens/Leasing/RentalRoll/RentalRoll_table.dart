import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/addLease.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../../widgets/drawer_tiles.dart';

class RentalRoll_table extends StatefulWidget {
  const RentalRoll_table({super.key});

  @override
  State<RentalRoll_table> createState() => _RentalRoll_tableState();
}

class _RentalRoll_tableState extends State<RentalRoll_table> {
  @override
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
                    selectedSubtopic: "Rent Roll"),
                buildDropdownListTile(
                    context,
                    FaIcon(
                      FontAwesomeIcons.thumbsUp,
                      size: 20,
                      color: Colors.black,
                    ),
                    "Leasing",
                    ["Rent Roll", "Applicants"],
                    selectedSubtopic: "Rent Roll"),
                buildDropdownListTile(
                    context,
                    Image.asset("assets/icons/maintence.png",
                        height: 20, width: 20),
                    "Maintenance",
                    ["Vendor", "Work Order"],
                    selectedSubtopic: "Rent Roll"),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => AddLease()));
                        // if(rentalownerCount < rentalOwnerCountLimit  )
                        // {
                        //   final result = await Navigator.of(context).push(
                        //       MaterialPageRoute(
                        //           builder: (context) => Add_rentalowners()));
                        //   if (result == true) {
                        //     setState(() {
                        //       futureStaffMembers =  RentalOwnerService().fetchRentalOwners("");
                        //       //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                        //     });
                        //   }
                        // }
                        // else{
                        //   _showAlertforLimit(context);
                        // }
                      },
                      child: Container(
                        height: (MediaQuery.of(context).size.width < 500)
                            ? 40
                            : MediaQuery.of(context).size.width * 0.065,
                        width: MediaQuery.of(context).size.width * 0.38,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "Add Lease",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.034,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (MediaQuery.of(context).size.width < 500)
                      SizedBox(width: 6),
                    if (MediaQuery.of(context).size.width > 500)
                      SizedBox(width: 22),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
