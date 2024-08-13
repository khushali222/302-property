import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/Model/propertytype.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/Property_type.dart';
import 'package:three_zero_two_property/repository/lease.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/editApplicant.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'make_payment.dart';

import 'package:three_zero_two_property/screens/Property_Type/Edit_property_type.dart';

import '../../../model/LeaseLedgerModel.dart';
import '../../test_table/card.dart';

import 'addcard/AddCard.dart';
import 'enterCharge.dart';

// class FinancialTable extends StatefulWidget {
//   final String leaseId;
//   final String tenantId;
//   final String status;
//   FinancialTable(
//       {required this.leaseId, required this.status, required this.tenantId});
//   @override
//   _FinancialTableState createState() => _FinancialTableState();
// }
//
// class _FinancialTableState extends State<FinancialTable> {
//   int totalrecords = 0;
//   late Future<List<propertytype>> futurePropertyTypes;
//   int rowsPerPage = 5;
//   int sortColumnIndex = 0;
//   bool sortAscending = true;
//   int currentPage = 0;
//   int itemsPerPage = 10;
//   List<int> itemsPerPageOptions = [
//     10,
//     25,
//     50,
//     100,
//   ]; // Options for items per page
//
//   // void sortData(List<leaseLedger> data) {
//   //   if (sorting1) {
//   //     data.sort((a, b) => ascending1
//   //         ? a.propertyType!.compareTo(b.propertyType!)
//   //         : b.propertyType!.compareTo(a.propertyType!));
//   //   } else if (sorting2) {
//   //     data.sort((a, b) => ascending2
//   //         ? a.propertysubType!.compareTo(b.propertysubType!)
//   //         : b.propertysubType!.compareTo(a.propertysubType!));
//   //   } else if (sorting3) {
//   //     data.sort((a, b) => ascending3
//   //         ? a.createdAt!.compareTo(b.createdAt!)
//   //         : b.createdAt!.compareTo(a.createdAt!));
//   //   }
//   // }
//
//   int? expandedIndex;
//   Set<int> expandedIndices = {};
//   late bool isExpanded;
//   bool sorting1 = false;
//   bool sorting2 = false;
//   bool sorting3 = false;
//   bool ascending1 = false;
//   bool ascending2 = false;
//   bool ascending3 = false;
//
//   Widget _buildHeaders() {
//     var width = MediaQuery.of(context).size.width;
//     return Container(
//       decoration: BoxDecoration(
//         color: blueColor,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(13),
//           topRight: Radius.circular(13),
//         ),
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         // leading: Container(
//         //   child: Icon(
//         //     Icons.expand_less,
//         //     color: Colors.transparent,
//         //   ),
//         // ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Container(
//               child: const Icon(
//                 Icons.expand_less,
//                 color: Colors.transparent,
//               ),
//             ),
//             Expanded(
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     if (sorting1 == true) {
//                       sorting2 = false;
//                       sorting3 = false;
//                       ascending1 = sorting1 ? !ascending1 : true;
//                       ascending2 = false;
//                       ascending3 = false;
//                     } else {
//                       sorting1 = !sorting1;
//                       sorting2 = false;
//                       sorting3 = false;
//                       ascending1 = sorting1 ? !ascending1 : true;
//                       ascending2 = false;
//                       ascending3 = false;
//                     }
//
//                     // Sorting logic here
//                   });
//                 },
//                 child: Row(
//                   children: [
//                     width < 400
//                         ? const Text("Type",
//                             style: TextStyle(color: Colors.white))
//                         : const Text("Type",
//                             style: TextStyle(color: Colors.white)),
//                     // Text("Property", style: TextStyle(color: Colors.white)),
//                     const SizedBox(width: 3),
//                    /* ascending1
//                         ? const Padding(
//                             padding: EdgeInsets.only(top: 7, left: 2),
//                             child: FaIcon(
//                               FontAwesomeIcons.sortUp,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Padding(
//                             padding: EdgeInsets.only(bottom: 7, left: 2),
//                             child: FaIcon(
//                               FontAwesomeIcons.sortDown,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           ),*/
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     if (sorting2) {
//                       sorting1 = false;
//                       sorting2 = sorting2;
//                       sorting3 = false;
//                       ascending2 = sorting2 ? !ascending2 : true;
//                       ascending1 = false;
//                       ascending3 = false;
//                     } else {
//                       sorting1 = false;
//                       sorting2 = !sorting2;
//                       sorting3 = false;
//                       ascending2 = sorting2 ? !ascending2 : true;
//                       ascending1 = false;
//                       ascending3 = false;
//                     }
//                     // Sorting logic here
//                   });
//                 },
//                 child: Row(
//                   children: [
//                     const Text("Balance      ",
//                         style: TextStyle(color: Colors.white)),
//                     const SizedBox(width: 5),
//                     /*ascending2
//                         ? const Padding(
//                             padding: EdgeInsets.only(top: 7, left: 2),
//                             child: FaIcon(
//                               FontAwesomeIcons.sortUp,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Padding(
//                             padding: EdgeInsets.only(bottom: 7, left: 2),
//                             child: FaIcon(
//                               FontAwesomeIcons.sortDown,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           ),*/
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     if (sorting3) {
//                       sorting1 = false;
//                       sorting2 = false;
//                       sorting3 = sorting3;
//                       ascending3 = sorting3 ? !ascending3 : true;
//                       ascending2 = false;
//                       ascending1 = false;
//                     } else {
//                       sorting1 = false;
//                       sorting2 = false;
//                       sorting3 = !sorting3;
//                       ascending3 = sorting3 ? !ascending3 : true;
//                       ascending2 = false;
//                       ascending1 = false;
//                     }
//
//                     // Sorting logic here
//                   });
//                 },
//                 child: Row(
//                   children: [
//                     const Text("      Date", style: TextStyle(color: Colors.white)),
//                     const SizedBox(width: 5),
//                    /* ascending3
//                         ? const Padding(
//                             padding: EdgeInsets.only(top: 7, left: 2),
//                             child: FaIcon(
//                               FontAwesomeIcons.sortUp,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Padding(
//                             padding: EdgeInsets.only(bottom: 7, left: 2),
//                             child: FaIcon(
//                               FontAwesomeIcons.sortDown,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           ),*/
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   final List<String> items = ['Residential', "Commercial", "All"];
//   String? selectedValue;
//   String searchvalue = "";
//   late Future<LeaseLedger?> _leaseLedgerFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _leaseLedgerFuture = LeaseRepository().fetchLeaseLedger(widget.leaseId);
//   }
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
//   // }
//
//   void handleEdit(LeaseLedger? ledge) async {
//     // Handle edit action
//     // print('Edit ${applicant.sId}');
//     // var check = await Navigator.push(
//     //     context,
//     //     MaterialPageRoute(
//     //         builder: (context) => EditApplicant(
//     //               applicant: ,
//     //               applicantId: ,
//     //             )));
//     // if (check == true) {
//     //   setState(() {});
//     // }
//   }
//
//   void _showAlert(BuildContext context, String id) {
//     Alert(
//       context: context,
//       type: AlertType.warning,
//       title: "Are you sure?",
//       desc: "Once deleted, you will not be able to recover this property!",
//       style: const AlertStyle(
//         backgroundColor: Colors.white,
//       ),
//       buttons: [
//         DialogButton(
//           child: const Text(
//             "Cancel",
//             style: TextStyle(color: Colors.white, fontSize: 18),
//           ),
//           onPressed: () => Navigator.pop(context),
//           color: Colors.grey,
//         ),
//         DialogButton(
//           child: const Text(
//             "Delete",
//             style: TextStyle(color: Colors.white, fontSize: 18),
//           ),
//           onPressed: () async {
//             var data = PropertyTypeRepository().DeletePropertyType(id: id);
//             // Add your delete logic here
//             setState(() {
//               futurePropertyTypes =
//                   PropertyTypeRepository().fetchPropertyTypes();
//             });
//             Navigator.pop(context);
//           },
//           color: Colors.red,
//         )
//       ],
//     ).show();
//   }
//
//   List<LeaseLedger?> _tableData = [];
//   int _rowsPerPage = 10;
//   int _currentPage = 0;
//   int? _sortColumnIndex;
//   bool _sortAscending = true;
//
//   List<LeaseLedger?> get _pagedData {
//     int startIndex = _currentPage * _rowsPerPage;
//     int endIndex = startIndex + _rowsPerPage;
//     return _tableData.sublist(startIndex,
//         endIndex > _tableData.length ? _tableData.length : endIndex);
//   }
//
//   void _changeRowsPerPage(int selectedRowsPerPage) {
//     setState(() {
//       _rowsPerPage = selectedRowsPerPage;
//       _currentPage = 0; // Reset to the first page when changing rows per page
//     });
//   }
//
//   void _sort<T>(Comparable<T> Function(LeaseLedger? d) getField,
//       int columnIndex, bool ascending) {
//     setState(() {
//       _sortColumnIndex = columnIndex;
//       _sortAscending = ascending;
//       _tableData.sort((a, b) {
//         final aValue = getField(a);
//         final bValue = getField(b);
//         final result = aValue.compareTo(bValue as T);
//         return _sortAscending ? result : -result;
//       });
//     });
//   }
//
//   void handleDelete(LeaseLedger? ledge) {
//     _showAlert(context, ledge!.data!.first.leaseId!);
//     // Handle delete action
//     // print('Delete ${property.sId}');
//   }
//
//   Widget _buildHeader<T>(String text, int columnIndex,
//       Comparable<T> Function(LeaseLedger? d)? getField) {
//     return TableCell(
//       child: InkWell(
//         onTap: getField != null
//             ? () {
//                 _sort(getField, columnIndex, !_sortAscending);
//               }
//             : null,
//         child: Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: Row(
//             children: [
//               Text(text,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 18)),
//               if (_sortColumnIndex == columnIndex)
//                 Icon(_sortAscending
//                     ? Icons.arrow_drop_down_outlined
//                     : Icons.arrow_drop_up_outlined),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDataCell(String text) {
//     return TableCell(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 20.0, left: 16),
//         child: Text(text, style: const TextStyle(fontSize: 18)),
//       ),
//     );
//   }
//
//   Widget _buildActionsCell(LeaseLedger? data) {
//     return TableCell(
//       child: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Container(
//           height: 50,
//           // color: Colors.blue,
//           child: Row(
//             children: [
//               const SizedBox(
//                 width: 20,
//               ),
//               InkWell(
//                 onTap: () {
//                   handleEdit(data);
//                 },
//                 child: const FaIcon(
//                   FontAwesomeIcons.edit,
//                   size: 30,
//                 ),
//               ),
//               const SizedBox(
//                 width: 15,
//               ),
//               InkWell(
//                 onTap: () {
//                   handleDelete(data);
//                 },
//                 child: const FaIcon(
//                   FontAwesomeIcons.trashCan,
//                   size: 30,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaginationControls() {
//     int numorpages = 1;
//     numorpages = (totalrecords / _rowsPerPage).ceil();
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         // Text('Rows per page: '),
//         // SizedBox(width: 10),
//         Material(
//           elevation: 2,
//           color: Colors.white,
//           child: Container(
//             height: 55,
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(4.0),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<int>(
//                 value: _rowsPerPage,
//                 items: [10, 25, 50, 100].map((int value) {
//                   return DropdownMenuItem<int>(
//                     value: value,
//                     child: Text(value.toString()),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   if (newValue != null) {
//                     _changeRowsPerPage(newValue);
//                   }
//                 },
//                 icon: const Icon(
//                   Icons.arrow_drop_down,
//                   size: 40,
//                 ),
//                 style: const TextStyle(color: Colors.black, fontSize: 17),
//                 dropdownColor: Colors.white,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         IconButton(
//           icon: FaIcon(
//             FontAwesomeIcons.circleChevronLeft,
//             size: 30,
//             color: _currentPage == 0
//                 ? Colors.grey
//                 : const Color.fromRGBO(21, 43, 83, 1),
//           ),
//           onPressed: _currentPage == 0
//               ? null
//               : () {
//                   setState(() {
//                     _currentPage--;
//                   });
//                 },
//         ),
//         Text(
//           'Page ${_currentPage + 1} of $numorpages',
//           style: const TextStyle(fontSize: 18),
//         ),
//         IconButton(
//           icon: FaIcon(
//             size: 30,
//             FontAwesomeIcons.circleChevronRight,
//             color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
//                 ? Colors.grey
//                 : const Color.fromRGBO(
//                     21, 43, 83, 1), // Change color based on availability
//           ),
//           onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
//               ? null
//               : () {
//                   setState(() {
//                     _currentPage++;
//                   });
//                 },
//         ),
//       ],
//     );
//   }
//
//   final _scrollController = ScrollController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 10,
//             ),
//             widget.status == 'Active'
//                 ? Padding(
//                     padding: const EdgeInsets.only(right: 16.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Container(
//                             height: 36,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(width: 1),
//                                 borderRadius: BorderRadius.circular(10.0)),
//                             child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(10.0)),
//                                     elevation: 0,
//                                     backgroundColor: Colors.white),
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => AddCard(
//                                                 leaseId: widget.leaseId,
//                                               )));
//                                 },
//                                 child: Text(
//                                   'Add Cards',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Color.fromRGBO(21, 43, 83, 1)),
//                                 ))),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         Container(
//                             height: 36,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(width: 1),
//                                 borderRadius: BorderRadius.circular(10.0)),
//                             child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(10.0)),
//                                     elevation: 0,
//                                     backgroundColor: Colors.white),
//                                 onPressed: () async{
//                                  final value = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => MakePayment(leaseId: widget.leaseId, tenantId: widget.tenantId,)));
//                                   if(value== true){
//                                     setState(() {
//                                       _leaseLedgerFuture = LeaseRepository().fetchLeaseLedger(widget.leaseId);
//                                     });
//
//                                   }
//                                  },
//                                 child: Text(
//                                   'Make Payment',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Color.fromRGBO(21, 43, 83, 1)),
//                                 ))),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         Container(
//                             height: 34,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(width: 1),
//                                 borderRadius: BorderRadius.circular(10.0)),
//                             child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(10.0)),
//                                     elevation: 0,
//                                     backgroundColor: Colors.white),
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => enterCharge(
//                                                 leaseId: widget.leaseId,
//                                               )));
//                                 },
//                                 child: Text(
//                                   'Enter Charge',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Color.fromRGBO(21, 43, 83, 1)),
//                                 ))),
//                       ],
//                     ),
//                   )
//                 : Container(),
//             const SizedBox(
//               height: 6,
//             ),
//             if (MediaQuery.of(context).size.width > 500)
//               const SizedBox(height: 25),
//             if (MediaQuery.of(context).size.width < 500)
//               Padding(
//                   padding: const EdgeInsets.only(
//                       left: 10.0, right: 10.0, bottom: 10.0),
//                   child: FutureBuilder<LeaseLedger?>(
//                     future: _leaseLedgerFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return ColabShimmerLoadingWidget();
//                       } else if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       } else if (!snapshot.hasData) {
//                         return Center(child: Text('No data found'));
//                       } else {
//                         final leaseLedger = snapshot.data!;
//                         return SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               const SizedBox(height: 5),
//                               _buildHeaders(),
//                               const SizedBox(height: 20),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: blueColor),
//                                 ),
//                                 child: Column(
//                                   children: leaseLedger.data!
//                                       .asMap()
//                                       .entries
//                                       .map((entry) {
//                                     int index = entry.key;
//                                     bool isExpanded = expandedIndex == index;
//                                     Data data = entry.value;
//                                     return Container(
//                                       decoration: BoxDecoration(
//                                         border: Border.all(color: blueColor),
//                                       ),
//                                       child: Column(
//                                         children: <Widget>[
//                                           ListTile(
//                                             contentPadding: EdgeInsets.zero,
//                                             title: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(2.0),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   InkWell(
//                                                     onTap: () {
//                                                       setState(() {
//                                                         if (expandedIndex ==
//                                                             index) {
//                                                           expandedIndex = null;
//                                                         } else {
//                                                           expandedIndex = index;
//                                                         }
//                                                       });
//                                                     },
//                                                     child: Container(
//                                                       margin:
//                                                           const EdgeInsets.only(
//                                                               left: 5),
//                                                       padding: !isExpanded
//                                                           ? const EdgeInsets
//                                                               .only(bottom: 10)
//                                                           : const EdgeInsets
//                                                               .only(top: 10),
//                                                       child: FaIcon(
//                                                         isExpanded
//                                                             ? FontAwesomeIcons
//                                                                 .sortUp
//                                                             : FontAwesomeIcons
//                                                                 .sortDown,
//                                                         size: 20,
//                                                         color: const Color
//                                                             .fromRGBO(
//                                                             21, 43, 83, 1),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: Text(
//                                                         ' ${data.type}'??"", // Assuming you want to show the charge type here
//                                                         style: TextStyle(
//                                                           color: blueColor,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontSize: 13,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       width:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width *
//                                                               .08),
//                                                   Expanded(
//                                                     child: Text(
//                                                       ' \$${data.balance!.toStringAsFixed(2)}', // Show total amount
//                                                       style: TextStyle(
//                                                         color: blueColor,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 13,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       width:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width *
//                                                               .08),
//                                                   Expanded(
//                                                     child: Text(
//                                                       formatDate(
//                                                           '${data.createdAt}'), // Format and show created date
//                                                       style: TextStyle(
//                                                         color: blueColor,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 13,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       width:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width *
//                                                               .02),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                           if (isExpanded)
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 8.0),
//                                               margin: const EdgeInsets.only(
//                                                   bottom: 20),
//                                               child: SingleChildScrollView(
//                                                 child: Column(
//                                                   children: [
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         FaIcon(
//                                                           isExpanded
//                                                               ? FontAwesomeIcons
//                                                                   .sortUp
//                                                               : FontAwesomeIcons
//                                                                   .sortDown,
//                                                           size: 50,
//                                                           color: Colors
//                                                               .transparent,
//                                                         ),
//                                                         Expanded(
//                                                           child: Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: <Widget>[
//                                                               Text.rich(
//                                                                 TextSpan(
//                                                                   children: [
//                                                                     const TextSpan(
//                                                                       text:
//                                                                           'Increase : ',
//                                                                       style: TextStyle(
//                                                                           fontWeight: FontWeight
//                                                                               .bold,
//                                                                           color: Color.fromRGBO(
//                                                                               21,
//                                                                               43,
//                                                                               83,
//                                                                               1)),
//                                                                     ),
//                                                                     TextSpan(
//                                                                       text: '${data.type == "Refund" ? data.totalAmount : null}',
//                                                                       style: const TextStyle(
//                                                                           fontWeight: FontWeight
//                                                                               .w700,
//                                                                           color:
//                                                                               Colors.grey),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                               Text.rich(
//                                                                 TextSpan(
//                                                                   children: [
//                                                                     const TextSpan(
//                                                                       text:
//                                                                           'Tenant : ',
//                                                                       style: TextStyle(
//                                                                           fontWeight: FontWeight
//                                                                               .bold,
//                                                                           color: Color.fromRGBO(
//                                                                               21,
//                                                                               43,
//                                                                               83,
//                                                                               1)),
//                                                                     ),
//                                                                     TextSpan(
//                                                                       text: data
//                                                                           .totalAmount
//                                                                           .toString(),
//                                                                       style: const TextStyle(
//                                                                           fontWeight: FontWeight
//                                                                               .w700,
//                                                                           color:
//                                                                               Colors.grey),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           width: 40,
//                                                           child: Column(
//                                                             children: [
//                                                               IconButton(
//                                                                 icon:
//                                                                     const FaIcon(
//                                                                   FontAwesomeIcons
//                                                                       .edit,
//                                                                   size: 20,
//                                                                   color: Color
//                                                                       .fromRGBO(
//                                                                           21,
//                                                                           43,
//                                                                           83,
//                                                                           1),
//                                                                 ),
//                                                                 onPressed:
//                                                                     () async {
//                                                                   // handleEdit(applicant);
//                                                                   // var check = await Navigator.push(
//                                                                   //     context,
//                                                                   //     MaterialPageRoute(
//                                                                   //         builder: (context) => EditApplicant(
//                                                                   //               applicant: applicant,
//                                                                   //               applicantId: applicant.applicantId!,
//                                                                   //             )));
//                                                                   // if (check ==
//                                                                   //     true) {
//                                                                   //   setState(
//                                                                   //       () {});
//                                                                   // }
//                                                                 },
//                                                               ),
//                                                               IconButton(
//                                                                 icon:
//                                                                     const FaIcon(
//                                                                   FontAwesomeIcons
//                                                                       .trashCan,
//                                                                   size: 20,
//                                                                   color: Color
//                                                                       .fromRGBO(
//                                                                           21,
//                                                                           43,
//                                                                           83,
//                                                                           1),
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   // handleDelete(applicant);
//                                                                   // _showDeleteAlert(
//                                                                   //     context,
//                                                                   //     applicant
//                                                                   //         .applicantId!);
//                                                                 },
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     Column(
//                                                       children: data.entry!
//                                                           .map((entry) {
//                                                         return Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             FaIcon(
//                                                               isExpanded
//                                                                   ? FontAwesomeIcons
//                                                                       .sortUp
//                                                                   : FontAwesomeIcons
//                                                                       .sortDown,
//                                                               size: 50,
//                                                               color: Colors
//                                                                   .transparent,
//                                                             ),
//                                                             Expanded(
//                                                               child: Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: <Widget>[
//                                                                   Text.rich(
//                                                                     TextSpan(
//                                                                       children: [
//                                                                         TextSpan(
//                                                                           text:
//                                                                               'Account: ',
//                                                                           style: TextStyle(
//                                                                               fontWeight: FontWeight.bold,
//                                                                               color: blueColor),
//                                                                         ),
//                                                                         TextSpan(
//                                                                           text:
//                                                                               "${entry.account}        ",
//                                                                           style: const TextStyle(
//                                                                               fontWeight: FontWeight.w700,
//                                                                               color: Colors.grey),
//                                                                         ),
//                                                                         TextSpan(
//                                                                           text:
//                                                                               "         \$${entry.amount.toString()}",
//                                                                           style:
//                                                                               const TextStyle(
//                                                                             fontWeight:
//                                                                                 FontWeight.w700,
//                                                                             color: Color.fromRGBO(
//                                                                                 21,
//                                                                                 43,
//                                                                                 83,
//                                                                                 1),
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   // Text.rich(
//                                                                   //   TextSpan(
//                                                                   //     children: [
//                                                                   //       TextSpan(
//                                                                   //         text:
//                                                                   //             'Amount: ',
//                                                                   //         style: TextStyle(
//                                                                   //             fontWeight: FontWeight.bold,
//                                                                   //             color: blueColor),
//                                                                   //       ),
//                                                                   //       TextSpan(
//                                                                   //         text:
//                                                                   //             '${entry.amount.toString()}',
//                                                                   //         style: const TextStyle(
//                                                                   //             fontWeight: FontWeight.w700,
//                                                                   //             color: Colors.grey),
//                                                                   //       ),
//                                                                   //     ],
//                                                                   //   ),
//                                                                   // ),
//                                                                   // Add more fields here as necessary
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         );
//                                                       }).toList(),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           // SizedBox(height: 13,),
//                                         ],
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                   )),
//             if (MediaQuery.of(context).size.width > 500)
//               FutureBuilder<LeaseLedger?>(
//                 future: _leaseLedgerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                       child: SpinKitFadingCircle(
//                         color: Colors.black,
//                         size: 55.0,
//                       ),
//                     );
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else if (!snapshot.hasData) {
//                     return const Center(child: Text('No data available'));
//                   } else {
//                     totalrecords = _tableData.length;
//                     print('${_tableData.length}');
//                     return SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           Container(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20.0, vertical: 5),
//                               child: Column(
//                                 children: [
//                                   SingleChildScrollView(
//                                     scrollDirection: Axis.horizontal,
//                                     child: Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           .91,
//                                       child: Table(
//                                         defaultColumnWidth:
//                                             const IntrinsicColumnWidth(),
//                                         children: [
//                                           TableRow(
//                                             decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   // color: blueColor
//                                                   ),
//                                             ),
//                                             children: [
//                                               _buildHeader(
//                                                   'Main Type',
//                                                   0,
//                                                   (property) => property!
//                                                       .data!.first.totalAmount
//                                                       .toString()),
//                                               _buildHeader(
//                                                   'Subtype',
//                                                   1,
//                                                   (property) => property!
//                                                       .data!.first.totalAmount
//                                                       .toString()),
//                                               _buildHeader(
//                                                   'Created At', 2, null),
//                                               _buildHeader(
//                                                   'Updated At', 3, null),
//                                               _buildHeader('Actions', 4, null),
//                                             ],
//                                           ),
//                                           TableRow(
//                                             decoration: const BoxDecoration(
//                                               border: Border.symmetric(
//                                                   horizontal: BorderSide.none),
//                                             ),
//                                             children: List.generate(
//                                                 5,
//                                                 (index) => TableCell(
//                                                     child:
//                                                         Container(height: 20))),
//                                           ),
//                                           for (var i = 0;
//                                               i < _pagedData.length;
//                                               i++)
//                                             TableRow(
//                                               decoration: BoxDecoration(
//                                                 border: Border(
//                                                   left: const BorderSide(
//                                                       color: Color.fromRGBO(
//                                                           21, 43, 81, 1)),
//                                                   right: const BorderSide(
//                                                       color: Color.fromRGBO(
//                                                           21, 43, 81, 1)),
//                                                   top: const BorderSide(
//                                                       color: Color.fromRGBO(
//                                                           21, 43, 81, 1)),
//                                                   bottom: i ==
//                                                           _pagedData.length - 1
//                                                       ? const BorderSide(
//                                                           color: Color.fromRGBO(
//                                                               21, 43, 81, 1))
//                                                       : BorderSide.none,
//                                                 ),
//                                               ),
//                                               children: [
//                                                 _buildDataCell(_pagedData[i]!
//                                                     .data!
//                                                     .first!
//                                                     .balance
//                                                     .toString()),
//                                                 _buildDataCell(_pagedData[i]!
//                                                     .data!
//                                                     .first!
//                                                     .balance
//                                                     .toString()),
//                                                 _buildDataCell(
//                                                   _pagedData[i]!
//                                                       .data!
//                                                       .first!
//                                                       .balance
//                                                       .toString(),
//                                                 ),
//                                                 _buildDataCell(
//                                                   _pagedData[i]!
//                                                       .data!
//                                                       .first!
//                                                       .balance
//                                                       .toString(),
//                                                 ),
//                                                 _buildActionsCell(
//                                                     _pagedData[i]),
//                                               ],
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 25),
//                                   _buildPaginationControls(),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 25),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class FinancialTable extends StatefulWidget {
  final String leaseId;
  final String tenantId;
  final String status;
  FinancialTable(
      {required this.leaseId, required this.status, required this.tenantId});
  @override
  _FinancialTableState createState() => _FinancialTableState();
}

class _FinancialTableState extends State<FinancialTable> {
  int totalrecords = 0;
  late Future<List<propertytype>> futurePropertyTypes;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  // void sortData(List<leaseLedger> data) {
  //   if (sorting1) {
  //     data.sort((a, b) => ascending1
  //         ? a.propertyType!.compareTo(b.propertyType!)
  //         : b.propertyType!.compareTo(a.propertyType!));
  //   } else if (sorting2) {
  //     data.sort((a, b) => ascending2
  //         ? a.propertysubType!.compareTo(b.propertysubType!)
  //         : b.propertysubType!.compareTo(a.propertysubType!));
  //   } else if (sorting3) {
  //     data.sort((a, b) => ascending3
  //         ? a.createdAt!.compareTo(b.createdAt!)
  //         : b.createdAt!.compareTo(a.createdAt!));
  //   }
  // }

  int? expandedIndex;
  Set<int> expandedIndices = {};
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1 == true) {
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = !sorting1;
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? const Text("Type",
                        style: TextStyle(color: Colors.white))
                        : const Text("Type",
                        style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
                    /* ascending1
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),*/
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2) {
                      sorting1 = false;
                      sorting2 = sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = !sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    }
                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    const Text("Balance      ",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
                    /*ascending2
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),*/
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting3) {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = !sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    const Text("      Date", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
                    /* ascending3
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  late Future<LeaseLedger?> _leaseLedgerFuture;

  @override
  void initState() {
    super.initState();
    _leaseLedgerFuture = LeaseRepository().fetchLeaseLedger(widget.leaseId);
  }
  // @override
  // void initState() {
  //   super.initState();
  //   futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  // }

  void handleEdit(Data? ledge) async {
    // Handle edit action
    // print('Edit ${applicant.sId}');
    // var check = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => EditApplicant(
    //               applicant: ,
    //               applicantId: ,
    //             )));
    // if (check == true) {
    //   setState(() {});
    // }
  }

  void _showAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this property!",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            var data = PropertyTypeRepository().DeletePropertyType(pro_id: id);
            // Add your delete logic here
            setState(() {
              futurePropertyTypes =
                  PropertyTypeRepository().fetchPropertyTypes();
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<Data?> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Data?> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  void _sort<T>(Comparable<T> Function(Data? d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        final result = aValue.compareTo(bValue as T);
        return _sortAscending ? result : -result;
      });
    });
  }

  void handleDelete(Data? ledge) {
    _showAlert(context, ledge!.leaseId!);
    // Handle delete action
    // print('Delete ${property.sId}');
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(Data? d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null
            ? () {
          _sort(getField, columnIndex, !_sortAscending);
        }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              if (_sortColumnIndex == columnIndex)
                Icon(_sortAscending
                    ? Icons.arrow_drop_down_outlined
                    : Icons.arrow_drop_up_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCell(Data? data) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 50,
          // color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  handleEdit(data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.edit,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              InkWell(
                onTap: () {
                  handleDelete(data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int numorpages = 1;
    numorpages = (totalrecords / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text('Rows per page: '),
        // SizedBox(width: 10),
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _changeRowsPerPage(newValue);
                  }
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: _currentPage == 0
                ? Colors.grey
                : const Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: _currentPage == 0
              ? null
              : () {
            setState(() {
              _currentPage--;
            });
          },
        ),
        Text(
          'Page ${_currentPage + 1} of $numorpages',
          style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : const Color.fromRGBO(
                21, 43, 83, 1), // Change color based on availability
          ),
          onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
              ? null
              : () {
            setState(() {
              _currentPage++;
            });
          },
        ),
      ],
    );
  }

  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            widget.status == 'Active'
                ? Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: MediaQuery.of(context).size.width < 500 ? 36 :45,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10.0)),
                              elevation: 0,
                              backgroundColor: Colors.white),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCard(
                                      leaseId: widget.leaseId,
                                    )));
                          },
                          child: Text(
                            'Add Cards',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 500 ? 12 :18,
                                color: Color.fromRGBO(21, 43, 83, 1)),
                          ))),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      height: MediaQuery.of(context).size.width < 500 ? 36 : 45,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10.0)),
                              elevation: 0,
                              backgroundColor: Colors.white),
                          onPressed: () async{
                            final value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MakePayment(leaseId: widget.leaseId, tenantId: widget.tenantId,)));
                            if(value== true){
                              setState(() {
                                _leaseLedgerFuture = LeaseRepository().fetchLeaseLedger(widget.leaseId);
                              });

                            }
                          },
                          child: Text(
                            'Make Payment',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 500 ? 12 :18,
                                color: Color.fromRGBO(21, 43, 83, 1)),
                          ))),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      height: MediaQuery.of(context).size.width < 500 ? 34 : 45,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10.0)),
                              elevation: 0,
                              backgroundColor: Colors.white),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => enterCharge(
                                      leaseId: widget.leaseId,
                                    )));
                          },
                          child: Text(
                            'Enter Charge',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 500 ? 12 :18,
                                color: Color.fromRGBO(21, 43, 83, 1)),
                          ))),
                ],
              ),
            )
                : Container(),
            const SizedBox(
              height: 6,
            ),
            if (MediaQuery.of(context).size.width > 500)
              const SizedBox(height: 25),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, bottom: 10.0),
                  child: FutureBuilder<LeaseLedger?>(
                    future: _leaseLedgerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ColabShimmerLoadingWidget();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No data found'));
                      } else {


                        final leaseLedger = snapshot.data!;
                        if(leaseLedger.data == null || leaseLedger.data!.length == 0){
                          return Container(child: Text("No data found"),);
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 5),
                              _buildHeaders(),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: blueColor),
                                ),
                                child: Column(
                                  children: leaseLedger.data!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    bool isExpanded = expandedIndex == index;
                                    Data data = entry.value;
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: blueColor),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Padding(
                                              padding:
                                              const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (expandedIndex ==
                                                            index) {
                                                          expandedIndex = null;
                                                        } else {
                                                          expandedIndex = index;
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      margin:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                      padding: !isExpanded
                                                          ? const EdgeInsets
                                                          .only(bottom: 10)
                                                          : const EdgeInsets
                                                          .only(top: 10),
                                                      child: FaIcon(
                                                        isExpanded
                                                            ? FontAwesomeIcons
                                                            .sortUp
                                                            : FontAwesomeIcons
                                                            .sortDown,
                                                        size: 20,
                                                        color: const Color
                                                            .fromRGBO(
                                                            21, 43, 83, 1),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                      child: Text(
                                                        ' ${data.type}'??"", // Assuming you want to show the charge type here
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .08),
                                                  Expanded(
                                                    child: Text(
                                                      ' \$${data.balance!.toStringAsFixed(2)}', // Show total amount
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .08),
                                                  Expanded(
                                                    child: Text(
                                                      formatDate(
                                                          '${data.createdAt}'), // Format and show created date
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .02),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isExpanded)
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      children: [
                                                        FaIcon(
                                                          isExpanded
                                                              ? FontAwesomeIcons
                                                              .sortUp
                                                              : FontAwesomeIcons
                                                              .sortDown,
                                                          size: 50,
                                                          color: Colors
                                                              .transparent,
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
                                                                    const TextSpan(
                                                                      text:
                                                                      'Increase : ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1)),
                                                                    ),
                                                                    TextSpan(
                                                                      text: (data.type == "Refund" || data.type == "Charge")
                                                                          ? '${data.totalAmount}'
                                                                          : 'N/A',
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                          Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text:
                                                                      'Tenant : ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1)),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${data.tenantData["tenant_firstName"]} ${data.tenantData["tenant_lastName"]}',
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                          Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 40,
                                                          child: Column(
                                                            children: [
                                                              IconButton(
                                                                icon:
                                                                const FaIcon(
                                                                  FontAwesomeIcons
                                                                      .edit,
                                                                  size: 20,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      83,
                                                                      1),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  // handleEdit(applicant);
                                                                  // var check = await Navigator.push(
                                                                  //     context,
                                                                  //     MaterialPageRoute(
                                                                  //         builder: (context) => EditApplicant(
                                                                  //               applicant: applicant,
                                                                  //               applicantId: applicant.applicantId!,
                                                                  //             )));
                                                                  // if (check ==
                                                                  //     true) {
                                                                  //   setState(
                                                                  //       () {});
                                                                  // }
                                                                },
                                                              ),
                                                              IconButton(
                                                                icon:
                                                                const FaIcon(
                                                                  FontAwesomeIcons
                                                                      .trashCan,
                                                                  size: 20,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      83,
                                                                      1),
                                                                ),
                                                                onPressed: () {
                                                                  // handleDelete(applicant);
                                                                  // _showDeleteAlert(
                                                                  //     context,
                                                                  //     applicant
                                                                  //         .applicantId!);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: data.entry!
                                                          .map((entry) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                          children: [
                                                            FaIcon(
                                                              isExpanded
                                                                  ? FontAwesomeIcons
                                                                  .sortUp
                                                                  : FontAwesomeIcons
                                                                  .sortDown,
                                                              size: 50,
                                                              color: Colors
                                                                  .transparent,
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
                                                                          'Transaction: ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                          "Manual ${data.type} FOR ${data.response} ${data.paymenttype} (#${data.transactionid})   ",
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              color: Colors.grey),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                          'Decrease: ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor),
                                                                        ),
                                                                        TextSpan(
                                                                          text:(data.type != "Refund" && data.type != "Charge")
                                                                              ? '${data.totalAmount}'
                                                                              : 'N/A',
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              color: Colors.grey),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          // SizedBox(height: 13,),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      }
                    },
                  )),
            if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<LeaseLedger?>(
                future: _leaseLedgerFuture,
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
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  } else {
                    _tableData = snapshot.data!.data!;
                    totalrecords = _tableData.length;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5),
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      child: Table(
                                        defaultColumnWidth:
                                        const IntrinsicColumnWidth(),
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                // color: blueColor
                                              ),
                                            ),
                                            children: [
                                              _buildHeader(
                                                  'Type',
                                                  0,
                                                  (property) => property!
                                                     .totalAmount
                                                      .toString()),
                                              _buildHeader(
                                                  'Tenant',
                                                  1,
                                                  (property) => property!
                                                      .totalAmount
                                                      .toString()),
                                              _buildHeader(
                                                  'Transaction', 2, null),
                                              _buildHeader(
                                                  'Increase', 3, null),
                                              _buildHeader(
                                                  'Decrease', 3, null),
                                              _buildHeader('Balance', 4, null),
                                              _buildHeader('Date', 4, null),
                                            ],
                                          ),
                                          TableRow(
                                            decoration: const BoxDecoration(
                                              border: Border.symmetric(
                                                  horizontal: BorderSide.none),
                                            ),
                                            children: List.generate(
                                                7,
                                                (index) => TableCell(
                                                    child:
                                                    Container(height: 20))),
                                          ),
                                          for (var i = 0;
                                          i < _pagedData.length;
                                          i++)
                                            TableRow(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1)),
                                                  right: const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1)),
                                                  top: const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1)),
                                                  bottom: i ==
                                                      _pagedData.length - 1
                                                      ? const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1))
                                                      : BorderSide.none,
                                                ),
                                              ),
                                              children: [
                                                _buildDataCell(_pagedData[i]!
                                                    .type
                                                    .toString()),
                                                _buildDataCell('${_pagedData[i]!.tenantData["tenant_firstName"].toString()} ${_pagedData[i]!.tenantData["tenant_lastName"].toString()}'),
                                                _buildDataCell(
                                                 'Manual ${_pagedData[i]!.type.toString()} ${_pagedData[i]!.response} for ${_pagedData[i]!.paymenttype} (#${_pagedData[i]!.transactionid})'
                                                ),
                                                _buildDataCell(
                                                  _pagedData[i]!.type == "Refund" && _pagedData[i]!.type == "Charge"
                                                      ? _pagedData[i]!.totalAmount.toString()
                                                      : 'N/A',
                                                ),
                                                _buildDataCell(
                                                  _pagedData[i]!.type != "Refund" && _pagedData[i]!.type != "Charge"
                                                      ? _pagedData[i]!.totalAmount.toString()
                                                      : 'N/A',
                                                ),
                                                _buildDataCell(
                                                  _pagedData[i]!.balance.toString(),
                                                ),
                                                _buildDataCell(
                                                 formatDate3( _pagedData[i]!
                                                      .createdAt.toString()),

                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  _buildPaginationControls(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}