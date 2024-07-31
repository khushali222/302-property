import 'package:flutter/material.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newAddLease.dart';
import "../screen/Properties/Properties_table.dart";
import '../screen/dashboard.dart';
import '../screen/profile.dart';
import '../screen/Tenants/Tenants_table.dart';
import '../screen/RentalRoll/lease_table.dart';
import '../screen/Workorder/Workorder_table.dart';

Widget buildListTile(
  BuildContext context,
  Widget leadingIcon,
  String title,
  bool active,
) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: active ? Color.fromRGBO(21, 43, 81, 1) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: ListTile(
      onTap: () {
        if (title == "Properties") {

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PropertiesTable()));
        }/* else if (title == "Add Property Type") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PropertyTable()));
        } else if (title == "Add Staff Member") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => StaffTable()));
        }*/
        else if (title == "Dashboard") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Dashboard_staff()));
        } else if (title == "Profile") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Profile_screen()));
        }
        else if (title == "Tenants") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Tenants_table()));
        }
        else if (title == "Rent Roll") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Lease_table()));
        }
        else if (title == "Work Order") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Workorder_table()));
        }
       /* else if (title == "Documents") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ReportsMainScreen()));
        }*/
      },
      leading: leadingIcon,
      title: Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
        ),
      ),
    ),
  );
}

/*void navigateToOption(
  BuildContext context,
  String option,
) {
  int index = 0;
  Map<String, WidgetBuilder> routes = {
    "Properties": (context) => PropertiesTable(),
    "RentalOwner": (context) => Rentalowner_table(),
    "Tenants": (context) => Tenants_table(),
    "Vendor": (context) => Vendor_table(),
    "Work Order": (context) => Workorder_table(),
    "Rent Roll": (context) => Lease_table(),
    "Applicants": (context) => Applicants_table(),
    "Vendor": (context) => Vendor_table(),

  };
  Navigator.push(
    context,
    MaterialPageRoute(builder: routes[option]!),
  );
}*/

Widget buildDropdownListTile(BuildContext context, Widget leadingIcon,
    String title, List<String> subTopics,
    {String? selectedSubtopic, bool? initvalue}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.symmetric(horizontal: 16),
    // decoration: BoxDecoration(
    //   color: subTopics.contains(selectedOption) ? Color.fromRGBO(21, 43, 81, 1) : Colors.transparent,
    //   borderRadius: BorderRadius.circular(10),
    // ),
    child: ExpansionTile(
      // initiallyExpanded: initvalue!,
      leading: leadingIcon,
      title: Text(title),
      children: subTopics.map((
        subTopic,
      ) {
        bool active = selectedSubtopic == subTopic;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color:
                  active ? Color.fromRGBO(21, 43, 81, 1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              // tileColor: selectedSubtopic == subTopic ? Colors.red :Colors.transparent ,
              title: Text(
                subTopic,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
             //   navigateToOption(context, subTopic);
              },
            ),
          ),
        );
      }).toList(),
    ),
  );
}
