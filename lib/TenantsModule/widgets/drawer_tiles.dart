import 'package:flutter/material.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../widgets/navigation_helper.dart';
import '../screen/documents/document_dashboard.dart';
import '../screen/financial/financial_table.dart';
import '../screen/dashboard.dart';
import '../screen/profile.dart';
import '../screen/property/property_table.dart';
import '../screen/work_order/workorder_table.dart';


Widget buildListTile(
    BuildContext context,
    Widget leadingIcon,
    String title,
    bool active,
    ) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: active ? blueColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ListTile(
      onTap: () {
        // Navigate with validation to prevent duplicate navigation
        if (title == "Dashboard") {
          NavigationHelper.navigateWithValidation(
            context,
            Dashboard_tenants(),
            "Dashboard",
          );
        } else if (title == "Profile") {
          NavigationHelper.navigateWithValidation(
            context,
            const Profile_screen(),
            "Profile",
          );
        } else if (title == "Properties") {
          NavigationHelper.navigateWithValidation(
            context,
            PropertyTable(),
            "Properties",
          );
        } else if (title == "Ledger") {
          NavigationHelper.navigateWithValidation(
            context,
            FinancialTable(),
            "Ledger",
          );
        } else if (title == "Work Order") {
          NavigationHelper.navigateWithValidation(
            context,
            WorkOrderTable(),
            "Work Order",
          );
        } else if (title == "Documents") {
          NavigationHelper.navigateWithValidation(
            context,
            ReportsMainScreen(),
            "Documents",
          );
        }
      },
      leading: leadingIcon,
      title: Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : blueColor,
        ),
      ),
    ),
  );
}

void navigateToOption(
    BuildContext context,
    String option,
    ) {
  Map<String, Widget> routes = {
    "Properties": PropertyTable(),
    /* "RentalOwner": Rentalowner_table(),
    "Tenants": Tenants_table(),
    "Vendor": Vendor_table(),
    "Work Order": Workorder_table(),
    "Rent Roll": Lease_table(),
    "Applicants": Applicants_table(),
    "Vendor": Vendor_table(),*/
  };

  if (routes.containsKey(option)) {
    NavigationHelper.navigateWithValidation(
      context,
      routes[option]!,
      option,
    );
  }
}

Widget buildDropdownListTile(BuildContext context, Widget leadingIcon,
    String title, List<String> subTopics,
    {String? selectedSubtopic, bool? initvalue}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    // decoration: BoxDecoration(
    //   color: subTopics.contains(selectedOption) ? blueColor : Colors.transparent,
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
              color: active ? blueColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              // tileColor: selectedSubtopic == subTopic ? Colors.red :Colors.transparent ,
              title: Text(
                subTopic,
                style: TextStyle(
                  color: active ? Colors.white : blueColor,
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
