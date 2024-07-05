import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';
// import 'package:three_zero_two_property/repository/properties_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/RentalOwnersData.dart';

import '../../../model/lease.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../repository/properties_summery.dart';
import '../../../widgets/drawer_tiles.dart';

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

  TabController? _tabController;
  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Text('{widget.properties.rentalAddress}',
                  style: TextStyle(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Material(
                      elevation: 3,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      child: Container(
                        height: 40,
                        width: 80,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: const Center(
                            child: Text(
                          "Back",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text('{widget.properties.propertyTypeData?.propertyType}',
                  style: TextStyle(
                      color: Color(0xFF8A95A8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
              // color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorWeight: 5,
              //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
              indicatorColor: const Color.fromRGBO(21, 43, 81, 1),
              labelColor: const Color.fromRGBO(21, 43, 81, 1),
              unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
              tabs: [
                const Tab(text: 'Summary'),
                const Tab(
                  text: 'Financial',
                ),
                StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return const Tab(text: 'Tenant');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SummaryPage(),
                const FinancialPage(),
                Tenant(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SummaryPage() {
    return FutureBuilder<Map<String, dynamic>>(
      future: LeaseRepository.fetchLeaseData(widget.leaseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data found'));
        } else {
          final data = snapshot.data!;
          print('Snapshot data: $data'); // Debug output

          LeaseDatas leaseData;
          try {
            leaseData = LeaseDatas.fromJson(data['data']);
          } catch (e) {
            return const Center(child: Text('Error parsing lease data'));
          }

          return _buildLeaseSummary(leaseData);
        }
      },
    );
  }

  Widget _buildLeaseSummary(LeaseDatas lease) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Lease ID: ${lease.leaseId}'),
        const SizedBox(height: 10),
        Text('Rental Address: ${lease.rentalAddress}'),
        const SizedBox(height: 10),
        Text('Lease Type: ${lease.leaseType}'),
        const SizedBox(height: 10),
        Text('Start Date: ${lease.startDate}'),
        const SizedBox(height: 10),
        Text('End Date: ${lease.endDate}'),
        const SizedBox(height: 10),
        Text('Amount: ${lease.amount}'),
        const SizedBox(height: 10),
        // Add more fields as needed
        Text('Tenant Information:'),
        for (var tenant in lease.tenantData)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${tenant.firstName} ${tenant.lastName}'),
                Text('Email: ${tenant.email}'),
                Text('Phone: ${tenant.phoneNumber}'),
                // Add more tenant fields as needed
              ],
            ),
          ),
      ],
    );
  }

  // SummaryPage() {
  //   return Center(
  //     child: FutureBuilder<List<Lease>>(
  //       future: LeaseRepository().fetchLeaseData(widget.leaseId),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(
  //             child: Center(
  //                 child: SpinKitFadingCircle(
  //               color: Colors.black,
  //               size: 40.0,
  //             )),
  //           );
  //         } else if (snapshot.hasError) {
  //           return Text('Error: ${snapshot.error}');
  //         } else {
  //           List<Lease> leases = snapshot.data!;
  //           LeaseData leaseData = leases.first.leaseData;
  //           //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
  //           return ListView(
  //             scrollDirection: Axis.vertical,
  //             children: [
  //               Text(widget.leaseId),
  //               //Personal information
  //               Padding(
  //                 padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
  //                 child: Material(
  //                   elevation: 6,
  //                   borderRadius: BorderRadius.circular(10),
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(10),
  //                       border: Border.all(
  //                           color: const Color.fromRGBO(21, 43, 81, 1)),
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(
  //                           left: 25, right: 25, top: 20, bottom: 30),
  //                       child: Column(
  //                         children: [
  //                           Row(
  //                             children: [
  //                               const SizedBox(
  //                                 width: 2,
  //                               ),
  //                               Text(
  //                                 "Tenant Details",
  //                                 style: TextStyle(
  //                                     color:
  //                                         const Color.fromRGBO(21, 43, 81, 1),
  //                                     fontWeight: FontWeight.bold,
  //                                     // fontSize: 18
  //                                     fontSize:
  //                                         MediaQuery.of(context).size.width *
  //                                             .045),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(
  //                             height: 10,
  //                           ),
  //                           //first name
  //                           Row(
  //                             children: [
  //                               const SizedBox(
  //                                 width: 2,
  //                               ),
  //                               Text(
  //                                 "Unit",
  //                                 style: TextStyle(
  //                                     color: const Color(0xFF8A95A8),
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize:
  //                                         MediaQuery.of(context).size.width *
  //                                             .036),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(
  //                             height: 5,
  //                           ),
  //                           Row(
  //                             children: [
  //                               const SizedBox(width: 2),
  //                               // Text(
  //                               //   '${rentalownersummery.isNotEmpty && rentalownersummery.first.rentalOwnerName != null ? rentalownersummery.first.rentalOwnerName : 'N/A'}',
  //                               // ),
  //                               Text(
  //                                 '${leaseData.unitId}',
  //                                 style: TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     color: blueColor),
  //                               ),
  //                               const SizedBox(width: 2),
  //                             ],
  //                           ),
  //                           const SizedBox(
  //                             height: 12,
  //                           ),
  //                           //company name
  //                           Row(
  //                             children: [
  //                               const SizedBox(
  //                                 width: 2,
  //                               ),
  //                               Text(
  //                                 "Rental Owner",
  //                                 style: TextStyle(
  //                                     // color: Colors.grey,
  //                                     color: const Color(0xFF8A95A8),
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize:
  //                                         MediaQuery.of(context).size.width *
  //                                             .036),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(
  //                             height: 5,
  //                           ),
  //                           Row(
  //                             children: [
  //                               const SizedBox(width: 2),
  //                               Text(
  //                                 '${leaseData.unitId}',
  //                                 style: TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     color: blueColor),
  //                               ),
  //                               const SizedBox(width: 2),
  //                             ],
  //                           ),
  //                           const SizedBox(
  //                             height: 12,
  //                           ),
  //                           //street address
  //                           Row(
  //                             children: [
  //                               const SizedBox(
  //                                 width: 2,
  //                               ),
  //                               Text(
  //                                 "Tenant",
  //                                 style: TextStyle(
  //                                     // color: Colors.grey,
  //                                     color: const Color(0xFF8A95A8),
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize:
  //                                         MediaQuery.of(context).size.width *
  //                                             .036),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(
  //                             height: 5,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(
  //                     left: 25, right: 25, top: 25, bottom: 25),
  //                 child: Material(
  //                   elevation: 6,
  //                   borderRadius: BorderRadius.circular(10),
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(10),
  //                       border: Border.all(
  //                           color: const Color.fromRGBO(21, 43, 81, 1)),
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(
  //                           left: 25, right: 25, top: 20, bottom: 30),
  //                       child: Column(
  //                         children: [
  //                           Row(
  //                             children: [
  //                               const SizedBox(
  //                                 width: 2,
  //                               ),
  //                               Text(
  //                                 "Lease Details",
  //                                 style: TextStyle(
  //                                     color:
  //                                         const Color.fromRGBO(21, 43, 81, 1),
  //                                     fontWeight: FontWeight.bold,
  //                                     // fontSize: 18
  //                                     fontSize:
  //                                         MediaQuery.of(context).size.width *
  //                                             .045),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(
  //                             height: 10,
  //                           ),
  //                           SingleChildScrollView(
  //                             scrollDirection: Axis.horizontal,
  //                             child: DataTable(
  //                                 border: TableBorder.all(
  //                                   width: 1,
  //                                   color: const Color.fromRGBO(21, 43, 83, 1),
  //                                 ),
  //                                 columns: [
  //                                   const DataColumn(
  //                                     label: Text('Status'),
  //                                   ),
  //                                   const DataColumn(
  //                                     label: Text('Start - End'),
  //                                   ),
  //                                   const DataColumn(
  //                                     label: Text('Property'),
  //                                   ),
  //                                   const DataColumn(
  //                                     label: Text('Type'),
  //                                   ),
  //                                   const DataColumn(
  //                                     label: Text('Rent'),
  //                                   ),
  //                                 ],
  //                                 rows: [
  //                                   const DataRow(cells: <DataCell>[
  //                                     DataCell(Text('EXPIRED')),
  //                                     DataCell(
  //                                         Text('05-15-2024 To 06-15-2024')),
  //                                     DataCell(Text('105,Street Road')),
  //                                     DataCell(Text('Fixed')),
  //                                     DataCell(Text('30')),
  //                                   ])
  //                                 ]),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

  Tenant(context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5),
      itemCount: 1,
      itemBuilder: (context, index) {
        // String fullName = '${tenants[index].leaseTenantData} ${tenants[index].tenantLastName}';
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
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      // width: MediaQuery.of(context).size.width * .4,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(21, 43, 81, 1),
                        border: Border.all(
                            color: const Color.fromRGBO(21, 43, 81, 1)),
                        // color: Colors.blue,
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
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              // ('Tenant: ${rentalSummary.leaseTenantData[0].tenantData.tenantFirstName} ${rentalSummary.leaseTenantData[0].tenantData.tenantLastName}')
                              //  '${tenants[index].leaseTenantData![0].tenantData?.tenantFirstName} ${tenants[index].leaseTenantData![0].tenantData?.
                              //  tenantLastName}'
                              'yash trivedi',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              '105,Street Road',
                              // '${widget.properties.rentalAddress}',
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
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            bool isChecked =
                                false; // Moved isChecked inside the StatefulBuilder
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const Row(
                                          children: [
                                            SizedBox(
                                              width: 0,
                                            ),
                                            Text(
                                              "Move out Tenants",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Row(
                                          children: [
                                            SizedBox(
                                              width: 0,
                                            ),
                                            Expanded(
                                              child: Text(
                                                "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Color(0xFF8A95A8),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 0,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Material(
                                          elevation: 3,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            // height: 280,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .65,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                              // color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  child: Table(
                                                    border: TableBorder.all(
                                                        color: const Color
                                                            .fromRGBO(
                                                            21, 43, 81, 1)),
                                                    children: [
                                                      const TableRow(children: [
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              'Address/Unit',
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              'Lease Type',
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              'Start End',
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                      TableRow(children: [
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              '{widget.properties.rentalAddress}',
                                                              style: const TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              ' {tenants[index].leaseType}',
                                                              style: const TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              ' {tenants[index].createdAt} {tenants[index].updatedAt}',
                                                              style: const TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        ),
                                                      ])
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  child: Table(
                                                    border: TableBorder.all(
                                                        color: const Color
                                                            .fromRGBO(
                                                            21, 43, 81, 1)),
                                                    children: [
                                                      const TableRow(children: [
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              'Tenants',
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              'Notice Given Date',
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              'Move-Out Date',
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                      TableRow(children: [
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              ' {tenants[index].firstName} {tenants[index].lastName}',
                                                              style: const TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                const SizedBox(
                                                                    width: 2),
                                                                Expanded(
                                                                  child:
                                                                      Material(
                                                                    elevation:
                                                                        4,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .4,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(2),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              const Color(0xFF8A95A8),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          Positioned
                                                                              .fill(
                                                                            child:
                                                                                TextField(
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  // startdatederror = false;
                                                                                  // _selectDate(context);
                                                                                });
                                                                              },
                                                                              controller: startdateController,
                                                                              cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                              decoration: InputDecoration(
                                                                                hintText: "mm/dd/yyyy",
                                                                                hintStyle: TextStyle(
                                                                                  fontSize: MediaQuery.of(context).size.width * .037,
                                                                                  color: const Color(0xFF8A95A8),
                                                                                ),
                                                                                // enabledBorder: startdatederror
                                                                                //     ? OutlineInputBorder(
                                                                                //   borderRadius:
                                                                                //   BorderRadius.circular(3),
                                                                                //   borderSide: BorderSide(
                                                                                //     color: Colors.red,
                                                                                //   ),
                                                                                // )
                                                                                //     : InputBorder.none,
                                                                                border: InputBorder.none,
                                                                                contentPadding: const EdgeInsets.all(12),
                                                                                suffixIcon: IconButton(
                                                                                  icon: const Icon(Icons.calendar_today),
                                                                                  onPressed: () {},
                                                                                ),
                                                                              ),
                                                                              readOnly: true,
                                                                              onTap: () {
                                                                                // _startDate(context);
                                                                                setState(() {
                                                                                  //startdatederror = false;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 2),
                                                              ],
                                                            ),
                                                            // Text(
                                                            //   '${widget.properties.staffMemberData!.staffmemberName}',
                                                            //   style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                            // ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                const SizedBox(
                                                                    width: 2),
                                                                Expanded(
                                                                  child:
                                                                      Material(
                                                                    elevation:
                                                                        4,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      //width: MediaQuery.of(context).size.width * .6,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(2),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              const Color(0xFF8A95A8),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          Positioned
                                                                              .fill(
                                                                            child:
                                                                                TextField(
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  // startdatederror = false;
                                                                                  // _selectDate(context);
                                                                                });
                                                                              },
                                                                              controller: enddateController,
                                                                              cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                              decoration: InputDecoration(
                                                                                  hintText: "mm/dd/yyyy",
                                                                                  hintStyle: TextStyle(
                                                                                    fontSize: MediaQuery.of(context).size.width * .037,
                                                                                    color: const Color(0xFF8A95A8),
                                                                                  ),
                                                                                  // enabledBorder: startdatederror
                                                                                  //     ? OutlineInputBorder(
                                                                                  //   borderRadius:
                                                                                  //   BorderRadius.circular(3),
                                                                                  //   borderSide: BorderSide(
                                                                                  //     color: Colors.red,
                                                                                  //   ),
                                                                                  // )
                                                                                  //     : InputBorder.none,
                                                                                  border: InputBorder.none,
                                                                                  contentPadding: const EdgeInsets.all(12),
                                                                                  // suffixIcon: IconButton(
                                                                                  //   icon: const Icon(Icons.calendar_today),
                                                                                  //   onPressed: () => _endDate(context),
                                                                                  // )
                                                                                  // ,
                                                                                  suffixIcon: IconButton(
                                                                                    icon: const Icon(Icons.calendar_today),
                                                                                    onPressed: () {},
                                                                                  )),
                                                                              readOnly: true,
                                                                              onTap: () {
                                                                                // _endDate(context);
                                                                                setState(() {
                                                                                  //startdatederror = false;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 2),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ])
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 60,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                      child: Text(
                                                    "Close",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Material(
                                              elevation: 3,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                              child: Container(
                                                height: 30,
                                                width: 80,
                                                decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                ),
                                                child: const Center(
                                                    child: Text(
                                                  "Move Out",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                )),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.rightFromBracket,
                            size: 17,
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                          SizedBox(
                            width: 5,
                          ),
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
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 65,
                    ),
                    Text(
                      '05-29-2024  to',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(21, 43, 81, 1),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 65,
                    ),
                    Text(
                      // '${tenants[index].updatedAt}',
                      '06-01-2024',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(21, 43, 81, 1),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 65,
                    ),
                    const FaIcon(
                      FontAwesomeIcons.phone,
                      size: 15,
                      color: Color.fromRGBO(21, 43, 81, 1),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '1234567890',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(21, 43, 81, 1),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 65,
                    ),
                    const FaIcon(
                      FontAwesomeIcons.solidEnvelope,
                      size: 15,
                      color: Color.fromRGBO(21, 43, 81, 1),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'alex@gmail.com',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(21, 43, 81, 1),
                          fontWeight: FontWeight.w500),
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

class TenantPage extends StatefulWidget {
  const TenantPage({super.key});

  @override
  State<TenantPage> createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  TextEditingController enddateController = TextEditingController();
  TextEditingController startdateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container();
    // return FutureBuilder<List<TenantData>>(
    //   future: Properies_summery_Repo()
    //       .fetchPropertiessummery(''),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(
    //         child: Center(
    //             child: SpinKitFadingCircle(
    //           color: Colors.black,
    //           size: 40.0,
    //         )),
    //       );
    //     } else if (snapshot.hasError) {
    //       return Text('Error: ${snapshot.error}');
    //     } else {
    //       List<TenantData> tenants = snapshot.data ?? [];
    //       print(snapshot.data!.length);
    //       //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
    //       return ListView.builder(
    //         padding: const EdgeInsets.symmetric(vertical: 5),
    //         itemCount: tenants.length,
    //         itemBuilder: (context, index) {
    //           // String fullName = '${tenants[index].leaseTenantData} ${tenants[index].tenantLastName}';
    //           return Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: Container(
    //               height: 165,
    //               width: MediaQuery.of(context).size.width * .9,
    //               margin: const EdgeInsets.symmetric(horizontal: 10),
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(5),
    //                 border: Border.all(
    //                   color: const Color.fromRGBO(21, 43, 81, 1),
    //                 ),
    //               ),
    //               child: Column(
    //                 children: [
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   Row(
    //                     children: [
    //                       const SizedBox(
    //                         width: 15,
    //                       ),
    //                       Container(
    //                         height: 30,
    //                         width: 30,
    //                         // width: MediaQuery.of(context).size.width * .4,
    //                         decoration: BoxDecoration(
    //                           color: const Color.fromRGBO(21, 43, 81, 1),
    //                           border: Border.all(
    //                               color: const Color.fromRGBO(21, 43, 81, 1)),
    //                           // color: Colors.blue,
    //                           borderRadius: BorderRadius.circular(5),
    //                         ),
    //                         child: const Center(
    //                           child: FaIcon(
    //                             FontAwesomeIcons.user,
    //                             size: 16,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                       ),
    //                       const SizedBox(
    //                         width: 20,
    //                       ),
    //                       Column(
    //                         children: [
    //                           const SizedBox(
    //                             height: 4,
    //                           ),
    //                           Row(
    //                             children: [
    //                               const SizedBox(
    //                                 width: 2,
    //                               ),
    //                               Text(
    //                                 // ('Tenant: ${rentalSummary.leaseTenantData[0].tenantData.tenantFirstName} ${rentalSummary.leaseTenantData[0].tenantData.tenantLastName}')
    //                                 //  '${tenants[index].leaseTenantData![0].tenantData?.tenantFirstName} ${tenants[index].leaseTenantData![0].tenantData?.
    //                                 //  tenantLastName}'
    //                                 '{tenants[index].firstName} {tenants[index].lastName}',
    //                                 style: const TextStyle(
    //                                   fontSize: 14,
    //                                   fontWeight: FontWeight.bold,
    //                                   color: Color.fromRGBO(21, 43, 81, 1),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                           const SizedBox(
    //                             height: 4,
    //                           ),
    //                           Row(
    //                             children: [
    //                               const SizedBox(
    //                                 width: 2,
    //                               ),
    //                               Text(
    //                                 formatDate2(tenants[index].updatedAt!),
    //                                 // '${widget.properties.rentalAddress}',
    //                                 style: const TextStyle(
    //                                   fontSize: 11,
    //                                   color: Color(0xFF8A95A8),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                       const Spacer(),
    //                       InkWell(
    //                         onTap: () {
    //                           showDialog(
    //                             context: context,
    //                             builder: (BuildContext context) {
    //                               bool isChecked =
    //                                   false; // Moved isChecked inside the StatefulBuilder
    //                               return StatefulBuilder(
    //                                 builder: (BuildContext context,
    //                                     StateSetter setState) {
    //                                   return AlertDialog(
    //                                     backgroundColor: Colors.white,
    //                                     surfaceTintColor: Colors.white,
    //                                     content: SingleChildScrollView(
    //                                       child: Column(
    //                                         children: [
    //                                           const Row(
    //                                             children: [
    //                                               SizedBox(
    //                                                 width: 0,
    //                                               ),
    //                                               Text(
    //                                                 "Move out Tenants",
    //                                                 style: TextStyle(
    //                                                     fontWeight:
    //                                                         FontWeight.bold,
    //                                                     color: Color.fromRGBO(
    //                                                         21, 43, 81, 1),
    //                                                     fontSize: 15),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                           const SizedBox(
    //                                             height: 10,
    //                                           ),
    //                                           const Row(
    //                                             children: [
    //                                               SizedBox(
    //                                                 width: 0,
    //                                               ),
    //                                               Expanded(
    //                                                 child: Text(
    //                                                   "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
    //                                                   style: TextStyle(
    //                                                     fontWeight:
    //                                                         FontWeight.w500,
    //                                                     fontSize: 13,
    //                                                     color:
    //                                                         Color(0xFF8A95A8),
    //                                                   ),
    //                                                 ),
    //                                               ),
    //                                               SizedBox(
    //                                                 width: 0,
    //                                               ),
    //                                             ],
    //                                           ),
    //                                           const SizedBox(
    //                                             height: 15,
    //                                           ),
    //                                           Material(
    //                                             elevation: 3,
    //                                             borderRadius:
    //                                                 BorderRadius.circular(10),
    //                                             child: Container(
    //                                               // height: 280,
    //                                               width: MediaQuery.of(context)
    //                                                       .size
    //                                                       .width *
    //                                                   .65,
    //                                               decoration: BoxDecoration(
    //                                                 border: Border.all(
    //                                                     color: const Color
    //                                                         .fromRGBO(
    //                                                         21, 43, 81, 1)),
    //                                                 // color: Colors.blue,
    //                                                 borderRadius:
    //                                                     BorderRadius.circular(
    //                                                         5),
    //                                               ),
    //                                               child: Column(
    //                                                 children: [
    //                                                   const SizedBox(
    //                                                     height: 10,
    //                                                   ),
    //                                                   Padding(
    //                                                     padding:
    //                                                         const EdgeInsets
    //                                                             .only(
    //                                                             left: 5,
    //                                                             right: 5),
    //                                                     child: Table(
    //                                                       border: TableBorder.all(
    //                                                           color: const Color
    //                                                               .fromRGBO(21,
    //                                                               43, 81, 1)),
    //                                                       children: const [
    //                                                         TableRow(children: [
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   EdgeInsets
    //                                                                       .all(
    //                                                                           8.0),
    //                                                               child: Text(
    //                                                                 'Address/Unit',
    //                                                                 style: TextStyle(
    //                                                                     color: Color.fromRGBO(
    //                                                                         21,
    //                                                                         43,
    //                                                                         81,
    //                                                                         1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .bold,
    //                                                                     fontSize:
    //                                                                         13),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   EdgeInsets
    //                                                                       .all(
    //                                                                           8.0),
    //                                                               child: Text(
    //                                                                 'Lease Type',
    //                                                                 style: TextStyle(
    //                                                                     color: Color.fromRGBO(
    //                                                                         21,
    //                                                                         43,
    //                                                                         81,
    //                                                                         1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .bold,
    //                                                                     fontSize:
    //                                                                         13),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   EdgeInsets
    //                                                                       .all(
    //                                                                           8.0),
    //                                                               child: Text(
    //                                                                 'Start End',
    //                                                                 style: TextStyle(
    //                                                                     color: Color.fromRGBO(
    //                                                                         21,
    //                                                                         43,
    //                                                                         81,
    //                                                                         1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .bold,
    //                                                                     fontSize:
    //                                                                         13),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                         ]),
    //                                                         TableRow(children: [
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   EdgeInsets
    //                                                                       .all(
    //                                                                           8.0),
    //                                                               child: Text(
    //                                                                 '{widget.properties.rentalAddress}',
    //                                                                 style: TextStyle(
    //                                                                     color: Color.fromRGBO(
    //                                                                         21,
    //                                                                         43,
    //                                                                         81,
    //                                                                         1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .w500,
    //                                                                     fontSize:
    //                                                                         12),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   EdgeInsets
    //                                                                       .all(
    //                                                                           8.0),
    //                                                               child: Text(
    //                                                                 ' {tenants[index].leaseType}',
    //                                                                 style: TextStyle(
    //                                                                     color: Color.fromRGBO(
    //                                                                         21,
    //                                                                         43,
    //                                                                         81,
    //                                                                         1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .w500,
    //                                                                     fontSize:
    //                                                                         12),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   EdgeInsets
    //                                                                       .all(
    //                                                                           8.0),
    //                                                               child: Text(
    //                                                                 ' {tenants[index].createdAt} {tenants[index].updatedAt}',
    //                                                                 style: TextStyle(
    //                                                                     color: Color.fromRGBO(
    //                                                                         21,
    //                                                                         43,
    //                                                                         81,
    //                                                                         1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .w500,
    //                                                                     fontSize:
    //                                                                         12),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                         ])
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                   const SizedBox(
    //                                                     height: 10,
    //                                                   ),
    //                                                   Padding(
    //                                                     padding:
    //                                                         const EdgeInsets
    //                                                             .only(
    //                                                             left: 5,
    //                                                             right: 5),
    //                                                     child: Table(
    //                                                       border: TableBorder.all(
    //                                                           color: const Color
    //                                                               .fromRGBO(21,
    //                                                               43, 81, 1)),
    //                                                       children: [
    //                                                         const TableRow(
    //                                                             children: [
    //                                                               TableCell(
    //                                                                 child:
    //                                                                     Padding(
    //                                                                   padding:
    //                                                                       EdgeInsets.all(
    //                                                                           8.0),
    //                                                                   child:
    //                                                                       Text(
    //                                                                     'Tenants',
    //                                                                     style: TextStyle(
    //                                                                         color: Color.fromRGBO(
    //                                                                             21,
    //                                                                             43,
    //                                                                             81,
    //                                                                             1),
    //                                                                         fontWeight:
    //                                                                             FontWeight.bold,
    //                                                                         fontSize: 13),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               TableCell(
    //                                                                 child:
    //                                                                     Padding(
    //                                                                   padding:
    //                                                                       EdgeInsets.all(
    //                                                                           8.0),
    //                                                                   child:
    //                                                                       Text(
    //                                                                     'Notice Given Date',
    //                                                                     style: TextStyle(
    //                                                                         color: Color.fromRGBO(
    //                                                                             21,
    //                                                                             43,
    //                                                                             81,
    //                                                                             1),
    //                                                                         fontWeight:
    //                                                                             FontWeight.bold,
    //                                                                         fontSize: 13),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               TableCell(
    //                                                                 child:
    //                                                                     Padding(
    //                                                                   padding:
    //                                                                       EdgeInsets.all(
    //                                                                           8.0),
    //                                                                   child:
    //                                                                       Text(
    //                                                                     'Move-Out Date',
    //                                                                     style: TextStyle(
    //                                                                         color: Color.fromRGBO(
    //                                                                             21,
    //                                                                             43,
    //                                                                             81,
    //                                                                             1),
    //                                                                         fontWeight:
    //                                                                             FontWeight.bold,
    //                                                                         fontSize: 13),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                             ]),
    //                                                         TableRow(children: [
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   const EdgeInsets
    //                                                                       .all(
    //                                                                       8.0),
    //                                                               child: Text(
    //                                                                 ' {tenants[index].firstName} {tenants[index].lastName}',
    //                                                                 style: const TextStyle(
    //                                                                     color: Color.fromRGBO(
    //                                                                         21,
    //                                                                         43,
    //                                                                         81,
    //                                                                         1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .w500,
    //                                                                     fontSize:
    //                                                                         12),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   const EdgeInsets
    //                                                                       .all(
    //                                                                       8.0),
    //                                                               child: Row(
    //                                                                 children: [
    //                                                                   const SizedBox(
    //                                                                       width:
    //                                                                           2),
    //                                                                   Expanded(
    //                                                                     child:
    //                                                                         Material(
    //                                                                       elevation:
    //                                                                           4,
    //                                                                       child:
    //                                                                           Container(
    //                                                                         height:
    //                                                                             50,
    //                                                                         width:
    //                                                                             MediaQuery.of(context).size.width * .4,
    //                                                                         decoration:
    //                                                                             BoxDecoration(
    //                                                                           borderRadius: BorderRadius.circular(2),
    //                                                                           border: Border.all(
    //                                                                             color: const Color(0xFF8A95A8),
    //                                                                           ),
    //                                                                         ),
    //                                                                         child:
    //                                                                             Stack(
    //                                                                           children: [
    //                                                                             Positioned.fill(
    //                                                                               child: TextField(
    //                                                                                 onChanged: (value) {
    //                                                                                   setState(() {
    //                                                                                     // startdatederror = false;
    //                                                                                     // _selectDate(context);
    //                                                                                   });
    //                                                                                 },
    //                                                                                 controller: startdateController,
    //                                                                                 cursorColor: const Color.fromRGBO(21, 43, 81, 1),
    //                                                                                 decoration: InputDecoration(
    //                                                                                   hintText: "mm/dd/yyyy",
    //                                                                                   hintStyle: TextStyle(
    //                                                                                     fontSize: MediaQuery.of(context).size.width * .037,
    //                                                                                     color: const Color(0xFF8A95A8),
    //                                                                                   ),
    //                                                                                   // enabledBorder: startdatederror
    //                                                                                   //     ? OutlineInputBorder(
    //                                                                                   //   borderRadius:
    //                                                                                   //   BorderRadius.circular(3),
    //                                                                                   //   borderSide: BorderSide(
    //                                                                                   //     color: Colors.red,
    //                                                                                   //   ),
    //                                                                                   // )
    //                                                                                   //     : InputBorder.none,
    //                                                                                   border: InputBorder.none,
    //                                                                                   contentPadding: const EdgeInsets.all(12),
    //                                                                                   // suffixIcon: IconButton(
    //                                                                                   //   icon: Icon(Icons.calendar_today),
    //                                                                                   //   onPressed: () => _startDate(context),
    //                                                                                   // ),
    //                                                                                   suffixIcon: IconButton(
    //                                                                                     icon: const Icon(Icons.calendar_today),
    //                                                                                     onPressed: () {},
    //                                                                                   ),
    //                                                                                 ),
    //                                                                                 readOnly: true,
    //                                                                                 onTap: () {
    //                                                                                   // _startDate(context);
    //                                                                                   setState(() {
    //                                                                                     //startdatederror = false;
    //                                                                                   });
    //                                                                                 },
    //                                                                               ),
    //                                                                             ),
    //                                                                           ],
    //                                                                         ),
    //                                                                       ),
    //                                                                     ),
    //                                                                   ),
    //                                                                   const SizedBox(
    //                                                                       width:
    //                                                                           2),
    //                                                                 ],
    //                                                               ),
    //                                                               // Text(
    //                                                               //   '${widget.properties.staffMemberData!.staffmemberName}',
    //                                                               //   style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
    //                                                               // ),
    //                                                             ),
    //                                                           ),
    //                                                           TableCell(
    //                                                             child: Padding(
    //                                                               padding:
    //                                                                   const EdgeInsets
    //                                                                       .all(
    //                                                                       8.0),
    //                                                               child: Row(
    //                                                                 children: [
    //                                                                   const SizedBox(
    //                                                                       width:
    //                                                                           2),
    //                                                                   Expanded(
    //                                                                     child:
    //                                                                         Material(
    //                                                                       elevation:
    //                                                                           4,
    //                                                                       child:
    //                                                                           Container(
    //                                                                         height:
    //                                                                             50,
    //                                                                         //width: MediaQuery.of(context).size.width * .6,
    //                                                                         decoration:
    //                                                                             BoxDecoration(
    //                                                                           borderRadius: BorderRadius.circular(2),
    //                                                                           border: Border.all(
    //                                                                             color: const Color(0xFF8A95A8),
    //                                                                           ),
    //                                                                         ),
    //                                                                         child:
    //                                                                             Stack(
    //                                                                           children: [
    //                                                                             Positioned.fill(
    //                                                                               child: TextField(
    //                                                                                 onChanged: (value) {
    //                                                                                   setState(() {
    //                                                                                     // startdatederror = false;
    //                                                                                     // _selectDate(context);
    //                                                                                   });
    //                                                                                 },
    //                                                                                 controller: enddateController,
    //                                                                                 cursorColor: const Color.fromRGBO(21, 43, 81, 1),
    //                                                                                 decoration: InputDecoration(
    //                                                                                   hintText: "mm/dd/yyyy",
    //                                                                                   hintStyle: TextStyle(
    //                                                                                     fontSize: MediaQuery.of(context).size.width * .037,
    //                                                                                     color: const Color(0xFF8A95A8),
    //                                                                                   ),
    //                                                                                   // enabledBorder: startdatederror
    //                                                                                   //     ? OutlineInputBorder(
    //                                                                                   //   borderRadius:
    //                                                                                   //   BorderRadius.circular(3),
    //                                                                                   //   borderSide: BorderSide(
    //                                                                                   //     color: Colors.red,
    //                                                                                   //   ),
    //                                                                                   // )
    //                                                                                   //     : InputBorder.none,
    //                                                                                   border: InputBorder.none,
    //                                                                                   contentPadding: const EdgeInsets.all(12),
    //                                                                                   // suffixIcon: IconButton(
    //                                                                                   //   icon: Icon(Icons.calendar_today),
    //                                                                                   //   onPressed: () => _endDate(context),
    //                                                                                   // ),
    //                                                                                   suffixIcon: IconButton(
    //                                                                                     icon: const Icon(Icons.calendar_today),
    //                                                                                     onPressed: () => {},
    //                                                                                   ),
    //                                                                                 ),
    //                                                                                 readOnly: true,
    //                                                                                 onTap: () {
    //                                                                                   // _endDate(context);
    //                                                                                   setState(() {
    //                                                                                     //startdatederror = false;
    //                                                                                   });
    //                                                                                 },
    //                                                                               ),
    //                                                                             ),
    //                                                                           ],
    //                                                                         ),
    //                                                                       ),
    //                                                                     ),
    //                                                                   ),
    //                                                                   const SizedBox(
    //                                                                       width:
    //                                                                           2),
    //                                                                 ],
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                         ])
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                   const SizedBox(
    //                                                     height: 10,
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           const SizedBox(
    //                                             height: 20,
    //                                           ),
    //                                           Row(
    //                                             mainAxisAlignment:
    //                                                 MainAxisAlignment.end,
    //                                             crossAxisAlignment:
    //                                                 CrossAxisAlignment.end,
    //                                             children: [
    //                                               GestureDetector(
    //                                                 onTap: () {
    //                                                   Navigator.pop(context);
    //                                                 },
    //                                                 child: Material(
    //                                                   elevation: 3,
    //                                                   borderRadius:
    //                                                       const BorderRadius
    //                                                           .all(
    //                                                     Radius.circular(5),
    //                                                   ),
    //                                                   child: Container(
    //                                                     height: 30,
    //                                                     width: 60,
    //                                                     decoration:
    //                                                         const BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       borderRadius:
    //                                                           BorderRadius.all(
    //                                                         Radius.circular(5),
    //                                                       ),
    //                                                     ),
    //                                                     child: const Center(
    //                                                         child: Text(
    //                                                       "Close",
    //                                                       style: TextStyle(
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .w500,
    //                                                           color: Color
    //                                                               .fromRGBO(
    //                                                                   21,
    //                                                                   43,
    //                                                                   81,
    //                                                                   1)),
    //                                                     )),
    //                                                   ),
    //                                                 ),
    //                                               ),
    //                                               const SizedBox(
    //                                                 width: 10,
    //                                               ),
    //                                               Material(
    //                                                 elevation: 3,
    //                                                 borderRadius:
    //                                                     const BorderRadius.all(
    //                                                   Radius.circular(5),
    //                                                 ),
    //                                                 child: Container(
    //                                                   height: 30,
    //                                                   width: 80,
    //                                                   decoration:
    //                                                       const BoxDecoration(
    //                                                     color: Color.fromRGBO(
    //                                                         21, 43, 81, 1),
    //                                                     borderRadius:
    //                                                         BorderRadius.all(
    //                                                       Radius.circular(5),
    //                                                     ),
    //                                                   ),
    //                                                   child: const Center(
    //                                                       child: Text(
    //                                                     "Move Out",
    //                                                     style: TextStyle(
    //                                                         fontWeight:
    //                                                             FontWeight.bold,
    //                                                         color: Colors.white,
    //                                                         fontSize: 13),
    //                                                   )),
    //                                                 ),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                           const SizedBox(
    //                                             height: 15,
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                   );
    //                                 },
    //                               );
    //                             },
    //                           );
    //                         },
    //                         child: const Row(
    //                           children: [
    //                             FaIcon(
    //                               FontAwesomeIcons.rightFromBracket,
    //                               size: 17,
    //                               color: Color.fromRGBO(21, 43, 81, 1),
    //                             ),
    //                             SizedBox(
    //                               width: 5,
    //                             ),
    //                             Text(
    //                               "Move out",
    //                               style: TextStyle(
    //                                 fontSize: 11,
    //                                 fontWeight: FontWeight.w500,
    //                                 color: Color.fromRGBO(21, 43, 81, 1),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       const SizedBox(
    //                         width: 15,
    //                       ),
    //                     ],
    //                   ),
    //                   const SizedBox(
    //                     height: 15,
    //                   ),
    //                   Row(
    //                     children: [
    //                       const SizedBox(
    //                         width: 65,
    //                       ),
    //                       Text(
    //                         '${tenants[index].createdAt}  to',
    //                         style: const TextStyle(
    //                             fontSize: 12,
    //                             color: Color.fromRGBO(21, 43, 81, 1),
    //                             fontWeight: FontWeight.w500),
    //                       ),
    //                     ],
    //                   ),
    //                   Row(
    //                     children: [
    //                       const SizedBox(
    //                         width: 65,
    //                       ),
    //                       Text(
    //                         // '${tenants[index].updatedAt}',
    //                         '${tenants[index].updatedAt}',
    //                         style: const TextStyle(
    //                             fontSize: 12,
    //                             color: Color.fromRGBO(21, 43, 81, 1),
    //                             fontWeight: FontWeight.w500),
    //                       ),
    //                     ],
    //                   ),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   Row(
    //                     children: [
    //                       const SizedBox(
    //                         width: 65,
    //                       ),
    //                       const FaIcon(
    //                         FontAwesomeIcons.phone,
    //                         size: 15,
    //                         color: Color.fromRGBO(21, 43, 81, 1),
    //                       ),
    //                       const SizedBox(
    //                         width: 5,
    //                       ),
    //                       Text(
    //                         '{tenants[index].phoneNumber}',
    //                         style: const TextStyle(
    //                             fontSize: 12,
    //                             color: Color.fromRGBO(21, 43, 81, 1),
    //                             fontWeight: FontWeight.w500),
    //                       ),
    //                     ],
    //                   ),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   Row(
    //                     // mainAxisAlignment: MainAxisAlignment.center,
    //                     // crossAxisAlignment: CrossAxisAlignment.center,
    //                     children: [
    //                       const SizedBox(
    //                         width: 65,
    //                       ),
    //                       const FaIcon(
    //                         FontAwesomeIcons.solidEnvelope,
    //                         size: 15,
    //                         color: Color.fromRGBO(21, 43, 81, 1),
    //                       ),
    //                       const SizedBox(
    //                         width: 5,
    //                       ),
    //                       Text(
    //                         '{tenants[index].email}',
    //                         style: const TextStyle(
    //                             fontSize: 12,
    //                             color: Color.fromRGBO(21, 43, 81, 1),
    //                             fontWeight: FontWeight.w500),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           );
    //         },
    //       );
    //     }
    //   },
    // );
  }
}
