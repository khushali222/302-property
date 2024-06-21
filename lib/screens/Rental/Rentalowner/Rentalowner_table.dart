import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/Edit_RentalOwners.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/rentalowner_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';



import '../../../Model/RentalOwnersData.dart';
import '../../../constant/constant.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../model/staffmember.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../repository/Staffmember.dart';
import '../../../repository/rentalowner.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../Staff_Member/Add_staffmember.dart';
import '../../Staff_Member/Edit_staff_member.dart';
import 'Add_RentalOwners.dart';
import 'package:http/http.dart'as http;

class Rentalowner_table extends StatefulWidget {
  RentalOwner? rentalownersummery;
  Rentalowner_table({super.key,this.rentalownersummery});

  @override
  State<Rentalowner_table> createState() => _Rentalowner_tableState();
}

class _Rentalowner_tableState extends State<Rentalowner_table> {

  late Future<List<RentalOwner>> futureStaffMembers;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> roles = ['Manager', 'Employee', 'All'];
  String? selectedRole;
  String searchValue = "";

  @override
  void initState() {
    super.initState();
    futureStaffMembers = RentalOwnerService().fetchRentalOwners("");
    fetchRentalOwneradded();
  }
  List<RentalOwner> _tableData = [];
  int totalrecords = 0;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<RentalOwner> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex, endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  void _sort<T>(Comparable<T> Function(RentalOwner d) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);

        int result;
        if (aValue is String && bValue is String) {
          result = aValue.toString().toLowerCase().compareTo(bValue.toString().toLowerCase());
        } else {
          result = aValue.compareTo(bValue as T);
        }

