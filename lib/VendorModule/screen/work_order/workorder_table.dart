import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../constant/constant.dart';

import '../../model/tenant_financial.dart';
import '../../model/tenant_property.dart';

import '../../repository/tenant_financial.dart';
import '../../repository/workorder.dart';
import '../../widgets/appbar.dart';
import '../../repository/tenant_repository.dart';
import '../../widgets/drawer_tiles.dart';
import 'add_workorder.dart';
import '../../model/workorder_model.dart';
import '../work_order/workorder_summery.dart';
class WorkOrderTable extends StatefulWidget {
  String? filter;
  WorkOrderTable({
    this.filter
});
  @override
  _WorkOrderTableState createState() => _WorkOrderTableState();
}

class _WorkOrderTableState extends State<WorkOrderTable> {
  int totalrecords = 0;
  late Future<List<WorkOrder>> futureworkorder;
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

  void sortData(List<WorkOrder> data) {
    /*  if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.propertyType!.compareTo(b.propertyType!)
          : b.propertyType!.compareTo(a.propertyType!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.propertysubType!.compareTo(b.propertysubType!)
          : b.propertysubType!.compareTo(a.propertysubType!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }*/
  }

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
        borderRadius: BorderRadius.only(
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
            /* Container(
              child: Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),*/

            Expanded(
              flex: 4,
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
                        ? Text("        Work Order",
                        style: TextStyle(color: Colors.white))
                        : Text("         Work Order",
                        style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                    /*ascending1
                        ? Padding(
                      padding: const EdgeInsets.only(top: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 7, left: 2),
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
              flex: 3,
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
                    Text(" Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    /* ascending2
                        ? Padding(
                      padding: const EdgeInsets.only(top: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 7, left: 2),
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
              flex: 2,
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
                    Text("Status", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    /*ascending3
                        ? Padding(
                      padding: const EdgeInsets.only(top: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 7, left: 2),
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

  final List<String> items = ['New', "In Progress", "On Hold","Completed","Over Due","All"];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    futureworkorder = WorkOrderRepository().fetchWorkOrders();
    selectedValue = widget.filter;
  }

  void handleEdit(WorkOrder property) async {
    /* // Handle edit action
    print('Edit ${property.sId}');
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_property_type(
              property: property,
            )));
    if (check == true) {
      setState(() {});
    }*/
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_property_type(
    //               property: property,
    //             )));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void _showAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this property!",
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            /* var data = TenantPropertyRepository().DeletePropertyType(id: id);
            // Add your delete logic here
            setState(() {
              futurePropertyTypes =
                  PropertyTypeRepository().fetchPropertyTypes();
            });
            Navigator.pop(context);*/
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<WorkOrder> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<WorkOrder> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(WorkOrder d) getField,
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

  void handleDelete(WorkOrder tenant) {
    // _showAlert(context, property.propertyId!);
    // // Handle delete action
    // print('Delete ${property.sId}');
  }

  // Widget _buildHeader<T>(String text, int columnIndex,
  //     Comparable<T> Function(propertytype d)? getField) {
  //   return Container(
  //     height: 70,
  //     // color: Colors.blue,
  //     child: TableCell(
  //       child: InkWell(
  //         onTap: getField != null
  //             ? () {
  //                 _sort(getField, columnIndex, !_sortAscending);
  //               }
  //             : null,
  //         child: Padding(
  //           padding: const EdgeInsets.all(14.0),
  //           child: Row(
  //             children: [
  //               SizedBox(width: 10),
  //               Text(text,
  //                   style:
  //                       TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
  //               if (_sortColumnIndex == columnIndex)
  //                 Icon(_sortAscending
  //                     ? Icons.arrow_drop_down_outlined
  //                     : Icons.arrow_drop_up_outlined),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(WorkOrder d)? getField) {
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
                  style:  TextStyle(
                      fontWeight: FontWeight.bold, color: blueColor, fontSize: 18)),
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

  // Widget _buildDataCell(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.all(5.0),
  //     child: Container(
  //       height: 50,
  //       // color: Colors.blue,
  //       child: TableCell(
  //         child: Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Center(child: Text(text, style: TextStyle(fontSize: 18))),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildDataCell(String text,String id) {
    return TableCell(
      child: InkWell(
        onTap: (){
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Workorder_summery(workorder_id:id,)));
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.only(top: 20.0, left: 16),
          child: Text(text, style:  TextStyle(fontSize: 18,color: blueColor)),
        ),
      ),
    );
  }

