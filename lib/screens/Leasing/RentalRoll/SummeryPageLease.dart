// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';

// import 'package:three_zero_two_property/Model/tenants.dart';

// import 'package:three_zero_two_property/constant/constant.dart';
// import 'package:three_zero_two_property/repository/lease.dart';

// import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';
// // import 'package:three_zero_two_property/repository/properties_summery.dart';
// import 'package:three_zero_two_property/widgets/appbar.dart';

// import '../../../../Model/RentalOwnersData.dart';

// import '../../../../model/lease.dart';
// import '../../../../repository/Rental_ownersData.dart';
// import '../../../../repository/properties_summery.dart';
// import '../../../../widgets/drawer_tiles.dart';
// import '../../../model/LeaseSummary.dart';
// import 'Financial.dart';

// class SummeryPageLease extends StatefulWidget {
//   String leaseId;
//   SummeryPageLease({super.key, required this.leaseId});
//   @override
//   State<SummeryPageLease> createState() => _SummeryPageLeaseState();
// }

// class _SummeryPageLeaseState extends State<SummeryPageLease>
//     with SingleTickerProviderStateMixin {
//   TextEditingController startdateController = TextEditingController();
//   TextEditingController enddateController = TextEditingController();
//   List formDataRecurringList = [];
//   late Future<LeaseSummary> futureLeaseSummary;

