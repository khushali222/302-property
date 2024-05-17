//
//
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:three_zero_two_property/widgets/appbar.dart';
//
// import '../widgets/drawer_tiles.dart';
// import 'add_property.dart';
//
// class DataTableDemo extends StatefulWidget {
//   const DataTableDemo({super.key});
//
//   @override
//   State<DataTableDemo> createState() => _DataTableDemoState();
// }
//
// class _RestorableDessertSelections extends RestorableProperty<Set<int>> {
//   // The set of indices of selected dessert rows
//   Set<int> _dessertSelections = {};
//
//   /// Returns whether or not a dessert row is selected by index.
//   bool isSelected(int index) => _dessertSelections.contains(index);
//
//   /// Takes a list of [_Dessert]s and saves the row indices of selected rows
//   /// into a [Set].
//   void setDessertSelections(List<_Dessert> desserts) {
//     final updatedSet = <int>{};
//     for (var i = 0; i < desserts.length; i += 1) {
//       var dessert = desserts[i];
//       if (dessert.selected) {
//         updatedSet.add(i);
//       }
//     }
//     _dessertSelections = updatedSet;
//     notifyListeners();
//   }
//
//   @override
//   Set<int> createDefaultValue() => _dessertSelections;
//
//   @override
//   Set<int> fromPrimitives(Object? data) {
//     final selectedItemIndices = data as List<dynamic>;
//     _dessertSelections = {
//       ...selectedItemIndices.map<int>((dynamic id) => id as int),
//     };
//     return _dessertSelections;
//   }
//
//   @override
//   void initWithValue(Set<int> value) {
//     _dessertSelections = value;
//   }
//
//   @override
//   Object toPrimitives() => _dessertSelections.toList();
// }
//
// class _DataTableDemoState extends State<DataTableDemo> with RestorationMixin {
//   final RestorableInt _rowIndex = RestorableInt(0);
//   final RestorableInt _rowsPerPage = RestorableInt(PaginatedDataTable.defaultRowsPerPage);
//   final RestorableBool _sortAscending = RestorableBool(true);
//   final RestorableIntN _sortColumnIndex = RestorableIntN(null);
//
//   late _DessertDataSource _dessertsDataSource;
//  // _DessertDataSource? _dessertsDataSource;
//
//   @override
//   void initState() {
//     super.initState();
//     _dessertsDataSource = _DessertDataSource(context);
//   }
//   @override
//   String get restorationId => 'data_table_demo';
//
//   @override
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(_rowIndex, 'current_row_index');
//     registerForRestoration(_rowsPerPage, 'rows_per_page');
//     registerForRestoration(_sortAscending, 'sort_ascending');
//     registerForRestoration(_sortColumnIndex, 'sort_column_index');
//
//     _dessertsDataSource ??= _DessertDataSource(context);
//
//     switch (_sortColumnIndex.value) {
//       case 0:
//         _dessertsDataSource._sort<String>((d) => d.name, _sortAscending.value);
//         break;
//       case 1:
//         _dessertsDataSource._sort<String>((d) => d.property, _sortAscending.value);
//         break;
//       case 2:
//         _dessertsDataSource._sort<String>((d) => d.subtype, _sortAscending.value);
//         break;
//       case 3:
//         _dessertsDataSource._sort<String>((d) => d.rentalowenername, _sortAscending.value);
//         break;
//     }
//     _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _dessertsDataSource ??= _DessertDataSource(context);
//     _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
//   }
//
//   void _updateSelectedDessertRowListener() {
//     // Example: Get the selected row index
//     int? selectedRowIndex = _dessertsDataSource.selectedRowCount;
//
//     // Example: Perform some action based on the selected row index
//     if (selectedRowIndex != null) {
//       // A row is selected, perform some action
//       print('Selected row index: $selectedRowIndex');
//     } else {
//       // No row is selected, perform some other action
//       print('No row selected');
//     }
//   }
//
//   void _sort<T>(
//       Comparable<T> Function(_Dessert d) getField,
//       int columnIndex,
//       bool ascending,
//       ) {
//     _dessertsDataSource._sort<T>(getField, ascending);
//     setState(() {
//       _sortColumnIndex.value = columnIndex;
//       _sortAscending.value = ascending;
//     });
//   }
//
//   final List<String> items = [
//    'Residential',
//     "Commercial",
//     "All"
//   ];
//   String? selectedValue;
//   @override
//   void dispose() {
//     _rowsPerPage.dispose();
//     _sortColumnIndex.dispose();
//     _sortAscending.dispose();
//     _dessertsDataSource.removeListener(_updateSelectedDessertRowListener);
//     _dessertsDataSource.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget_302.App_Bar(context: context),
//       drawer: Drawer(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 40),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Image.asset("assets/images/logo.png"),
//               ),
//               SizedBox(height: 40),
//               buildListTile(context,Icon(CupertinoIcons.circle_grid_3x3,color: Colors.black,), "Dashboard",false),
//               buildListTile(context,Icon(CupertinoIcons.house,color: Colors.white,), "Add Property Type",true),
//               buildListTile(context,Icon(CupertinoIcons.person_add), "Add Staff Member",false),
//               buildDropdownListTile(context,
//                   Icon(Icons.key), "Rental", ["Properties", "RentalOwner", "Tenants"]),
//               buildDropdownListTile(context,Icon(Icons.thumb_up_alt_outlined), "Leasing",
//                   ["Rent Roll", "Applicants"]),
//               buildDropdownListTile(context,
//                   Image.asset("assets/icons/maintence.png", height: 20, width: 20),
//                   "Maintenance",
//                   ["Vendor", "Work Order"]),
//             ],
//           ),
//         ),
//       ),
//       body: Scrollbar(
//         child: ListView(
//
//           restorationId: 'data_table_list_view',
//           padding: const EdgeInsets.all(16),
//           children: [
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GestureDetector(
//                   onTap: (){
//                     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Add_property()));
//                   },
//                   child: Container(
//                     height: 40,
//                     width: MediaQuery.of(context).size.width * 0.4,
//                     decoration: BoxDecoration(
//                       color: Color.fromRGBO(21, 43, 81, 1),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Add New Property",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: MediaQuery.of(context).size.width * 0.034,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 5),
//               ],
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.all(5.0),
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
//                     "Property Type",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 22),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 SizedBox(width: 5),
//                 Container(
//                   height: 40,
//                   width: 140,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(2),
//                     border: Border.all(color: Colors.grey),
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned.fill(
//                         child: TextField(
//                           // onChanged: (value) {
//                           //   setState(() {
//                           //     cvverror = false;
//                           //   });
//                           // },
//                          // controller: cvv,
//                           cursorColor: Color.fromRGBO(21, 43, 81, 1),
//                           decoration: InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Search here...",
//                             contentPadding: EdgeInsets.all(10),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 DropdownButtonHideUnderline(
//                   child: DropdownButton2<String>(
//                     isExpanded: true,
//                     hint: const Row(
//                       children: [
//
//                         SizedBox(
//                           width: 4,
//                         ),
//                         Expanded(
//                           child: Text(
//                             'Type',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     items: items
//                         .map((String item) => DropdownMenuItem<String>(
//                       value: item,
//                       child: Text(
//                         item,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ))
//                         .toList(),
//                     value: selectedValue,
//                     onChanged: (value) {
//                       setState(() {
//                         selectedValue = value;
//                       });
//                     },
//                     buttonStyleData: ButtonStyleData(
//                       height: 50,
//                       width: 160,
//                       padding: const EdgeInsets.only(left: 14, right: 14),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: Colors.black26,
//                         ),
//                        color: Colors.white,
//                       ),
//                       elevation: 0,
//                     ),
//
//                     dropdownStyleData: DropdownStyleData(
//                       maxHeight: 200,
//                       width: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(14),
//                         //color: Colors.redAccent,
//                       ),
//                       offset: const Offset(-20, 0),
//                       scrollbarTheme: ScrollbarThemeData(
//                         radius: const Radius.circular(40),
//                         thickness: MaterialStateProperty.all(6),
//                         thumbVisibility: MaterialStateProperty.all(true),
//                       ),
//                     ),
//                     menuItemStyleData: const MenuItemStyleData(
//                       height: 40,
//                       padding: EdgeInsets.only(left: 14, right: 14),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Theme(
//               data: ThemeData(
//                 scaffoldBackgroundColor: Colors.white,
//                 cardTheme: CardTheme( // Apply custom style to the Card wrapping the DataTable
//                   shape: RoundedRectangleBorder( // Remove border radius
//                     borderRadius: BorderRadius.zero,
//                   ),
//                 ),
//               ),
//               child: PaginatedDataTable(
//                 rowsPerPage: _rowsPerPage.value,
//                 onRowsPerPageChanged: (value) {
//                   setState(() {
//                     _rowsPerPage.value = value!;
//                   });
//                 },
//                 initialFirstRowIndex: _rowIndex.value,
//                 onPageChanged: (rowIndex) {
//                   setState(() {
//                     _rowIndex.value = rowIndex;
//                   });
//                 },
//                 availableRowsPerPage: [3, 5, 10,15, 25],
//                 sortColumnIndex: _sortColumnIndex.value,
//                 sortAscending: _sortAscending.value,
//                 columnSpacing: 28,
//                 dataRowHeight: 45,
//                 headingRowHeight: 60,
//               //  showEmptyRows: false,
//                 columns: [
//                   DataColumn(
//                     label: Text('Property', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                     onSort: (columnIndex, ascending) => _sort<String>((d) => d.name, columnIndex, ascending),
//                   ),
//                   DataColumn(
//                     label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                     onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                   ),
//                   DataColumn(
//                     label: Text('Sub Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                     onSort: (columnIndex, ascending) => _sort<String>((d) => d.subtype, columnIndex, ascending),
//                   ),
//                   DataColumn(
//                     label: Text('Rental Owner Name', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                     onSort: (columnIndex, ascending) => _sort<String>((d) => d.rentalowenername, columnIndex, ascending),
//                   ),
//                 ],
//                 source: _dessertsDataSource,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class _Dessert {
//   _Dessert(
//       this.name,
//       this.property,
//       this.subtype,
//       this.rentalowenername,
//       );
//
//   final String name;
//   final String property;
//   final String subtype;
//   final String rentalowenername;
//   bool selected = false;
// }
//
//
// class _DessertDataSource extends DataTableSource {
//   _DessertDataSource(this.context) {
//     _desserts = <_Dessert>[
//       _Dessert(
//         '2Clipercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '5jeggingscourt',
//         'Recidential',
//         'Single Family',
//         '37',
//       ),
//       _Dessert(
//         '36Clipercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '3willycourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '2williamcourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//       _Dessert(
//         '28cartercourt',
//         'Commercial',
//         'combo',
//         '24',
//       ),
//     ];
//   }
//
//   final BuildContext context;
//   late List<_Dessert> _desserts;
//
//   void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
//     _desserts.sort((a, b) {
//       final aValue = getField(a);
//       final bValue = getField(b);
//       return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
//     });
//     notifyListeners();
//   }
//
//   @override
//   DataRow? getRow(int index) {
//     assert(index >= 0);
//     if (index >= _desserts.length) return null;
//     final dessert = _desserts[index];
//     return DataRow.byIndex(
//       index: index,
//       cells: [
//         DataCell(Text(dessert.name)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.subtype)),
//         DataCell(Text(dessert.rentalowenername)),
//       ],
//     );
//   }
//
//   @override
//   int get rowCount => _desserts.length;
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get selectedRowCount => 0; // No checkbox, so always returning 0
// }
//
//
//


/*
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../Model/propertytype.dart';
import '../widgets/drawer_tiles.dart';
import 'add_property.dart';

class Property_table extends StatefulWidget {
  const Property_table({super.key});

  @override
  State<Property_table> createState() => _Property_tableState();
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
}*/
// class _Property_tableState extends State<Property_table> with RestorationMixin {
//   // Create restoration properties
//   final _RestorableDessertSelections _dessertSelections = _RestorableDessertSelections();
//   final RestorableInt _rowIndex = RestorableInt(0);
//   final RestorableInt _rowsPerPage = RestorableInt(PaginatedDataTable.defaultRowsPerPage);
//   final RestorableBool _sortAscending = RestorableBool(true);
//   final RestorableIntN _sortColumnIndex = RestorableIntN(null);
//
//
//   // Declare a _DessertDataSource instance and initialize it to null
//   _DessertDataSource? _dessertsDataSource;
//
//   // Set restoration ID
//   @override
//   String get restorationId => 'data_table_demo';
//
//   // Register restorable properties for restoration
//   @override
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(_dessertSelections, 'selected_row_indices');
//     registerForRestoration(_rowIndex, 'current_row_index');
//     registerForRestoration(_rowsPerPage, 'rows_per_page');
//     registerForRestoration(_sortAscending, 'sort_ascending');
//     registerForRestoration(_sortColumnIndex, 'sort_column_index');
//
//     // Initialize _dessertsDataSource if it is null
//
//     _dessertsDataSource ??= _DessertDataSource(context);
//
//     // Sort the data source according to the sort column index
//     switch (_sortColumnIndex.value) {
//       case 0:
//         _dessertsDataSource!._sort<String>((d) => d.name, _sortAscending.value);
//         break;
//       case 1:
//         _dessertsDataSource!._sort<String>((d) => d.property, _sortAscending.value);
//         break;
//       case 2:
//         _dessertsDataSource!._sort<String>((d) => d.subtype, _sortAscending.value);
//         break;
//       case 3:
//         _dessertsDataSource!._sort<String>((d) => d.rentalowenername, _sortAscending.value);
//         break;
//
//     }
//
//     // Update the selection of desserts
//     _dessertsDataSource!.updateSelectedDesserts(_dessertSelections);
//
//     // Add listener to _dessertsDataSource to update selected dessert row
//     _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
//   }
//
//   // Add listener to _dessertsDataSource when the widget is attached to the tree
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     // Initialize _dessertsDataSource if it is null
//     _dessertsDataSource ??= _DessertDataSource(context);
//
//     // Add listener to _dessertsDataSource to update selected dessert row
//     _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
//   }
//
//   // Update the selected dessert row
//   void _updateSelectedDessertRowListener() {
//     _dessertSelections.setDessertSelections(_dessertsDataSource!._desserts);
//   }
//
//   // Sort the data source
//   void _sort<T>(
//       Comparable<T> Function(_Dessert d) getField,
//       int columnIndex,
//       bool ascending,
//       ) {
//     _dessertsDataSource!._sort<T>(getField, ascending);
//     setState(() {
//       _sortColumnIndex.value = columnIndex;
//       _sortAscending.value = ascending;
//     });
//   }
//
//   @override
//   void dispose() {
//     // Dispose of the _rowsPerPage stream subscription
//     _rowsPerPage.dispose();
//
//     // Dispose of the _sortColumnIndex stream subscription
//     _sortColumnIndex.dispose();
//
//     // Dispose of the _sortAscending stream subscription
//     _sortAscending.dispose();
//
//     // Remove the listener that updates the selected dessert row
//     // from the _dessertsDataSource
//     _dessertsDataSource!.removeListener(_updateSelectedDessertRowListener);
//
//     // Dispose of the _dessertsDataSource stream subscription
//     _dessertsDataSource!.dispose();
//
//     // Call the superclass's dispose method
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget_302.App_Bar(context: context),
//       body: Scrollbar( // Add a scrollbar to the body of the scaffold
//         child: ListView(
//           restorationId: 'data_table_list_view',
//           padding: const EdgeInsets.all(16),
//           children: [
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GestureDetector(
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.034,
//                     width: MediaQuery.of(context).size.width * 0.4,
//                     decoration: BoxDecoration(
//                       color: Color.fromRGBO(21, 43, 81, 1),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Add New Property",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: MediaQuery.of(context).size.width * 0.034,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 5),
//               ],
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.all(5.0),
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
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 SizedBox(width: 5),
//                 Container(
//                   height: 40,
//                   width: 140,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(2),
//                     border: Border.all(color: Colors.grey),
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned.fill(
//                         child: TextField(
//                           // onChanged: (value) {
//                           //   setState(() {
//                           //     cvverror = false;
//                           //   });
//                           // },
//                          // controller: cvv,
//                           cursorColor: Color.fromRGBO(21, 43, 81, 1),
//                           decoration: InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Search here...",
//                             contentPadding: EdgeInsets.all(10),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 20),
//               ],
//             ),
//             SizedBox(height: 20), // Example spacing between widgets
//             Container(
//               decoration: BoxDecoration(
//                // borderRadius: BorderRadius.circular(25),
//                 border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)), // Set border color and width
//               ),
//               child:
//               // PaginatedDataTable(
//               //  // header: Text('Nutrition'), // Set the header text of the data table
//               //   rowsPerPage: _rowsPerPage.value,
//               //   onRowsPerPageChanged: (value) {
//               //     setState(() {
//               //       _rowsPerPage.value = value!;
//               //     });
//               //   },
//               //   initialFirstRowIndex: _rowIndex.value,
//               //   onPageChanged: (rowIndex) {
//               //     setState(() {
//               //       _rowIndex.value = rowIndex;
//               //     });
//               //   },
//               //
//               //   sortColumnIndex: _sortColumnIndex.value,
//               //   sortAscending: _sortAscending.value,
//               //   onSelectAll: _dessertsDataSource!._selectAll, // Set the select all callback of the data table
//               //   columnSpacing: 20, // Adjust column spacing
//               //   dataRowHeight: 50, // Adjust row height
//               //   headingRowHeight: 60,
//               //   columns: [
//               //     DataColumn(
//               //       label: Text('Property',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the first column
//               //       onSort: (columnIndex, ascending) =>
//               //           _sort<String>((d) => d.name, columnIndex, ascending), // Set the sorting function of the first column
//               //     ),
//               //     DataColumn(
//               //       label: Text('Property Type',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the second column
//               //       numeric: true,
//               //       onSort: (columnIndex, ascending) =>
//               //           _sort<num>((d) => d.property, columnIndex, ascending), // Set the sorting function of the second column
//               //     ),
//               //     DataColumn(
//               //       label: Text('Sub Type',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the third column
//               //       numeric: true,
//               //       onSort: (columnIndex, ascending) =>
//               //           _sort<String>((d) => d.subtype, columnIndex, ascending), // Set the sorting function of the third column
//               //     ),
//               //     DataColumn(
//               //       label: Text('Renatl Owner Name',style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold),), // Set the label of the fourth column
//               //       numeric: true,
//               //       onSort: (columnIndex, ascending) =>
//               //           _sort<String>((d) => d.rentalowenername, columnIndex, ascending), // Set the sorting function of the fourth column
//               //     ),
//               //   ],
//               //   source: _dessertsDataSource!,
//               //
//               // ),
//               Theme(
//                 data: ThemeData(
//                   scaffoldBackgroundColor: Colors.white,
//                   cardTheme: CardTheme( // Apply custom style to the Card wrapping the DataTable
//                     shape: RoundedRectangleBorder( // Remove border radius
//                       borderRadius: BorderRadius.zero,
//                     ),
//                   ),
//                 ),
//                 child: PaginatedDataTable(
//                   rowsPerPage: _rowsPerPage.value,
//                   onRowsPerPageChanged: (value) {
//                     setState(() {
//                       _rowsPerPage.value = value!;
//                     });
//                   },
//                   initialFirstRowIndex: _rowIndex.value,
//                   onPageChanged: (rowIndex) {
//                     setState(() {
//                       _rowIndex.value = rowIndex;
//                     });
//                   },
//                   sortColumnIndex: _sortColumnIndex.value,
//                   sortAscending: _sortAscending.value,
//                 //  onSelectAll: _dessertsDataSource!._selectAll,
//                   columnSpacing: 28,
//                   dataRowHeight: 45,
//                   headingRowHeight: 60,
//                   columns: [
//                     DataColumn(
//                       label: Text('Property', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.name, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Sub Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.subtype, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Renatl Owner\nName', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.rentalowenername, columnIndex, ascending),
//                     ),
//
//                     DataColumn(
//                       label: Text('Renatl Owner\nName', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.rentalowenername, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                     DataColumn(
//                       label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
//                       // numeric: true,
//                       onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
//                     ),
//                   ],
//                   source: _dessertsDataSource!,
//                 ),
//               )
//
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
/*
class _Property_tableState extends State<Property_table> with RestorationMixin {
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage = RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);

  late _DessertDataSource _dessertsDataSource;
  // _DessertDataSource? _dessertsDataSource;

  @override
  void initState() {
    super.initState();
    _dessertsDataSource = _DessertDataSource(context);
  }
  @override
  String get restorationId => 'data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    _dessertsDataSource ??= _DessertDataSource(context);

    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource._sort<String>((d) => d.name, _sortAscending.value);
        break;
      case 1:
        _dessertsDataSource._sort<String>((d) => d.property, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource._sort<String>((d) => d.subtype, _sortAscending.value);
        break;
      case 3:
        _dessertsDataSource._sort<String>((d) => d.rentalowenername, _sortAscending.value);
        break;
    }
    _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dessertsDataSource ??= _DessertDataSource(context);
    _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
  }

  void _updateSelectedDessertRowListener() {
    // Example: Get the selected row index
    int? selectedRowIndex = _dessertsDataSource.selectedRowCount;

    // Example: Perform some action based on the selected row index
    if (selectedRowIndex != null) {
      // A row is selected, perform some action
      print('Selected row index: $selectedRowIndex');
    } else {
      // No row is selected, perform some other action
      print('No row selected');
    }
  }

  void _sort<T>(
      Comparable<T> Function(_Dessert d) getField,
      int columnIndex,
      bool ascending,
      ) {
    _dessertsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  void dispose() {
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    _dessertsDataSource.removeListener(_updateSelectedDessertRowListener);
    _dessertsDataSource.dispose();
    super.dispose();
  }

  final List<String> items = [
    'Residential',
    "Commercial",
    "All"
  ];
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
    drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(context,Icon(CupertinoIcons.circle_grid_3x3,color: Colors.black,), "Dashboard",false),
              buildListTile(context,Icon(CupertinoIcons.house,color: Colors.white,), "Add Property Type",true),
              buildListTile(context,Icon(CupertinoIcons.person_add,color: Colors.black,), "Add Staff Member",false),
              buildDropdownListTile(context,
                  Icon(Icons.key), "Rental", ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(context,Icon(Icons.thumb_up_alt_outlined), "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(context,
                  Image.asset("assets/icons/maintence.png", height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
            ],
          ),
        ),
      ),
      body: Scrollbar(
        child: ListView(
          restorationId: 'data_table_list_view',
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_property()));
                  },
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
                DropdownButtonHideUnderline(
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
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                      height: 50,
                      width: 160,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
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
              ],
            ),
            SizedBox(height: 20),
            Theme(
              data: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                cardTheme: CardTheme( // Apply custom style to the Card wrapping the DataTable
                  shape: RoundedRectangleBorder( // Remove border radius
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              child: PaginatedDataTable(
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
                columnSpacing: 28,
                dataRowHeight: 45,
                headingRowHeight: 60,
                columns: [
                  DataColumn(
                    label: Text('Property', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) => _sort<String>((d) => d.name, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Property Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) => _sort<String>((d) => d.property, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Sub Type', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) => _sort<String>((d) => d.subtype, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Rental Owner Name', style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) => _sort<String>((d) => d.rentalowenername, columnIndex, ascending),
                  ),
                ],
                source: _dessertsDataSource,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// class _Dessert {
//   _Dessert(
//       this.name,     // The name of the dessert
//       this.property, // The number of calories in the dessert
//       this.subtype,      // The amount of fat in the dessert (in grams)
//       this.rentalowenername,    // The number of carbohydrates in the dessert (in grams)
//            // The amount of iron in the dessert (in milligrams)
//       );
//
//   final String name;     // The name of the dessert (immutable)
//   final String property;    // The number of calories in the dessert (immutable)
//   final String subtype;      // The amount of fat in the dessert (in grams) (immutable)
//   final String rentalowenername;      // The number of carbohydrates in the dessert (in grams) (immutable)
//       // The amount of iron in the dessert (in milligrams) (immutable)
//   bool selected = false; // Whether the dessert is currently selected (default is false)
// }

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../Model/propertytype.dart';
import '../repository/Property_type.dart';
import '../widgets/drawer_tiles.dart';
import 'add_property.dart';

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

// class _DessertDataSource extends DataTableSource {
//   // Constructor for _DessertDataSource class, takes a BuildContext argument
//   _DessertDataSource(this.context) {
//     // Initialize the list of desserts
//     _desserts = <_Dessert>[
//       _Dessert(
//         '2Clipercourt',
//         'Commercial',
//        ' combo',
//         '24',
//
//       ),
//       _Dessert(
//         '5jeggingscourt',
//         'Recidential',
//         'Single Family',
//         '37',
//
//       ),
//       _Dessert(
//         '800 Barkdal Road',
//         'Commercial',
//         'Office',
//        ' 24',
//
//       ),
//       _Dessert(
//         '8 jubling Street',
//         'Recidential',
//         'office',
//        ' 67',
//
//       ),
//       _Dessert(
//         '12 Star market',
//         'Recidential',
//         'combo',
//         '49',
//
//       ),
//       _Dessert(
//         '19 smith city road',
//         'Commercial',
//         'single family',
//        ' 94',
//
//       ),
//       _Dessert(
//         '19 smith city road',
//         'Commercial',
//         'single family',
//         ' 94',
//
//       ),
//       _Dessert(
//         '8 jubling Street',
//         'Recidential',
//         'office',
//         ' 67',
//
//       ),
//
//       _Dessert(
//         '8 jubling Street',
//         'Recidential',
//         'office',
//         ' 67',
//
//       ),
//       _Dessert(
//         '8 jubling Street',
//         'Recidential',
//         'office',
//         ' 67',
//
//       ),
//       _Dessert(
//         '8 jubling Street',
//         'Recidential',
//         'office',
//         ' 67',
//
//       ),
//       _Dessert(
//         '8 jubling Street',
//         'Recidential',
//         'office',
//         ' 67',
//       ),
//
//
//
//     ];
//   }
//
//   // The BuildContext passed to the constructor
//   final BuildContext context;
//
//   // List of desserts
//   late List<_Dessert> _desserts;
//
//   // Sort the desserts by a given field
//   void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
//     _desserts.sort((a, b) {
//       final aValue = getField(a);
//       final bValue = getField(b);
//       return ascending
//           ? Comparable.compare(aValue, bValue)
//           : Comparable.compare(bValue, aValue);
//     });
//     notifyListeners();
//   }
//
//   // Number of selected desserts
//   int _selectedCount = 0;
//
//   // Update the selected desserts
//   void updateSelectedDesserts(_RestorableDessertSelections selectedRows) {
//     _selectedCount = 0;
//     for (var i = 0; i < _desserts.length; i += 1) {
//       var dessert = _desserts[i];
//       if (selectedRows.isSelected(i)) {
//         dessert.selected = true;
//         _selectedCount += 1;
//       } else {
//         dessert.selected = false;
//       }
//     }
//     notifyListeners();
//   }
//
//   // Get a DataRow for a given index
//   @override
//   DataRow? getRow(int index) {
//     // Number formatter for percentages
//     final format = NumberFormat.decimalPercentPattern(
//       decimalDigits: 0,
//     );
//     // Make sure index is valid
//     assert(index >= 0);
//     if (index >= _desserts.length) return null;
//     final dessert = _desserts[index];
//     // Create the DataRow with cells for each dessert property
//     return DataRow.byIndex(
//       index: index,
//       selected: dessert.selected,
//       onSelectChanged: (value) {
//         // Update the selected count and dessert selection
//         if (dessert.selected != value) {
//           _selectedCount += value! ? 1 : -1;
//           assert(_selectedCount >= 0);
//           dessert.selected = value;
//           notifyListeners();
//         }
//       },
//       cells: [
//         DataCell(Text(dessert.name)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.subtype)),
//         DataCell(Text('${dessert.rentalowenername}')),
//
//         DataCell(Text('${dessert.rentalowenername}')),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//         DataCell(Text(dessert.property)),
//       ],
//     );
//   }
//
//   // Number of rows in the DataTable
//   @override
//   int get rowCount => _desserts.length;
//   // Whether or not the rowCount is approximate
//   @override
//   bool get isRowCountApproximate => false;
//   // Number of selected rows
//   @override
//   int get selectedRowCount => _selectedCount;
//
//  // Select or deselect all rows
//   void _selectAll(bool? checked) {
//     for (final dessert in _desserts) {
//       dessert.selected = checked ?? false;
//     }
//     _selectedCount = checked! ? _desserts.length : 0;
//     notifyListeners();
//   }
// }
class PropertyTable extends StatefulWidget {
  @override
  _PropertyTableState createState() => _PropertyTableState();
}

class _PropertyTableState extends State<PropertyTable> {
  late Future<List<propertytype>> futurePropertyTypes;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> items = [
   'Residential',
    "Commercial",
    "All"
  ];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  }
  void handleEdit(propertytype property) {
    // Handle edit action
    print('Edit ${property.sId}');
  }
  void _sort<T>(Comparable<T> Function(propertytype) getField, int columnIndex, bool ascending) {
    futurePropertyTypes.then((propertyTypes) {
      propertyTypes.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
      });
      setState(() {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      });
    });
  }

  void handleDelete(propertytype property) {
    // Handle delete action
    print('Delete ${property.sId}');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(context,Icon(CupertinoIcons.circle_grid_3x3,color: Colors.black,), "Dashboard",false),
              buildListTile(context,Icon(CupertinoIcons.house,color: Colors.white,), "Add Property Type",true),
              buildListTile(context,Icon(CupertinoIcons.person_add), "Add Staff Member",false),
              buildDropdownListTile(context,
                  Icon(Icons.key), "Rental", ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(context,Icon(Icons.thumb_up_alt_outlined), "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(context,
                  Image.asset("assets/icons/maintence.png", height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<propertytype>>(
        future: futurePropertyTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            List<propertytype>? filteredData =[];
            if(selectedValue == null  && searchvalue == ""){
              filteredData = snapshot.data;
            }
            else if(selectedValue == "All"){
              filteredData = snapshot.data;
            }
            else if (searchvalue != null && searchvalue.isNotEmpty) {
              filteredData = snapshot.data!.where((property) =>
              property.propertyType!.toLowerCase().contains(searchvalue.toLowerCase()) ||
                  property.propertysubType!.toLowerCase().contains(searchvalue.toLowerCase())
              ).toList();
            }
            else  {
              filteredData = snapshot.data!.where((property) => property.propertyType == selectedValue).toList();
            }

            return SingleChildScrollView(
              child: Column(
                children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Add_property()));
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
                            onChanged: (value){
                              setState(() {
                                searchvalue = value;
                              });
                            },
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
                  SizedBox(width: 10),
                  DropdownButtonHideUnderline(
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
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
                        height: 50,
                        width: 160,
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black26,
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
                ],
              ),
                  SingleChildScrollView(
                    child: PaginatedDataTable(
                      sortAscending: sortAscending,
                      sortColumnIndex: sortColumnIndex,
                      rowsPerPage: rowsPerPage,
                      showEmptyRows: false,
                      columnSpacing: 15,
                      availableRowsPerPage: [5, 10, 15,20],
                      onRowsPerPageChanged: (value) {
                        setState(() {
                          rowsPerPage = value!;
                        });
                      },
                      columns: [
                        DataColumn(
                          label: Text('Main Type'),
                          onSort: (columnIndex, ascending) {
                            _sort<String>((property) => property.propertyType!, columnIndex, ascending);
                          },
                        ),
                        DataColumn(
                          label: Text('Subtype'),
                          onSort: (columnIndex, ascending) {
                            _sort<String>((property) => property.propertysubType!, columnIndex, ascending);
                          },
                        ),
                        DataColumn(label: Text('Created At')),
                        DataColumn(label: Text('Updated At')),
                        DataColumn(label: Text('Actions')),
              
                      ],
                      source: PropertyDataSource(filteredData!,
                        onEdit: handleEdit,
                        onDelete: handleDelete,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
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
    return DataRow.byIndex(index: index, cells: [

      DataCell(Text(property.propertyType ?? '')),
      DataCell(Text(property.propertysubType ?? '')),

      DataCell(Text(_formatDate(property.createdAt))),
      DataCell(Text(_formatDate(property.updatedAt))),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap:(){
    onEdit(property);
    },
            child: Container(
            //  color: Colors.redAccent,
              padding: EdgeInsets.zero,
              child: FaIcon(FontAwesomeIcons.edit,size: 20,),
            ),
          ),
          SizedBox(width: 4,),
          InkWell(
            onTap: (){
              onDelete(property);
            },
            child: Container(
          //    color: Colors.redAccent,
              padding: EdgeInsets.zero,
              child: FaIcon(FontAwesomeIcons.trashCan,size: 20,),
            ),
          ),

        ],
      )),
    ]);
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
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

}