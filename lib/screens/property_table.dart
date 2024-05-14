

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../widgets/drawer_tiles.dart';
import 'add_property.dart';

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

  final List<String> items = [
   'Residential',
    "Commercial",
    "All"
  ];
  String? selectedValue;
  @override
  void dispose() {
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    _dessertsDataSource.removeListener(_updateSelectedDessertRowListener);
    _dessertsDataSource.dispose();
    super.dispose();
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
                availableRowsPerPage: [3, 5, 10,15, 25],
                sortColumnIndex: _sortColumnIndex.value,
                sortAscending: _sortAscending.value,
                columnSpacing: 28,
                dataRowHeight: 45,
                headingRowHeight: 60,
                showEmptyRows: false,
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


class _DessertDataSource extends DataTableSource {
  _DessertDataSource(this.context) {
    _desserts = <_Dessert>[
      _Dessert(
        '2Clipercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '5jeggingscourt',
        'Recidential',
        'Single Family',
        '37',
      ),
      _Dessert(
        '36Clipercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '3willycourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '2williamcourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
      _Dessert(
        '28cartercourt',
        'Commercial',
        'combo',
        '24',
      ),
    ];
  }

  final BuildContext context;
  late List<_Dessert> _desserts;

  void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
    _desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= _desserts.length) return null;
    final dessert = _desserts[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(dessert.name)),
        DataCell(Text(dessert.property)),
        DataCell(Text(dessert.subtype)),
        DataCell(Text(dessert.rentalowenername)),
      ],
    );
  }

  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0; // No checkbox, so always returning 0
}



