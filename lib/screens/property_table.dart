// import 'dart:convert';
//
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:expandable_datatable/expandable_datatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:three_zero_two_property/widgets/appbar.dart';
//
// import 'barchart.dart';
//
// class Property_Table extends StatefulWidget {
//   const Property_Table({super.key});
//
//   @override
//   State<Property_Table> createState() => _Property_TableState();
// }
//
// class _Property_TableState extends State<Property_Table> {
//   final List<String> items = [
//     'commercial',
//     'Residencial',
//     'All',
//   ];
//   String? selectedValue;
//   bool isChecked = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget_302.App_Bar(context: context),
//       drawer: Drawer(),
//       body: HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<Users> userList = [];
//
//   late List<ExpandableColumn<dynamic>> headers;
//   late List<ExpandableRow> rows;
//
//   bool _isLoading = true;
//
//   void setLoading() {
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     fetch();
//   }
//
//   void fetch() async {
//     userList = await getUsers();
//
//     createDataSource();
//
//     setLoading();
//   }
//
//   Future<List<Users>> getUsers() async {
//     final String response = await rootBundle.loadString('assets/dumb1.json');
//
//     final data = await json.decode(response);
//
//     print(data);
//     API apiData = API.fromJson(data);
//
//     if (apiData.users != null) {
//       return apiData.users!;
//     }
//
//     return [];
//   }
//
//   void createDataSource() {
//     headers = [
//       ExpandableColumn<int>(columnTitle: "ID", columnFlex: 1),
//       ExpandableColumn<String>(columnTitle: "First name", columnFlex: 2),
//       ExpandableColumn<String>(columnTitle: "Last name", columnFlex: 2),
//       ExpandableColumn<String>(columnTitle: "Maiden name", columnFlex: 2),
//       ExpandableColumn<int>(columnTitle: "Age", columnFlex: 1),
//       ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
//       ExpandableColumn<String>(columnTitle: "Email", columnFlex: 4),
//     ];
//
//     rows = userList.map<ExpandableRow>((e) {
//       return ExpandableRow(cells: [
//         ExpandableCell<int>(columnTitle: "ID", value: e.id),
//         ExpandableCell<String>(columnTitle: "First name", value: e.firstName),
//         ExpandableCell<String>(columnTitle: "Last name", value: e.lastName),
//         ExpandableCell<String>(columnTitle: "Maiden name", value: e.maidenName),
//         ExpandableCell<int>(columnTitle: "Age", value: e.age),
//         ExpandableCell<String>(columnTitle: "Gender", value: e.gender),
//         ExpandableCell<String>(columnTitle: "Email", value: e.email),
//       ]);
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Users Table', // Add your text here
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(30.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(5.0),
//                 child: Container(
//                   height: 50.0,
//                   padding: EdgeInsets.only(top: 8, left: 10),
//                   width: MediaQuery.of(context).size.width * .91,
//                   margin: const EdgeInsets.only(
//                       bottom: 6.0), //Same as `blurRadius` i guess
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5.0),
//                     color: Color.fromRGBO(21, 43, 81, 1),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey,
//                         offset: Offset(0.0, 1.0), //(x,y)
//                         blurRadius: 6.0,
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     "Preminum Plans",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 22),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 25,right: 25),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black), // Add border here
//                   ),
//                   child: !_isLoading
//                       ? LayoutBuilder(builder: (context, constraints) {
//                     // Your ExpandableDataTable widget goes here
//                     int visibleCount = 3;
//                     if (constraints.maxWidth < 600) {
//                       visibleCount = 3;
//                     } else if (constraints.maxWidth < 800) {
//                       visibleCount = 4;
//                     } else if (constraints.maxWidth < 1000) {
//                       visibleCount = 5;
//                     } else {
//                       visibleCount = 6;
//                     }
//                     return ExpandableTheme(
//                       data: ExpandableThemeData(
//                         context,
//                         contentPadding: const EdgeInsets.all(2),
//                         expandedBorderColor: Colors.transparent,
//                         paginationSize: 48,
//                         headerHeight: 56,
//                         headerColor: Colors.amber[400],
//                         headerBorder: const BorderSide(
//                           color: Colors.black,
//                           width: 1,
//                         ),
//                         evenRowColor: const Color(0xFFFFFFFF),
//                         oddRowColor: Colors.white,
//                         rowBorder: const BorderSide(
//                           color: Colors.black,
//                           width: 0.3,
//                         ),
//                         rowColor: Colors.green,
//                         headerTextMaxLines: 4,
//                         headerSortIconColor: const Color(0xFF6c59cf),
//                         paginationSelectedFillColor: const Color(0xFF6c59cf),
//                         paginationSelectedTextColor: Colors.white,
//                       ),
//                       child: ExpandableDataTable(
//                         headers: headers,
//                         rows: rows,
//                         multipleExpansion: false,
//                         isEditable: false,
//                         onRowChanged: (newRow) {
//                           print(newRow.cells[01].value);
//                         },
//                         onPageChanged: (page) {
//                           print(page);
//                         },
//                         renderEditDialog: (row, onSuccess) =>
//                             _buildEditDialog(row, onSuccess),
//                         visibleColumnCount: visibleCount,
//                       ),
//                     );
//                   })
//                       : const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _buildEditDialog(
//       ExpandableRow row, Function(ExpandableRow) onSuccess) {
//     return AlertDialog(
//       title: SizedBox(
//         height: 300,
//         child: TextButton(
//           child: const Text("Change name"),
//           onPressed: () {
//             row.cells[1].value = "x3";
//             onSuccess(row);
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class Users {
//   final int id;
//   final String firstName;
//   final String lastName;
//   final String maidenName;
//   final int age;
//   final String gender;
//   final String email;
//
//   Users({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.maidenName,
//     required this.age,
//     required this.gender,
//     required this.email,
//   });
//
//   factory Users.fromJson(Map<String, dynamic> json) {
//     return Users(
//       id: json['id'] as int,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       maidenName: json['maidenName'] as String,
//       age: json['age'] as int,
//       gender: json['gender'] as String,
//       email: json['email'] as String,
//     );
//   }
// }
//
// class API {
//   final List<Users>? users;
//
//   API({this.users});
//
//   factory API.fromJson(Map<String, dynamic> json) {
//     return API(
//       users: (json['users'] as List<dynamic>?)
//           ?.map((userJson) => Users.fromJson(userJson))
//           .toList(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// class MyTable extends StatelessWidget {
//   // Dummy data for demonstration
//   final List<Map<String, String>> _data = [
//     {'Column 1': 'Data 1', 'Column 2': 'Data 2', 'Column 3': 'Data 3'},
//     {'Column 1': 'Data 4', 'Column 2': 'Data 5', 'Column 3': 'Data 6'},
//     // Add more data as needed
//   ];
//
//   // Dropdown menu options
//   final List<String> _propertyOptions = ['Option 1', 'Option 2', 'Option 3'];
//   final List<String> _propertyTypeOptions = ['Type 1', 'Type 2', 'Type 3'];
//
//   // Selected values for dropdowns
//   String _selectedProperty = 'Option 1';
//   String _selectedPropertyType = 'Type 1';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Table Example'),
//       ),
//       body: SingleChildScrollView(
//         child: PaginatedDataTable(
//           header: Row(
//             children: [
//               DropdownButton<String>(
//                 value: _selectedProperty,
//                 onChanged: (newValue) {
//                   if (newValue != null) {
//                     // Update selected property
//                     _selectedProperty = newValue;
//                   }
//                 },
//                 items: _propertyOptions
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(width: 20),
//               DropdownButton<String>(
//                 value: _selectedPropertyType,
//                 onChanged: (newValue) {
//                   if (newValue != null) {
//                     // Update selected property type
//                     _selectedPropertyType = newValue;
//                   }
//                 },
//                 items: _propertyTypeOptions
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//           columns: [
//             DataColumn(label: Text('Column 1')),
//             DataColumn(label: Text('Column 2')),
//             DataColumn(label: Text('Column 3')),
//             // Add more columns as needed
//           ],
//           source: _DataSource(context, _data),
//           rowsPerPage: 5, // Adjust the number of rows per page
//         ),
//       ),
//     );
//   }
// }
//
// class _DataSource extends DataTableSource {
//   final BuildContext context;
//   final List<Map<String, String>> _data;
//
//   _DataSource(this.context, this._data);
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) {
//       return null;
//     }
//     final row = _data[index];
//     return DataRow(cells: [
//       DataCell(Text(row['Column 1'] ?? '')),
//       DataCell(Text(row['Column 2'] ?? '')),
//       DataCell(Text(row['Column 3'] ?? '')),
//       // Add more cells as needed
//     ]);
//   }
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get rowCount => _data.length;
//
//   @override
//   int get selectedRowCount => 0;
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: MyTable(),
//   ));
// }

// import 'package:flutter/material.dart';
//
// class MyTable extends StatelessWidget {
//   // Dummy data for demonstration
//   final List<Map<String, String>> _data = [
//     {'Column 1': 'Data 1', 'Column 2': 'Data 2', 'Column 3': 'Data 3'},
//     {'Column 1': 'Data 4', 'Column 2': 'Data 5', 'Column 3': 'Data 6'},
//     // Add more data as needed
//   ];
//
//   // Dropdown menu options
//   final List<String> _propertyOptions = ['House', 'Apartment', 'Condo'];
//   final List<String> _propertyTypeOptions = ['Rent', 'Sale', 'Lease'];
//   final List<String> _subTypeOptions = ['Single Family', 'Multi-family', 'Townhome'];
//   final List<String> _rentalOwnerNames = ['John Doe', 'Jane Smith', 'Michael Johnson'];
//
//   // Selected values for dropdowns
//   String _selectedProperty = 'House';
//   String _selectedPropertyType = 'Rent';
//   String _selectedSubType = 'Single Family';
//   String _selectedRentalOwnerName = 'John Doe';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Table Example'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 20),
//           Padding(
//             padding: EdgeInsets.only(left: 20, right: 20),
//             child: Container(
//               padding: EdgeInsets.only(left: 10, right: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                 ),
//                 border: Border.all(color: Colors.black), // Add black border
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ColumnHeaderWithDropdown(
//                       label: 'Property',
//                       options: _propertyOptions,
//                       selectedOption: _selectedProperty,
//                       onOptionChanged: (String? newValue) {
//                         if (newValue != null) {
//                           _selectedProperty = newValue;
//                         }
//                       },
//                     ),
//                     SizedBox(width: 20),
//                     ColumnHeaderWithDropdown(
//                       label: 'Property Type',
//                       options: _propertyTypeOptions,
//                       selectedOption: _selectedPropertyType,
//                       onOptionChanged: (String? newValue) {
//                         if (newValue != null) {
//                           _selectedPropertyType = newValue;
//                         }
//                       },
//                     ),
//                     SizedBox(width: 20),
//                     ColumnHeaderWithDropdown(
//                       label: 'Subtype',
//                       options: _subTypeOptions,
//                       selectedOption: _selectedSubType,
//                       onOptionChanged: (String? newValue) {
//                         if (newValue != null) {
//                           _selectedSubType = newValue;
//                         }
//                       },
//                     ),
//                     SizedBox(width: 20),
//                     ColumnHeaderWithDropdown(
//                       label: 'Rental Owner Name',
//                       options: _rentalOwnerNames,
//                       selectedOption: _selectedRentalOwnerName,
//                       onOptionChanged: (String? newValue) {
//                         if (newValue != null) {
//                           _selectedRentalOwnerName = newValue;
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 20, right: 20),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.black), // Add black border
//                 ),
//                 child: PaginatedDataTable(
//                   columns: [
//                     DataColumn(label: Text('Column 1')),
//                     DataColumn(label: Text('Column 2')),
//                     DataColumn(label: Text('Column 3')),
//                     // Add more columns as needed
//                   ],
//                   source: _DataSource(context, _data),
//                   rowsPerPage: 5,
//                   // Adjust the number of rows per page
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ColumnHeaderWithDropdown extends StatelessWidget {
//   final String label;
//   final List<String> options;
//   final String selectedOption;
//   final ValueChanged<String?>? onOptionChanged;
//
//   const ColumnHeaderWithDropdown({
//     Key? key,
//     required this.label,
//     required this.options,
//     required this.selectedOption,
//     this.onOptionChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         DropdownButton<String>(
//           value: selectedOption,
//           onChanged: onOptionChanged,
//           items: options
//               .map<DropdownMenuItem<String>>(
//                 (String value) => DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             ),
//           )
//               .toList(),
//         ),
//       ],
//     );
//   }
// }
//
// class _DataSource extends DataTableSource {
//   final BuildContext context;
//   final List<Map<String, String>> _data;
//
//   _DataSource(this.context, this._data);
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) {
//       return null;
//     }
//     final row = _data[index];
//     return DataRow(cells: [
//       DataCell(Text(row['Column 1'] ?? '')),
//       DataCell(Text(row['Column 2'] ?? '')),
//       DataCell(Text(row['Column 3'] ?? '')),
//       // Add more cells as needed
//     ]);
//   }
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get rowCount => _data.length;
//
//   @override
//   int get selectedRowCount => 0;
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: MyTable(),
//   ));
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

class DataTableDemo extends StatefulWidget {
  const DataTableDemo({super.key});

  @override
  State<DataTableDemo> createState() => _DataTableDemoState();
}

class _RestorableDessertSelections extends RestorableProperty<Set<int>> {
  // The set of indices of selected dessert rows
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [_Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<_Dessert> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _dessertSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _dessertSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _dessertSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _dessertSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _dessertSelections = value;
  }

  @override
  Object toPrimitives() => _dessertSelections.toList();
}


class _DataTableDemoState extends State<DataTableDemo> with RestorationMixin {
  // Create restoration properties
  final _RestorableDessertSelections _dessertSelections = _RestorableDessertSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage = RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);

  // Declare a _DessertDataSource instance and initialize it to null
  _DessertDataSource? _dessertsDataSource;

  // Set restoration ID
  @override
  String get restorationId => 'data_table_demo';

  // Register restorable properties for restoration
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    // Initialize _dessertsDataSource if it is null
    _dessertsDataSource ??= _DessertDataSource(context);

    // Sort the data source according to the sort column index
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource!._sort<String>((d) => d.name, _sortAscending.value);
        break;
      case 1:
        _dessertsDataSource!._sort<num>((d) => d.property, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource!._sort<String>((d) => d.subtype, _sortAscending.value);
        break;
      case 3:
        _dessertsDataSource!._sort<String>((d) => d.rentalowenername, _sortAscending.value);
        break;

    }

    // Update the selection of desserts
    _dessertsDataSource!.updateSelectedDesserts(_dessertSelections);

    // Add listener to _dessertsDataSource to update selected dessert row
    _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  // Add listener to _dessertsDataSource when the widget is attached to the tree
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize _dessertsDataSource if it is null
    _dessertsDataSource ??= _DessertDataSource(context);

    // Add listener to _dessertsDataSource to update selected dessert row
    _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  // Update the selected dessert row
  void _updateSelectedDessertRowListener() {
    _dessertSelections.setDessertSelections(_dessertsDataSource!._desserts);
  }

  // Sort the data source
  void _sort<T>(
      Comparable<T> Function(_Dessert d) getField,
      int columnIndex,
      bool ascending,
      ) {
    _dessertsDataSource!._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  void dispose() {
    // Dispose of the _rowsPerPage stream subscription
    _rowsPerPage.dispose();

    // Dispose of the _sortColumnIndex stream subscription
    _sortColumnIndex.dispose();

    // Dispose of the _sortAscending stream subscription
    _sortAscending.dispose();

    // Remove the listener that updates the selected dessert row
    // from the _dessertsDataSource
    _dessertsDataSource!.removeListener(_updateSelectedDessertRowListener);

    // Dispose of the _dessertsDataSource stream subscription
    _dessertsDataSource!.dispose();

    // Call the superclass's dispose method
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      body: Scrollbar( // Add a scrollbar to the body of the scaffold
        child: ListView(
          restorationId: 'data_table_list_view',
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.034,
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
                              fontSize: MediaQuery.of(context).size.width * 0.034,
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
                    "Preminum Plans",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Container(
                  height: 40,
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.grey),
                  ),
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
                          cursorColor: Color.fromRGBO(21, 43, 81, 1),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search here...",
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 20), // Example spacing between widgets
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black), // Set border color and width
              ),
              child: PaginatedDataTable(
               // header: Text('Nutrition'), // Set the header text of the data table
                rowsPerPage: _rowsPerPage.value,
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage.value = value!;
                  });
                },
                initialFirstRowIndex: _rowIndex.value,
                onPageChanged: (rowIndex) {
                  setState(() {
                    _rowIndex.value = rowIndex;
                  });
                },

                sortColumnIndex: _sortColumnIndex.value,
                sortAscending: _sortAscending.value,
                onSelectAll: _dessertsDataSource!._selectAll, // Set the select all callback of the data table
                columns: [

                  DataColumn(

                    label: Text('Property',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the first column
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((d) => d.name, columnIndex, ascending), // Set the sorting function of the first column
                  ),
                  DataColumn(
                    label: Text('Property Type',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the second column
                    numeric: true,
                    onSort: (columnIndex, ascending) =>
                        _sort<num>((d) => d.property, columnIndex, ascending), // Set the sorting function of the second column
                  ),
                  DataColumn(
                    label: Text('Sub Type',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the third column
                    numeric: true,
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((d) => d.subtype, columnIndex, ascending), // Set the sorting function of the third column
                  ),
                  DataColumn(
                    label: Text('Renatl Owner Name',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the fourth column
                    numeric: true,
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((d) => d.rentalowenername, columnIndex, ascending), // Set the sorting function of the fourth column
                  ),
                ],
                source: _dessertsDataSource!,

              ),
            ),
          ],
        ),
      ),
    );
  }


}

