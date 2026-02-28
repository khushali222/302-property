import 'package:flutter/material.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '../screens/Communications/Send E-mail/send_mail.dart';
import '../screens/Rental/mortgage/mortgageTable.dart';
import 'navigation_helper.dart';

import 'package:three_zero_two_property/screens/Leasing/upcoming_renewal/upcoming_renewal.dart';
import 'package:three_zero_two_property/screens/Reports/ReportsMainScreen.dart';

import '../screens/Communications/E-mail Logs/email_log_table.dart';
import '../screens/Communications/Send E-mail/Send_email_table.dart';
import '../screens/Communications/Templates/Templet_table.dart';
import '../screens/Leasing/Applicants/Applicants_table.dart';

import '../screens/Leasing/RentalRoll/lease_table.dart';
import '../screens/Leasing/Scheduled_Payments/Scheduled_Payments_table.dart';
import '../screens/Leasing/scheduled_charges/ScheduledCharge.dart';
// import '../screens/Maintenance/Vendor/Vendor_table.dart'; // Vendor moved to Settings
import '../screens/Maintenance/Workorder/Workorder_table.dart';
import '../screens/Rental/Properties/Properties_table.dart';
import '../screens/Rental/Tenants/Tenants_table.dart';
import '../screens/BidRoom/bid_room_table.dart';
// import '../screens/Rental/mortgage/mortgageTable.dart'; // Commented out - Mortgage feature preserved but not shown in sidebar
import '../screens/Dashboard/dashboard_one.dart';
// import '../screens/Property_Type/Property_type_table.dart'; // Moved to Settings
// import '../screens/Rental/Rentalowner/Rentalowner_table.dart'; // Moved to Settings as Property Owners
import '../screens/Staff_Member/Staffmemvertable.dart';
import '../screens/Profile/Settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/VendorModule/screen/bid_room/vendor_bid_room_table.dart';

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
      dense: true,
      onTap: () {
        if (title == "Dashboard" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => Dashboard(),
            "Dashboard",
          );
        } else if (title == "Staff" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => StaffTable(),
            "Staff",
          );
        } else if (title == "Reports" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => ReportsMainScreen(),
            "Reports",
          );
        } else if (title == "Work Orders" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => Workorder_table(),
            "Work Orders",
          );
        } else if (title == "Properties" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => PropertiesTable(),
            "Properties",
          );
        } else if (title == "Mortgage" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => MortgageTable(),
            "Mortgage",
          );
        } else if (title == "Tenants" && active != true) {
          NavigationHelper.navigateWithValidationBuilder(
            context,
            (context) => Tenants_table(),
            "Tenants",
          );
        } else if (title == "Bid Room" && active != true) {
          SharedPreferences.getInstance().then((prefs) {
            String? vendorId = prefs.getString('vendor_id');
            if (vendorId != null && vendorId.isNotEmpty) {
              NavigationHelper.navigateWithValidationBuilder(
                context,
                (context) => VendorBidRoomTable(),
                "Bid Room",
              );
            } else {
              NavigationHelper.navigateWithValidationBuilder(
                context,
                (context) => BidRoomTable(),
                "Bid Room",
              );
            }
          });
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
    "Mortgage": (context) => MortgageTable(),
    "Tenants": (context) => Tenants_table(),
    // "Rental Owner": (context) => Rentalowner_table(), // Moved to Settings as "Property Owners"
    // "Property Type": (context) => PropertyTable(), // Moved to Settings
    // "Vendor": (context) => Vendor_table(), // Vendor moved to Settings
    "Work Orders": (context) => Workorder_table(),
    "Bid Room": (context) => BidRoomTable(),
    "Leases": (context) => Lease_table(),
    "Templates": (context) => TempletTable(),
   // "E-mail Logs": (context) => Email_log_tablee(),
    "E-mail Logs": (context) => Send_Email_table(),
    "Send E-mail": (context) => send_email(),//Send_Email_table(),
    "Applicants": (context) => Applicants_table(),
    "Upcoming Renewal": (context) => Upcomingrenewal(),
    "Scheduled Payment": (context) => Scheduled_Payments_table(),
    "Scheduled Charges": (context) => ScheduledChargeTable(),
    // "Mortgage": (context) => MortgageTable() // Commented out - not deleted
    // "Work Orders": (context) => Cardpayment(leaseId: '',),
  };

  // Handle Property Owners and Property Type navigation to Settings
  if (option == "Property Owners" || option == "Rental Owner") {
    NavigationHelper.navigateWithValidationBuilder(
      context,
      (context) => TabBarExample(initialTab: 'Property Owners'),
      "Settings",
    );
  } else if (option == "Property Type") {
    NavigationHelper.navigateWithValidationBuilder(
      context,
      (context) => TabBarExample(initialTab: 'Property Type'),
      "Settings",
    );
  } else if (option == "Bid Room") {
    SharedPreferences.getInstance().then((prefs) {
      String? vendorId = prefs.getString('vendor_id');
      if (vendorId != null && vendorId.isNotEmpty) {
        NavigationHelper.navigateWithValidationBuilder(
          context,
          (context) => VendorBidRoomTable(),
          "Bid Room",
        );
      } else {
        NavigationHelper.navigateWithValidationBuilder(
          context,
          (context) => BidRoomTable(),
          "Bid Room",
        );
      }
    });
  } else if (routes.containsKey(option)) {
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
              dense: true,
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
