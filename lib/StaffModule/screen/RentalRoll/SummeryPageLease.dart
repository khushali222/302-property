import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:three_zero_two_property/Model/tenants.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';
// import 'package:three_zero_two_property/repository/properties_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../../Model/RentalOwnersData.dart';

import '../../../../model/lease.dart';
import '../../../../repository/Rental_ownersData.dart';
import '../../../../repository/properties_summery.dart';
import '../../../../widgets/drawer_tiles.dart';
import '../../../model/LeaseSummary.dart';
import '../../model/staffpermission.dart';
import '../../repository/staffpermission_provider.dart';
import 'Financial.dart';
import '../../widgets/custom_drawer.dart';
class SummeryPageLease extends StatefulWidget {
  String leaseId;
  SummeryPageLease({super.key, required this.leaseId});
  @override
  State<SummeryPageLease> createState() => _SummeryPageLeaseState();
}

class _SummeryPageLeaseState extends State<SummeryPageLease>
    with SingleTickerProviderStateMixin {
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  List formDataRecurringList = [];
  late Future<LeaseSummary> futureLeaseSummary;

  TabController? _tabController;
  @override
  void initState() {
    // TODO: implement initState
    futureLeaseSummary = LeaseRepository.fetchLeaseSummary(widget.leaseId);
  //  _tabController = TabController(length: 3, vsync: this);
 //   _initializeTabs();
    super.initState();
  }
  void _initializeTabs() {
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;

    if (permissions != null && permissions.paymentView!) {
     // showFinancialTab = true;
      _tabController = TabController(length: 3, vsync: this);
    } else {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;

    // Define the tabs based on permissions
    List<Tab> tabs = [
      const Tab(text: 'Summary'),
      if (permissions?.paymentView ?? false) const Tab(text: 'Financial'),
      const Tab(text: 'Tenant'),
    ];

    // Define the tab views based on permissions


    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawer(currentpage: 'Rent Roll'),
        body: FutureBuilder<LeaseSummary>(
          future: futureLeaseSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 50.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data found.'));
            } else {
              List<Widget> tabViews = [
                SummaryPage(),
                if (permissions?.paymentView ?? false)
                  FinancialTable(
                    leaseId: widget.leaseId,
                    status:
                    '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate).toString()}',// Replace with actual status calculation
                    tenantId: 'tenantId', // Replace with actual tenantId
                  ),
                Tenant(context),
              ];
              return Column(
                children: <Widget>[
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        '${snapshot.data!.data!.rentalAddress}',
                        style: TextStyle(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Material(
                          elevation: 3,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: const Center(
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
                        style: TextStyle(
                          color: Color(0xFF8A95A8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 60,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      tabs: tabs,
                      indicatorWeight: 5,
                      indicatorColor: const Color.fromRGBO(21, 43, 81, 1),
                      labelColor: const Color.fromRGBO(21, 43, 81, 1),
                      unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: tabViews,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  String determineStatus(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'Unknown';

    DateTime start = DateFormat('yyyy-MM-dd').parse(startDate);
    DateTime end = DateFormat('yyyy-MM-dd').parse(endDate);
    DateTime today = DateTime.now();

    if (today.isBefore(start)) {
      return 'Future';
    } else if (today.isAfter(end)) {
      return 'Expired';
    } else {
      return 'Active';
    }
  }

  SummaryPage() {
    return FutureBuilder<LeaseSummary>(
      future: futureLeaseSummary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitFadingCircle(
              color: Colors.black,
              size: 50.0,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data found.'));
        } else {
          return ListView(
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, top: 20, bottom: 30),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                "Tenant Details",
                                style: TextStyle(
                                    color: const Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            .045),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Unit ID
                          Row(
                            children: [
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                "Unit",
                                style: TextStyle(
                                    color: const Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 2),
                              Text(
                                '${snapshot.data!.data!.rentalAddress}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(21, 43, 83, 1),
                                ),
                              ),
                              const SizedBox(width: 2),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          // Rental Owner
                          Row(
                            children: [
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                "Rental Owner",
                                style: TextStyle(
                                    color: const Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 2),
                              Text(
                                '${snapshot.data!.data!.rentalOwnerName ?? 'N/A'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(21, 43, 83, 1),
                                ),
                              ),
                              const SizedBox(width: 2),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          // Tenant
                          Row(
                            children: [
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                "Tenant",
                                style: TextStyle(
                                    color: const Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
//// Display tenant details here if needed
                          if (snapshot.data!.data!.tenantData != null &&
                              snapshot.data!.data!.tenantData!.isNotEmpty)
                            Column(
                              children: snapshot.data!.data!.tenantData!
                                  .map((tenant) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    // Display Tenant Name
                                    Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        Text(
                                          '${tenant.tenantFirstName}  ${tenant.tenantLastName}' ??
                                              'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(21, 43, 83, 1),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 5),
                                  ],
                                );
                              }).toList(),
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 25, bottom: 25),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, top: 20, bottom: 30),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                "Lease Details",
                                style: TextStyle(
                                    color: const Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            .045),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              dataRowHeight: 35,
                              headingRowHeight: 35,
                              border: TableBorder.all(
                                width: 1,
                                color: const Color.fromRGBO(21, 43, 83, 1),
                              ),
                              columns: [
                                const DataColumn(
                                  label: Text('Status'),
                                ),
                                const DataColumn(
                                  label: Text('Start - End'),
                                ),
                                const DataColumn(
                                  label: Text('Property'),
                                ),
                                const DataColumn(
                                  label: Text('Type'),
                                ),
                                const DataColumn(
                                  label: Text('Rent'),
                                ),
                              ],
                              rows: [
                                DataRow(cells: <DataCell>[
                                  DataCell(Text(
                                      '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}')),
                                  DataCell(Text(
                                      ' ${snapshot.data!.data!.startDate} to ${snapshot.data!.data!.endDate}')),
                                  DataCell(Text(
                                      '${snapshot.data!.data!.rentalAddress}')),
                                  DataCell(Text(
                                      '${snapshot.data!.data!.leaseType}')),
                                  DataCell(
                                      Text('${snapshot.data!.data!.amount}')),
                                ]),
                                // Add more rows as needed
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Tenant(context) {
    return FutureBuilder<LeaseSummary>(
      future: futureLeaseSummary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.data!.tenantData!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 165,
                  width: MediaQuery.of(context).size.width * .9,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color.fromRGBO(21, 43, 81, 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(21, 43, 81, 1),
                              border: Border.all(
                                  color: const Color.fromRGBO(21, 43, 81, 1)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.user,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${snapshot.data!.data!.tenantData![index].tenantFirstName} ${snapshot.data!.data!.tenantData![index].tenantLastName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    snapshot.data!.data!.rentalAddress!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8A95A8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.rightFromBracket,
                                size: 17,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Move out",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const SizedBox(width: 65),
                          Text(
                            '${snapshot.data!.data!.startDate} to',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 65),
                          Text(
                            '${snapshot.data!.data!.endDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 65),
                          const FaIcon(
                            FontAwesomeIcons.phone,
                            size: 15,
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${snapshot.data!.data!.tenantData![index].tenantPhoneNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 65),
                          const FaIcon(
                            FontAwesomeIcons.solidEnvelope,
                            size: 15,
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${snapshot.data!.data!.tenantData![index].tenantEmail}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class FinancialPage extends StatefulWidget {
  const FinancialPage({super.key});

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