//   TabController? _tabController;
//   @override
//   void initState() {
//     // TODO: implement initState
//     futureLeaseSummary = LeaseRepository.fetchLeaseSummary(widget.leaseId);
//     _tabController = TabController(length: 3, vsync: this);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       // appBar: widget302.,
//       appBar: widget_302.App_Bar(context: context),
//       backgroundColor: Colors.white,
//       drawer: Drawer(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Image.asset("assets/images/logo.png"),
//               ),
//               const SizedBox(height: 40),
//               buildListTile(
//                   context,
//                   const Icon(
//                     CupertinoIcons.circle_grid_3x3,
//                     color: Colors.black,
//                   ),
//                   "Dashboard",
//                   false),
//               buildListTile(
//                   context,
//                   const Icon(
//                     CupertinoIcons.house,
//                     color: Colors.black,
//                   ),
//                   "Add Property Type",
//                   false),
//               buildListTile(
//                   context,
//                   const Icon(
//                     CupertinoIcons.person_add,
//                     color: Colors.black,
//                   ),
//                   "Add Staff Member",
//                   false),
//               buildDropdownListTile(
//                   context,
//                   const FaIcon(
//                     FontAwesomeIcons.key,
//                     size: 20,
//                     color: Colors.black,
//                   ),
//                   "Rental",
//                   ["Properties", "RentalOwner", "Tenants"],
//                   selectedSubtopic: "Properties"),
//               buildDropdownListTile(
//                   context,
//                   const FaIcon(
//                     FontAwesomeIcons.thumbsUp,
//                     size: 20,
//                     color: Colors.black,
//                   ),
//                   "Leasing",
//                   ["Rent Roll", "Applicants"],
//                   selectedSubtopic: "Properties"),
//               buildDropdownListTile(
//                   context,
//                   Image.asset("assets/icons/maintence.png",
//                       height: 20, width: 20),
//                   "Maintenance",
//                   ["Vendor", "Work Order"],
//                   selectedSubtopic: "Properties"),
//             ],
//           ),
//         ),
//       ),
//       body: FutureBuilder<LeaseSummary>(
//           future: futureLeaseSummary,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: SpinKitFadingCircle(
//                   color: Colors.black,
//                   size: 55.0,
//                 ),
//               );
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data == null) {
//               return Center(child: Text('No data found.'));
//             } else {
//               return Column(
//                 children: <Widget>[
//                   const SizedBox(
//                     height: 50,
//                   ),
//                   Row(
//                     children: [
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Text('${snapshot.data!.data!.rentalAddress}',
//                           style: TextStyle(
//                               color: Color.fromRGBO(21, 43, 81, 1),
//                               fontWeight: FontWeight.bold)),
//                       const Spacer(),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Material(
//                               elevation: 3,
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(5),
//                               ),
//                               child: Container(
//                                 height: 40,
//                                 width: 80,
//                                 decoration: const BoxDecoration(
//                                   color: Color.fromRGBO(21, 43, 81, 1),
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(5),
//                                   ),
//                                 ),
//                                 child: const Center(
//                                     child: Text(
//                                   "Back",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.white),
//                                 )),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Text(
//                           '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
//                           style: TextStyle(
//                               color: Color(0xFF8A95A8),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12)),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 10),
//                     height: 60,
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                           color: const Color.fromRGBO(21, 43, 81, 1)),
//                       // color: Colors.blue,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: TabBar(
//                       controller: _tabController,
//                       dividerColor: Colors.transparent,
//                       indicatorWeight: 5,
//                       //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
//                       indicatorColor: const Color.fromRGBO(21, 43, 81, 1),
//                       labelColor: const Color.fromRGBO(21, 43, 81, 1),
//                       unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
//                       tabs: [
//                         const Tab(text: 'Summary'),
//                         const Tab(
//                           text: 'Financial',
//                         ),
//                         StatefulBuilder(
//                           builder: (BuildContext context,
//                               void Function(void Function()) setState) {
//                             return const Tab(text: 'Tenant');
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         SummaryPage(),
//                         FinancialTable(
//                           leaseId: widget.leaseId,
//                           status:
//                               '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate).toString()}',
//                           tenantId: ' ${snapshot.data!.data!.tenantId}',
//                         ),
//                         Tenant(context),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             }
//           }),
//     );
//   }

//   int? expandedIndex;
//   bool isExpanded = false;

//   String determineStatus(String? startDate, String? endDate) {
//     if (startDate == null || endDate == null) return 'Unknown';

//     DateTime start = DateFormat('yyyy-MM-dd').parse(startDate);
//     DateTime end = DateFormat('yyyy-MM-dd').parse(endDate);
//     DateTime today = DateTime.now();

//     if (today.isBefore(start)) {
//       return 'Future';
//     } else if (today.isAfter(end)) {
//       return 'Expired';
//     } else {
//       return 'Active';
//     }
//   }

//   SummaryPage() {
//     var width = MediaQuery.of(context).size.width;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return FutureBuilder<LeaseSummary>(
//       future: futureLeaseSummary,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data == null) {
//           return Center(child: Text('No data found.'));
//         } else {
//           return ListView(
//             scrollDirection: Axis.vertical,
//             children: [
//               if (MediaQuery.of(context).size.width < 500)
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
//                   child: Material(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                             color: const Color.fromRGBO(21, 43, 81, 1)),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 25, right: 25, top: 20, bottom: 30),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 const SizedBox(
//                                   width: 2,
//                                 ),
//                                 Text(
//                                   "Tenant Details",
//                                   style: TextStyle(
//                                       color:
//                                           const Color.fromRGBO(21, 43, 81, 1),
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 21),
//                                 ),
//                               ],
//                             ),
//                             Divider(color: blueColor),
//                             const SizedBox(
//                               height: 10,
//                             ),

