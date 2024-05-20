import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: CustomDataTablePage(),
  ));
}

class CustomDataTablePage extends StatefulWidget {
  @override
  _CustomDataTablePageState createState() => _CustomDataTablePageState();
}

class _CustomDataTablePageState extends State<CustomDataTablePage> {
  final int rowsPerPage = 1;
  int currentPage = 0;
  int rowsPerPageSelected = 1;
  int totalRows = 0; // Example data count
  bool sortAscending = true;
  int sortColumnIndex = 0;
  List<propertytype> data = [];

  Future<List<propertytype>> fetchPropertyTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    final response = await http.get(Uri.parse('https://saas.cloudrentalmanager.com/api/propertytype/property_type/$id'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => propertytype.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      List<propertytype> fetchedData = await fetchPropertyTypes();
      setState(() {
        data = fetchedData;
        totalRows = data.length;
      });
    } catch (e) {
      // Handle error
      print('Error fetching data: $e');
    }
  }

  List<propertytype> getData() {
    // Sort data based on the selected column
    data.sort((a, b) {
      dynamic aValue = getPropertySortValue(a);
      dynamic bValue = getPropertySortValue(b);
      if (sortAscending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });
    return data;
  }

  dynamic getPropertySortValue(propertytype property) {
    switch (sortColumnIndex) {
      case 0:
        return property.propertyType;
      case 1:
        return property.propertysubType;
      case 2:
        return property.isMultiunit;
      default:
        return property.createdAt; // Default to createdAt for unknown cases
    }
  }

  void onRowsPerPageChanged(int? value) {
    if (value != null) {
      setState(() {
        rowsPerPageSelected = value;
        currentPage = 0;
      });
    }
  }

  void onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    int start = currentPage * rowsPerPageSelected;
    int end = start + rowsPerPageSelected;
    end = end > totalRows ? totalRows : end;
    List<propertytype> displayedData = getData().sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: Text('Custom DataTable'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child:
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Scrollbar(
                  thickness: 10,

                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                         color: Colors.white,
                             border: Border.all(color: Colors.black)
                       ),
                        child: DataTable(
                          columnSpacing: 10,
                          sortColumnIndex: sortColumnIndex,
                          sortAscending: sortAscending,
                          columns: [
                            DataColumn(
                              label: Text('Property Type'),
                              onSort: (columnIndex, ascending) {
                                onSort(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: Text('Property Subtype'),
                              onSort: (columnIndex, ascending) {
                                onSort(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: Text('Is Multiunit'),
                              onSort: (columnIndex, ascending) {
                                onSort(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: Text('Created At'),
                              onSort: (columnIndex, ascending) {
                                onSort(columnIndex, ascending);
                              },
                            ),
                          ],
                          rows: displayedData.map((property) {
                            return DataRow(cells: [
                              DataCell(Text(property.propertyType ?? '')),
                              DataCell(Text(property.propertysubType ?? '')),
                              DataCell(Text(property.isMultiunit.toString())),
                              DataCell(Text(property.createdAt ?? '')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            CustomPagination(
              rowsPerPage: rowsPerPageSelected,
              currentPage: currentPage,
              totalRows: totalRows,
              onRowsPerPageChanged: onRowsPerPageChanged,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPagination extends StatelessWidget {
  final int rowsPerPage;
  final int currentPage;
  final int totalRows;
  final ValueChanged<int?> onRowsPerPageChanged;
  final ValueChanged<int> onPageChanged;

  const CustomPagination({
    required this.rowsPerPage,
    required this.currentPage,
    required this.totalRows,
    required this.onRowsPerPageChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    int totalPages = (totalRows / rowsPerPage).ceil();
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<int>(
            value: rowsPerPage,
            items: [1, 2, 5].map((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
            onChanged: onRowsPerPageChanged,
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              ),
              Text('Page ${currentPage + 1} of $totalPages'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class propertytype {
  String? sId;
  String? adminId;
  String? propertyId;
  String? propertyType;
  String? propertysubType;
  bool? isMultiunit;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  propertytype({
    this.sId,
    this.adminId,
    this.propertyId,
    this.propertyType,
    this.propertysubType,
    this.isMultiunit,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.iV,
  });

  factory propertytype.fromJson(Map<String, dynamic> json) {
    return propertytype(
      sId: json['_id'],
      adminId: json['admin_id'],
      propertyId: json['property_id'],
      propertyType: json['property_type'],
      propertysubType: json['propertysub_type'],
      isMultiunit: json['is_multiunit'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDelete: json['is_delete'],
      iV: json['__v'],
    );
  }
}