        return _sortAscending ? result : -result;
      });
    });
  }

  // void handleEdit(RentalOwnerData staff) async {
  //   // Handle edit action
  //   print('Edit ${staff.sId}');
  //   // final result = await Navigator.push(
  //   //     context,
  //   //     MaterialPageRoute(
  //   //         builder: (context) => Edit_staff_member(
  //   //           staff: staff,
  //   //         )));
  //   // if (result == true) {
  //   //   setState(() {
  //   //     futureStaffMembers = RentalOwnerService().fetchRentalOwners("");
  //   //   });
  //   // }
  // }
  void handleEdit(RentalOwner rentalOwner) async {
    // Handle edit action
    print('Edit ${rentalOwner.rentalownerId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_rentalowners(rentalOwner: rentalOwner,)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this staff member!",
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
            await StaffMemberRepository().DeleteStaffMember(id: id);
            setState(() {
              futureStaffMembers = RentalOwnerService().fetchRentalOwners("");
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  /* void _sort<T>(Comparable<T> Function(RentalOwnerData) getField, int columnIndex, bool ascending) {
    futureStaffMembers.then((staffMembers) {
      staffMembers.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
      setState(() {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      });
    });
  }
*/
  void handleDelete(RentalOwnerData staff) {
    // _showDeleteAlert(context, staff.staffmemberId!);
    // // Handle delete action
    // print('Delete ${staff.staffmemberId}');
  }

  final _scrollController = ScrollController();
  void handleTap(RentalOwnerSummey rentalownersummery ) async {
    // Handle edit action
    print('Edit ${rentalownersummery.rentalownerId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Rentalowners_summery(  rentalOwnersid: '',)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }
  String? rentalOwnersid;
  int rentalownerCount = 0;
  int rentalOwnerCountLimit = 0;
  Future<void> fetchRentalOwneradded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    final response =
    await http.get(Uri.parse('${Api_url}/api/rental_owner/limitation/$id'));
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201 ) {
      print(rentalownerCount);
      print(rentalOwnerCountLimit);
      setState(() {
        rentalownerCount = jsonData['rentalownerCount'];
        print(rentalownerCount);
        rentalOwnerCountLimit = jsonData['rentalOwnerCountLimit'];
        print(rentalOwnerCountLimit);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showAlertforLimit(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Plan Limitation",
      desc: "The limit for adding rentalowners according to the plan has been reached.",
      style: AlertStyle(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          descStyle: TextStyle(fontSize: 14)
        //  overlayColor: Colors.black.withOpacity(.8)
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(21, 43, 83, 1),
        ),
        /* DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
             var data = PropertiesRepository().DeleteProperties(id: id);

            setState(() {
              futureRentalOwners = PropertiesRepository().fetchProperties();
              //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        )*/
      ],
    ).show();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.key,
                size: 20,
                color: Colors.black,
              ), "Rental",
                  ["Properties", "RentalOwner", "Tenants"],selectedSubtopic: "RentalOwner"),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.thumbsUp,
                size: 20,
                color: Colors.black,
              ),
                  "Leasing", ["Rent Roll", "Applicants"],selectedSubtopic: "RentalOwner"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],selectedSubtopic: "RentalOwner"),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    // onTap: () async {
                    //   final result = await Navigator.of(context).push(MaterialPageRoute(
                    //       builder: (context) => Add_rentalowners()));
                    //   if (result == true) {
                    //     setState(() {
                    //       futureStaffMembers =  RentalOwnerService().fetchRentalOwners("");
                    //     });
                    //   }
                    // },
                    onTap: () async {
                      if(rentalownerCount < rentalOwnerCountLimit  )
                      {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Add_rentalowners()));
                        if (result == true) {
                          setState(() {
                            futureStaffMembers =  RentalOwnerService().fetchRentalOwners("");
                            //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                          });
                        }
                      }
                      else{
                        _showAlertforLimit(context);
                      }

                    },
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "Add Rental Owner",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.034,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 13,right: 13),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: EdgeInsets.only(top: 8, left: 10),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(bottom: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color.fromRGBO(21, 43, 81, 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text(
                    "Rental Owner",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 19, right: 13),
              child: Row(
                children: [
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      height: 40,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Color(0xFF8A95A8)),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchValue = value;
                          });
                        },
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here...",
                          hintStyle: TextStyle(color: Color(0xFF8A95A8)),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text(
                        'Added : ${rentalownerCount.toString()}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8A95A8),
                            fontSize: 13),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      //  Text("rentalOwnerCountLimit: ${response['rentalOwnerCountLimit']}"),
                      Text(
                        'Total: ${rentalOwnerCountLimit.toString()}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8A95A8),
                            fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  /*  DropdownButtonHideUnderline(
                    child: Material(
                      elevation: 3,
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Role',
                                style: TextStyle(fontSize: 14, color: Color(0xFF8A95A8)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: roles.map((String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                        value: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 40,
                          width: 160,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Color(0xFF8A95A8)),
                            color: Colors.white,
                          ),
                          elevation: 0,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
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
                  ),*/
                ],
              ),
            ),
            SizedBox(height: 25),
            FutureBuilder<List<RentalOwner>>(
              future: futureStaffMembers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: SpinKitFadingCircle(
                    color: Colors.black,
                    size: 40.0,
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  List<RentalOwner>? filteredData = [];
                  _tableData = snapshot.data!;
                  if (selectedRole == null && searchValue == "") {
                    filteredData = snapshot.data;
                  } else if (selectedRole == "All") {
                    filteredData = snapshot.data;
                  } else if (searchValue.isNotEmpty) {
                    filteredData = snapshot.data!
                        .where((staff) =>
                    staff.rentalOwnerName!.toLowerCase().contains(searchValue.toLowerCase()) ||
                        staff.rentalOwnerName!.toLowerCase().contains(searchValue.toLowerCase()))
                        .toList();
                  }
                  _tableData = filteredData!;
                  totalrecords = _tableData.length;
                  return  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            defaultColumnWidth: IntrinsicColumnWidth(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(border: Border.all()),
                                children: [
                                  //_buildHeader('FirstName', 0, (staff) => staff.rentalOwnerFirstName!),
                                 //  _buildHeader('LastName', 1, (staff) => staff.rentalOwnerLastName!),
                                 // _buildHeader('Name', 0, (staff) => '${staff.rentalOwnerFirstName ?? ''} ${staff.rentalOwnerLastName ?? ''}'),
                                  _buildHeader('Name', 0, (staff) => staff.rentalOwnerName!),
                                  _buildHeader('Phone', 1, (staff) => staff.rentalOwnerPhoneNumber!),
                                  _buildHeader('Email', 2, (staff) => staff.rentalOwnerPrimaryEmail!),
                                  _buildHeader('Actions',3, null),
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(
                                  border: Border.symmetric(horizontal: BorderSide.none),
                                ),
                                children: List.generate(4, (index) => TableCell(child: Container(height: 20))),
                              ),
                              for (var i = 0; i < _pagedData.length; i++)
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
                                      right: BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
                                      top: BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
                                      bottom: i == _pagedData.length - 1
                                          ? BorderSide(color: Color.fromRGBO(21, 43, 81, 1))
                                          : BorderSide.none,
                                    ),
                                  ),
                                  children: [
                                     //_buildDataCell(_pagedData[i].rentalOwnerFirstName!),
                                    InkWell(
                                        onTap:()async{
                                          final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Rentalowners_summery(rentalOwnersid:_pagedData[i].rentalownerId!,)));
                                          },
                                        child: _buildDataCell(_pagedData[i].rentalOwnerName??"")),
                                    // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                    _buildDataCell(_pagedData[i].rentalOwnerPhoneNumber!),
                                    _buildDataCell(_pagedData[i].rentalOwnerPrimaryEmail!),
                                    _buildActionsCell(_pagedData[i]),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if(_tableData.isEmpty)
                          Text("No Search Records Found"),
                        SizedBox(height: 10),
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
  Widget _buildHeader<T>(String text, int columnIndex, Comparable<T> Function(RentalOwner d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null
            ? () {
          _sort(getField, columnIndex, !_sortAscending);
        }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
              if ( getField != null)
                Icon(
                  _sortColumnIndex == columnIndex
                      ? (_sortAscending ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined)
                      : Icons.arrow_drop_down_outlined, // Default icon for unsorted columns

                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }

  Widget _buildActionsCell(RentalOwner data) {
    return TableCell(
      child: Row(
        children: [
          InkWell(
            onTap: (){
              handleEdit(data);
            },
            child: Container(
              margin: EdgeInsets.only(top: 8,left: 8),
              child: FaIcon(
                FontAwesomeIcons.edit,
                size: 20,
              ),

            ),
          ),
          SizedBox(width: 6,),
          InkWell(
            onTap: (){

            },
            child: Container(
              margin: EdgeInsets.only(top: 8,left: 8),
              child: FaIcon(
                FontAwesomeIcons.trashCan,
                size: 20,
              ),

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    int numorpages = 1;
    numorpages = (totalrecords /_rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text('Rows per page: '),
        // SizedBox(width: 10),
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 2,5 , 1].map((int value) {
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
                icon: Icon(Icons.arrow_drop_down),
                style: TextStyle(color: Colors.black),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
              FontAwesomeIcons.circleChevronLeft,
                  color: _currentPage == 0 ? Colors.grey : Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: _currentPage == 0
              ? null
              : () {
            setState(() {
              _currentPage--;
            });
          },
        ),
        Text('Page ${_currentPage + 1} of $numorpages'),
        IconButton(
          icon: FaIcon(
              FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length ? Colors.grey : Color.fromRGBO(21, 43, 83, 1), // Change color based on availability

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


}
