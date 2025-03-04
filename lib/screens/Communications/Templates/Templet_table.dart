import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../constant/constant.dart';
import '../../../widgets/custom_drawer.dart';
import 'Add_mail.dart';


class TempletTable extends StatefulWidget {
  @override
  _TempletTableState createState() => _TempletTableState();
}

class _TempletTableState extends State<TempletTable> {
  // int totalrecords = 0;
  // Future<List<propertytype>>? futurePropertyTypes;
  // int rowsPerPage = 5;
  // int sortColumnIndex = 0;
  // bool sortAscending = true;
  // int currentPage = 0;
  // int itemsPerPage = 10;
  // List<int> itemsPerPageOptions = [
  //   10,
  //   25,
  //   50,
  //   100,
  // ]; // Options for items per page
  //
  // void sortData(List<propertytype> data) {
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
  //
  // int? expandedIndex;
  // Set<int> expandedIndices = {};
  // late bool isExpanded;
  // bool sorting1 = false;
  // bool sorting2 = false;
  // bool sorting3 = false;
  // bool ascending1 = false;
  // bool ascending2 = false;
  // bool ascending3 = false;
  // Widget _buildHeaders() {
  //   var width = MediaQuery.of(context).size.width;
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: blueColor,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(13),
  //         topRight: Radius.circular(13),
  //       ),
  //     ),
  //     child: ListTile(
  //       contentPadding: EdgeInsets.zero,
  //       // leading: Container(
  //       //   child: Icon(
  //       //     Icons.expand_less,
  //       //     color: Colors.transparent,
  //       //   ),
  //       // ),
  //       title: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           Container(
  //             child: Icon(
  //               Icons.expand_less,
  //               color: Colors.transparent,
  //             ),
  //           ),
  //           Expanded(
  //             child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   if (sorting1 == true) {
  //                     sorting2 = false;
  //                     sorting3 = false;
  //                     ascending1 = sorting1 ? !ascending1 : true;
  //                     ascending2 = false;
  //                     ascending3 = false;
  //                   } else {
  //                     sorting1 = !sorting1;
  //                     sorting2 = false;
  //                     sorting3 = false;
  //                     ascending1 = sorting1 ? !ascending1 : true;
  //                     ascending2 = false;
  //                     ascending3 = false;
  //                   }
  //
  //                   // Sorting logic here
  //                 });
  //               },
  //               child: Row(
  //                 children: [
  //                   width < 400
  //                       ? Text("Main Type ",
  //                       style: TextStyle(color: Colors.white))
  //                       : Text("Main Type",
  //                       style: TextStyle(color: Colors.white)),
  //                   // Text("Property", style: TextStyle(color: Colors.white)),
  //                   SizedBox(width: 3),
  //                   ascending1
  //                       ? Padding(
  //                     padding: const EdgeInsets.only(top: 7, left: 2),
  //                     child: FaIcon(
  //                       FontAwesomeIcons.sortUp,
  //                       size: 20,
  //                       color: Colors.white,
  //                     ),
  //                   )
  //                       : Padding(
  //                     padding: const EdgeInsets.only(bottom: 7, left: 2),
  //                     child: FaIcon(
  //                       FontAwesomeIcons.sortDown,
  //                       size: 20,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   if (sorting2) {
  //                     sorting1 = false;
  //                     sorting2 = sorting2;
  //                     sorting3 = false;
  //                     ascending2 = sorting2 ? !ascending2 : true;
  //                     ascending1 = false;
  //                     ascending3 = false;
  //                   } else {
  //                     sorting1 = false;
  //                     sorting2 = !sorting2;
  //                     sorting3 = false;
  //                     ascending2 = sorting2 ? !ascending2 : true;
  //                     ascending1 = false;
  //                     ascending3 = false;
  //                   }
  //                   // Sorting logic here
  //                 });
  //               },
  //               child: Row(
  //                 children: [
  //                   Text("  Subtypes", style: TextStyle(color: Colors.white)),
  //                   SizedBox(width: 5),
  //                   ascending2
  //                       ? Padding(
  //                     padding: const EdgeInsets.only(top: 7, left: 2),
  //                     child: FaIcon(
  //                       FontAwesomeIcons.sortUp,
  //                       size: 20,
  //                       color: Colors.white,
  //                     ),
  //                   )
  //                       : Padding(
  //                     padding: const EdgeInsets.only(bottom: 7, left: 2),
  //                     child: FaIcon(
  //                       FontAwesomeIcons.sortDown,
  //                       size: 20,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   if (sorting3) {
  //                     sorting1 = false;
  //                     sorting2 = false;
  //                     sorting3 = sorting3;
  //                     ascending3 = sorting3 ? !ascending3 : true;
  //                     ascending2 = false;
  //                     ascending1 = false;
  //                   } else {
  //                     sorting1 = false;
  //                     sorting2 = false;
  //                     sorting3 = !sorting3;
  //                     ascending3 = sorting3 ? !ascending3 : true;
  //                     ascending2 = false;
  //                     ascending1 = false;
  //                   }
  //
  //                   // Sorting logic here
  //                 });
  //               },
  //               child: Row(
  //                 children: [
  //                   Text("  Created At", style: TextStyle(color: Colors.white)),
  //                   SizedBox(width: 5),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // final List<String> items = ['Residential', "Commercial", "All"];
  // String? selectedValue;
  // String searchvalue = "";
  // @override
  // void initState() {
  //   super.initState();
  //   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
  //     setState(() {
  //       _connectivityResult = result;
  //       if (_connectivityResult != ConnectivityResult.none)
  //         futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  //     });
  //   });
  //   checkInternet();
  // }
  //
  // void checkInternet() async {
  //   var connectiondata;
  //   connectiondata = await Connectivity().checkConnectivity();
  //   setState(() {
  //     _connectivityResult = connectiondata;
  //   });
  //
  //   if (_connectivityResult != ConnectivityResult.none)
  //     futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  // }
  //
  // void handleEdit(propertytype property) async {
  //   // Handle edit action
  //
  //   var check = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => Edit_property_type(
  //             property: property,
  //           )));
  //   if (check == true) {
  //     setState(() {});
  //   }
  //   // final result = await Navigator.push(
  //   //     context,
  //   //     MaterialPageRoute(
  //   //         builder: (context) => Edit_property_type(
  //   //               property: property,
  //   //             )));
  //   /* if (result == true) {
  //     setState(() {
  //       futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  //     });
  //   }*/
  // }
  //
  // bool _errorText = false;
  // void _showAlert(BuildContext context, String id) {
  //   TextEditingController reason = TextEditingController();
  //   Alert(
  //     context: context,
  //     type: AlertType.warning,
  //     title: "Are you sure?",
  //     desc: "Once deleted, you will not be able to recover this property!",
  //     content: Column(
  //       children: <Widget>[
  //         SizedBox(
  //           height: 10,
  //         ),
  //         SizedBox(
  //           height: 45,
  //           child: TextField(
  //             controller: reason,
  //             decoration: InputDecoration(
  //               border: OutlineInputBorder(),
  //               hintText: 'Enter reason for deletion',
  //               contentPadding: EdgeInsets.only(top: 8, left: 15),
  //             ),
  //           ),
  //         ),
  //         // if (_errorText)
  //         //   Text(
  //         //     "Please fill in all fields correctly.",
  //         //     style: TextStyle(color: Colors.redAccent),
  //         //   ),
  //       ],
  //     ),
  //     style: AlertStyle(
  //       backgroundColor: Colors.white,
  //     ),
  //     buttons: [
  //       DialogButton(
  //         child: Text(
  //           "Delete",
  //           style: TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //         onPressed: () async {
  //           if (reason.text.isEmpty) {
  //             // setState(() {
  //             //  _errorText == true;
  //             // });
  //             Fluttertoast.showToast(msg: "Please enter a reason for deletion");
  //           } else {
  //             var data = await PropertyTypeRepository()
  //                 .DeletePropertyType(pro_id: id, reason: reason.text);
  //             // Add your delete logic here
  //             if (data != null)
  //               setState(() {
  //                 futurePropertyTypes =
  //                     PropertyTypeRepository().fetchPropertyTypes();
  //               });
  //             Navigator.pop(context);
  //           }
  //         },
  //         color: blueColor,
  //       ),
  //       DialogButton(
  //         child: Text(
  //           "Cancel",
  //           style: TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //         onPressed: () => Navigator.pop(context),
  //         color: Colors.grey,
  //       ),
  //     ],
  //   ).show();
  // }
  //
  // List<propertytype> _tableData = [];
  // int _rowsPerPage = 10;
  // int _currentPage = 0;
  // int? _sortColumnIndex;
  // bool _sortAscending = true;
  //
  // List<propertytype> get _pagedData {
  //   int startIndex = _currentPage * _rowsPerPage;
  //   int endIndex = startIndex + _rowsPerPage;
  //   return _tableData.sublist(startIndex,
  //       endIndex > _tableData.length ? _tableData.length : endIndex);
  // }
  //
  // void _changeRowsPerPage(int selectedRowsPerPage) {
  //   setState(() {
  //     _rowsPerPage = selectedRowsPerPage;
  //     _currentPage = 0; // Reset to the first page when changing rows per page
  //   });
  // }
  //
  // void _sort<T>(Comparable<T> Function(propertytype d) getField,
  //     int columnIndex, bool ascending) {
  //   setState(() {
  //     _sortColumnIndex = columnIndex;
  //     _sortAscending = ascending;
  //     _tableData.sort((a, b) {
  //       final aValue = getField(a);
  //       final bValue = getField(b);
  //       final result = aValue.compareTo(bValue as T);
  //       return _sortAscending ? result : -result;
  //     });
  //   });
  // }
  //
  // void handleDelete(propertytype property) {
  //   _showAlert(context, property.propertyId!);
  //   // Handle delete action
  // }
  //
  //
  // Widget _buildHeader<T>(String text, int columnIndex,
  //     Comparable<T> Function(propertytype d)? getField) {
  //   return TableCell(
  //     child: InkWell(
  //       onTap: getField != null
  //           ? () {
  //         _sort(getField, columnIndex, !_sortAscending);
  //       }
  //           : null,
  //       child: Padding(
  //         padding: const EdgeInsets.all(18.0),
  //         child: Row(
  //           children: [
  //             Text(text,
  //                 style: const TextStyle(
  //                     fontWeight: FontWeight.bold, fontSize: 18)),
  //             if (_sortColumnIndex == columnIndex)
  //               Icon(_sortAscending
  //                   ? Icons.arrow_drop_down_outlined
  //                   : Icons.arrow_drop_up_outlined),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // // Widget _buildDataCell(String text) {
  // //   return Padding(
  // //     padding: const EdgeInsets.all(5.0),
  // //     child: Container(
  // //       height: 50,
  // //       // color: Colors.blue,
  // //       child: TableCell(
  // //         child: Padding(
  // //           padding: const EdgeInsets.all(10.0),
  // //           child: Center(child: Text(text, style: TextStyle(fontSize: 18))),
  // //         ),
  // //       ),
  // //     ),
  // //   );
  // // }
  // Widget _buildDataCell(String text) {
  //   return TableCell(
  //     child: Padding(
  //       padding: const EdgeInsets.only(top: 20.0, left: 16),
  //       child: Text(text, style: const TextStyle(fontSize: 18)),
  //     ),
  //   );
  // }
  //
  // // Widget _buildActionsCell(propertytype data) {
  // //   return Padding(
  // //     padding: const EdgeInsets.all(5.0),
  // //     child: Container(
  // //       height: 50,
  // //       // color: Colors.blue,
  // //       child: TableCell(
  // //         child: Row(
  // //           children: [
  // //             SizedBox(
  // //               width: 20,
  // //             ),
  // //             InkWell(
  // //               onTap: () {
  // //                 handleEdit(data);
  // //               },
  // //               child: FaIcon(
  // //                 FontAwesomeIcons.edit,
  // //                 size: 30,
  // //               ),
  // //             ),
  // //             SizedBox(
  // //               width: 15,
  // //             ),
  // //             InkWell(
  // //               onTap: () {
  // //                 handleDelete(data);
  // //               },
  // //               child: FaIcon(
  // //                 FontAwesomeIcons.trashCan,
  // //                 size: 30,
  // //               ),
  // //             ),
  // //           ],
  // //         ),
  // //       ),
  // //     ),
  // //   );
  // // }
  // Widget _buildActionsCell(propertytype data) {
  //   return TableCell(
  //     child: Padding(
  //       padding: const EdgeInsets.all(5.0),
  //       child: Container(
  //         height: 50,
  //         // color: Colors.blue,
  //         child: Row(
  //           children: [
  //             const SizedBox(
  //               width: 20,
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 handleEdit(data);
  //               },
  //               child: const FaIcon(
  //                 FontAwesomeIcons.edit,
  //                 size: 30,
  //               ),
  //             ),
  //             const SizedBox(
  //               width: 15,
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 handleDelete(data);
  //               },
  //               child: const FaIcon(
  //                 FontAwesomeIcons.trashCan,
  //                 size: 30,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildPaginationControls() {
  //   int numorpages = 1;
  //   numorpages = (totalrecords / _rowsPerPage).ceil();
  //
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       // Text('Rows per page: '),
  //       // SizedBox(width: 10),
  //       Material(
  //         elevation: 2,
  //         color: Colors.white,
  //         child: Container(
  //           height: 55,
  //           padding: EdgeInsets.symmetric(horizontal: 12.0),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.grey),
  //             borderRadius: BorderRadius.circular(4.0),
  //           ),
  //           child: DropdownButtonHideUnderline(
  //             child: DropdownButton<int>(
  //               value: _rowsPerPage,
  //               items: [10, 25, 50, 100].map((int value) {
  //                 return DropdownMenuItem<int>(
  //                   value: value,
  //                   child: Text(value.toString()),
  //                 );
  //               }).toList(),
  //               onChanged: (newValue) {
  //                 if (newValue != null) {
  //                   _changeRowsPerPage(newValue);
  //                 }
  //               },
  //               icon: Icon(
  //                 Icons.arrow_drop_down,
  //                 size: 40,
  //               ),
  //               style: TextStyle(color: Colors.black, fontSize: 17),
  //               dropdownColor: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 10),
  //       IconButton(
  //         icon: FaIcon(
  //           FontAwesomeIcons.circleChevronLeft,
  //           size: 30,
  //           color: _currentPage == 0 ? Colors.grey : blueColor,
  //         ),
  //         onPressed: _currentPage == 0
  //             ? null
  //             : () {
  //           setState(() {
  //             _currentPage--;
  //           });
  //         },
  //       ),
  //       Text(
  //         'Page ${_currentPage + 1} of $numorpages',
  //         style: TextStyle(fontSize: 18),
  //       ),
  //       IconButton(
  //         icon: FaIcon(
  //           size: 30,
  //           FontAwesomeIcons.circleChevronRight,
  //           color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
  //               ? Colors.grey
  //               : blueColor, // Change color based on availability
  //         ),
  //         onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
  //             ? null
  //             : () {
  //           setState(() {
  //             _currentPage++;
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }
  //
  // ConnectivityResult? _connectivityResult;
  // final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
   // final dateProvider = Provider.of<DateProvider>(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Templates",
        dropdown: false,
      ),
      body:Column(
          children: [
            SizedBox(
              height: 20,
            ),
            //add propertytype
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: titleBar(
                      width: MediaQuery.of(context).size.width * .65,
                      title: 'Templates',
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => Add_Email_templet()));
                      if (result == true) {
                        setState(() {
                          // futurePropertyTypes = PropertyTypeRepository()
                          //     .fetchPropertyTypes();
                        });
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 50
                          : MediaQuery.of(context).size.width * 0.062,

                      // height:  MediaQuery.of(context).size.width * 0.07,
                      // height:  40,
                      width: (MediaQuery.of(context).size.width < 500)
                          ? MediaQuery.of(context).size.width * 0.25
                          : MediaQuery.of(context).size.width * 0.25,
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 4.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "+ Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width <
                                    500
                                    ? 16
                                    : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 6),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 22),
                ],
              ),
            ),

          ],
        ),
    );
  }
}

void main() => runApp(MaterialApp(home: TempletTable()));