class _Dessert {
  _Dessert(
      this.name,     // The name of the dessert
      this.property, // The number of calories in the dessert
      this.subtype,      // The amount of fat in the dessert (in grams)
      this.rentalowenername,    // The number of carbohydrates in the dessert (in grams)
           // The amount of iron in the dessert (in milligrams)
      );

  final String name;     // The name of the dessert (immutable)
  final int property;    // The number of calories in the dessert (immutable)
  final String subtype;      // The amount of fat in the dessert (in grams) (immutable)
  final String rentalowenername;      // The number of carbohydrates in the dessert (in grams) (immutable)
      // The amount of iron in the dessert (in milligrams) (immutable)
  bool selected = false; // Whether the dessert is currently selected (default is false)
}

class _DessertDataSource extends DataTableSource {
  // Constructor for _DessertDataSource class, takes a BuildContext argument
  _DessertDataSource(this.context) {
    // Initialize the list of desserts
    _desserts = <_Dessert>[
      _Dessert(
        'Frozen Yogurt',
        159,
       ' combo',
        '24',

      ),
      _Dessert(
        'IceCream Sandwich',
        237,
        'Single Family',
        '37',

      ),
      _Dessert(
        'Eclair',
        262,
        'Office',
       ' 24',

      ),
      _Dessert(
        'Cupcake',
        305,
        'office',
       ' 67',

      ),
      _Dessert(
        'Gingerbread',
        356,
        'combo',
        '49',

      ),
      _Dessert(
        'JellyBean',
        375,
        'single family',
       ' 94',

      ),


    ];
  }

