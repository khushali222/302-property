import 'package:flutter/material.dart';

import '../screens/add_new_property.dart';
import '../screens/add_staffmember.dart';
import '../screens/dashboard_one.dart';
import '../screens/properties.dart';
import '../screens/property_table.dart';
import '../screens/staffmember_table.dart';


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
    "RentalOwner": (context) => Add_new_property(),
    "Tenants": (context) => Add_new_property(),
  };
  Navigator.push(
    context,
    MaterialPageRoute(builder: routes[option]!),
  );
}


Widget buildDropdownListTile(BuildContext context, Widget leadingIcon, String title, List<String> subTopics ,) {
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            title: Text(subTopic),
            onTap: () {
              Navigator.pop(context);
              navigateToOption(context, subTopic);

            },
          ),
        );
      }).toList(),
    ),
  );
}
