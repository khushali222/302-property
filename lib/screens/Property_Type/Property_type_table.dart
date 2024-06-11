import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../Model/propertytype.dart';
import '../../repository/Property_type.dart';
import '../../widgets/drawer_tiles.dart';
import 'Edit_property_type.dart';
import 'Add_property_type.dart';



class PropertyTable extends StatefulWidget {
  @override
  _PropertyTableState createState() => _PropertyTableState();
}

class _PropertyTableState extends State<PropertyTable> {
  int totalrecords = 0;
  late Future<List<propertytype>> futurePropertyTypes;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  }

  void handleEdit(propertytype property) async {
    // Handle edit action
    print('Edit ${property.sId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_property_type(
                  property: property,
                )));
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
            var data = PropertyTypeRepository().DeletePropertyType(id: id);
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

  List<propertytype> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<propertytype> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(propertytype d) getField,
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

  void handleDelete(propertytype property) {
    _showAlert(context, property.propertyId!);
    // Handle delete action
    print('Delete ${property.sId}');
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(propertytype d)? getField) {
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
              if (_sortColumnIndex == columnIndex)
                Icon(
                    _sortAscending ? Icons.arrow_drop_down_outlined : Icons.arrow_drop_up_outlined),
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

  Widget _buildActionsCell(propertytype data) {
    return TableCell(
      child: Row(
        children: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.edit,
              size: 20,
            ),
            onPressed: () => handleEdit(data),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.trashCan,
              size: 20,
            ),
            onPressed: () => handleDelete(data),
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
        Text('Rows per page: '),
        SizedBox(width: 10),
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
                items: [10,25,50,100].map((int value) {
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

  final _scrollController = ScrollController();
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
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => Add_property()));
                      if (result == true) {
                        setState(() {
                          futurePropertyTypes =
                              PropertyTypeRepository().fetchPropertyTypes();
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
                              "Add New Property",
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
            Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: Row(
                children: [
                  SizedBox(width: 5),
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
                          width: 160,
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
                ],
              ),
            ),
            SizedBox(height: 25),
            FutureBuilder<List<propertytype>>(
              future: futurePropertyTypes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 40.0,
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
                  }
                  totalrecords = _tableData.length;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Table(
                                    defaultColumnWidth: IntrinsicColumnWidth(),
                                    children: [
                                      TableRow(
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        children: [
                                          _buildHeader(
                                              'Main Type',
                                              0,
                                              (property) =>
                                                  property.propertyType!),
                                          _buildHeader(
                                              'Subtype',
                                              1,
                                              (property) =>
                                                  property.propertysubType!),
                                          _buildHeader('Created At', 2, null),
                                          _buildHeader('Updated At', 3, null),
                                          _buildHeader('Actions', 4, null),
                                        ],
                                      ),
                                      TableRow(
                                        decoration: BoxDecoration(
                                          border: Border.symmetric(
                                              horizontal: BorderSide.none),
                                        ),
                                        children: List.generate(
                                            5,
                                            (index) => TableCell(
                                                child: Container(height: 20))),
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
                                              bottom: i == _pagedData.length - 1
                                                  ? BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1))
                                                  : BorderSide.none,
                                            ),
                                          ),
                                          children: [
                                            _buildDataCell(
                                                _pagedData[i].propertyType!),
                                            _buildDataCell(
                                                _pagedData[i].propertysubType!),
                                            _buildDataCell(
                                                _pagedData[i].createdAt!),
                                            _buildDataCell(
                                                _pagedData[i].updatedAt!),
                                            _buildActionsCell(_pagedData[i]),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
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
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: PropertyTable()));

class PropertyDataSource extends DataTableSource {
  final List<propertytype> data;
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final Function(propertytype) onEdit;
  final Function(propertytype) onDelete;

  PropertyDataSource(this.data, {required this.onEdit, required this.onDelete});

  @override
  DataRow getRow(int index) {
    final property = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(property.propertyType ?? '')),
        DataCell(Text(property.propertysubType ?? '')),
        DataCell(Text(_formatDate(property.createdAt))),
        DataCell(Text(_formatDate(property.updatedAt))),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                onEdit(property);
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
                onDelete(property);
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
  void sort<T>(Comparable<T> getField(propertytype d), bool ascending) {
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
