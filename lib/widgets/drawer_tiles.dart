import 'package:flutter/material.dart';

import '../screens/Leasing/Applicants_table.dart';
import '../screens/Leasing/RentalRoll_table.dart';
import '../screens/Maintenance/Vendor_table.dart';
import '../screens/Maintenance/Workorder_table.dart';
import '../screens/Rental/Tenants_table.dart';
import '../screens/add_new_property.dart';
import '../screens/add_staffmember.dart';
import '../screens/dashboard_one.dart';
import '../screens/properties.dart';
import '../screens/property_table.dart';
import '../screens/staffmember_table.dart';
import '../screens/Rental/Rentalowner_table.dart';

Widget buildListTile(BuildContext context, Widget leadingIcon, String title, bool active,) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: active ? Color.fromRGBO(21, 43, 81, 1) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: ListTile(
      onTap: () {
        if(title =="Dashboard"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
        }else if(title =="Add Property Type"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Property_table()));
        }else if(title == "Add Staff Member"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> Staffmember_table()));
        }
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

void navigateToOption(BuildContext context, String option,) {
  Map<String, WidgetBuilder> routes = {
    "Properties": (context) => Add_new_property(),
    "RentalOwner": (context) => Rentalowner_table(),
    "Tenants": (context) => Tenants_table(),
    "Vendor":(context)=>Vendor_table(),
    "Work Order":(context)=>Workorder_table(),
    "Rent Roll":(context)=>RentalRoll_table(),
    "Applicants":(context)=>Applicants_table(),
  };
  Navigator.push(
    context,
    MaterialPageRoute(builder: routes[option]!),
  );
}


Widget buildDropdownListTile(BuildContext context, Widget leadingIcon, String title, List<String> subTopics ,{String? selectedSubtopic}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.symmetric(horizontal: 16),
    // decoration: BoxDecoration(
    //   color: subTopics.contains(selectedOption) ? Color.fromRGBO(21, 43, 81, 1) : Colors.transparent,
    //   borderRadius: BorderRadius.circular(10),
    // ),
    child: ExpansionTile(
      leading: leadingIcon,
      title: Text(title),
      children: subTopics.map((subTopic,) {
        bool active = selectedSubtopic == subTopic;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: active ? Color.fromRGBO(21, 43, 81, 1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
             // tileColor: selectedSubtopic == subTopic ? Colors.red :Colors.transparent ,
              title: Text(subTopic,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                navigateToOption(context, subTopic);

              },
            ),
          ),
        );
      }).toList(),
    ),
  );
}
