import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/add_new_property.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/summery_page.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../../Model/propertytype.dart';
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/rental_properties.dart';
import '../../../repository/properties.dart';
import '../../../repository/rental_properties.dart';
import '../../../widgets/drawer_tiles.dart';
import 'package:http/http.dart' as http;

import 'edit_properties.dart';

class _Dessert {
  _Dessert(
    this.name,
    this.property,
    this.subtype,
    this.rentalowenername,
  );

  final String name;
  final String property;
  final String subtype;
  final String rentalowenername;
  bool selected = false;
}

class PropertiesTable extends StatefulWidget {
  @override
  _PropertiesTableState createState() => _PropertiesTableState();
}

class _PropertiesTableState extends State<PropertiesTable> {
  late Future<List<Rentals>> futureRentalOwners;
  // late Future<List<propertytype>> futurePropertyTypes;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  List<Rentals> _tableData = [];
  int totalrecords = 0;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Rentals> get _pagedData {
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
  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    futureRentalOwners = PropertiesRepository().fetchProperties();
    fetchRentaladded();
  }

  void handleEdit(Rentals properties) async {
    // Handle edit action
    print('Edit ${properties.staffMemberId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_properties(properties: properties,)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void handleTap(Rentals properties ) async {
    // Handle edit action
    print('Edit ${properties.rentalId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Summery_page(properties: properties)));
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
        //  overlayColor: Colors.black.withOpacity(.8)
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
            var data = PropertiesRepository().DeleteProperties(id: id);

            setState(() {
              futureRentalOwners = PropertiesRepository().fetchProperties();
              //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        )
      ],
    ).show();
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

  void _sort<T>(Comparable<T> Function(Rentals) getField, int columnIndex,
      bool ascending) {
    futureRentalOwners.then((Rentals) {
      Rentals.sort((a, b) {
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

  void handleDelete(Rentals properties) {
    // _showAlert(context,property.propertyId!);
    _showAlert(context, properties.propertyId!);

    // Handle delete action
    print('Delete ${properties.propertyId}');
  }

  final _scrollController = ScrollController();
  int rentalCount = 0;
  int propertyCountLimit = 0;
  Future<void> fetchRentaladded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    final response =
        await http.get(Uri.parse('${Api_url}/api/rentals/limitation/$id'));
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(rentalCount);
      print(propertyCountLimit);
      setState(() {
        rentalCount = jsonData['rentalCount'];
        print(rentalCount);
        propertyCountLimit = jsonData['propertyCountLimit'];
        print(propertyCountLimit);
      });
    } else {
      throw Exception('Failed to load data');
    }
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
              buildListTile(context, Icon(CupertinoIcons.person_add),
                  "Add Staff Member", false),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],selectedSubtopic: "Properties"),
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
            Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if(rentalCount < propertyCountLimit  )
                        {
                          final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Add_new_property()));
                          if (result == true) {
                            setState(() {
                              futureRentalOwners =
                                  PropertiesRepository().fetchProperties();
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
                              "Add Property",
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
                  SizedBox(width: 5),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: EdgeInsets.only(top: 8, left: 10),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(
                      bottom: 6.0), //Same as `blurRadius` i guess
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color.fromRGBO(21, 43, 81, 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text(
                    "Properties",
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
              padding: const EdgeInsets.only(left: 13, right: 20,),
              child: Row(
                children: [
                  SizedBox(width: 5),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          // border: Border.all(color: Colors.grey),
                          border: Border.all(color: Color(0xFF8A95A8))),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: TextField(
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
                                  // fontWeight: FontWeight.bold,
                                  color: Color(0xFF8A95A8),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
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
                          height: 40,
                          width: 110,
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
                          maxHeight: 200,
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
                  Spacer(),
                  Row(
                    children: [
                      Text(
                        'Added : ${rentalCount.toString()}',
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
                        'Total: ${propertyCountLimit.toString()}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8A95A8),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            FutureBuilder<List<Rentals>>(
              future: futureRentalOwners,
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
                  List<Rentals>? filteredData = [];
                  _tableData = snapshot.data!;
                /*  if (selectedRole == null && searchValue == "") {
                    filteredData = snapshot.data;
                  } else if (selectedRole == "All") {
                    filteredData = snapshot.data;
                  } else if (searchValue.isNotEmpty) {
                    filteredData = snapshot.data!
                        .where((staff) =>
                    staff.rentalOwnerFirstName!.toLowerCase().contains(searchValue.toLowerCase()) ||
                        staff.rentalOwnerLastName!.toLowerCase().contains(searchValue.toLowerCase()))
                        .toList();
                  }*/
                 // _tableData = filteredData!;
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
                                  _buildHeader('Property', 0, (staff) => staff.rentalAddress!),
                                  _buildHeader('PropertyType', 1, (staff) => staff.propertyTypeData!.propertyType!),
                                  _buildHeader('PropertySubTYpe', 2, (staff) => staff.propertyTypeData!.propertySubType!),
                                  _buildHeader('RentalOwnersName', 3, (staff) => staff.rentalOwnerData!.rentalOwnerFirstName!),
                                  _buildHeader('RentalCompanyName', 4, (staff) => staff.rentalOwnerData!.rentalOwnerCompanyName!),
                                  _buildHeader('Locality', 5, (staff) => staff.rentalCity!),
                                  _buildHeader('PrimaryEmail', 6, (staff) => staff.rentalOwnerData!.rentalOwnerPrimaryEmail!),
                                  _buildHeader('PhoneNumber', 7, (staff) => staff.rentalOwnerData!.rentalOwnerPhoneNumber!),
                                  _buildHeader('Actions', 8, null),
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(
                                  border: Border.symmetric(horizontal: BorderSide.none),
                                ),
                                children: List.generate(9, (index) => TableCell(child: Container(height: 20))),
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
                                    InkWell(
                                        onTap:()async{
                                          final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Summery_page(properties: _pagedData[i])));

                                        },
                                        child: _buildDataCell(_pagedData[i].rentalAddress!)),
                                    _buildDataCell(_pagedData[i].propertyTypeData!.propertyType!),
                                    _buildDataCell(_pagedData[i].propertyTypeData!.propertySubType!),
                                    _buildDataCell(_pagedData[i].rentalOwnerData!.rentalOwnerFirstName!),
                                    _buildDataCell(_pagedData[i].rentalOwnerData!.rentalOwnerCompanyName!),
                                    _buildDataCell(_pagedData[i].rentalCity!),
                                    _buildDataCell(_pagedData[i].rentalOwnerData!.rentalOwnerPrimaryEmail!),
                                    _buildDataCell(_pagedData[i].rentalOwnerData!.rentalOwnerPhoneNumber!),
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
           /* FutureBuilder<List<Rentals>>(
              future: futureRentalOwners,
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
                  List<Rentals>? filteredData = [];
                  if (selectedValue == null && searchvalue == "") {
                    filteredData = snapshot.data;
                  } else if (selectedValue == "All") {
                    filteredData = snapshot.data;
                  } else if (searchvalue != null && searchvalue.isNotEmpty) {
                    filteredData = snapshot.data!
                        .where((property) =>
                            property.rentalAddress!
                                .toLowerCase()
                                .contains(searchvalue.toLowerCase()) ||
                            property.rentalCity!
                                .toLowerCase()
                                .contains(searchvalue.toLowerCase()))
                        .toList();
                  } else {
                    filteredData = snapshot.data!
                        .where((property) =>
                            property.rentalAddress == selectedValue)
                        .toList();
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Scrollbar(
                            thickness: 20,
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 50),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  cardTheme: CardTheme(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius
                                          .zero, // Remove border radius
                                    ),
                                  ),
                                  dataTableTheme: DataTableThemeData(
                                    dataRowColor: MaterialStateProperty.all(Colors
                                        .transparent), // Set data row color to transparent
                                    headingRowColor: MaterialStateProperty.all(
                                        Colors
                                            .transparent), // Set heading row color to transparent
                                    dividerThickness: 0, // Remove divider
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Colors.black), // Add black border
                                    ),
                                    child: PaginatedDataTable(
                                      sortAscending: sortAscending,
                                      sortColumnIndex: sortColumnIndex,
                                      rowsPerPage: rowsPerPage,
                                      //  showEmptyRows: false,
                                      columnSpacing: 15,
                                      availableRowsPerPage: [5, 10, 15, 20],
                                      onRowsPerPageChanged: (value) {
                                        setState(() {
                                          rowsPerPage = value!;
                                        });
                                      },
                                      columns: [
                                        DataColumn(
                                          label: Text(
                                            'PROPERTY',
                                            style: TextStyle(
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            _sort<String>(
                                                    (properties) => properties.rentalAddress ?? "",
                                                columnIndex,
                                                ascending);
                                          },
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'PROPERTY TYPE',
                                            style: TextStyle(
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            _sort<String>(
                                                    (properties) => properties
                                                    .propertyTypeData
                                                    ?.propertyType ?? "",
                                                columnIndex,
                                                ascending);
                                          },
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'PROPERTY SUBTYPE',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            _sort<String>(
                                                (properties) => properties
                                                    .propertyTypeData
                                                    ?.propertySubType ?? "",
                                                columnIndex,
                                                ascending);
                                          },
                                        ),
                                        DataColumn(
                                            label: Text(
                                              'RENTALOWNERS NAME',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onSort: (columnIndex, ascending) {
                                              _sort<String>(
                                                  (properties) => properties
                                                      .rentalOwnerData
                                                      ?.rentalOwnerFirstName ?? "",
                                                  columnIndex,
                                                  ascending);
                                            }),
                                        DataColumn(
                                            label: Text(
                                              'RENTAL COMPANY NAME',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onSort: (columnIndex, ascending) {
                                              _sort<String>(
                                                  (properties) => properties
                                                      .rentalOwnerData
                                                      ?.rentalOwnerCompanyName ?? "",
                                                  columnIndex,
                                                  ascending);
                                            }),
                                        DataColumn(
                                            label: Text(
                                              'LOCALITY',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onSort: (columnIndex, ascending) {
                                              _sort<String>(
                                                  (properties) =>
                                                      properties.rentalCity ?? "",
                                                  columnIndex,
                                                  ascending);
                                            }),
                                        DataColumn(
                                            label: Text(
                                              'PRIMARY EMAIL',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onSort: (columnIndex, ascending) {
                                              _sort<String>(
                                                  (properties) => properties
                                                      .rentalOwnerData
                                                      ?.rentalOwnerPrimaryEmail ?? "",
                                                  columnIndex,
                                                  ascending);
                                            }),
                                        DataColumn(
                                          label: Text(
                                            'PHONE NUMBER',
                                            style: TextStyle(
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            _sort<String>(
                                                    (properties) =>
                                                properties.rentalOwnerData?.rentalOwnerPhoneNumber ?? "",
                                                columnIndex,
                                                ascending);
                                          }

                                        ),
                                        DataColumn(
                                            label: Text(
                                              'CREATED AT',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onSort: (columnIndex, ascending) {
                                              _sort<String>(
                                                  (properties) => properties
                                                      .createdAt
                                                      .toString(),
                                                  columnIndex,
                                                  ascending);
                                            }),
                                        DataColumn(
                                            label: Text(
                                              'UPDATED AT',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onSort: (columnIndex, ascending) {
                                              _sort<String>(
                                                  (properties) => properties
                                                      .createdAt
                                                      .toString(),
                                                  columnIndex,
                                                  ascending);
                                            }),
                                        DataColumn(
                                            label: Text(
                                          'ACTION',
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                      ],

                                      source: PropertyDataSource(filteredData!,
                                          onTap:handleTap,
                                          onEdit: handleEdit,
                                          onDelete: handleDelete),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  );
                }
              },
            ),*/
          ],
        ),
      ),
    );
  }
  Widget _buildHeader<T>(String text, int columnIndex, Comparable<T> Function(Rentals d)? getField) {
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

  Widget _buildActionsCell(Rentals data) {
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
              handleDelete(data);
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

void main() => runApp(MaterialApp(home: PropertiesTable()));

class PropertyDataSource extends DataTableSource {
  final List<Rentals> data;
  // TenantData? tenants;
  // final List<propertytype> data2;

  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final Function(Rentals) onEdit;
  final Function(Rentals) onDelete;
 final Function(Rentals) onTap;

  PropertyDataSource(this.data, {required this.onEdit, required this.onDelete, required this.onTap});

  @override
  DataRow getRow(int index) {
    final properties = data[index];
    // final propety = data2[index];
    // final tenants = data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Text(properties.rentalAddress ?? '',
            ),
          onTap:  (){
            onTap(properties);
            }
          ),
        DataCell(Text(properties.propertyTypeData?.propertyType ?? "")),
        DataCell(Text(properties.propertyTypeData?.propertySubType ?? "")),
        DataCell(Text(properties.rentalOwnerData?.rentalOwnerFirstName ?? "")),
        DataCell(
            Text(properties.rentalOwnerData?.rentalOwnerCompanyName ?? "")),
        DataCell(Text(properties.rentalCity ?? "")),
        DataCell(
            Text(properties.rentalOwnerData?.rentalOwnerPrimaryEmail ?? "")),
        DataCell(
            Text(properties.rentalOwnerData?.rentalOwnerPhoneNumber ?? "")),
        DataCell(Text(_formatDate(properties.createdAt))),
        DataCell(Text(_formatDate(properties.updatedAt))),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                onEdit(properties);
              },
              child: Container(
                //  color: Colors.redAccent,
                padding: EdgeInsets.zero,
                child: FaIcon(
                  FontAwesomeIcons.edit,
                  size: 20,
                ),
              ),
            ),
            SizedBox(
              width: 4,
            ),
            InkWell(
              onTap: () {
                onDelete(properties);
              },
              child: Container(
                //    color: Colors.redAccent,
                padding: EdgeInsets.zero,
                child: FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 20,
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return '';
    }
    DateTime dateTime = DateTime.parse(dateStr);
    return dateFormat.format(dateTime);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
  void sort<T>(Comparable<T> getField(Rentals d), bool ascending) {
    data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }
}