//                             Table(
//                               children: [
//                                 TableRow(children: [
//                                   TableCell(
//                                       child: Padding(
//                                     padding: const EdgeInsets.all(12.0),
//                                     child: Text(
//                                       'Unit',
//                                       style: TextStyle(
//                                           color: const Color(0xFF8A95A8),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16),
//                                     ),
//                                   )),
//                                   TableCell(
//                                       child: Padding(
//                                     padding: const EdgeInsets.only(top: 12),
//                                     child: Text(
//                                       '${snapshot.data!.data!.rentalAddress}',
//                                       style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                           color: blueColor),
//                                     ),
//                                   )),
//                                 ]),
//                                 TableRow(children: [
//                                   TableCell(
//                                       child: Padding(
//                                     padding: const EdgeInsets.all(12.0),
//                                     child: Text(
//                                       'Rental Owner',
//                                       style: TextStyle(
//                                           color: const Color(0xFF8A95A8),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16),
//                                     ),
//                                   )),
//                                   TableCell(
//                                       child: Padding(
//                                     padding: const EdgeInsets.only(top: 12),
//                                     child: Text(
//                                       '${snapshot.data!.data!.rentalOwnerName ?? 'N/A'}',
//                                       style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                           color: blueColor),
//                                     ),
//                                   )),
//                                 ]),
//                                 TableRow(children: [
//                                   TableCell(
//                                       child: Padding(
//                                     padding: const EdgeInsets.all(12.0),
//                                     child: Text(
//                                       'Tenant',
//                                       style: TextStyle(
//                                           color: const Color(0xFF8A95A8),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16),
//                                     ),
//                                   )),
//                                   TableCell(
//                                       child: Padding(
//                                     padding: const EdgeInsets.only(top: 12),
//                                     child: Column(
//                                       children: snapshot.data!.data!.tenantData!
//                                           .map((tenant) {
//                                         return Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             // Display Tenant Name
//                                             Row(
//                                               children: [
//                                                 const SizedBox(width: 5),
//                                                 Text(
//                                                   '${tenant.tenantFirstName}  ${tenant.tenantLastName}' ??
//                                                       'N/A',
//                                                   style: TextStyle(
//                                                     fontSize: 15,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Color.fromRGBO(
//                                                         21, 43, 83, 1),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),

//                                             const SizedBox(height: 5),
//                                           ],
//                                         );
//                                       }).toList(),
//                                     ),
//                                   )),
//                                 ]),
//                               ],
//                             ),
//                             // Unit ID
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               if (MediaQuery.of(context).size.width > 500)
//                 Row(
//                   children: [
//                     Padding(
//                       padding:
//                           const EdgeInsets.only(left: 16, right: 16, top: 16),
//                       child: Material(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Container(
//                           width: screenWidth * 0.45,
//                           height: 370,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                                 color: const Color.fromRGBO(21, 43, 81, 1)),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 25, right: 25, top: 20, bottom: 30),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Tenant Details",
//                                       style: TextStyle(
//                                           color: const Color.fromRGBO(
//                                               21, 43, 81, 1),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 24),
//                                     ),
//                                   ],
//                                 ),
//                                 Divider(color: blueColor),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 // Unit ID
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Unit",
//                                       style: TextStyle(
//                                           color: const Color(0xFF8A95A8),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 17),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${snapshot.data!.data!.rentalAddress}',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromRGBO(21, 43, 83, 1),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 2),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 // Rental Owner
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Rental Owner",
//                                       style: TextStyle(
//                                           color: const Color(0xFF8A95A8),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 17),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${snapshot.data!.data!.rentalOwnerName ?? 'N/A'}',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromRGBO(21, 43, 83, 1),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 2),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 // Tenant
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Tenant",
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         color: const Color(0xFF8A95A8),
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 5),
//                                 //// Display tenant details here if needed
//                                 if (snapshot.data!.data!.tenantData != null &&
//                                     snapshot.data!.data!.tenantData!.isNotEmpty)
//                                   Column(
//                                     children: snapshot.data!.data!.tenantData!
//                                         .map((tenant) {
//                                       return Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Display Tenant Name
//                                           Row(
//                                             children: [
//                                               const SizedBox(width: 5),
//                                               Text(
//                                                 '${tenant.tenantFirstName}  ${tenant.tenantLastName}' ??
//                                                     'N/A',
//                                                 style: TextStyle(
//                                                   fontSize: 15,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Color.fromRGBO(
//                                                       21, 43, 83, 1),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),

