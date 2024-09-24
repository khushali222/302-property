import 'package:flutter/material.dart';
import 'package:three_zero_two_property/StaffModule/screen/Leasing/Applicants/Applicants_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Leasing/RentalRoll/lease_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Vendor/Vendor_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Workorder/Workorder_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Property_Type/Property_type_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Properties/Properties_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Rentalowner/Rentalowner_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Tenants/Tenants_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Reports/ReportsMainScreen.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newAddLease.dart';



import '../screen/dashboard.dart';
import '../screen/profile.dart';




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
        if (title == "Dashboard" && active != true) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Dashboard_staff()));
        } else if (title == "Property Type" && active != true) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PropertyTable()));
        } else if (title == "Reports" && active != true) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReportsMainScreen()));
        }
        else if (title == "Profile") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Profile_screen()));
        }
      },
      leading: leadingIcon,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: active ? Colors.white : blueColor,
        ),
      ),
    ),
  );
}

void navigateToOption(BuildContext context, String option, bool isActive) {
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
    // "Work Order": (context) => Cardpayment(leaseId: '',),
  };
  // if (isActive != true) {
   Navigator.push(
    context,
    MaterialPageRoute(builder: routes[option]!),
  );
  // }
}

Widget buildDropdownListTile(
    BuildContext context,
    Widget leadingIcon,
    String title,
    List<String> subTopics,
    List<Widget> subTopicIcons, {
      String? selectedSubtopic,
      bool? initvalue,
    }) {
  // Check if the selectedSubtopic is in the list of subTopics
  bool isExpanded = selectedSubtopic != null && subTopics.contains(selectedSubtopic);

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: ExpansionTile(
      initiallyExpanded: isExpanded,
      leading: leadingIcon,
      title: Text(
        title,
        style: TextStyle(color: blueColor),
      ),
      children: subTopics.asMap().entries.map((entry) {
        int index = entry.key;
        String subTopic = entry.value;
        bool active = selectedSubtopic == subTopic;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: active ? Color.fromRGBO(21, 43, 81, 1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: subTopicIcons[index], // Add icon here
              title: Text(
                subTopic,
                style: TextStyle(
                  fontSize: 15,
                  color: active ? Colors.white : blueColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                navigateToOption(context, subTopic, active);
              },
            ),
          ),
        );
      }).toList(),
    ),
  );
}

