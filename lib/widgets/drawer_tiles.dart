import 'package:flutter/material.dart';

import '../screens/Leasing/Applicants/Applicants_table.dart';
import '../screens/Leasing/RentalRoll/RentalRoll_table.dart';
import '../screens/Maintenance/Vendor/Vendor_table.dart';
import '../screens/Maintenance/Workorder/Workorder_table.dart';
import '../screens/Rental/Properties/Properties_table.dart';
import '../screens/Rental/Rentalowner/Add_RentalOwners.dart';
import '../screens/Rental/Tenants/Tenants_table.dart';
import '../screens/Rental/Properties/add_new_property.dart';
import '../screens/Staff_Member/Add_staffmember.dart';
import '../screens/Dashboard/dashboard_one.dart';
import '../screens/Rental/Properties/properties.dart';
import '../screens/Property_Type/Property_type_table.dart';
import '../screens/Staff_Member/Staffmember_table.dart';
import '../screens/Rental/Rentalowner/Rentalowner_table.dart';
import '../screens/Staff_Member/Staffmemvertable.dart';

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
          Navigator.push(context, MaterialPageRoute(builder: (context) => PropertyTable()));
        }else if(title == "Add Staff Member"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> StaffTable()));
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
    "Properties": (context) => PropertiesTable(),
    "RentalOwner": (context) => Add_rentalowners(),
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