//                                           const SizedBox(height: 5),
//                                         ],
//                                       );
//                                     }).toList(),
//                                   ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           const EdgeInsets.only(left: 16, right: 16, top: 16),
//                       child: Material(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Container(
//                           width: screenWidth * 0.45,
//                           height: 370,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                                 color: const Color.fromRGBO(21, 43, 81, 1)),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 25, right: 25, top: 20, bottom: 30),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Lease Details",
//                                       style: TextStyle(
//                                           color: const Color.fromRGBO(
//                                               21, 43, 81, 1),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 24),
//                                     ),
//                                   ],
//                                 ),
//                                 Divider(color: blueColor),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 // Unit ID
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Status",
//                                       style: TextStyle(
//                                           color: const Color(0xFF8A95A8),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 17),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromRGBO(21, 43, 83, 1),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 2),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 // Rental Owner
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Start - End",
//                                       style: TextStyle(
//                                           color: const Color(0xFF8A95A8),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 17),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${snapshot.data!.data!.startDate} to ${snapshot.data!.data!.endDate}',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromRGBO(21, 43, 83, 1),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 2),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 // Tenant
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Property",
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         color: const Color(0xFF8A95A8),
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${snapshot.data!.data!.rentalAddress}',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromRGBO(21, 43, 83, 1),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 2),
//                                   ],
//                                 ),

//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 // Tenant
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Type",
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         color: const Color(0xFF8A95A8),
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${snapshot.data!.data!.leaseType}',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromRGBO(21, 43, 83, 1),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 2),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 // Tenant
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 2,
//                                     ),
//                                     Text(
//                                       "Rent",
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         color: const Color(0xFF8A95A8),
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${snapshot.data!.data!.amount}',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromRGBO(21, 43, 83, 1),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 2),
//                                   ],
//                                 ),
//                                 //// Display tenant details here if needed
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               if (MediaQuery.of(context).size.width < 500)
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
//                   child: Material(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                             color: const Color.fromRGBO(21, 43, 81, 1)),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 8, right: 8, top: 20, bottom: 30),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (MediaQuery.of(context).size.width < 500)
//                               Row(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                       left: 16,
//                                     ),
//                                     child: Text(
//                                       "Lease Details",
//                                       style: TextStyle(
//                                           color: const Color.fromRGBO(
//                                               21, 43, 81, 1),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 21),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             Divider(),
//                             const SizedBox(
//                               height: 10,
//                             ),