  // Widget _buildActionsCell(propertytype data) {
  //   return Padding(
  //     padding: const EdgeInsets.all(5.0),
  //     child: Container(
  //       height: 50,
  //       // color: Colors.blue,
  //       child: TableCell(
  //         child: Row(
  //           children: [
  //             SizedBox(
  //               width: 20,
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 handleEdit(data);
  //               },
  //               child: FaIcon(
  //                 FontAwesomeIcons.edit,
  //                 size: 30,
  //               ),
  //             ),
  //             SizedBox(
  //               width: 15,
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 handleDelete(data);
  //               },
  //               child: FaIcon(
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
  Widget _buildActionsCell(WorkOrder data) {
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
            padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color:
            _currentPage == 0 ? Colors.grey : Color.fromRGBO(21, 43, 83, 1),
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
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : Color.fromRGBO(
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
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: () {
        key.currentState!.openDrawer();
      },),
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
                  SvgPicture.asset(
                    "assets/images/tenants/dashboard.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/Admin.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Profile",
                  false),
             /* buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/Property.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Properties",
                  false),
              buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/Financial.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Financial",
                  false),*/
              buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/Work Light.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Work Order",
                  true),
              /* buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),*/
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
              SizedBox(
              height: 20,
            ),
           /* //add propertytype
            Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => Add_Workorder()));
                      if (result == true) {
                        setState(() {
                          futureworkorder =
                          WorkOrderRepository().fetchWorkOrders();
                        });
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 40
                          : MediaQuery.of(context).size.width * 0.065,

                      // height:  MediaQuery.of(context).size.width * 0.07,
                      // height:  40,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Add Work Order",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * 0.034,
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
            SizedBox(height: 10),*/
            titleBar(
              width: MediaQuery.of(context).size.width > 500 ?MediaQuery.of(context).size.width * .88 :MediaQuery.of(context).size.width * .91,
              title: 'Work Orders',
            ),
            SizedBox(height: 10),
            //search

            Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 5),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 32),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // height: 40,
                      height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                      width: MediaQuery.of(context).size.width < 500
                          ? MediaQuery.of(context).size.width * .52
                          : MediaQuery.of(context).size.width * .49,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          // border: Border.all(color: Colors.grey),
                          border: Border.all(color: Color(0xFF8A95A8))),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: TextField(
                              style:TextStyle(
                                  fontSize:  MediaQuery.of(context).size.width < 500 ? 12 : 14
                              ),
                              // onChanged: (value) {
                              //   setState(() {
                              //     cvverror = false;
                              //   });
                              // },
                              // controller: cvv,
                              onChanged: (value) {
                                setState(() {
                                  searchvalue = value;
                                });
                              },
                              cursorColor: Color.fromRGBO(21, 43, 81, 1),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search here...",
                                  hintStyle: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18 ,
                                    // fontWeight: FontWeight.bold,
                                    color: Color(0xFF8A95A8),
                                  ),
                                  contentPadding:
                                  EdgeInsets.only(left: 5,bottom: 10,top: 14)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  DropdownButtonHideUnderline(
                    child: Material(
                      elevation: 3,
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                'Type',
                                style: TextStyle(
                                  fontSize: 14,
                                  // fontWeight: FontWeight.bold,
                                  color: Color(0xFF8A95A8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: items
                            .map((String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        value: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height:
                          MediaQuery.of(context).size.width < 500 ? 40 : 50,
                          // width: 180,
                          width: MediaQuery.of(context).size.width < 500
                              ? MediaQuery.of(context).size.width * .35
                              : MediaQuery.of(context).size.width * .35,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              // color: Colors.black26,
                              color: Color(0xFF8A95A8),
                            ),
                            color: Colors.white,
                          ),
                          elevation: 0,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            //color: Colors.redAccent,
                          ),
                          offset: const Offset(-20, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 500) SizedBox(height: 25),
            if (MediaQuery.of(context).size.width < 500)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: FutureBuilder<List<WorkOrder>>(
                  future: futureworkorder,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: SpinKitFadingCircle(
                            color: Colors.black,
                            size: 40.0,
                          ));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    } else {
                      var data = snapshot.data!;
                    if (selectedValue == null && searchvalue!.isEmpty) {
                        data = snapshot.data!;
                      } else if (selectedValue == "All") {
                        data = snapshot.data!;
                      } else if (searchvalue!.isNotEmpty) {
                        data = snapshot.data!
                            .where((property) =>
                        property.workSubject!
                            .toLowerCase()
                            .contains(searchvalue!.toLowerCase()) ||
                            property.rentalAddress!
                                .toLowerCase()
                                .contains(searchvalue!.toLowerCase()))
                            .toList();

                      } else {
                      if(selectedValue =="Over Due"){
                        data = snapshot.data!.where((element) {
                          DateTime dueDate = DateTime.parse(element.date!);
                          bool isOverDue = dueDate.isBefore(DateTime.now());
                          bool isNotCompleted = element.status != "Completed";
                          // Adjust based on your date format
                          return isOverDue && isNotCompleted;
                        }).toList();
                      }
                      else{
                        data = snapshot.data!
                            .where((property) =>
                        property.status == selectedValue)
                            .toList();
                      }


                      }
                      if(data.length == 0){
                        return Column(
                          children: [
                            SizedBox(height: 20,),
                            Center(
                              child: Text("No Work Order Added"),
                            ),
                          ],
                        );
                      }

                      //sortData(data);
                      print(data);
                      //   print(snapshot.data!.first.totalBalance);
                      final totalPages = (data.length / itemsPerPage).ceil();
                      final currentPageData = data
                          .skip(currentPage * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            _buildHeaders(),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: blueColor)),
                              child: Column(
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  WorkOrder workorder = entry.value;
                                  //print(Tenant_financial.totalBalance);
                                  //return CustomExpansionTile(data: Propertytype, index: index);
                                  return Container(
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
                                                    // setState(() {
                                                    //    isExpanded = !isExpanded;
                                                    // //  expandedIndex = !expandedIndex;
                                                    //
                                                    // });
                                                    // setState(() {
                                                    //   if (isExpanded) {
                                                    //     expandedIndex = null;
                                                    //     isExpanded = !isExpanded;
                                                    //   } else {
                                                    //     expandedIndex = index;
                                                    //   }
                                                    // });
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
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    padding: !isExpanded
                                                        ? EdgeInsets.only(
                                                        bottom: 10)
                                                        : EdgeInsets.only(
                                                        top: 10),
                                                    child: FaIcon(
                                                      isExpanded
                                                          ? FontAwesomeIcons
                                                          .sortUp
                                                          : FontAwesomeIcons
                                                          .sortDown,
                                                      size: 20,
                                                      color: Color.fromRGBO(
                                                          21, 43, 83, 1),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: InkWell(
                                                    onTap: (){
                                                      Navigator.of(context)
                                                          .push(MaterialPageRoute(builder: (context) => Workorder_summery(workorder_id: workorder.workOrderId,)));
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: Text(
                                                        '${workorder.workSubject!}',
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
                                                    width:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .03),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    '${workorder.rentalAddress}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .02),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    // '${widget.data.createdAt}',
                                                    '${workorder.status}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 12,
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            margin: EdgeInsets.only(bottom: 20),
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
                                                        color:
                                                        Colors.transparent,
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
                                                                    'Category: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: '${workorder.workCategory}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                        color: Colors
                                                                            .grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                    'Created At : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: formatDate('${workorder.createdAt}'),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                        color: Colors
                                                                            .grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 6),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                    'Assign : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                    '${workorder.staffMemberName}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                        color: Colors
                                                                            .grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(height: MediaQuery.of(context).size.height * .0065),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                    'Updated At : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:formatDate( '${workorder.updatedAt}'),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                        color: Colors
                                                                            .grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                    /*  Container(
                                                        width: 40,
                                                        child: Column(
                                                          children: [
                                                            IconButton(
                                                              icon: FaIcon(
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
                                                                // handleEdit(Propertytype);

                                                                // var check = await Navigator.push(
                                                                //     context,
                                                                //     MaterialPageRoute(
                                                                //         builder: (context) => Edit_property_type(
                                                                //           property: Propertytype,
                                                                //         )));
                                                                // if (check ==
                                                                //     true) {
                                                                //   setState(
                                                                //           () {});
                                                                // }
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: FaIcon(
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
                                                                //handleDelete(Propertytype);
                                                                // _showAlert(
                                                                //     context,
                                                                //     Propertytype
                                                                //         .propertyId!);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),*/
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        //SizedBox(height: 13,),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    // Text('Rows per page:'),
                                    SizedBox(width: 10),
                                    Material(
                                      elevation: 3,
                                      child: Container(
                                        height: 40,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          border:
                                          Border.all(color: Colors.grey),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: itemsPerPage,
                                            items: itemsPerPageOptions
                                                .map((int value) {
                                              return DropdownMenuItem<int>(
                                                value: value,
                                                child: Text(value.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                itemsPerPage = newValue!;
                                                currentPage =
                                                0; // Reset to first page when items per page change
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronLeft,
                                        color: currentPage == 0
                                            ? Colors.grey
                                            : Color.fromRGBO(21, 43, 83, 1),
                                      ),
                                      onPressed: currentPage == 0
                                          ? null
                                          : () {
                                        setState(() {
                                          currentPage--;
                                        });
                                      },
                                    ),
                                    // IconButton(
                                    //   icon: Icon(Icons.arrow_back),
                                    //   onPressed: currentPage > 0
                                    //       ? () {
                                    //     setState(() {
                                    //       currentPage--;
                                    //     });
                                    //   }
                                    //       : null,
                                    // ),
                                    Text(
                                        'Page ${currentPage + 1} of $totalPages'),
                                    // IconButton(
                                    //   icon: Icon(Icons.arrow_forward),
                                    //   onPressed: currentPage < totalPages - 1
                                    //       ? () {
                                    //     setState(() {
                                    //       currentPage++;
                                    //     });
                                    //   }
                                    //       : null,
                                    // ),
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronRight,
                                        color: currentPage < totalPages - 1
                                            ? Color.fromRGBO(21, 43, 83, 1)
                                            : Colors.grey,
                                      ),
                                      onPressed: currentPage < totalPages - 1
                                          ? () {
                                        setState(() {
                                          currentPage++;
                                        });
                                      }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<List<WorkOrder>>(
                future: futureworkorder,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 55.0,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    _tableData = snapshot.data!;
                    if (selectedValue == null && searchvalue.isEmpty) {
                      _tableData = snapshot.data!;
                    } else if (selectedValue == "All") {
                      _tableData = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      _tableData = snapshot.data!
                          .where((property) =>
                      property.workSubject!
                          .toLowerCase()
                          .contains(searchvalue.toLowerCase()) ||
                          property.rentalAddress!
                              .toLowerCase()
                              .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      if(selectedValue =="Over Due"){
                        _tableData = snapshot.data!.where((element) {
                          DateTime dueDate = DateTime.parse(element.date!);
                          bool isOverDue = dueDate.isBefore(DateTime.now());
                          bool isNotCompleted = element.status != "Completed";
                          // Adjust based on your date format
                          return isOverDue && isNotCompleted;
                        }).toList();
                      }
                      else{
                        _tableData = snapshot.data!
                            .where((property) =>
                        property.status == selectedValue)
                            .toList();
                      }
                    }

                    totalrecords = _tableData.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding:
                              const EdgeInsets.only(left: 22, right: 22),
                              child: Table(

                                defaultColumnWidth: IntrinsicColumnWidth(),
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        // color: blueColor
                                      ),
                                    ),
                                    children: [

                                      _buildHeader(
                                          'Work Order',
                                          0,
                                              (tenant) =>
                                          tenant.workSubject!),
                                      _buildHeader(
                                          'Property',
                                          1,
                                              (tenant) =>
                                          tenant.rentalAddress!), _buildHeader(
                                          'Category',
                                          2,
                                              (tenant) =>
                                          tenant.workCategory!), _buildHeader(
                                          'Asssigned',
                                          3,
                                              (tenant) =>
                                          tenant.staffMemberName!), _buildHeader(
                                          'Status',
                                          4,
                                              (tenant) =>
                                          tenant.status!),
                                      _buildHeader(
                                          'Create At', 5, null),
                                      _buildHeader(
                                          'Updated At', 6, null),

                                      // _buildHeader('Actions', 4, null),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(
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
                                          left: BorderSide(
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1)),
                                          right: BorderSide(
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1)),
                                          top: BorderSide(
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1)),
                                          bottom: i ==
                                              _pagedData.length - 1
                                              ? BorderSide(
                                            width: 2,
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1))
                                              : BorderSide.none,
                                        ),
                                      ),
                                      children: [

                                        _buildDataCell(_pagedData[i]
                                            .workSubject!,_pagedData[i]
                                            .workOrderId!),

                                        _buildDataCell(
                                          _pagedData[i]
                                              .rentalAddress!,_pagedData[i]
                                            .workOrderId!
                                        ),
                                        _buildDataCell(
                                          _pagedData[i]
                                              .workCategory!,_pagedData[i]
                                            .workOrderId!
                                        ),
                                        _buildDataCell(
                                          _pagedData[i]
                                              .staffMemberName!,_pagedData[i]
                                            .workOrderId!
                                        ),
                                        _buildDataCell(
                                          _pagedData[i]
                                              .status!,_pagedData[i]
                                            .workOrderId!
                                        ),
                                        _buildDataCell(
                                          _pagedData[i]
                                              .createdAt!,_pagedData[i]
                                            .workOrderId!
                                        ),
                                        _buildDataCell(
                                          _pagedData[i]
                                              .updatedAt!,_pagedData[i]
                                            .workOrderId!
                                        ),

                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_tableData.isEmpty)
                            Text("No Search Records Found"),
                          SizedBox(height: 25),
                          _buildPaginationControls(),
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

void main() => runApp(MaterialApp(home: WorkOrderTable()));