import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../Model/propertytype.dart';
import '../../model/staffmember.dart';
import '../../repository/Property_type.dart';
import '../../repository/Staffmember.dart';
import '../../widgets/drawer_tiles.dart';
import '../Property_Type/Add_property_type.dart';
import 'Add_staffmember.dart';
import 'Edit_staff_member.dart';


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
class StaffTable extends StatefulWidget {
  @override
  _StaffTableState createState() => _StaffTableState();
}

class _StaffTableState extends State<StaffTable> {
  late Future<List<Staffmembers>> futureStaffMembers;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> roles = ['Manager', 'Employee', 'All'];
  String? selectedRole;
  String searchValue = "";

  @override
  void initState() {
    super.initState();
    futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
  }


  void handleEdit(Staffmembers staff) async {
    // Handle edit action
    print('Edit ${staff.sId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_staff_member(
              staff: staff,
            )));
    if (result == true) {
      setState(() {
        futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
      });
    }
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
              futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  void _sort<T>(Comparable<T> Function(Staffmembers) getField, int columnIndex, bool ascending) {
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

  void handleDelete(Staffmembers staff) {
    _showDeleteAlert(context, staff.staffmemberId!);
    // Handle delete action
    print('Delete ${staff.staffmemberId}');
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
              buildListTile(context,Icon(CupertinoIcons.circle_grid_3x3,color: Colors.black,), "Dashboard",false),
              buildListTile(context,Icon(CupertinoIcons.house,color: Colors.black,), "Add Property Type",false),
              buildListTile(context,Icon(CupertinoIcons.person_add,color: Colors.white,), "Add Staff Member",true),
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
                    onTap: () async {
                      final result = await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Add_staffmember()));
                      if (result == true) {
                        setState(() {
                          futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
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
                        child: Text(
                          "Add New Staff Member",
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
                    "Staff Members",
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
            FutureBuilder<List<Staffmembers>>(
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
                  List<Staffmembers>? filteredData = [];
                  if (selectedRole == null && searchValue == "") {
                    filteredData = snapshot.data;
                  } else if (selectedRole == "All") {
                    filteredData = snapshot.data;
                  } else if (searchValue.isNotEmpty) {
                    filteredData = snapshot.data!
                        .where((staff) =>
                    staff.staffmemberName!.toLowerCase().contains(searchValue.toLowerCase()) ||
                        staff.staffmemberDesignation!.toLowerCase().contains(searchValue.toLowerCase()))
                        .toList();
                  } else {
                    filteredData = snapshot.data!
                        .where((staff) => staff.staffmemberDesignation == selectedRole)
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
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  dataTableTheme: DataTableThemeData(
                                    dataRowColor: MaterialStateProperty.all(Colors.transparent),
                                    headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                    dividerThickness: 0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: PaginatedDataTable(
                                      sortAscending: sortAscending,
                                      sortColumnIndex: sortColumnIndex,
                                      rowsPerPage: rowsPerPage,
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
                                            'Name',
                                            style: TextStyle(
                                              color: Color.fromRGBO(21, 43, 81, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            _sort<String>(
                                                    (staff) => staff.staffmemberName!,
                                                columnIndex,
                                                ascending);
                                          },
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Role',
                                            style: TextStyle(
                                                color: Color.fromRGBO(21, 43, 81, 1),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            _sort<String>(
                                                    (staff) => staff.staffmemberDesignation!,
                                                columnIndex,
                                                ascending);
                                          },
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Email',
                                            style: TextStyle(
                                              color: Color.fromRGBO(21, 43, 81, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Phone',
                                            style: TextStyle(
                                              color: Color.fromRGBO(21, 43, 81, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Actions',
                                            style: TextStyle(
                                              color: Color.fromRGBO(21, 43, 81, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      source: StaffDataSource(
                                        filteredData!,
                                        onEdit: handleEdit,
                                        onDelete: handleDelete,
                                      ),
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
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: StaffTable()));

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
class StaffDataSource extends DataTableSource {
  final List<Staffmembers> staffMembers;
  final Function(Staffmembers) onEdit;
  final Function(Staffmembers) onDelete;

  StaffDataSource(this.staffMembers, {required this.onEdit, required this.onDelete});

  @override
  DataRow getRow(int index) {
    final staff = staffMembers[index];
    return DataRow(cells: [
      DataCell(Text(staff.staffmemberName!)),
      DataCell(Text(staff.staffmemberDesignation!)),
      DataCell(Text(staff.staffmemberEmail!)),
      DataCell(Text(staff.staffmemberPhoneNumber.toString()!)),
      DataCell(Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => onEdit(staff),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onDelete(staff),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => staffMembers.length;

  @override
  int get selectedRowCount => 0;
}