//                             Column(
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: blueColor,
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(13),
//                                       topRight: Radius.circular(13),
//                                     ),
//                                   ),
//                                   child: ListTile(
//                                     contentPadding: EdgeInsets.zero,
//                                     title: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Expanded(
//                                           flex: 3,
//                                           child: InkWell(
//                                             onTap: () {},
//                                             child: Row(
//                                               children: [
//                                                 width < 400
//                                                     ? const Padding(
//                                                         padding:
//                                                             EdgeInsets.only(
//                                                                 left: 20.0),
//                                                         child: Text(
//                                                           "Property",
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize: 14),
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                         ),
//                                                       )
//                                                     : const Text(
//                                                         "     Property",
//                                                         style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize: 14),
//                                                         textAlign:
//                                                             TextAlign.center),
//                                                 // Text("Property", style: TextStyle(color: Colors.white)),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: InkWell(
//                                             onTap: () {},
//                                             child: const Row(
//                                               children: [
//                                                 Padding(
//                                                   padding: EdgeInsets.only(
//                                                       left: 0.0),
//                                                   child: Text("Status",
//                                                       style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: 14)),
//                                                 ),
//                                                 SizedBox(width: 5),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: InkWell(
//                                             onTap: () {},
//                                             child: const Row(
//                                               children: [
//                                                 Text(
//                                                   "Type",
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 14),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                                 SizedBox(width: 5),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: blueColor),
//                                   ),
//                                   child: Column(
//                                     children: <Widget>[
//                                       ListTile(
//                                         contentPadding: EdgeInsets.zero,
//                                         title: Padding(
//                                           padding: const EdgeInsets.all(2.0),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: <Widget>[
//                                               InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     isExpanded = !isExpanded;
//                                                   });
//                                                 },
//                                                 child: Container(
//                                                   margin: const EdgeInsets.only(
//                                                       left: 5),
//                                                   padding: !isExpanded
//                                                       ? const EdgeInsets.only(
//                                                           bottom: 10)
//                                                       : const EdgeInsets.only(
//                                                           top: 10),
//                                                   child: FaIcon(
//                                                     isExpanded
//                                                         ? FontAwesomeIcons
//                                                             .sortUp
//                                                         : FontAwesomeIcons
//                                                             .sortDown,
//                                                     size: 20,
//                                                     color: const Color.fromRGBO(
//                                                         21, 43, 83, 1),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 flex: 4,
//                                                 child: InkWell(
//                                                   onTap: () {
//                                                     // Handle navigation or other actions if needed
//                                                   },
//                                                   child: Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             left: 5.0),
//                                                     child: Text(
//                                                       '${snapshot.data!.data!.rentalAddress}',
//                                                       style: TextStyle(
//                                                         color: blueColor,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 13,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width *
//                                                     .00,
//                                               ),
//                                               Expanded(
//                                                 flex: 2,
//                                                 child: Text(
//                                                   '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
//                                                   style: TextStyle(
//                                                     color: blueColor,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width *
//                                                     .08,
//                                               ),
//                                               Expanded(
//                                                 flex: 3,
//                                                 child: Text(
//                                                   '${snapshot.data!.data!.leaseType}',
//                                                   style: TextStyle(
//                                                     color: blueColor,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width *
//                                                     .02,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       if (isExpanded)
//                                         Container(
//                                           margin:
//                                               const EdgeInsets.only(bottom: 20),
//                                           child: SingleChildScrollView(
//                                             child: Column(
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.start,
//                                                   children: [
//                                                     FaIcon(
//                                                       isExpanded
//                                                           ? FontAwesomeIcons
//                                                               .sortUp
//                                                           : FontAwesomeIcons
//                                                               .sortDown,
//                                                       size: 50,
//                                                       color: Colors.transparent,
//                                                     ),
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: <Widget>[
//                                                           Text.rich(
//                                                             TextSpan(
//                                                               children: [
//                                                                 TextSpan(
//                                                                   text:
//                                                                       'Start - End   ',
//                                                                   style: TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       color:
//                                                                           blueColor),
//                                                                 ),
//                                                                 TextSpan(
//                                                                   text:
//                                                                       '${snapshot.data!.data!.startDate} to ${snapshot.data!.data!.endDate}',
//                                                                   style: const TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w700,
//                                                                       color: Colors
//                                                                           .grey),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           SizedBox(
//                                                             height: 4,
//                                                           ),
//                                                           Text.rich(
//                                                             TextSpan(
//                                                               children: [
//                                                                 TextSpan(
//                                                                   text:
//                                                                       'Amount : ',
//                                                                   style: TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       color:
//                                                                           blueColor),
//                                                                 ),
//                                                                 TextSpan(
//                                                                   text:
//                                                                       '${snapshot.data!.data!.amount}',
//                                                                   style: const TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w700,
//                                                                       color: Colors
//                                                                           .grey),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // if (MediaQuery.of(context).size.width > 500)
//                             //   Row(
//                             //     children: [
//                             //       const SizedBox(
//                             //         width: 16,
//                             //       ),
//                             //       Text(
//                             //         "Lease Details",
//                             //         style: TextStyle(
//                             //             color:
//                             //                 const Color.fromRGBO(21, 43, 81, 1),
//                             //             fontWeight: FontWeight.bold,
//                             //             fontSize: 24),
//                             //       ),
//                             //     ],
//                             //   ),
//                             // const SizedBox(
//                             //   height: 10,
//                             // ),
//                             // if (MediaQuery.of(context).size.width > 500)
//                             //   Padding(
//                             //     padding: const EdgeInsets.only(left: 16),
//                             //     child: SingleChildScrollView(
//                             //       scrollDirection: Axis.horizontal,
//                             //       child: DataTable(
//                             //         dataRowHeight: 35,
//                             //         headingRowHeight: 35,
//                             //         border: TableBorder.all(
//                             //           width: 1,
//                             //           color: const Color.fromRGBO(21, 43, 83, 1),
//                             //         ),
//                             //         columns: [
//                             //           const DataColumn(
//                             //             label: Text('Status'),
//                             //           ),
//                             //           const DataColumn(
//                             //             label: Text('Start - End'),
//                             //           ),
//                             //           const DataColumn(
//                             //             label: Text('Property'),
//                             //           ),
//                             //           const DataColumn(
//                             //             label: Text('Type'),
//                             //           ),
//                             //           const DataColumn(
//                             //             label: Text('Rent'),
//                             //           ),
//                             //         ],
//                             //         rows: [
//                             //           DataRow(cells: <DataCell>[
//                             //             DataCell(Text(
//                             //                 '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}')),
//                             //             DataCell(Text(
//                             //                 ' ${snapshot.data!.data!.startDate} to ${snapshot.data!.data!.endDate}')),
//                             //             DataCell(Text(
//                             //                 '${snapshot.data!.data!.rentalAddress}')),
//                             //             DataCell(Text(
//                             //                 '${snapshot.data!.data!.leaseType}')),
//                             //             DataCell(Text(
//                             //                 '${snapshot.data!.data!.amount}')),
//                             //           ]),
//                             //           // Add more rows as needed
//                             //         ],
//                             //       ),
//                             //     ),
//                             //   ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         }
//       },
//     );
//   }

//   Tenant(context) {
//     return FutureBuilder<LeaseSummary>(
//       future: futureLeaseSummary,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data == null) {
//           return Center(child: Text('No data found.'));
//         } else {
//           return ListView.builder(
//             itemCount: snapshot.data!.data!.tenantData!.length,
//             itemBuilder: (context, index) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   height: 165,
//                   width: MediaQuery.of(context).size.width * .9,
//                   margin: const EdgeInsets.symmetric(horizontal: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     border: Border.all(
//                       color: const Color.fromRGBO(21, 43, 81, 1),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           const SizedBox(width: 15),
//                           Container(
//                             height: 30,
//                             width: 30,
//                             decoration: BoxDecoration(
//                               color: const Color.fromRGBO(21, 43, 81, 1),
//                               border: Border.all(
//                                   color: const Color.fromRGBO(21, 43, 81, 1)),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: const Center(
//                               child: FaIcon(
//                                 FontAwesomeIcons.user,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   const SizedBox(width: 2),
//                                   Text(
//                                     '${snapshot.data!.data!.tenantData![index].tenantFirstName} ${snapshot.data!.data!.tenantData![index].tenantLastName}',
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color.fromRGBO(21, 43, 81, 1),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   const SizedBox(width: 2),
//                                   Text(
//                                     snapshot.data!.data!.rentalAddress!,
//                                     style: const TextStyle(
//                                       fontSize: 11,
//                                       color: Color(0xFF8A95A8),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const Spacer(),
//                           const Row(
//                             children: [
//                               FaIcon(
//                                 FontAwesomeIcons.rightFromBracket,
//                                 size: 17,
//                                 color: Color.fromRGBO(21, 43, 81, 1),
//                               ),
//                               SizedBox(width: 5),
//                               Text(
//                                 "Move out",
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color.fromRGBO(21, 43, 81, 1),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 15),
//                         ],
//                       ),
//                       const SizedBox(height: 15),
//                       Row(
//                         children: [
//                           const SizedBox(width: 65),
//                           Text(
//                             '${snapshot.data!.data!.startDate} to',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color.fromRGBO(21, 43, 81, 1),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const SizedBox(width: 65),
//                           Text(
//                             '${snapshot.data!.data!.endDate}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color.fromRGBO(21, 43, 81, 1),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           const SizedBox(width: 65),
//                           const FaIcon(
//                             FontAwesomeIcons.phone,
//                             size: 15,
//                             color: Color.fromRGBO(21, 43, 81, 1),
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             '${snapshot.data!.data!.tenantData![index].tenantPhoneNumber}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color.fromRGBO(21, 43, 81, 1),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           const SizedBox(width: 65),
//                           const FaIcon(
//                             FontAwesomeIcons.solidEnvelope,
//                             size: 15,
//                             color: Color.fromRGBO(21, 43, 81, 1),
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             '${snapshot.data!.data!.tenantData![index].tenantEmail}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color.fromRGBO(21, 43, 81, 1),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }

