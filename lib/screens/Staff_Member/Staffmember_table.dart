import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../widgets/drawer_tiles.dart';
import 'Add_staffmember.dart';
import 'Staffmemvertable.dart';

class Staffmember_table extends StatefulWidget {
  const Staffmember_table({super.key});

  @override
  State<Staffmember_table> createState() => _Staffmember_tableState();
}

class _RestorableDessertSelections extends RestorableProperty<Set<int>> {
  // The set of indices of selected dessert rows
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [_Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setDataSelections(List<_Details> desserts) {
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

class _Staffmember_tableState extends State<Staffmember_table>
    with RestorationMixin {
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage =
      RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);

  late _DataSource _dataSource;
  // _DessertDataSource? _dessertsDataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = _DataSource(context);
  }

  @override
  String get restorationId => 'data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    _dataSource ??= _DataSource(context);

    switch (_sortColumnIndex.value) {
      case 0:
        _dataSource._sort<String>((d) => d.name, _sortAscending.value);
        break;
      case 1:
        _dataSource._sort<String>((d) => d.designation, _sortAscending.value);
        break;
      case 2:
        _dataSource._sort<String>((d) => d.contact, _sortAscending.value);
        break;
      case 3:
        _dataSource._sort<String>((d) => d.email, _sortAscending.value);
        break;
    }
    _dataSource.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataSource ??= _DataSource(context);
    _dataSource.addListener(_updateSelectedDessertRowListener);
  }

  void _updateSelectedDessertRowListener() {
    // Example: Get the selected row index
    int? selectedRowIndex = _dataSource.selectedRowCount;

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
    Comparable<T> Function(_Details d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dataSource._sort<T>(getField, ascending);
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
    _dataSource.removeListener(_updateSelectedDessertRowListener);
    _dataSource.dispose();
    super.dispose();
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String? selectedOption;
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
                    color: Colors.white,
                  ),
                  "Add Staff Member",
                  true),
              buildDropdownListTile(context, Icon(Icons.key), "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(context, Icon(Icons.thumb_up_alt_outlined),
                  "Leasing", ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
              buildListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.letterboxd,
                    color: Colors.white,
                  ),
                  "Reports",
                  true),
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
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StaffTable()));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.034,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add Staff Member",
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
                    "Staff Member",
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
            SizedBox(height: 20),
            Theme(
              data: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                cardTheme: CardTheme(
                  // Apply custom style to the Card wrapping the DataTable
                  shape: RoundedRectangleBorder(
                    // Remove border radius
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
                    label: Text('Name',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((d) => d.name, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Designation',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (d) => d.designation, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Contact',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((d) => d.contact, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Mail ID',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold)),
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((d) => d.email, columnIndex, ascending),
                  ),
                ],
                source: _dataSource,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Details {
  _Details(
    this.name,
    this.designation,
    this.contact,
    this.email,
  );

  final String name;
  final String designation;
  final String contact;
  final String email;
  bool selected = false;
}

class _DataSource extends DataTableSource {
  _DataSource(this.context) {
    _details = <_Details>[
      _Details('John Doe', 'Manager', '1234567890', 'john@example.com'),
      _Details('Jane Smith', 'Supervisor', '9876543210', 'jane@example.com'),
    ];
  }

  final BuildContext context;
  late List<_Details> _details;
  void addStaffMember(_Details newStaffMember) {
    _details.add(newStaffMember);
    notifyListeners();
  }

  void _sort<T>(Comparable<T> Function(_Details d) getField, bool ascending) {
    _details.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= _details.length) return null;
    final staffMember = _details[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(staffMember.name)),
        DataCell(Text(staffMember.designation)),
        DataCell(Text(staffMember.contact)),
        DataCell(Text(staffMember.email)),
      ],
    );
  }

  @override
  int get rowCount => _details.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0; // No checkbox, so always returning 0
}