  // The BuildContext passed to the constructor
  final BuildContext context;

  // List of desserts
  late List<_Dessert> _desserts;

  // Sort the desserts by a given field
  void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
    _desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  // Number of selected desserts
  int _selectedCount = 0;

  // Update the selected desserts
  void updateSelectedDesserts(_RestorableDessertSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < _desserts.length; i += 1) {
      var dessert = _desserts[i];
      if (selectedRows.isSelected(i)) {
        dessert.selected = true;
        _selectedCount += 1;
      } else {
        dessert.selected = false;
      }
    }
    notifyListeners();
  }

  // Get a DataRow for a given index
  @override
  DataRow? getRow(int index) {
    // Number formatter for percentages
    final format = NumberFormat.decimalPercentPattern(
      decimalDigits: 0,
    );
    // Make sure index is valid
    assert(index >= 0);
    if (index >= _desserts.length) return null;
    final dessert = _desserts[index];
    // Create the DataRow with cells for each dessert property
    return DataRow.byIndex(
      index: index,
      selected: dessert.selected,
      onSelectChanged: (value) {
        // Update the selected count and dessert selection
        if (dessert.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(dessert.name)),
        DataCell(Text('${dessert.property}')),
        DataCell(Text(dessert.subtype)),
        DataCell(Text('${dessert.rentalowenername}')),

      ],
    );
  }

  // Number of rows in the DataTable
  @override
  int get rowCount => _desserts.length;

  // Whether or not the rowCount is approximate
  @override
  bool get isRowCountApproximate => false;

  // Number of selected rows
  @override
  int get selectedRowCount => _selectedCount;

  // Select or deselect all rows
  void _selectAll(bool? checked) {
    for (final dessert in _desserts) {
      dessert.selected = checked ?? false;
    }
    _selectedCount = checked! ? _desserts.length : 0;
    notifyListeners();
  }
}