// class FinancialPage extends StatefulWidget {
//   const FinancialPage({super.key});

//   @override
//   State<FinancialPage> createState() => _FinancialPageState();
// }

// class _FinancialPageState extends State<FinancialPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
import 'Financial.dart';

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
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
      body: FutureBuilder<LeaseSummary>(
          future: futureLeaseSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 55.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data found.'));
            } else {
              return Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      if( MediaQuery.of(context).size.width < 500)
                        SizedBox(
                          width: 18,
                        ),
                      if( MediaQuery.of(context).size.width > 500)
                        SizedBox(
                          width: 25,
                        ),
                      Text('${snapshot.data!.data!.rentalAddress}',
                          style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.bold,
                            fontSize:   MediaQuery.of(context).size.width < 500 ? 15 :18)),

                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      if( MediaQuery.of(context).size.width < 500)
                      SizedBox(
                        width: 18,
                      ),
                      if( MediaQuery.of(context).size.width > 500)
                        SizedBox(
                          width: 25,
                        ),
                      Text(
                          '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
                          style: TextStyle(
                              color: Color(0xFF8A95A8),
                              fontWeight: FontWeight.bold,
                              fontSize:   MediaQuery.of(context).size.width < 500 ? 13 :16)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width < 500 ? 15 :18),
                    height: 60,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
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
                      labelStyle: screenWidth > 500
                          ? TextStyle(fontSize: 18, fontWeight: FontWeight.w500)
                          : TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                      unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
                      tabs: [
                        const Tab(
                          text: 'Summary',
                        ),
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
                        FinancialTable(
                            leaseId: widget.leaseId,
                            status:
                                '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate).toString()}',
                          tenantId:' ${snapshot.data!.data!.tenantId}',),
                        Tenant(context),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }

  int? expandedIndex;
  bool isExpanded = false;

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
    var width = MediaQuery.of(context).size.width;
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
          return ListView(
            scrollDirection: Axis.vertical,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Material(
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
                                    // fontSize: 18
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          Divider(
                            color: blueColor,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Table(
                            children: [
                              TableRow(children: [
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Unit',
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    '${snapshot.data!.data!.rentalAddress}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                )),
                              ]),
                              TableRow(children: [
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Rental Owner',
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    '${snapshot.data!.data!.rentalOwnerName ?? 'N/A'}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                )),
                              ]),
                              TableRow(children: [
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Tenants',
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    children: snapshot.data!.data!.tenantData!
                                        .map((tenant) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Display Tenant Name
                                          if (snapshot.data!.data!.tenantData !=
                                                  null &&
                                              snapshot.data!.data!.tenantData!
                                                  .isNotEmpty)
                                            Row(
                                              children: [
                                                Text(
                                                  '${tenant.tenantFirstName}  ${tenant.tenantLastName}' ??
                                                      'N/A',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          const SizedBox(height: 5),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                )),
                              ]),
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
                          left: 8, right: 8, top: 20, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (MediaQuery.of(context).size.width < 500)
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
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(
                            height: 10,
                          ),
                          if (MediaQuery.of(context).size.width < 500)
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: blueColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(13),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Row(
                                              children: [
                                                width < 400
                                                    ? const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.0),
                                                        child: Text(
                                                          "Property",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      )
                                                    : const Text(
                                                        "     Property",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14),
                                                        textAlign:
                                                            TextAlign.center),
                                                // Text("Property", style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () {},
                                            child: const Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 0.0),
                                                  child: Text("Status",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14)),
                                                ),
                                                SizedBox(width: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () {},
                                            child: const Row(
                                              children: [
                                                Text(
                                                  "Type",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(width: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: blueColor),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isExpanded = !isExpanded;
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5),
                                                  padding: !isExpanded
                                                      ? const EdgeInsets.only(
                                                          bottom: 10)
                                                      : const EdgeInsets.only(
                                                          top: 10),
                                                  child: FaIcon(
                                                    isExpanded
                                                        ? FontAwesomeIcons
                                                            .sortUp
                                                        : FontAwesomeIcons
                                                            .sortDown,
                                                    size: 20,
                                                    color: const Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: InkWell(
                                                  onTap: () {
                                                    // Handle navigation or other actions if needed
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Text(
                                                      '${snapshot.data!.data!.rentalAddress}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .00,
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .08,
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  '${snapshot.data!.data!.leaseType}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .02,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isExpanded)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 20),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    FaIcon(
                                                      isExpanded
                                                          ? FontAwesomeIcons
                                                              .sortUp
                                                          : FontAwesomeIcons
                                                              .sortDown,
                                                      size: 50,
                                                      color: Colors.transparent,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Start - End   ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${snapshot.data!.data!.startDate} to ${snapshot.data!.data!.endDate}',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Amount : ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${snapshot.data!.data!.amount}',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          if (MediaQuery.of(context).size.width > 500)
                            Row(
                              children: [
                                 SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  "Lease Details",
                                  style: TextStyle(
                                      color:
                                          const Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (MediaQuery.of(context).size.width > 500)
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Expanded(
                                  child: Container(
                                    child: DataTable(
                                      dataRowHeight: 50,
                                      headingRowHeight: 50,
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
                                          DataCell(Text(
                                              '${snapshot.data!.data!.amount}')),
                                        ]),
                                        // Add more rows as needed
                                      ],
                                    ),
                                  ),
                                ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        return
          FutureBuilder<LeaseSummary>(
            future: futureLeaseSummary,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No data found.'));
              } else {
                return isTablet
                    ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child:
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 35,
                      right: 35,
                      top: 30,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: MediaQuery.of(context).size.width * 0.03,
                      runSpacing: MediaQuery.of(context).size.width * 0.035,
                      children: List.generate(
                        snapshot.data!.data!.tenantData!.length,
                            (index) => Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 220,
                            width: MediaQuery.of(context).size.width * .44,
                            decoration: BoxDecoration(
                              color:
                              Colors.white, // Change as per your need
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                            child:Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const SizedBox(width: 15),
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(21, 43, 81, 1),
                                          border: Border.all(
                                              color: const Color.fromRGBO(21, 43, 81, 1)),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.user,
                                            size: 17,
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
                                                  fontSize: 16,
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
                                                  fontSize: 15,
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
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
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
                                          fontSize: 15,
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
                                          fontSize: 15,
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
                                        size: 18,
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${snapshot.data!.data!.tenantData![index].tenantPhoneNumber}',
                                        style: const TextStyle(
                                          fontSize: 13,
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
                                        size: 18,
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${snapshot.data!.data!.tenantData![index].tenantEmail}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color.fromRGBO(21, 43, 81, 1),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: MediaQuery.of(context).size.width * 0.03,
                    runSpacing: MediaQuery.of(context).size.width * 0.02,
                    children: List.generate(
                      snapshot.data!.data!.tenantData!.length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20,),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 205,
                            //  width: MediaQuery.of(context).size.width * .44,
                            decoration: BoxDecoration(
                              color:
                              Colors.white, // Change as per your need
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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

                          ),
                        ),
                      ),
                    ),
                  ),
                );


              }
            },
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
