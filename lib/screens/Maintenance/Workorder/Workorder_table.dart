import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/repository/workorder.dart';
import 'package:three_zero_two_property/screens/Maintenance/Workorder/Add_workorder.dart';
import 'package:three_zero_two_property/screens/Maintenance/Workorder/Edit_workorders.dart';
import 'package:three_zero_two_property/screens/Maintenance/Workorder/workorder_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../constant/constant.dart';
import '../../../model/workordr.dart';
import '../../../provider/dateProvider.dart';
import '../../../widgets/CustomTableShimmer.dart';
import '../../../widgets/custom_drawer.dart';

class Workorder_table extends StatefulWidget {
  const Workorder_table({super.key});

  @override
  State<Workorder_table> createState() => _Workorder_tableState();
}

class _Workorder_tableState extends State<Workorder_table> {
  int totalrecords = 0;
  late Future<Map<String, dynamic>> futureworkorders;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  Map<String, dynamic>? paginationInfo;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page
  List<String> selectedStatuses = ['New', 'In Progress']; // Default selected

  void sortData(List<Data> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.workOrderData!.workSubject!
              .compareTo(b.workOrderData!.workSubject!)
          : b.workOrderData!.workSubject!
              .compareTo(a.workOrderData!.workSubject!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.workOrderData!.status!.compareTo(b.workOrderData!.status!)
          : b.workOrderData!.status!.compareTo(a.workOrderData!.status!));
    }
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
  bool isChecked = false;
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
                        ? const Text("Work Order ",
                            style: TextStyle(color: Colors.white))
                        : const Text("Work Order",
                            style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),

