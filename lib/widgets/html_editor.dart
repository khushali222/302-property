import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../StaffModule/repository/staffpermission_provider.dart';
import '../TenantsModule/repository/permission_provider.dart';
import '../VendorModule/repository/vendor_permission.dart';
import '../constant/constant.dart';
import '../main.dart';
import '../provider/edit_applicant.dart';
import '../provider/notification_provider.dart';
import '../screens/Reports/ReportScreens/AccountTotals.dart';
import '../screens/Reports/ReportScreens/CompletedWorkOrders.dart';
import '../screens/Reports/ReportScreens/ConvenienceFee.dart';
import '../screens/Reports/ReportScreens/DelinquentTenants.dart';
import '../screens/Reports/ReportScreens/ExpiringLeases.dart';
import '../screens/Reports/ReportScreens/Expiring_Insurance.dart';
import '../screens/Reports/ReportScreens/OpenWorkOrders.dart';
import '../screens/Reports/ReportScreens/Payment_Exception.dart';
import '../screens/Reports/ReportScreens/Recurring_Payments_Configuration_table.dart';
import '../screens/Reports/ReportScreens/RentRollReport.dart';
import '../screens/Reports/ReportScreens/RentersInsurance.dart';
import '../screens/Reports/ReportScreens/dailytransaction.dart';
import '../screens/Reports/ReportScreens/rentalownerreport.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/provider/NetworkProvider.dart';
import 'package:three_zero_two_property/provider/Plan%20Purchase/plancheckProvider.dart';

import 'package:three_zero_two_property/provider/add_property.dart';
import 'package:three_zero_two_property/provider/color_theme.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/provider/editapplicationsummaryForm.dart';
import 'package:three_zero_two_property/provider/getAdminAddress.dart';

import 'package:three_zero_two_property/provider/lease_provider.dart';

import 'package:three_zero_two_property/provider/properties_workorders.dart';

import 'package:three_zero_two_property/provider/property_summery.dart';
import 'package:three_zero_two_property/repository/properties_summery.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/Summary/SummaryEditApplicant.dart';

import 'package:three_zero_two_property/screens/Splash_Screen/splash_screen.dart';


import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:timeago/timeago.dart' as timeago;


void main() {
  runApp(DevicePreview(
    enabled: true,
    tools: [
      ...DevicePreview.defaultTools,
    ],
    builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => OwnerDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Tenants_counts(),
        ),
        ChangeNotifierProvider(
          create: (context) => SelectedTenantsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SelectedCosignersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SelectedApplicantProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => NameProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LeaseLedgerProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => EditFormState(),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkOrderCountProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ApplicantDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => checkPlanPurchaseProiver(),
        ),
        ChangeNotifierProvider(
          create: (context) => PermissionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => StaffPermissionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkOrderCountProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(),
        ),
        ChangeNotifierProvider(create: (_) => DateProvider()),
        ChangeNotifierProvider(create: (_) => DropdownProvider()),
        ChangeNotifierProvider(create: (_) => CheckConnection()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => VendorPermission()),
      ],
      child: MyApp(),
    ),
  ),);
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reports',
      theme: ThemeData(
        fontFamily: "Poppins",
        iconTheme: IconThemeData(color: blueColor),
        colorScheme: ColorScheme.fromSeed(seedColor: blueColor),
        useMaterial3: false,
      ),
      home: const ReportScreen(),
    );
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Widget sectionTitle(String title, String svgPath,String subtitle) {
    return
      Column(
        children: [
          ListTile(

            visualDensity: const VisualDensity(vertical: -4), // Reduce vertical spacing
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            leading:  Container(
              margin: EdgeInsets.only(left: 10,top: 5),
              child: SvgPicture.asset(
                svgPath,
                width: 25,
                height: 25,
                // colorFilter: const ColorFilter.mode(Colors.indigo, BlendMode.srcIn),
              ),
            ),
            title:Text(
              title,
              style:  TextStyle(fontSize: 14,color: blueColor, fontWeight: FontWeight.bold),
            ) ,
            subtitle:   Text(subtitle, style:  TextStyle(color: Colors.grey.shade500,fontWeight: FontWeight.w200, fontSize: 11)),
          ),
          Divider()
        ],
      );


  }

  Widget reportItem(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const Divider(height: 16),
          ],
        ),
      ),
    );
  }

  Widget reportSection(String svgIconPath, String title, List<Map<String, dynamic>> items,String subtitle,BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
      //  color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(title, svgIconPath,subtitle),
          const SizedBox(height: 5),
          ...items.map((item) => reportItem(item['title']!, item['subtitle']!,() {
            // Handle navigation based on title or a new field like `route`
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => item["navigate"],
              ),
            );
          },)).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF0B2C5B),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            reportSection('assets/images/entypo_bar-graph.svg', 'Financial Reports', [
              {'title': 'Rent Collection Report', 'subtitle': 'Rent collection due by property',"navigate":RentersInsurance()},
              {'title': 'Daily Transaction Report', 'subtitle': 'Listing of all transaction summarized by day',"navigate":DailyTransactions()},
              {'title': 'Rental Owner Report', 'subtitle': 'Listing of all transaction summarized by day owner',"navigate":RentalOwnerReports()},
              {'title': 'Account Totals Report', 'subtitle': 'Summarized by account and rental owner',"navigate":AccountTotalsReports()},
              {'title': 'Payment Exception Report', 'subtitle': 'Transaction list not assigned to a tenant',"navigate":PaymentExceptionReports()},
              {'title': 'Recurring Payments Configuration', 'subtitle': 'Configured recurring payment by lease',"navigate":Recurring_Payments_Configuration_Report()},
              {'title': 'Convenience Fee Override', 'subtitle': 'Leases with convenience fee override',"navigate":ConvenienceFeeReports()},
            ],"Track payments, transactions, and owner accounts.",context),
            SizedBox(height: 10,),
            reportSection('assets/images/mingcute_clipboard-fill.svg', 'Maintenance & Work Orders', [
              {'title': 'Open Work Orders', 'subtitle': 'Work order not yet in complete state',"navigate":OpenWorkOrders()},
              {'title': 'Completed Work Orders', 'subtitle': 'All completed work orders',"navigate":CompletedWorkOrders()},
            ],"Fix it fast, document it all",context),
            SizedBox(height: 10,),
            reportSection('assets/images/solar_shield-up-bold.svg', 'Insurance', [
              {'title': 'Renter’s Insurance', 'subtitle': 'Listing of all renter’s insurance policies',"navigate":RentersInsurance()},
              {'title': 'Expiring Insurance', 'subtitle': 'Policies expiring within the selected period',"navigate":ExpiringInsurance()},
            ],"Coverage at a glance",context),
            SizedBox(height: 10,),
            reportSection('assets/images/fontisto_person.svg', 'Lease & Tenant Management', [
              {'title': 'Expiring Leases', 'subtitle': 'All leases that will end during a timeframe',"navigate":ExpiringLeases()},
              {'title': 'Delinquent Tenants', 'subtitle': 'Tenants with outstanding ledger balances',"navigate":DelinquentTenants()},
              {'title': 'Rent Roll Report', 'subtitle': 'Rent balance due by property and tenants',"navigate":RentersInsurances()},
            ],"Active leases and tenant solutions.",context),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
