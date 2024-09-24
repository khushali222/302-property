import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../repository/staffpermission_provider.dart';
import 'add_new_property.dart';
import 'summery_page.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../Model/propertytype.dart';
import '../../../../constant/constant.dart';
import '../../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/rental_properties.dart';
import '../../../../provider/add_property.dart';
import '../../../repository/properties.dart';
import '../../../repository/rental_properties.dart';
import '../../../widgets/drawer_tiles.dart';
import 'package:http/http.dart' as http;

import 'EditProperties.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../model/staffpermission.dart';

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
  int currentPage = 0;
  int itemsPerPage = 10;
  int? expandedIndex;
  Set<int> expandedIndices = {};

  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;
  void sortData(List<Rentals> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.rentalAddress!.compareTo(b.rentalAddress!)
          : b.rentalAddress!.compareTo(a.rentalAddress!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.propertyTypeData!.propertyType!
              .compareTo(b.propertyTypeData!.propertyType!)
          : b.propertyTypeData!.propertyType!
              .compareTo(a.propertyTypeData!.propertyType!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.propertyTypeData!.propertySubType!
              .compareTo(b.propertyTypeData!.propertySubType!)
          : b.propertyTypeData!.propertySubType!
              .compareTo(a.propertyTypeData!.propertySubType!));
    }
  }

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Icon(
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
                    SizedBox(width: 6),
                    width < 400
                        ? Text("Property",
                            style: TextStyle(color: Colors.white, fontSize: 14))
                        : Text("Property",
                            style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                    ascending1
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
                          ),
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
                    Text("     Type",
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    SizedBox(width: 3),
                    ascending2
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
                          ),
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
                    Text(" SubType",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(width: 5),
                    ascending3
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
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Rentals> get _pagedData {
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
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_properties(
                  properties: properties,
                  rentalId: properties.rentalId!,
                )));
    if (check == true) {
      setState(() {});
    }
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_properties(properties: properties,)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void handleTap(Rentals properties) async {
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
            SharedPreferences prefs = await SharedPreferences.getInstance();
            print(id);

            var data = PropertiesRepository().DeleteProperties(
              property_id: id,
            );
            fetchRentaladded();
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
      desc:
          "The limit for adding rentalowners according to the plan has been reached.",
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
    print(properties.propertyId);
    // _showAlert(context,property.propertyId!);
    _showAlert(context, properties.rentalId!);

    // Handle delete action
    print('Delete ${properties.propertyId}');
  }

  final _scrollController = ScrollController();
  int rentalCount = 0;
  int propertyCountLimit = 0;
  Future<void> fetchRentaladded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/rentals/limitation/$adminid'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
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
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;

    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Properties",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            if (permissions!.propertyAdd == true)
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: titleBar(
                        width: MediaQuery.of(context).size.width * .65,
                        title: 'Properties',
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (rentalCount < propertyCountLimit) {
                          final ownerDetailsProvider =
                              Provider.of<OwnerDetailsProvider>(context,
                                  listen: false);
                          ownerDetailsProvider.clearOwners();
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
                        } else {
                          _showAlertforLimit(context);
                        }
                      },
                      child: Container(
                        //  height: 45,
                        height:
                            (MediaQuery.of(context).size.width < 500) ? 50 : 45,
                        width: (MediaQuery.of(context).size.width < 500)
                            ? MediaQuery.of(context).size.width * 0.25
                            : MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0),
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
                                      MediaQuery.of(context).size.width < 500
                                          ? 18
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
            if (permissions!.propertyAdd != true)
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: titleBar(
                        width: MediaQuery.of(context).size.width * .93,
                        title: 'Properties',
                      ),
                    ),
                  ],
                ),
              ),
            // SizedBox(height: 10),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(
                left: 11,
                right: 11,
              ),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 22),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // height: 40,
                      height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
                      width: MediaQuery.of(context).size.width < 500
                          ? MediaQuery.of(context).size.width * .52
                          : MediaQuery.of(context).size.width * .49,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(color: Colors.grey),
                          border: Border.all(color: Color(0xFF8A95A8))),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: TextField(
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
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
                                });
                              },
                              cursorColor: Color.fromRGBO(21, 43, 81, 1),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search here...",
                                hintStyle: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 14
                                            : 18),
                                contentPadding: (EdgeInsets.only(
                                    left: 5, bottom: 12, top: 5)),
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
                      borderRadius: BorderRadius.circular(8),
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
                          // height: 40,
                          height:
                              MediaQuery.of(context).size.width < 500 ? 45 : 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? MediaQuery.of(context).size.width * .37
                              : MediaQuery.of(context).size.width * .4,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
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
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Spacer(),
                Row(
                  children: [
                    Text(
                      'Added : ${rentalCount.toString()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8A95A8),
                        fontSize:
                            MediaQuery.of(context).size.width < 500 ? 13 : 18,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "/",
                      style: TextStyle(color: greyColor),
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
                        fontSize:
                            MediaQuery.of(context).size.width < 500 ? 13 : 18,
                      ),
                    ),
                  ],
                ),
                if (MediaQuery.of(context).size.width < 500)
                  SizedBox(width: 15),
                if (MediaQuery.of(context).size.width > 500)
                  SizedBox(width: 39),
              ],
            ),
            if (MediaQuery.of(context).size.width > 500) SizedBox(height: 25),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<Rentals>>(
                  future: futureRentalOwners,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ColabShimmerLoadingWidget();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                            .where((properties) => properties.rentalAddress!
                                .toLowerCase()
                                .contains(searchvalue.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((properties) =>
                                properties.propertyTypeData?.propertyType ==
                                selectedValue)
                            .toList();
                      }
                      sortData(data);
                      final totalPages = (data.length / itemsPerPage).ceil();
                      final currentPageData = data
                          .skip(currentPage * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 2),
                            _buildHeaders(),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Color.fromRGBO(152, 162, 179, .5))),
                              // decoration: BoxDecoration(
                              //     border: Border.all(color: blueColor)),
                              child: Column(
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  Rentals rentals = entry.value;
                                  //return CustomExpansionTile(data: Propertytype, index: index);
                                  return Container(
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(color: blueColor),
                                    // ),
                                    decoration: BoxDecoration(
                                      color: index % 2 != 0
                                          ? Colors.white
                                          : blueColor.withOpacity(0.09),
                                      border: Border.all(
                                          color: Color.fromRGBO(
                                              152, 162, 179, .5)),
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
                                                    //width: 25,
                                                    // color: Colors.blue,
                                                    margin: EdgeInsets.only(
                                                        left: 5, right: 2),
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
                                                  child: InkWell(
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
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Text(
                                                        '${(rentals.rentalAddress ?? '').isEmpty ? 'N/A' : rentals.rentalAddress}',
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
                                                            .01),
                                                Expanded(
                                                  child: Text(
                                                    '${(rentals.propertyTypeData!.propertyType ?? '').isEmpty ? 'N/A' : rentals.propertyTypeData!.propertyType}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                // SizedBox(
                                                //     width:
                                                //         MediaQuery.of(context)
                                                //                 .size
                                                //                 .width *
                                                //             .08),
                                                Expanded(
                                                  child: Text(
                                                    '${(rentals.propertyTypeData!.propertySubType ?? '').isEmpty ? 'N/A' : rentals.propertyTypeData!.propertySubType}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                // SizedBox(
                                                //     width:
                                                //         MediaQuery.of(context)
                                                //                 .size
                                                //                 .width *
                                                //             .02),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isExpanded)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            margin: EdgeInsets.only(bottom: 2),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  // Row(
                                                  //   mainAxisAlignment:
                                                  //   MainAxisAlignment.start,
                                                  //   children: [
                                                  //    SizedBox(width: 20,),
                                                  //     Text.rich(
                                                  //       TextSpan(
                                                  //         children: [
                                                  //           TextSpan(
                                                  //             text:
                                                  //             'Primery E-mail: ',
                                                  //             style: TextStyle(
                                                  //                 fontWeight:
                                                  //                 FontWeight
                                                  //                     .bold,
                                                  //                 color:
                                                  //                 blueColor), // Bold and black
                                                  //           ),
                                                  //           TextSpan(
                                                  //             text:
                                                  //             '${(rentals.rentalOwnerData!.rentalOwnerPrimaryEmail ?? "").isEmpty?'N/A' : rentals.rentalOwnerData!.rentalOwnerPrimaryEmail}',
                                                  //             style: TextStyle(
                                                  //                 fontWeight:
                                                  //                 FontWeight
                                                  //                     .w700,
                                                  //                 color: grey), // Light and grey
                                                  //           ),
                                                  //         ],
                                                  //       ),
                                                  //     ),
                                                  //     // SizedBox(
                                                  //     //   height: MediaQuery.of(
                                                  //     //       context)
                                                  //     //       .size
                                                  //     //       .height *
                                                  //     //       .01,
                                                  //     // ),
                                                  //   ],
                                                  // ),

                                                  // Row(
                                                  //   mainAxisAlignment:
                                                  //       MainAxisAlignment.start,
                                                  //   children: [
                                                  //     FaIcon(
                                                  //       isExpanded
                                                  //           ? FontAwesomeIcons
                                                  //               .sortUp
                                                  //           : FontAwesomeIcons
                                                  //               .sortDown,
                                                  //       size: 50,
                                                  //       color:
                                                  //           Colors.transparent,
                                                  //     ),
                                                  //     Expanded(
                                                  //       child: Column(
                                                  //         crossAxisAlignment:
                                                  //             CrossAxisAlignment
                                                  //                 .start,
                                                  //         children: <Widget>[
                                                  //           Text.rich(
                                                  //             TextSpan(
                                                  //               children: [
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       'Rental Owners Name: ',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .bold,
                                                  //                       color:
                                                  //                           blueColor), // Bold and black
                                                  //                 ),
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       '${(rentals.rentalOwnerData!.rentalOwnerName??'').isEmpty ? 'N/A':rentals.rentalOwnerData!.rentalOwnerName}',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .w700,
                                                  //                       color: Colors
                                                  //                           .grey), // Light and grey
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           ),
                                                  //           SizedBox(
                                                  //             height: MediaQuery.of(
                                                  //                         context)
                                                  //                     .size
                                                  //                     .height *
                                                  //                 .01,
                                                  //           ),
                                                  //           Text.rich(
                                                  //             TextSpan(
                                                  //               children: [
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       'Locality : ',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .bold,
                                                  //                       color:
                                                  //                           blueColor), // Bold and black
                                                  //                 ),
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       '${(rentals.rentalOwnerData!.city ??"").isEmpty ? 'N/A':rentals.rentalOwnerData!.city}',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .w700,
                                                  //                       color: Colors
                                                  //                           .grey), // Light and grey
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           ),
                                                  //           SizedBox(
                                                  //             height: MediaQuery.of(
                                                  //                         context)
                                                  //                     .size
                                                  //                     .height *
                                                  //                 .01,
                                                  //           ),
                                                  //           Text.rich(
                                                  //             TextSpan(
                                                  //               children: [
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       'Phone Number : ',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .bold,
                                                  //                       color:
                                                  //                           blueColor), // Bold and black
                                                  //                 ),
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       '${(rentals.rentalOwnerData!.rentalOwnerPhoneNumber ??"").isEmpty ? 'N/A' : rentals.rentalOwnerData!.rentalOwnerPhoneNumber}',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .w700,
                                                  //                       color: Colors
                                                  //                           .grey), // Light and grey
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           ),
                                                  //           SizedBox(
                                                  //             height: MediaQuery.of(
                                                  //                         context)
                                                  //                     .size
                                                  //                     .height *
                                                  //                 .01,
                                                  //           ),
                                                  //
                                                  //         ],
                                                  //       ),
                                                  //     ),
                                                  //     SizedBox(width: 7),
                                                  //     Expanded(
                                                  //       child: Column(
                                                  //         crossAxisAlignment:
                                                  //             CrossAxisAlignment
                                                  //                 .start,
                                                  //         children: <Widget>[
                                                  //           Text.rich(
                                                  //             TextSpan(
                                                  //               children: [
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       'Rental Company Name: ',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .bold,
                                                  //                       color:
                                                  //                           blueColor), // Bold and black
                                                  //                 ),
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       '${(rentals.rentalOwnerData!.rentalOwnerCompanyName ?? "").isEmpty ?'N/A':rentals.rentalOwnerData!.rentalOwnerCompanyName}',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .w700,
                                                  //                       color: Colors
                                                  //                           .grey), // Light and grey
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           ),
                                                  //           SizedBox(
                                                  //             height: MediaQuery.of(
                                                  //                         context)
                                                  //                     .size
                                                  //                     .height *
                                                  //                 .01,
                                                  //           ),
                                                  //           Text.rich(
                                                  //             TextSpan(
                                                  //               children: [
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                       'Created At: ',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .bold,
                                                  //                       color:
                                                  //                           blueColor), // Bold and black
                                                  //                 ),
                                                  //                 TextSpan(
                                                  //                   text: formatDate(
                                                  //                       '${rentals.createdAt}'),
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                           FontWeight
                                                  //                               .w700,
                                                  //                       color: Colors
                                                  //                           .grey), // Light and grey
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           ),
                                                  //           SizedBox(
                                                  //             height: MediaQuery.of(
                                                  //                 context)
                                                  //                 .size
                                                  //                 .height *
                                                  //                 .01,
                                                  //           ),
                                                  //           Text.rich(
                                                  //             TextSpan(
                                                  //               children: [
                                                  //                 TextSpan(
                                                  //                   text:
                                                  //                   'Updated At : ',
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                       FontWeight
                                                  //                           .bold,
                                                  //                       color:
                                                  //                       blueColor), // Bold and black
                                                  //                 ),
                                                  //                 TextSpan(
                                                  //                   text: formatDate(
                                                  //                       '${rentals.updatedAt}'),
                                                  //                   style: TextStyle(
                                                  //                       fontWeight:
                                                  //                       FontWeight
                                                  //                           .w700,
                                                  //                       color: Colors
                                                  //                           .grey), // Light and grey
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           ),
                                                  //         ],
                                                  //       ),
                                                  //     ),
                                                  //     Container(
                                                  //       width: 40,
                                                  //       child: Column(
                                                  //         children: [
                                                  //           IconButton(
                                                  //             icon: FaIcon(
                                                  //               FontAwesomeIcons
                                                  //                   .edit,
                                                  //               size: 20,
                                                  //               color: Color
                                                  //                   .fromRGBO(
                                                  //                       21,
                                                  //                       43,
                                                  //                       83,
                                                  //                       1),
                                                  //             ),
                                                  //             onPressed:
                                                  //                 () async {
                                                  //               // handleEdit(Propertytype);
                                                  //                   var check = await Navigator.push(
                                                  //                   context,
                                                  //                   MaterialPageRoute(
                                                  //                       builder: (context) => Edit_properties(
                                                  //                           properties:
                                                  //                               rentals,
                                                  //                           rentalId:
                                                  //                               rentals.rentalId!)));
                                                  //               if (check ==
                                                  //                   true) {
                                                  //                 setState(
                                                  //                     () {});
                                                  //               }
                                                  //             },
                                                  //           ),
                                                  //           IconButton(
                                                  //             icon: FaIcon(
                                                  //               FontAwesomeIcons
                                                  //                   .trashCan,
                                                  //               size: 20,
                                                  //               color: Color
                                                  //                   .fromRGBO(
                                                  //                       21,
                                                  //                       43,
                                                  //                       83,
                                                  //                       1),
                                                  //             ),
                                                  //             onPressed: () {
                                                  //               //handleDelete(Propertytype);
                                                  //               _showAlert(
                                                  //                   context,
                                                  //                   rentals
                                                  //                       .rentalId!);
                                                  //             },
                                                  //           ),
                                                  //         ],
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  Row(
                                                    children: [
                                                      FaIcon(
                                                        isExpanded
                                                            ? FontAwesomeIcons
                                                                .sortUp
                                                            : FontAwesomeIcons
                                                                .sortDown,
                                                        size: 20,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      Expanded(
                                                        child: Table(
                                                          columnWidths: {
                                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                            // 1: FlexColumnWidth(),
                                                            0: FlexColumnWidth(), // Distribute columns equally
                                                            1: FlexColumnWidth(),
                                                          },
                                                          children: [
                                                            _buildTableRow(
                                                                'RentalOwners Name:',
                                                                _getDisplayValue(rentals
                                                                    .rentalOwnerData
                                                                    ?.rentalOwnerName),
                                                                'Phone Number:',
                                                                _getDisplayValue(rentals
                                                                    .rentalOwnerData
                                                                    ?.rentalOwnerPhoneNumber)),
                                                            _buildTableRow(
                                                                'Rental Company Name:',
                                                                _getDisplayValue(rentals
                                                                    .rentalOwnerData
                                                                    ?.rentalOwnerCompanyName),
                                                                'Primary Email',
                                                                _getDisplayValue(rentals
                                                                    .rentalOwnerData
                                                                    ?.rentalOwnerPrimaryEmail)),
                                                            _buildTableRow(
                                                                'Locality:',
                                                                _getDisplayValue(
                                                                    rentals
                                                                        .rentalOwnerData
                                                                        ?.city),
                                                                'Created At:',
                                                                formatDate(
                                                                    '${rentals.createdAt}')),
                                                            _buildTableRow(
                                                              'Updated At:',
                                                              formatDate(
                                                                  '${rentals.updatedAt}'),
                                                              '',
                                                              '',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // FaIcon(
                                                      //   isExpanded
                                                      //       ? FontAwesomeIcons
                                                      //       .sortUp
                                                      //       : FontAwesomeIcons
                                                      //       .sortDown,
                                                      //   size: 20,
                                                      //   color:
                                                      //   Colors.transparent,
                                                      // ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            var check =
                                                                await Navigator
                                                                    .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Edit_properties(
                                                                  properties:
                                                                      rentals,
                                                                  rentalId: rentals
                                                                      .rentalId!,
                                                                ),
                                                              ),
                                                            );
                                                            if (check == true) {
                                                              setState(() {
                                                                futureRentalOwners =
                                                                    PropertiesRepository()
                                                                        .fetchProperties();
                                                              });
                                                              // Update State
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                        .grey[
                                                                    350]), // color:Colors.grey[100],
                                                            child: Row(
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
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Edit",
                                                                  style: TextStyle(
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _showAlert(
                                                                context,
                                                                rentals
                                                                    .rentalId!);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        350]),
                                                            child: Row(
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
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Summery_page(
                                                                              properties: rentals,
                                                                            )));
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        350]),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Image.asset(
                                                                    'assets/icons/view.png'),
                                                                // FaIcon(
                                                                //   FontAwesomeIcons.trashCan,
                                                                //   size: 15,
                                                                //   color:blueColor,
                                                                // ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  "View Summery",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
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
                                            // onChanged: (newValue) {
                                            //   setState(() {
                                            //     itemsPerPage = newValue!;
                                            //     currentPage =
                                            //         0; // Reset to first page when items per page change
                                            //   });
                                            // },
                                            onChanged: data.length >
                                                    itemsPerPageOptions
                                                        .first // Condition to check if dropdown should be enabled
                                                ? (newValue) {
                                                    setState(() {
                                                      itemsPerPage = newValue!;
                                                      currentPage =
                                                          0; // Reset to first page when items per page change
                                                    });
                                                  }
                                                : null,
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
              FutureBuilder<List<Rentals>>(
                future: futureRentalOwners,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    List<Rentals>? filteredData = [];
                    _tableData = snapshot.data!;
                    if (selectedValue == null && searchvalue.isEmpty) {
                      _tableData = snapshot.data!;
                    } else if (selectedValue == "All") {
                      _tableData = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      _tableData = snapshot.data!
                          .where((property) => property.rentalAddress!
                              .toLowerCase()
                              .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      _tableData = snapshot.data!
                          .where((property) =>
                              property.propertyTypeData?.propertyType ==
                              selectedValue)
                          .toList();
                    }
                    totalrecords = _tableData.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Table(
                                defaultColumnWidth: IntrinsicColumnWidth(),
                                children: [
                                  TableRow(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    children: [
                                      _buildHeader('Property', 0,
                                          (staff) => staff.rentalAddress!),
                                      _buildHeader(
                                          'PropertyType',
                                          1,
                                          (staff) => staff
                                              .propertyTypeData!.propertyType!),
                                      _buildHeader(
                                          'PropertySubTYpe',
                                          2,
                                          (staff) => staff.propertyTypeData!
                                              .propertySubType!),
                                      _buildHeader(
                                          'RentalOwnersName',
                                          3,
                                          (staff) => staff.rentalOwnerData!
                                              .rentalOwnerName!),
                                      _buildHeader(
                                          'RentalCompanyName',
                                          4,
                                          (staff) => staff.rentalOwnerData!
                                              .rentalOwnerCompanyName!),
                                      _buildHeader('Locality', 5,
                                          (staff) => staff.rentalCity!),
                                      _buildHeader(
                                          'PrimaryEmail',
                                          6,
                                          (staff) => staff.rentalOwnerData!
                                              .rentalOwnerPrimaryEmail!),
                                      _buildHeader(
                                          'PhoneNumber',
                                          7,
                                          (staff) => staff.rentalOwnerData!
                                              .rentalOwnerPhoneNumber!),
                                      //  _buildHeader('Created At', 8, (staff) => staff.rentalOwnerData!.rentalOwnerPhoneNumber!),
                                      //_buildHeader('Last Updated At', 9, (staff) => staff.rentalOwnerData!.rentalOwnerPhoneNumber!),
                                      _buildHeader('Actions', 8, null),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide.none),
                                    ),
                                    children: List.generate(
                                        9,
                                        (index) => TableCell(
                                            child: Container(height: 20))),
                                  ),
                                  for (var i = 0; i < _pagedData.length; i++)
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
                                          bottom: i == _pagedData.length - 1
                                              ? BorderSide(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1))
                                              : BorderSide.none,
                                        ),
                                      ),
                                      children: [
                                        _buildDataCell(
                                            _pagedData[i].rentalAddress!,
                                            _pagedData[i]),
                                        _buildDataCell(
                                            _pagedData[i]
                                                .propertyTypeData!
                                                .propertyType!,
                                            _pagedData[i]),
                                        _buildDataCell(
                                            _pagedData[i]
                                                .propertyTypeData!
                                                .propertySubType!,
                                            _pagedData[i]),
                                        // _buildDataCell(_pagedData[i].rentalOwnerData!.rentalOwnerFirstName!),
                                        _buildDataCell(
                                            '${_pagedData[i].rentalOwnerData?.rentalOwnerName ?? ''} ',
                                            _pagedData[i]),
                                        _buildDataCell(
                                            _pagedData[i]
                                                .rentalOwnerData!
                                                .rentalOwnerCompanyName!,
                                            _pagedData[i]),

                                        _buildDataCell(
                                            _pagedData[i].rentalCity!,
                                            _pagedData[i]),
                                        _buildDataCell(
                                            _pagedData[i]
                                                .rentalOwnerData!
                                                .rentalOwnerPrimaryEmail!,
                                            _pagedData[i]),
                                        _buildDataCell(
                                            _pagedData[i]
                                                .rentalOwnerData!
                                                .rentalOwnerPhoneNumber!,
                                            _pagedData[i]),
                                        _buildActionsCell(_pagedData[i]),
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

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
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
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
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

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(Rentals d)? getField) {
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

  Widget _buildDataCell(String text, Rentals inkText) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Summery_page(properties: inkText)));
            },
            child: Text(text?.isNotEmpty == true ? text! : 'N/A',
                style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  Widget _buildActionsCell(Rentals data) {
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
            // height: 40,
            height: 55,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 2, 5, 1].map((int value) {
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
            size: 30,
            FontAwesomeIcons.circleChevronLeft,
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
}