                    ascending1
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
                          ),
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
                    const Text("       Status",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
                    ascending2
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
                          ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
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
                child: const Row(
                  children: [
                    Text("      Billable ",
                        style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> items = [
    "All",
    'Closed',
    "Completed",
    "In Progress",
    'New',
    "On Hold",
    "Over Due"
  ];
  String? selectedValue;
  ConnectivityResult? _connectivityResult;
  String searchvalue = "";

  Future<void> _loadWorkOrders() async {
    setState(() {
      futureworkorders = WorkOrderRepository().fetchWorkOrdersPaginated(
        page: currentPage + 1,
        limit: itemsPerPage,
        sortBy: 'createdAt',
        sortOrder: 'desc',
        status: selectedStatuses.contains('All') ? null : selectedStatuses,
        search: searchvalue.isEmpty ? null : searchvalue,
      );
    });
    final result = await futureworkorders;
    setState(() {
      paginationInfo = result['pagination'];
    });
  }

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    _loadWorkOrders();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void handleEdit(Data property) async {
    // Handle edit action
    //print('Edit ${property.sId}');
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResponsiveEditWorkOrder(
                  workorderId: property.workOrderData!.workOrderId!,
                )));
    if (check == true) {
      setState(() {});
    }
  }

  void _showAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this Workorder!",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      content: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for deletion',
                  contentPadding: EdgeInsets.only(top: 8, left: 15)),
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            if (reason.text.isEmpty) {
              Fluttertoast.showToast(msg: "Please enter a reason for deletion");
            } else {
              var data = await WorkOrderRepository()
                  .DeleteWorkOrder(workOrderid: id, reason: reason.text);
              // Add your delete logic here
              _loadWorkOrders();
              Navigator.pop(context);
            }
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8), // Rounded corners
          border: Border.all(
            color: blueColor, // Blue border
            width: 1.5,
          ),
        ),
      ],
    ).show();
  }

  List<Data> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Data> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(Data d) getField, int columnIndex,
      bool ascending) {
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

  void handleDelete(Data workorder) {
    _showAlert(context, workorder.workOrderData!.workOrderId!);
    // Handle delete action
    print('Delete ${workorder.workOrderData?.workOrderId!}');
  }

  Widget _buildHeader<T>(
      String text, int columnIndex, Comparable<T> Function(Data d)? getField) {
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
  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  Widget _buildDataCellBillable(bool isBillable) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isBillable) Icon(Icons.check, color: blueColor),
            if (!isBillable) Icon(Icons.close, color: blueColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCell(Data data) {
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
            color: _currentPage == 0 ? Colors.grey : blueColor,
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
                : blueColor, // Change color based on availability
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

  Widget _buildMultiSelectDropdown() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
        width: MediaQuery.of(context).size.width < 500
            ? MediaQuery.of(context).size.width * .38
            : MediaQuery.of(context).size.width * .4,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8A95A8)),
          color: Colors.white,
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedStatuses.isEmpty || selectedStatuses.contains('All')
                      ? 'Status'
                      : selectedStatuses.length == 1
                          ? selectedStatuses.first
                          : '${selectedStatuses.length} Selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedStatuses.isEmpty ||
                            selectedStatuses.contains('All')
                        ? const Color(0xFF8A95A8)
                        : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF8A95A8)),
            ],
          ),
          itemBuilder: (BuildContext context) {
            return items.map((String item) {
              final isSelected = selectedStatuses.contains(item) ||
                  (item == 'All' && selectedStatuses.contains('All'));
              return PopupMenuItem<String>(
                value: item,
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (item == 'All') {
                            if (value == true) {
                              selectedStatuses = ['All'];
                            } else {
                              selectedStatuses = [];
                            }
                          } else {
                            if (selectedStatuses.contains('All')) {
                              selectedStatuses.remove('All');
                            }
                            if (value == true) {
                              if (!selectedStatuses.contains(item)) {
                                selectedStatuses.add(item);
                              }
                            } else {
                              selectedStatuses.remove(item);
                            }
                            if (selectedStatuses.isEmpty) {
                              selectedStatuses = ['All'];
                            }
                          }
                          currentPage = 0;
                          _loadWorkOrders();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  DateTime parseDate(String dateString) {
    try {
      // List of common date formats to try
      List<String> formats = [
        'yyyy-MM-dd', // Example: 2024-11-25
        'MM/dd/yyyy', // Example: 11/25/2024
        'dd/MM/yyyy', // Example: 25/11/2024
        'yyyy-MM-dd HH:mm', // Example: 2024-11-25 14:30
        'yyyy/MM/dd', // Example: 2024/11/25
        'MMMM dd, yyyy', // Example: November 25, 2024
      ];

      for (String format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (e) {
          // Continue trying other formats
        }
      }

      // If none of the formats match, throw an error
      throw FormatException("Unsupported date format: $dateString");
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime.now(); // Fallback to current date if parsing fails
    }
  }

  final _scrollController = ScrollController();
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Work Order",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header Section with Title and Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 8.0),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(
                            width: 13,
                          ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: titleBar(
                              width: double.infinity,
                              title: 'Work Orders',
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ResponsiveAddWorkOrder()));
                                if (result == true) {
                                  _loadWorkOrders();
                                }
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width < 768)
                                        ? 50
                                        : 60,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    "+ Add",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          SizedBox(width: 3),
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  //search
                  Padding(
                    padding: const EdgeInsets.only(left: 11, right: 11),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 18),
                        Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            // height: 40,
                            height: MediaQuery.of(context).size.width < 500
                                ? 45
                                : 50,
                            width: MediaQuery.of(context).size.width < 500
                                ? MediaQuery.of(context).size.width * .52
                                : MediaQuery.of(context).size.width * .49,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                // border: Border.all(color: Colors.grey),
                                border:
                                    Border.all(color: const Color(0xFF8A95A8))),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 12
                                                : 14),
                                    // onChanged: (value) {
                                    //   setState(() {
                                    //     cvverror = false;
                                    //   });
                                    // },
                                    // controller: cvv,
                                    onChanged: (value) {
                                      setState(() {
                                        searchvalue = value;
                                        currentPage = 0;
                                        _loadWorkOrders();
                                      });
                                    },
                                    cursorColor: blueColor,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search here...",
                                        hintStyle: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14
                                              : 18,
                                          // fontWeight: FontWeight.bold,
                                          color: const Color(0xFF8A95A8),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            left: 5, bottom: 11, top: 5)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildMultiSelectDropdown(),
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    const SizedBox(height: 10),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(height: 20),
                  //billable
                  Padding(
                    padding: const EdgeInsets.only(left: 11, right: 11),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 5),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 25),
                        Row(
                          children: [
                            Text(
                              "Billable To Tenants",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 500
                                          ? 20
                                          : 12),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 24.0, // Standard width for checkbox
                              height: 24.0,
                              child: Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value ?? false;
                                  });
                                },
                                activeColor:
                                    isChecked ? blueColor : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // if (MediaQuery.of(context).size.width > 500)
                  //   const SizedBox(height: 25),
                  // if (MediaQuery.of(context).size.width < 500)
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 500 ? 11 : 28),
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: futureworkorders,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ColabShimmerLoadingWidget();
                        } else if (!snapshot.hasData ||
                            (snapshot.data!['data'] as List).isEmpty) {
                          return Container(
                            height: MediaQuery.of(context).size.height * .5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/no_data.jpg",
                                    height: 200,
                                    width: 200,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No Data Available",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          final List<Data> data =
                              (snapshot.data!['data'] as List)
                                  .map((item) => item as Data)
                                  .toList();

                          // Filter by billable if checked
                          final List<Data> filteredData = isChecked
                              ? data
                                  .where((workorder) =>
                                      workorder.workOrderData!.isBillable ==
                                      true)
                                  .toList()
                              : data;

                          final currentPageData = filteredData;
                          final totalPages = paginationInfo != null
                              ? paginationInfo!['totalPages'] as int
                              : 1;
                          Widget workOrderCard(
                            Data workOrder,
                            bool isExpanded,
                            VoidCallback onExpandTap,
                            BuildContext context,
                            DateProvider dateProvider,
                            VoidCallback onEdit,
                            VoidCallback onDelete,
                            VoidCallback onViewSummary,
                          ) {
                            return GestureDetector(
                              onTap: onExpandTap,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      currentPageData.indexOf(workOrder) % 2 ==
                                              0
                                          ? const Color(0xFFF4F8FF)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFDBE0E5)),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black12,
                                  //     blurRadius: 8,
                                  //     offset: Offset(0, 2),
                                  //   ),
                                  // ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: onExpandTap,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            child: Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: blueColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            workOrder.rentalAddress
                                                    ?.rentalAdress ??
                                                'N/A',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: blueColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            workOrder.workOrderData?.status ??
                                                'N/A',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // const Spacer(),
                                        // Expanded(
                                        //   flex: 2,
                                        //   child: Text(
                                        //     workOrder.workOrderData
                                        //             ?.ticketNumber ??
                                        //         'N/A',
                                        //     style: TextStyle(
                                        //       fontSize: 13,
                                        //       color: blueColor,
                                        //       fontWeight: FontWeight.bold,
                                        //     ),
                                        //     textAlign: TextAlign.end,
                                        //     maxLines: 1,
                                        //     softWrap: false,
                                        //     overflow: TextOverflow.ellipsis,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    if (isExpanded)
                                      Column(
                                        children: [
                                          const Divider(thickness: 2),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 25,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Assigned:',
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13)),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      workOrder.staffMember
                                                              ?.staffmemberName ??
                                                          "-",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text('Created:',
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13)),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      dateProvider.formatCurrentDate(
                                                              '${workOrder.workOrderData?.createdAt}') ??
                                                          "-",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 35,
                                              ),
                                              // Spacer(),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Billable:',
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13)),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      workOrder.workOrderData
                                                                  ?.isBillable ==
                                                              true
                                                          ? "Yes"
                                                          : "No",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text('Due Date:',
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13)),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      dateProvider.formatCurrentDate(
                                                              '${workOrder.workOrderData?.date}') ??
                                                          "-",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: onDelete,
                                                child: Container(
                                                  height: 35,
                                                  width: 35,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color:
                                                          Colors.red.shade50),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      FaIcon(
                                                        FontAwesomeIcons
                                                            .trashCan,
                                                        size: 15,
                                                        color: Colors.red,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              GestureDetector(
                                                onTap: onEdit,
                                                child: Container(
                                                  height: 35,
                                                  width: 35,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.green
                                                          .shade50), // color:Colors.grey[100],
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      FaIcon(
                                                        FontAwesomeIcons.edit,
                                                        size: 15,
                                                        color: Colors.green,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              GestureDetector(
                                                onTap: onViewSummary,
                                                child: Container(
                                                  height: 35,
                                                  width: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      FaIcon(
                                                        FontAwesomeIcons.eye,
                                                        size: 15,
                                                        color: Colors.black,
                                                      ),
                                                      SizedBox(width: 2),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF7F9FC),
                                      border: Border.all(
                                          color: const Color(0xFFDBE0E5)),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 8),
                                  margin: const EdgeInsets.only(bottom: 2),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Work Order",
                                          style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "  Status",
                                          style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // const Spacer(),
                                      // Expanded(
                                      //   flex: 2,
                                      //   child: Text(
                                      //     "Ticket #",
                                      //     style: TextStyle(
                                      //       color: blueColor,
                                      //       fontWeight: FontWeight.bold,
                                      //       fontSize: 14,
                                      //     ),
                                      //     textAlign: TextAlign.end,
                                      //   ),
                                      // ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                ...currentPageData.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Data workOrder = entry.value;
                                  bool isExpanded = expandedIndex == index;
                                  return workOrderCard(
                                    workOrder,
                                    isExpanded,
                                    () {
                                      setState(() {
                                        expandedIndex =
                                            isExpanded ? null : index;
                                      });
                                    },
                                    context,
                                    dateProvider,
                                    () async {
                                      var check = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ResponsiveEditWorkOrder(
                                            workorderId: workOrder
                                                .workOrderData!.workOrderId!,
                                          ),
                                        ),
                                      );
                                      if (check == true) {
                                        _loadWorkOrders();
                                      }
                                    },
                                    () {
                                      _showAlert(
                                          context,
                                          workOrder
                                              .workOrderData!.workOrderId!);
                                    },
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Workorder_summery(
                                            workorder_id: workOrder
                                                .workOrderData?.workOrderId,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                                if (paginationInfo != null &&
                                    (paginationInfo!['totalPages'] as int) > 1)
                                  const SizedBox(height: 20),
                                if (paginationInfo != null &&
                                    (paginationInfo!['totalPages'] as int) > 1)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Material(
                                            elevation: 3,
                                            child: Container(
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<int>(
                                                  value: itemsPerPage,
                                                  items: itemsPerPageOptions
                                                      .map((int value) {
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: value,
                                                      child: Text(
                                                          value.toString()),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      itemsPerPage = newValue!;
                                                      currentPage = 0;
                                                      _loadWorkOrders();
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
                                              FontAwesomeIcons
                                                  .circleChevronLeft,
                                              color: currentPage == 0
                                                  ? Colors.grey
                                                  : blueColor,
                                            ),
                                            onPressed: currentPage == 0
                                                ? null
                                                : () {
                                                    setState(() {
                                                      currentPage--;
                                                      _loadWorkOrders();
                                                    });
                                                  },
                                          ),
                                          Text(
                                              'Page ${currentPage + 1} of $totalPages'),
                                          IconButton(
                                            icon: FaIcon(
                                              FontAwesomeIcons
                                                  .circleChevronRight,
                                              color:
                                                  currentPage < totalPages - 1
                                                      ? blueColor
                                                      : Colors.grey,
                                            ),
                                            onPressed:
                                                currentPage < totalPages - 1
                                                    ? () {
                                                        setState(() {
                                                          currentPage++;
                                                          _loadWorkOrders();
                                                        });
                                                      }
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/no_internet.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                  const Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 2.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 2.0), // Space between label and value
                Text(
                  rightValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayValue(String? value) {
    // Return 'N/A' if the value is null or empty, otherwise return the value
    return (value == null || value.trim().isEmpty) ? 'N/A' : value;
  }
}
