import 'package:flutter/material.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newAddLease.dart';
import 'package:three_zero_two_property/screens/Leasing/upcoming_renewal/upcoming_renewal.dart';
import 'package:three_zero_two_property/screens/Reports/ReportsMainScreen.dart';
import 'package:three_zero_two_property/screens/Reports/ReportsMainScreen.dart';

import '../screens/Leasing/Applicants/Applicants_table.dart';

import '../screens/Leasing/RentalRoll/lease_table.dart';
import '../screens/Maintenance/Vendor/Vendor_table.dart';
import '../screens/Maintenance/Workorder/Add_workorder.dart';
import '../screens/Maintenance/Workorder/Workorder_table.dart';
import '../screens/Rental/Properties/Properties_table.dart';
import '../screens/Rental/Rentalowner/Add_RentalOwners.dart';
import '../screens/Rental/Tenants/Tenants_table.dart';
import '../screens/Rental/Properties/add_new_property.dart';
import '../screens/Rental/Tenants/add_tenants.dart';
import '../screens/Staff_Member/Add_staffmember.dart';
import '../screens/Dashboard/dashboard_one.dart';
import '../screens/Rental/Properties/properties.dart';
import '../screens/Property_Type/Property_type_table.dart';

import '../screens/Rental/Rentalowner/Rentalowner_table.dart';
import '../screens/Staff_Member/Staffmemvertable.dart';



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
              context, MaterialPageRoute(builder: (context) => Dashboard()));
        } else if (title == "Property Type" && active != true) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PropertyTable()));
        } else if (title == "Staff Member" && active != true) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => StaffTable()));
        } else if (title == "Reports" && active != true) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReportsMainScreen()));
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
    "Upcoming renewal":(context)=> Upcomingrenewal()
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

