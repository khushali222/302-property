import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/RentalOwnersData.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';

class SummeryPageLease extends StatefulWidget {
  String rentalOwnersid;
  SummeryPageLease({super.key, required this.rentalOwnersid});
  @override
  State<SummeryPageLease> createState() => _SummeryPageLeaseState();
}

class _SummeryPageLeaseState extends State<SummeryPageLease>
    with SingleTickerProviderStateMixin {
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
                const SummaryPage(),
                const FinancialPage(),
                const TenantPage()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List formDataRecurringList = [];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<RentalOwnerData>>(
        future: RentalOwnerService().fetchRentalOwnerssummery('1715146591684'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Center(
                  child: SpinKitFadingCircle(
                color: Colors.black,
                size: 40.0,
              )),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<RentalOwnerData> rentalownersummery = snapshot.data ?? [];
            print(snapshot.data!.length);
            //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
            return ListView(
              scrollDirection: Axis.vertical,
              children: [
                //Personal information
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
                                      color:
                                          const Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.bold,
                                      // fontSize: 18
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .045),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //first name
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
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .036),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 2),
                                // Text(
                                //   '${rentalownersummery.isNotEmpty && rentalownersummery.first.rentalOwnerName != null ? rentalownersummery.first.rentalOwnerName : 'N/A'}',
                                // ),
                                Text(
                                  '${rentalownersummery.first.rentalOwnername}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                                const SizedBox(width: 2),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            //company name
                            Row(
                              children: [
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "Rental Owner",
                                  style: TextStyle(
                                      // color: Colors.grey,
                                      color: const Color(0xFF8A95A8),
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .036),
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
                                  '${rentalownersummery.first.rentalOwnerCompanyName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                                const SizedBox(width: 2),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            //street address
                            Row(
                              children: [
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "Tenant",
                                  style: TextStyle(
                                      // color: Colors.grey,
                                      color: const Color(0xFF8A95A8),
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .036),
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
                                  '${rentalownersummery.first.streetAddress}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                                const SizedBox(width: 2),
                              ],
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
                                      color:
                                          const Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.bold,
                                      // fontSize: 18
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
                                    const DataRow(cells: <DataCell>[
                                      DataCell(Text('EXPIRED')),
                                      DataCell(
                                          Text('05-15-2024 To 06-15-2024')),
                                      DataCell(Text('105,Street Road')),
                                      DataCell(Text('Fixed')),
                                      DataCell(Text('30')),
                                    ])
                                  ]),
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
      ),
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
//Property : undefined
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Text(
            "Property:",
            style: TextStyle(
                color: const Color(0xFF8f9aac),
                fontWeight: FontWeight.w500,
                // fontSize: 18
                fontSize: MediaQuery.of(context).size.width * .035),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Text(
            "undefined",
            style: TextStyle(
                color: const Color.fromRGBO(21, 43, 81, 1),
                fontWeight: FontWeight.w500,
                // fontSize: 18
                fontSize: MediaQuery.of(context).size.width * .045),
          ),
        ),

        //Personal information
        // Padding(
        //   padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
        //   child: Material(
        //     elevation: 6,
        //     borderRadius: BorderRadius.circular(10),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(10),
        //         border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
        //       ),
        //       child: Padding(
        //         padding: const EdgeInsets.only(
        //             left: 16, right: 16, top: 16, bottom: 16),
        //         child: Stack(
        //           children: [
        //             Positioned(
        //               left: 0,
        //               top: 0,
        //               child: Container(
        //                   height: 40,
        //                   width: 40,
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(8.0),
        //                     color: const Color.fromRGBO(21, 43, 83, 1),
        //                   ),
        //                   child: const Center(
        //                       child: Icon(
        //                     Icons.person_outline_rounded,
        //                     color: Colors.white,
        //                   ))),
        //             ),
        //             Positioned(
        //               left: 50,
        //               top: 0,
        //               child: Container(
        //                 width: 160,
        //                 color: Colors.amber,
        //                 child: const Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     Text(
        //                       'Alex Wikins',
        //                       style: TextStyle(
        //                           color: Color.fromRGBO(21, 43, 83, 1),
        //                           fontSize: 18,
        //                           fontWeight: FontWeight.w600),
        //                     ),
        //                     SizedBox(
        //                       height: 4,
        //                     ),
        //                     Text(
        //                       '800 Barksdale Road - 1',
        //                       style: TextStyle(
        //                           color: Color(0xff8f9aac),
        //                           fontSize: 12,
        //                           fontWeight: FontWeight.w600),
        //                     ),
        //                     SizedBox(
        //                       height: 4,
        //                     ),
        //                     Text(
        //                       '06-28-2024 to 12-28-2024',
        //                       style: TextStyle(
        //                           color: Color.fromRGBO(21, 43, 83, 1),
        //                           fontSize: 12,
        //                           fontWeight: FontWeight.w600),
        //                     ),
        //                     SizedBox(
        //                       height: 4,
        //                     ),
        //                     Row(
        //                       children: [
        //                         Icon(
        //                           Icons.phone,
        //                           size: 18,
        //                           color: Color.fromRGBO(21, 43, 83, 1),
        //                         ),
        //                         SizedBox(
        //                           width: 4,
        //                         ),
        //                         Text(
        //                           '8742373212',
        //                           style: TextStyle(
        //                               color: Color.fromRGBO(21, 43, 83, 1),
        //                               fontSize: 12,
        //                               fontWeight: FontWeight.w600),
        //                         ),
        //                       ],
        //                     ),
        //                     SizedBox(
        //                       height: 4,
        //                     ),
        //                     Row(
        //                       children: [
        //                         Icon(
        //                           Icons.email,
        //                           size: 18,
        //                           color: Color.fromRGBO(21, 43, 83, 1),
        //                         ),
        //                         SizedBox(
        //                           width: 4,
        //                         ),
        //                         Text(
        //                           'alex@properties.com',
        //                           style: TextStyle(
        //                               color: Color.fromRGBO(21, 43, 83, 1),
        //                               fontSize: 12,
        //                               fontWeight: FontWeight.w600),
        //                         ),
        //                       ],
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //             Positioned(
        //               top: 0,
        //               right: 0,
        //               child: Container(
        //                 child: const Column(
        //                   children: [
        //                     Row(
        //                       children: [
        //                         Icon(Icons.logout_rounded),
        //                         Text(
        //                           'Move out',
        //                           style: TextStyle(
        //                               color: Color.fromRGBO(21, 43, 83, 1),
        //                               fontSize: 14,
        //                               fontWeight: FontWeight.w600),
        //                         ),
        //                       ],
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: const Color.fromRGBO(21, 43, 83, 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alex Wikins',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 83, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '800 Barksdale Road - 1',
                            style: TextStyle(
                              color: Color(0xff8f9aac),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '06-28-2024 to 12-28-2024',
                            style: TextStyle(
                                color: Color.fromRGBO(21, 43, 83, 1),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(
                                Icons.phone,
                                size: 18,
                                color: Color.fromRGBO(21, 43, 83, 1),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '8742373212',
                                style: TextStyle(
                                  color: Color.fromRGBO(21, 43, 83, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(
                                Icons.email,
                                size: 18,
                                color: Color.fromRGBO(21, 43, 83, 1),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'alex@properties.com',
                                style: TextStyle(
                                  color: Color.fromRGBO(21, 43, 83, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: const Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.logout_rounded),
                              SizedBox(width: 4),
                              Text(
                                'Move out',
                                style: TextStyle(
                                  color: Color.fromRGBO(21, 43, 83, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding:
              const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 25),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
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
                              // fontSize: 18
                              fontSize:
                                  MediaQuery.of(context).size.width * .045),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
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
                            const DataRow(cells: <DataCell>[
                              DataCell(Text('EXPIRED')),
                              DataCell(Text('05-15-2024 To 06-15-2024')),
                              DataCell(Text('105,Street Road')),
                              DataCell(Text('Fixed')),
                              DataCell(Text('30')),
                            ])
                          ]),
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
}
