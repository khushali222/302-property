import 'package:flutter/material.dart';

import '../screens/dashboard_one.dart';
import '../screens/properties.dart';
import '../screens/property_table.dart';

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
          Navigator.push(context, MaterialPageRoute(builder: (context) => DataTableDemo()));
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

Widget buildDropdownListTile(BuildContext context, Widget leadingIcon, String title, List<String> subTopics) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: ExpansionTile(
      leading: leadingIcon,
      title: Text(title),
      children: subTopics.map((subTopic) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            title: Text(subTopic),
            onTap: () {
              // Handle sub-topic selection
              Navigator.pop(context); // Close drawer after selecting a sub-topic
            },
          ),
        );
      }).toList(),
    ),
  );
}
