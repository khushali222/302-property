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
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../Rental/Properties/moveout/repository.dart';
import 'Financial.dart';
import '../../../widgets/custom_drawer.dart';
class SummeryPageLease extends StatefulWidget {
  bool? isredirectpayment;
  String leaseId;
  SummeryPageLease({super.key, required this.leaseId,this.isredirectpayment});
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
    moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    if(widget.isredirectpayment != null && widget.isredirectpayment!){
      _tabController!.animateTo(1);
    }
    super.initState();
  }
  String moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isLoading = false;
  bool isMovedOut = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Rent Roll",dropdown: true,),
      body: FutureBuilder<LeaseSummary>(
          future: futureLeaseSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Center(
                child: SpinKitSpinningLines(
                  color: blueColor,
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 500 ? 200: 180,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 1),
                          child: Text(
                            '${snapshot.data!.data?.rentalAddress}',
                            maxLines: 5, // Set maximum number of lines
                            overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 500 ? 13 : 18,
                              color: blueColor,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      // Text('${snapshot.data!.data!.rentalAddress}',
                      //     style: TextStyle(
                      //         color: Color.fromRGBO(21, 43, 81, 1),
                      //         fontWeight: FontWeight.bold,
                      //       fontSize:   MediaQuery.of(context).size.width < 500 ? 15 :18)),

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
                          '${determineStatus(snapshot.data!.data?.startDate, snapshot.data!.data?.endDate)}',
                          style: TextStyle(
                              color: _getStatusColor(determineStatus(snapshot.data!.data?.startDate, snapshot.data!.data?.endDate)),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FinancialTable(
                              leaseId: widget.leaseId,
                              status:
                                  '${determineStatus(snapshot.data!.data?.startDate, snapshot.data!.data?.endDate).toString()}',
                            tenantId:' ${snapshot.data!.data?.tenantId}',),
                        ),
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

  String  determineStatus(String? startDate, String? endDate) {
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
  Color _getStatusColor(String status) {
    if (status == 'Active') {
      return Colors.green; // Green color for 'Active'
    } else if (status == 'Expired') {
      return Colors.grey; // Grey color for 'Expired'
    } else {
      return Color(0xFF8A95A8); // Default color for other statuses
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
                                                SizedBox(
                                                  width:130,
                                                  child: Text(
                                                    '${tenant.tenantFirstName}  ${tenant.tenantLastName}' ??
                                                        'N/A',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          21, 43, 83, 1),
                                                    ),
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
                  //elevation: 6,
                  //borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(
                      //     color: const Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 2, right: 2, top: 5, bottom: 30),
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
                                     // color: index %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                      border: Border.all(color: Color.fromRGBO(152, 162, 179, .5))),
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(color: blueColor),
                                  // ),
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
                              padding: const EdgeInsets.only(left: 5),
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
                String status = determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate);
                return isTablet
                    ?
                SingleChildScrollView(
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
                            height: 245,
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
                                              Container(
                                                width: 150,
                                                child: Text(
                                                  '${snapshot.data!.data!.tenantData![index].tenantFirstName} ${snapshot.data!.data!.tenantData![index].tenantLastName}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              //const SizedBox(width: 2),
                                              // Text(
                                              //   snapshot.data!.data!.rentalAddress!,
                                              //   style: const TextStyle(
                                              //     fontSize: 15,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              SizedBox(
                                                width: 140,
                                                child: Text(
                                                  '${snapshot.data!.data!.rentalAddress!}',
                                                  maxLines: 4, // Set maximum number of lines
                                                  overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: blueColor,
                                                  ),
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
                                                 builder: (BuildContext context,
                                                     StateSetter setState) {
                                                   return AlertDialog(
                                                     backgroundColor: Colors.white,
                                                     surfaceTintColor: Colors.white,
                                                     content:
                                                     buildMoveout(snapshot.data!),
                                                   );
                                                 },
                                               );
                                             },
                                           );
                                         },
                                         child: Row(
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
                                       ),
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
                                      Expanded(
                                        child: Text(
                                          '${snapshot.data!.data!.tenantData![index].tenantEmail}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color.fromRGBO(21, 43, 81, 1),
                                            fontWeight: FontWeight.w500,
                                          ),
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
                  child: Column(
                    children: [
                      Wrap(
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
                                //height: 240,
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
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
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
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 6),
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
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width > 500 ? 200: 150,
                                                    child: Text(
                                                      '${snapshot.data!.data!.rentalAddress!}',
                                                      maxLines: 4, // Set maximum number of lines
                                                      overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(context).size.width < 500 ? 13 : 18,
                                                        color: blueColor,
                                                      ),
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   snapshot.data!.data!.rentalAddress!,
                                                  //   style: const TextStyle(
                                                  //     fontSize: 15,
                                                  //     color: Color(0xFF8A95A8),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          if (isMovedOut == true || status != 'Expired' )
                                           InkWell(
                                             onTap: () {
                                               showDialog(
                                                 context: context,
                                                 builder: (BuildContext context) {
                                                   bool isChecked =
                                                   false; // Moved isChecked inside the StatefulBuilder
                                                   return StatefulBuilder(
                                                     builder: (BuildContext context,
                                                         StateSetter setState) {
                                                       return AlertDialog(
                                                         backgroundColor: Colors.white,
                                                         surfaceTintColor: Colors.white,
                                                         content:
                                                         buildMoveout(snapshot.data!),
                                                       );
                                                     },
                                                   );
                                                 },
                                               );
                                             },
                                             child:
                                             Row(
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
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                  ),
                                                ),
                                              ],
                                                                                   ),
                                           ),
                                         if(isMovedOut || status == 'Expired')
                                           Row(
                                             children: [
                                               FaIcon(
                                                 FontAwesomeIcons.check,
                                                 size: 17,
                                                 color: Color.fromRGBO(21, 43, 81, 1),
                                               ),
                                               SizedBox(width: 5),
                                               Text(
                                                 "Moved out",
                                                 style: TextStyle(
                                                   fontSize: 14,
                                                   fontWeight: FontWeight.w500,
                                                   color: Color.fromRGBO(21, 43, 81, 1),
                                                 ),
                                               ),
                                             ],
                                           ),
                                           // if(MediaQuery.of(context).size.width < 350)
                                           //   SizedBox(width: 5),

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
                                            size: 15,
                                            color: Color.fromRGBO(21, 43, 81, 1),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${snapshot.data!.data!.tenantData![index].tenantPhoneNumber}',
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
                                            FontAwesomeIcons.solidEnvelope,
                                            size: 15,
                                            color: Color.fromRGBO(21, 43, 81, 1),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              '${snapshot.data!.data!.tenantData![index].tenantEmail}',
                                              maxLines: 3, // Set maximum number of lines
                                              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: blueColor,
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                          // Text(
                                          //   '${snapshot.data!.data!.tenantData![index].tenantEmail}',
                                          //   style: const TextStyle(
                                          //     fontSize: 15,
                                          //     color: Color.fromRGBO(21, 43, 81, 1),
                                          //     fontWeight: FontWeight.w500,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                    ],
                                  ),
                                ),

                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                );


              }
            },
          );
      },
    );

  }
  Widget buildMoveout(LeaseSummary tenant) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Move out Tenants",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(21, 43, 81, 1),
                fontSize: MediaQuery.of(context).size.width < 500 ? 18 : 22),
          ),
          SizedBox(height: 13),
          Text(
            "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18,
              color: Color(0xFF8A95A8),
            ),
          ),
          SizedBox(height: 15),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    'Property Details',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width < 500 ? 16 : 20,
                        color: blueColor),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration:  BoxDecoration(
                  borderRadius:
                  BorderRadius
                      .circular(
                      5),

                  border: Border.all(
                      color: blueColor),
                ),
                child: Table(
                  //border: TableBorder.all(color:blueColor),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      width: 1.0,
                    ),

                  ),
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      children: [
                        buildTableCell(Text('Address/Unit',style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 17,),)),
                        buildTableCell(Text('${tenant.data?.rentalAddress}')),
                      ],
                    ),
                    TableRow(
                      children: [
                        buildTableCell(Text('Lease Type',style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,
                          fontSize:  MediaQuery.of(context).size.width < 500 ? 15 : 17,))),
                        buildTableCell(Text('${tenant.data?.leaseType}')),
                      ],
                    ),
                    TableRow(
                      children: [
                        buildTableCell(Text('Start End',style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,
                          fontSize:  MediaQuery.of(context).size.width < 500 ? 15 : 17,))),
                        buildTableCell(Text('${tenant.data?.startDate} ${tenant.data?.endDate}')),
                      ],
                    ),

                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    'Tenant Details',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width < 500 ? 16 : 20,
                        color: Color.fromRGBO(21, 43, 81, 1)),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Table(
                border: TableBorder.all(color: blueColor),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  TableRow(
                    children: [
                      buildTableCell(Text('Tenants',style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,
                        fontSize:  MediaQuery.of(context).size.width < 500 ? 15 : 17,))),
                      buildTableCell(Text('${tenant.data?.tenantData?.first.tenantFirstName} ${tenant.data?.tenantData?.first.tenantLastName}')),
                    ],
                  ),
                  TableRow(
                    children: [
                      buildTableCell(Text('Notice Given Date',style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,
                        fontSize:  MediaQuery.of(context).size.width < 500 ? 15 : 17,))),
                      buildTableCell(buildDateField(startdateController)),
                    ],
                  ),
                  TableRow(
                    children: [
                      buildTableCell(Text('Move-Out Date',style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,
                        fontSize:  MediaQuery.of(context).size.width < 500 ? 15 : 17,))),
                      buildTableCell(Column(
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Material(
                                elevation:2,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height:40,
                                  width:130,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      moveOutDate,
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Container(
                    height:  MediaQuery.of(context).size.width < 500 ? 40 : 50,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Center(
                        child: Text(
                          "Close",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize:  MediaQuery.of(context).size.width < 500 ? 15 : 18,
                              color: Color.fromRGBO(21, 43, 81, 1)),
                        )),
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: ()async{
                  String? tenantId = tenant.data?.tenantId != null
                      ? tenant.data?.tenantId!.first
                      : null;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? id = prefs.getString("adminId");
                  LeaseMoveoutRepository()
                      .addMoveoutTenant(
                    adminId: id!,
                    tenantId: tenantId,
                    leaseId: tenant.data?.leaseId,
                    moveoutDate: moveOutDate,
                    moveoutNoticeGivenDate: startdateController.text,
                  ).then((value) {
                    setState(() {
                      isLoading = false;
                      isMovedOut = true;
                    });
                    Navigator.pop(context, true);
                  }).catchError((e) {
                    setState(() {
                      isLoading = false;
                    });
                  });
                },
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Container(
                    height:  MediaQuery.of(context).size.width < 500 ? 40 : 50,
                    width:  MediaQuery.of(context).size.width < 500 ? 100: 130,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Center(
                        child: Text(
                          "Move Out",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize:  MediaQuery.of(context).size.width < 500 ? 15 : 17,),
                        )),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget buildTableCell(Widget child) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  Widget buildDateField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Select Date',
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
              });
            }
          },
        ),
      ),
      readOnly: true,
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
