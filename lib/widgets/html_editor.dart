import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant/constant.dart';

void main() {
  runApp(const ReportApp());
}

class ReportApp extends StatelessWidget {
  const ReportApp({super.key});

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
            leading:  SvgPicture.asset(
              svgPath,
              width: 25,
              height: 25,
              // colorFilter: const ColorFilter.mode(Colors.indigo, BlendMode.srcIn),
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

  Widget reportItem(String title, String subtitle) {
    return Padding(
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
    );
  }

  Widget reportSection(String svgIconPath, String title, List<Map<String, String>> items,String subtitle) {
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
          ...items.map((item) => reportItem(item['title']!, item['subtitle']!)).toList(),
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
              {'title': 'Rent Collection Report', 'subtitle': 'Rent collection due by property'},
              {'title': 'Daily Transaction Report', 'subtitle': 'Listing of all transaction summarized by day'},
              {'title': 'Rental Owner Report', 'subtitle': 'Listing of all transaction summarized by day owner'},
              {'title': 'Account Totals Report', 'subtitle': 'Summarized by account and rental owner'},
              {'title': 'Payment Exception Report', 'subtitle': 'Transaction list not assigned to a tenant'},
              {'title': 'Recurring Payments Configuration', 'subtitle': 'Configured recurring payment by lease'},
              {'title': 'Convenience Fee Override', 'subtitle': 'Leases with convenience fee override'},
            ],"Track payments, transactions, and owner accounts."),
            SizedBox(height: 10,),
            reportSection('assets/images/mingcute_clipboard-fill.svg', 'Maintenance & Work Orders', [
              {'title': 'Open Work Orders', 'subtitle': 'Work order not yet in complete state'},
              {'title': 'Completed Work Orders', 'subtitle': 'All completed work orders'},
            ],"Fix it fast, document it all"),
            SizedBox(height: 10,),
            reportSection('assets/images/solar_shield-up-bold.svg', 'Insurance', [
              {'title': 'Renter’s Insurance', 'subtitle': 'Listing of all renter’s insurance policies'},
              {'title': 'Expiring Insurance', 'subtitle': 'Policies expiring within the selected period'},
            ],"Coverage at a glance"),
            SizedBox(height: 10,),
            reportSection('assets/images/fontisto_person.svg', 'Lease & Tenant Management', [
              {'title': 'Expiring Leases', 'subtitle': 'All leases that will end during a timeframe'},
              {'title': 'Delinquent Tenants', 'subtitle': 'Tenants with outstanding ledger balances'},
              {'title': 'Rent Roll Report', 'subtitle': 'Rent balance due by property and tenants'},
            ],"Active leases and tenant solutions."),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
