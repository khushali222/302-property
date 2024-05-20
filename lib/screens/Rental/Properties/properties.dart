

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../widgets/drawer_tiles.dart';
class Properties extends StatefulWidget {
  const Properties({Key? key}) : super(key: key);

  @override
  State<Properties> createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {
  final List<String> items = [
    'This Year',
    'Previous Year',
  ];

  String? selectedValue;


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
              buildListTile(context,Icon(CupertinoIcons.circle_grid_3x3,color: Colors.black,), "Dashboard",false),
              buildListTile(context,Icon(CupertinoIcons.house,color: Colors.black,), "Add Property Type",false),
              buildListTile(context,Icon(CupertinoIcons.person_add,color: Colors.white,), "Add Staff Member",true),
              buildDropdownListTile(context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ), "Rental", ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(context,FaIcon(
                FontAwesomeIcons.thumbsUp,
                size: 20,
                color: Colors.black,
              ), "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(context,
                  Image.asset("assets/icons/maintence.png", height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
            ],
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: 150,
                  height: 40,
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
                  child: Center(child: Text("Add New Property",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: EdgeInsets.only(top: 8, left: 10),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(
                      bottom: 6.0), //Same as `blurRadius` i guess
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
                    "Properties",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Search here...",
                      border: OutlineInputBorder()

                    ),
                  ),
                ),

              ],
            )
          ],
        ),
      ),


    );
  }

}
