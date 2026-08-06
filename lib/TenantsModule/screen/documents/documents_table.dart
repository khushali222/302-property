import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/TenantsModule/screen/property/summery_page.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../constant/constant.dart';

import '../../model/insurance.dart';
import '../../model/tenant_property.dart';

import '../../repository/insurance.dart';
import '../../repository/permission_provider.dart';
import '../../widgets/appbar.dart';
import '../../repository/tenant_repository.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/drawer_tiles.dart';
import 'add_insurance.dart';
import 'edit_insurance.dart';

class DocumentsInsuranceTable extends StatefulWidget {
  @override
  _DocumentsInsuranceTableState createState() =>
      _DocumentsInsuranceTableState();
}

class _DocumentsInsuranceTableState extends State<DocumentsInsuranceTable> {
  int totalrecords = 0;
  late Future<List<Insurance_data>> futurePropertyTypes;
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

  void sortData(List<Insurance_data> data) {
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
  void _showAddInsuranceAlert(
      BuildContext context, VoidCallback onConfirm, Insurance_data? property) {
    var id = property?.status == 'ACTIVE' ? property?.policyId : null;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFECA14E), width: 2.5),
                  ),
                  child: const Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        color: Color(0xFFECA14E),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Are you sure you want to add a new renter's insurance policy?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(21, 43, 81, 1),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "The currently active policy (Policy ID: ${id ?? '-'}) will be marked as expired.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFDBE0E5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            onConfirm();
                          },
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color: blueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFCEBEB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFFE24B4A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
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
              flex: 3,
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
                        ?
                    Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Company",
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          )
                        :
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Company",
                        style: TextStyle(
                            color: blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text("Policy Id",
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
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
                    Text(
                      "Expiration",
                      style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
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

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  ConnectivityResult? _connectivityResult;

  @override
  void initState() {
    super.initState();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
    checkInternet();
    Provider.of<PermissionProvider>(context, listen: false).fetchPermissions();
    futurePropertyTypes = InsuranceRepository().fetchInsurancesProperties();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void handleEdit(Insurance_data property) async {
    /* // Handle edit action
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
    final TextEditingController reasonController = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this Insurance!",
      content: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reasonController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for deletion',
                  contentPadding: EdgeInsets.only(top: 8, left: 15)),
            ),
          ),
        ],
      ),
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
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
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            if (reasonController.text.trim().isEmpty) {
              Fluttertoast.showToast(
                  msg: "Please enter a reason for deletion");
              return;
            }
            var data = await InsuranceRepository()
                .deleteInsurancesProperties(id, reasonController.text.trim());
            // Add your delete logic here

            if (data == true)
              setState(() {
                futurePropertyTypes =
                    InsuranceRepository().fetchInsurancesProperties();
              });
            Navigator.pop(context);
          },
          color: blueColor,
        )
      ],
    ).show();
  }

  List<Insurance_data> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Insurance_data> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(Insurance_data d) getField,
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

  void handleDelete(Insurance_data property) {
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
      Comparable<T> Function(Insurance_data d)? getField) {
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
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
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
  Widget _buildActionsCell(Insurance_data data) {
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
    final dateProvider = Provider.of<DateProvider>(context);
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final permissions = permissionProvider.permissions;
    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () {
          key.currentState!.openDrawer();
        },
      ),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: 'Documents',
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  //add propertytype

                  // Header Section with Title and Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: permissions!.documentsAdd ? 3 : 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: titleBar(
                              width: double.infinity,
                              title: 'Insurance',
                            ),
                          ),
                        ),
                        if (permissions!.documentsAdd)
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  // Check if there are existing insurance entries
                                  final existingInsurances =
                                      await futurePropertyTypes
                                          .catchError((_) => []);

                                  // Filter to find active insurance
                                  final activeInsurances =
                                      existingInsurances.where(
                                    (insurance) => insurance.status == 'ACTIVE',
                                  );

                                  final Insurance_data? activeInsurance =
                                      activeInsurances.isNotEmpty
                                          ? activeInsurances.first
                                          : null;

                                  if (activeInsurance != null) {
                                    // Show alert with active policy ID
                                    _showAddInsuranceAlert(context, () async {
                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                add_insurance()),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          futurePropertyTypes =
                                              InsuranceRepository()
                                                  .fetchInsurancesProperties();
                                        });
                                      }
                                    }, activeInsurance);
                                  } else {
                                    // Navigate directly to add_insurance if no active insurance
                                    final result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              add_insurance()),
                                    );
                                    if (result == true) {
                                      setState(() {
                                        futurePropertyTypes =
                                            InsuranceRepository()
                                                .fetchInsurancesProperties();
                                      });
                                    }
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
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  SizedBox(height: 10),
                  //search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFDBE0E5)),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: 14),
                        onChanged: (value) {
                          setState(() {
                            searchvalue = value;
                          });
                        },
                        cursorColor: blueColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here...",
                          hintStyle: TextStyle(color: Color(0xFF8A95A8), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF8A95A8), size: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(height: 25),
                  if (MediaQuery.of(context).size.width < 500)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FutureBuilder<List<Insurance_data>>(
                        future: futurePropertyTypes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              padding: EdgeInsets.only(top: 200),
                              child: Center(
                                  child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 40.0,
                              )),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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
                                    SizedBox(
                                      height: 10,
                                    ),
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
                            var data = snapshot.data!;
                            if (selectedValue == null && searchvalue!.isEmpty) {
                              data = snapshot.data!;
                            } else if (selectedValue == "All") {
                              data = snapshot.data!;
                            } else if (searchvalue!.isNotEmpty) {
                              data = snapshot.data!
                                  .where((property) => property.provider!
                                      .toLowerCase()
                                      .contains(searchvalue!.toLowerCase()))
                                  .toList();
                            }
                            if (data.length == 0) {
                              return Column(
                                children: [
                                  SizedBox(height: 14),
                                  _buildHeaders(),
                                  SizedBox(height: 30),
                                  Image.asset("assets/images/no_data.jpg", height: 120, width: 120),
                                  SizedBox(height: 10),
                                  Text("No Data Available",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: blueColor, fontSize: 15)),
                                  SizedBox(height: 20),
                                ],
                              );
                            }
                            sortData(data);
                            final totalPages =
                                (data.length / itemsPerPage).ceil();
                            final currentPageData = data
                                .skip(currentPage * itemsPerPage)
                                .take(itemsPerPage)
                                .toList();
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  _buildHeaders(),
                                  SizedBox(height: 10),
                                  Container(
                                    child: Column(
                                      children: currentPageData
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        bool isExpanded =
                                            expandedIndex == index;
                                        Insurance_data Propertytype =
                                            entry.value;
                                        //return CustomExpansionTile(data: Propertytype, index: index);
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: index % 2 != 0
                                                ? Color(0xFFF4F8FF)
                                                : Colors.white,
                                            border: Border.all(
                                                color: Color(0xFFDBE0E5)),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                                        CrossAxisAlignment
                                                            .center,
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
                                                              expandedIndex =
                                                                  null;
                                                            } else {
                                                              expandedIndex =
                                                                  index;
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
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
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: InkWell(
                                                          onTap: () {
                                                            // Navigator.of(context)
                                                            //     .push(MaterialPageRoute(builder: (context) => summery_page(lease_id: Propertytype.leaseId,)));
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5.0),
                                                            child: Text(
                                                              '${Propertytype.provider}',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .04),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          '${Propertytype.policyId}',
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .02),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          // '${widget.data.createdAt}',
                                                          '${Propertytype.expirationDate?.isNotEmpty == true ? dateProvider.formatCurrentDate('${Propertytype.expirationDate}') : 'N/A'}',

                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
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
                                                      horizontal: 0.0),
                                                  margin: EdgeInsets.only(
                                                      bottom: 2),
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
                                                              size: 35,
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
                                                                              'Liability Coverage : ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor), // Bold and black
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              formatMoney(Propertytype.liabilityCoverage),
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              color: grey), // Light and grey
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              'Status : ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor), // Bold and black
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${Propertytype.status}',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              color: grey), // Light and grey
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              'Effective Date : ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor), // Bold and black
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${Propertytype.effectiveDate?.isNotEmpty == true ? dateProvider.formatCurrentDate('${Propertytype.effectiveDate}') : 'N/A'}',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              color: grey), // Light and grey
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            // if (Propertytype
                                                            //         .status ==
                                                            //     'ACTIVE')
                                                            InkWell(
                                                              onTap: () async {
                                                                var check = await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => edit_insurance(
                                                                              data: Propertytype,
                                                                            )));
                                                                if (check ==
                                                                    true) {
                                                                  setState(() {
                                                                    futurePropertyTypes =
                                                                        InsuranceRepository()
                                                                            .fetchInsurancesProperties();
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 35,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    color: Colors
                                                                        .green
                                                                        .shade50), // color:Colors.grey[100],
                                                                child:
                                                                    const Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    FaIcon(
                                                                      FontAwesomeIcons
                                                                          .edit,
                                                                      size: 15,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                _showAlert(
                                                                    context,
                                                                    Propertytype
                                                                        .tenantInsuranceId!);
                                                                // _showAlert(context, rentals.rentalId!);
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 35,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    color: Colors
                                                                        .red
                                                                        .shade50),
                                                                child:
                                                                    const Row(
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
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            /*  SizedBox(width: 5,),
                                                      Expanded(
                                                        child: Container(
                                                          height:40,
                                                          decoration: BoxDecoration(
                                                              color: Colors.grey[350]
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.center,
                                                            children: [
                                                              SizedBox(width: 5,),
                                                              Image.asset('assets/icons/view.png'),
                                                              // FaIcon(
                                                              //   FontAwesomeIcons.trashCan,
                                                              //   size: 15,
                                                              //   color:blueColor,
                                                              // ),
                                                              SizedBox(width: 8,),
                                                              Text("View Summery",style: TextStyle(fontSize: 11,color: blueColor,fontWeight: FontWeight.bold),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),*/
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 8,
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
                                  if (data.length > itemsPerPage) ...[
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
                                                        });
                                                      }
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ],
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  if (MediaQuery.of(context).size.width > 500)
                    FutureBuilder<List<Insurance_data>>(
                      future: futurePropertyTypes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SpinKitFadingCircle(
                              color: Colors.black,
                              size: 55.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
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
                                  SizedBox(
                                    height: 10,
                                  ),
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
                          _tableData = snapshot.data!;
                          /* if (selectedValue == null && searchvalue.isEmpty) {
                      _tableData = snapshot.data!;
                    } else if (selectedValue == "All") {
                      _tableData = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      _tableData = snapshot.data!
                          .where((property) =>
                      property.propertyType!
                          .toLowerCase()
                          .contains(searchvalue.toLowerCase()) ||
                          property.propertysubType!
                              .toLowerCase()
                              .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      _tableData = snapshot.data!
                          .where((property) =>
                      property.propertyType == selectedValue)
                          .toList();
                    }*/
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
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Table(
                                              defaultColumnWidth:
                                                  IntrinsicColumnWidth(),
                                              children: [
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        // color: blueColor
                                                        ),
                                                  ),
                                                  children: [
                                                    _buildHeader(
                                                        'Insurance Company',
                                                        0,
                                                        (property) =>
                                                            property.provider!),

                                                    _buildHeader(
                                                        'Policy Id', 2, null),
                                                    _buildHeader(
                                                        'Liability Coverage',
                                                        2,
                                                        null),
                                                    _buildHeader(
                                                        'Status', 2, null),
                                                    _buildHeader(
                                                        'Effective Date',
                                                        2,
                                                        null),
                                                    _buildHeader(
                                                        'Expiration Date',
                                                        3,
                                                        null),
                                                    _buildHeader(
                                                        'Actions', 3, null),
                                                    // _buildHeader('Actions', 4, null),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    border: Border.symmetric(
                                                        horizontal:
                                                            BorderSide.none),
                                                  ),
                                                  children: List.generate(
                                                      7,
                                                      (index) => TableCell(
                                                          child: Container(
                                                              height: 20))),
                                                ),
                                                for (var i = 0;
                                                    i < _pagedData.length;
                                                    i++)
                                                  TableRow(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        left: BorderSide(
                                                            color: blueColor),
                                                        right: BorderSide(
                                                            color: blueColor),
                                                        top: BorderSide(
                                                            color: blueColor),
                                                        bottom: i ==
                                                                _pagedData
                                                                        .length -
                                                                    1
                                                            ? BorderSide(
                                                                color:
                                                                    blueColor)
                                                            : BorderSide.none,
                                                      ),
                                                    ),
                                                    children: [
                                                      // Text(
                                                      //     '${_pagedData[i].propertyType!}'),
                                                      // Text(
                                                      //     '${_pagedData[i].propertysubType!}'),
                                                      // Text(
                                                      //     '${formatDate(_pagedData[i].createdAt!)}'),
                                                      // Text(
                                                      //     '${formatDate(_pagedData[i].updatedAt!)}'),
                                                      _buildDataCell(
                                                          _pagedData[i]
                                                              .provider!),

                                                      _buildDataCell(
                                                        _pagedData[i].policyId!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .liabilityCoverage
                                                            .toString()!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i].status!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .effectiveDate!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .expirationDate!,
                                                      ),
                                                      _buildActionsCell(
                                                          _pagedData[i]),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 25),
                                        _buildPaginationControls(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),
                              ],
                            ),
                          );
                        }
                      },
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
                  Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }
}
