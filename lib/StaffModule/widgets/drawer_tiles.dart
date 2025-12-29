import 'package:flutter/material.dart';
import '../../widgets/navigation_helper.dart';

import 'package:three_zero_two_property/StaffModule/screen/Leasing/Applicants/Applicants_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Leasing/RentalRoll/lease_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Vendor/Vendor_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Workorder/Workorder_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Property_Type/Property_type_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Properties/Properties_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Rentalowner/Rentalowner_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Tenants/Tenants_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/mortgage/mortgageTable.dart';
import 'package:three_zero_two_property/StaffModule/screen/Reports/ReportsMainScreen.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '../../screens/Profile/Settings_screen.dart';
import '../screen/Communications/E-mail Logs/email_log_table.dart';
import '../screen/Communications/Send E-mail/Send_email_table.dart';
import '../screen/Communications/Templates/Templet_table.dart';
import '../screen/Leasing/Scheduled_Payments/Scheduled_Payments_table.dart';
import '../screen/Leasing/scheduled_charges/ScheduledCharge.dart';
import '../screen/dashboard.dart';
import '../screen/profile.dart';
import '../screen/upcoming_renewal/upcoming_renewal.dart';

Widget buildListTile(
  BuildContext context,
  Widget leadingIcon,
  String title,
  bool active,
) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: active ? blueColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(horizontal: 5),
    child: ListTile(
      onTap: () {
        if (title == "Dashboard" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => Dashboard_staff(),
            "Dashboard",
          );
        } else if (title == "Profile") {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => Profile_screen(),
            "Profile",
          );
        } else if (title == "Reports" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => ReportsMainScreen(),
            "Reports",
          );
        } else if (title == "Work Order" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => Workorder_table(),
            "Work Order",
          );
        } else if (title == "Settings") {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => TabBarExample(),
            "Settings",
          );
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
  Map<String, WidgetBuilder> routes = {
    "Properties": (context) => PropertiesTable(),
    "Rental Owner": (context) => Rentalowner_table(),
    "Tenants": (context) => Tenants_table(),
    "Property Type": (context) => PropertyTable(),
    "Vendor": (context) =>
        Vendor_table(), // Vendor accessible through Settings, not sidebar
    "Work Order": (context) => Workorder_table(),
    "Leases": (context) => Lease_table(),
    "Applicants": (context) => Applicants_table(),
    "Upcoming Renewal": (context) => Upcomingrenewal(),
    "Templates": (context) => TempletTable(),
    "E-mail Logs": (context) => Email_log_tablee(),
    "Send E-mail": (context) => Send_Email_table(),
    "Scheduled Payment": (context) => Scheduled_Payments_table(),
    "Scheduled Charges": (context) => ScheduledChargeTable(),
    "Mortgage": (context) => MortgageTable()
  };

  if (routes.containsKey(option)) {
    NavigationHelper.navigateWithValidationBuilder(
      context,
      routes[option]!,
      option,
    );
  }
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
  bool isExpanded =
      selectedSubtopic != null && subTopics.contains(selectedSubtopic);

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 14),
    padding: EdgeInsets.symmetric(horizontal: 5),
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
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            decoration: BoxDecoration(
              color: active ? blueColor : Colors.transparent,
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
