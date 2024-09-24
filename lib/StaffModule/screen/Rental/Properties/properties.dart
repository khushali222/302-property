import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/custom_drawer.dart';

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
      drawer: CustomDrawer(
        currentpage: "RentalOwner",
        dropdown: false,
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
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
                  child: Center(
                      child: Text(
                    "Add New Property",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
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
                        border: OutlineInputBorder()),
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
