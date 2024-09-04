//import 'package:device_preview/device_preview.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../Model/propertytype.dart';
import '../../constant/constant.dart';
import '../../repository/Property_type.dart';
import '../../widgets/drawer_tiles.dart';
import '../Property_Type/Add_property_type.dart';
import '../Property_Type/Edit_property_type.dart';

class DataRow {
  final String field1;
  final String field2;
  final String field3;
  bool isExpanded;
  DataRow(this.field1, this.field2, this.field3, {this.isExpanded = false});
}

// void main() {
//   runApp(
//     DevicePreview(
//       enabled: true,
//       tools: [
//         ...DevicePreview.defaultTools,
//       ],
//       builder: (context) => ExpandTable(),
//     ),
//   );
// }

class ExpandTable extends StatefulWidget {
  // final propertytype data;
  // final int index;
  // ExpandTable({required this.data, required this.index});
  @override
  State<ExpandTable> createState() => _ExpandTableState();
}

class _ExpandTableState extends State<ExpandTable> {
  late Future<List<propertytype>> futurePropertyTypes;
  int currentPage = 0;
  int itemsPerPage = 10; // Adjust the number of items per page as needed
  @override
  void initState() {
    super.initState();
    futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
    isExpanded = false;
  }

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
  void handleEdit(propertytype property) async {
    // Handle edit action
    print('Edit ${property.sId}');
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Edit_property_type(
    //       property: property,
    //     ),
    //   ),
    // );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Edit_property_type(
            property: property,
          ),
        ));
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

  void sortData(List<propertytype> data) {
    if (sorting1) {
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
    }
  }

  void handleDelete(propertytype property) {
    _showAlert(context, property.propertyId!);
    // Handle delete action
    print('Delete ${property.sId}');
  }

  int? expandedIndex;
  Set<int> expandedIndices = {};
  String? selectedValue;
  String searchvalue = "";

  final List<String> items = ['Residential', "Commercial", "All"];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: widget_302.App_Bar(context: context),
        /*drawer: Drawer(
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
                      color: Colors.white,
                    ),
                    "Add Property Type",
                    true),
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
                    ["Properties", "RentalOwner", "Tenants"]),
                buildDropdownListTile(
                    context,
                    FaIcon(
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
                    ["Vendor", "Work Order"]),
              ],
            ),
          ),
        ),*/
        body:
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Add_property()));
                        if (result == true) {
                          setState(() {
                            futurePropertyTypes = PropertyTypeRepository()
                                .fetchPropertyTypes();
                          });
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
                                "Add Property Type",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  MediaQuery.of(context).size.width *
                                      0.034,
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
                      "Property Type",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              //search
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: Row(
                  children: [
                    SizedBox(width: 13),
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 40,
                        width: 140,
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
                                cursorColor:
                                Color.fromRGBO(21, 43, 81, 1),
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
                    SizedBox(width: 10),
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
                              .map((String item) =>
                              DropdownMenuItem<String>(
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
                            width: 160,
                            padding: const EdgeInsets.only(
                                left: 14, right: 14),
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
                              thumbVisibility:
                              MaterialStateProperty.all(true),
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
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<propertytype>>(
                  future: futurePropertyTypes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
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
                              Image.asset("assets/images/no_data.jpg",height: 200,width: 200,),
                              SizedBox(height: 10,),
                              Text("No Data Available",style: TextStyle(fontWeight: FontWeight.bold,color:blueColor,fontSize: 16),)
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
                            .where((property) =>
                        property.propertyType!
                            .toLowerCase()
                            .contains(searchvalue!.toLowerCase()) ||
                            property.propertysubType!
                                .toLowerCase()
                                .contains(searchvalue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((property) =>
                        property.propertyType == selectedValue)
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
                            SizedBox(height: 20),
                            _buildHeader(),
                            SizedBox(height: 20),
                            Container(
                              decoration:
                              BoxDecoration(border: Border.all(color: blueColor)),
                              child: Column(
                                children: currentPageData.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  propertytype Propertytype = entry.value;
                                  //return CustomExpansionTile(data: Propertytype, index: index);
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: InkWell(
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
                                                if (expandedIndex == index) {
                                                  expandedIndex = null;
                                                } else {
                                                  expandedIndex = index;
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              padding: !isExpanded
                                                  ? EdgeInsets.only(bottom: 10)
                                                  : EdgeInsets.only(top: 10),
                                              child: FaIcon(
                                                isExpanded
                                                    ? FontAwesomeIcons.sortUp
                                                    : FontAwesomeIcons.sortDown,
                                                size: 20,
                                                color: Color.fromRGBO(21, 43, 83, 1),
                                              ),
                                            ),
                                          ),
                                          title: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    '${Propertytype.propertyType}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .08),
                                                Expanded(
                                                  child: Text(
                                                    '${Propertytype.propertysubType}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .08),
                                                Expanded(
                                                  child: Text(
                                                    // '${widget.data.createdAt}',
                                                    formatDate(
                                                        '${Propertytype.createdAt}'),

                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context)
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
                                            EdgeInsets.symmetric(horizontal: 8.0),
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
                                                            ? FontAwesomeIcons.sortUp
                                                            : FontAwesomeIcons.sortDown,
                                                        size: 50,
                                                        color: Colors.transparent,
                                                      ),
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
                                                                    'Updated At : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: formatDate(
                                                                        '${Propertytype.updatedAt}'),
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
                                                      // SizedBox(width: 5),
                                                      // Expanded(
                                                      //   child: Column(
                                                      //     crossAxisAlignment:
                                                      //     CrossAxisAlignment.start,
                                                      //     children: <Widget>[
                                                      //       Text.rich(
                                                      //         TextSpan(
                                                      //           children: [
                                                      //             TextSpan(
                                                      //               text:
                                                      //               'Sample Header: ',
                                                      //               style: TextStyle(
                                                      //                   fontWeight:
                                                      //                   FontWeight
                                                      //                       .bold,
                                                      //                   color:
                                                      //                   blueColor), // Bold and black
                                                      //             ),
                                                      //             TextSpan(
                                                      //               text: 'Sample Data',
                                                      //               style: TextStyle(
                                                      //                   fontWeight:
                                                      //                   FontWeight
                                                      //                       .w700,
                                                      //                   color: Colors
                                                      //                       .grey), // Light and grey
                                                      //             ),
                                                      //           ],
                                                      //         ),
                                                      //       ),
                                                      //       Text.rich(
                                                      //         TextSpan(
                                                      //           children: [
                                                      //             TextSpan(
                                                      //               text:
                                                      //               'Sample Header : ',
                                                      //               style: TextStyle(
                                                      //                   fontWeight:
                                                      //                   FontWeight
                                                      //                       .bold,
                                                      //                   color:
                                                      //                   blueColor), // Bold and black
                                                      //             ),
                                                      //             TextSpan(
                                                      //               text: 'Sample Data',
                                                      //               style: TextStyle(
                                                      //                   fontWeight:
                                                      //                   FontWeight
                                                      //                       .w700,
                                                      //                   color: Colors
                                                      //                       .grey), // Light and grey
                                                      //             ),
                                                      //           ],
                                                      //         ),
                                                      //       ),
                                                      //       Text.rich(
                                                      //         TextSpan(
                                                      //           children: [
                                                      //             TextSpan(
                                                      //               text:
                                                      //               'Sample Header : ',
                                                      //               style: TextStyle(
                                                      //                   fontWeight:
                                                      //                   FontWeight
                                                      //                       .bold,
                                                      //                   color:
                                                      //                   blueColor), // Bold and black
                                                      //             ),
                                                      //             TextSpan(
                                                      //               text: 'Sample Data',
                                                      //               style: TextStyle(
                                                      //                   fontWeight:
                                                      //                   FontWeight
                                                      //                       .w700,
                                                      //                   color: Colors
                                                      //                       .grey), // Light and grey
                                                      //             ),
                                                      //           ],
                                                      //         ),
                                                      //       ),
                                                      //     ],
                                                      //   ),
                                                      // ),
                                                      Container(
                                                        width: 40,
                                                        child: Column(
                                                          children: [
                                                            IconButton(
                                                              icon: FaIcon(
                                                                FontAwesomeIcons.edit,
                                                                size: 20,
                                                                color: Color.fromRGBO(
                                                                    21, 43, 83, 1),
                                                              ),
                                                              onPressed: () {
                                                                // handleEdit(Propertytype);
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                            Edit_property_type(
                                                                              property:
                                                                              Propertytype,
                                                                            )));
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: FaIcon(
                                                                FontAwesomeIcons
                                                                    .trashCan,
                                                                size: 20,
                                                                color: Color.fromRGBO(
                                                                    21, 43, 83, 1),
                                                              ),
                                                              onPressed: () {
                                                                //handleDelete(Propertytype);
                                                                _showAlert(
                                                                    context,
                                                                    Propertytype
                                                                        .propertyId!);
                                                              },
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
                                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: itemsPerPage,
                                            items: itemsPerPageOptions.map((int value) {
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
                                    Text('Page ${currentPage + 1} of $totalPages'),
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

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeader() {
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
        leading: Container(
          child: Icon(
            Icons.expand_less,
            color: Colors.transparent,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                        ? Text("Main Type ",
                        style: TextStyle(color: Colors.white))
                        : Text("Main Type",
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
                    Text("Subtypes", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
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
                    Text("Created At", style: TextStyle(color: Colors.white)),
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
}