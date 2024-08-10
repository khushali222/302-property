import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/unit.dart';
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/unitsummery_propeties.dart';
import '../../../provider/property_summery.dart';
import '../../../repository/properties_summery.dart';
import '../../../repository/unit_data.dart';

// void main() {
//   runApp(const MaterialApp(home: unitScreen()));
// }

class unitScreen extends StatefulWidget {
  Rentals? properties;
  unit_properties? unit;
  unitScreen(BuildContext context, {
    super.key,
    this.properties,
    this.unit,
  });

  @override
  State<unitScreen> createState() => _unitScreenState();
}

class _unitScreenState extends State<unitScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body:
      SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                //height: screenHeight * 0.82,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromRGBO(21, 43, 83, 1),
                    width: 1,
                  ),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 36,
                            width: 76,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(21, 43, 83, 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 36,
                            width: 126,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(21, 43, 83, 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0))),
                              onPressed: () {},
                              child: const Text(
                                'Delete unit',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: screenHeight * 0.30,
                      width: screenWidth * 0.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: const Image(
                          image: NetworkImage(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRe_jcaXNfnjMStYxu0ScZHngqxm-cTA9lJbB9DrbhxHQ6G-aAvZFZFu9-xSz31R5gKgjM&usqp=CAU'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                'ADDRESS',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${widget.properties?.rentalAddress}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        // height: screenHeight * 0.26,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Add Lease',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 36,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                  //  Navigator.push(context, MaterialPageRoute(builder: (context)=>addLease3()));
                                  },
                                  child: const Text(
                                    'Add Lease',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Rental Applicant',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                ),
                              ),
                            ),
                          /*  Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 36,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AddApplicant()));
                                  },
                                  child: const Text(
                                    'Create Applicant',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
             LeasesTable(unit:widget.unit),
            AppliancesPart(unit:widget.unit,),
          ],
        ),
      ),
    );
  }
}

class LeasesTable extends StatefulWidget {
  unit_properties? unit;
  LeasesTable({
    super.key,
    this.unit,
  });
  //LeasesTable({Key? key}) : super(key: key);

  @override
  State<LeasesTable> createState() => _LeasesTableState();
}

class _LeasesTableState extends State<LeasesTable> {
  final UnitData leaseRepository = UnitData();

  List<unit_lease> leases = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchLeases();
    futureLease = UnitData().fetchUnitLeases(widget.unit?.unitId ??"");
  }

  Future<void> fetchLeases() async {
    //  try {
    final fetchedLeases =
        await leaseRepository.fetchUnitLeases(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      leases = fetchedLeases;
      isLoading = false;
    });
    //} catch (e) {
    setState(() {
      isLoading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }

  String getStatus(String startDate, String endDate) {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return (now.isAfter(start) && now.isBefore(end)) ? 'Active' : 'Inactive';
  }

  //for table

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(unit_lease d)? getField) {
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

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16,bottom: 20),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCell(unit_lease data) {
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

  //

  List<unit_lease> _tableData = [];
  int totalrecords = 0;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<unit_lease> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(unit_lease d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);

        int result;
        if (aValue is String && bValue is String) {
          result = aValue
              .toString()
              .toLowerCase()
              .compareTo(bValue.toString().toLowerCase());
        } else {
          result = aValue.compareTo(bValue as T);
        }

        return _sortAscending ? result : -result;
      });
    });
  }

  void handleEdit(unit_lease rentalOwner) async {
    // Handle edit action
    // print('Edit ${rentalOwner.rentalownerId}');
    // var check = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_rentalowners(
    //           rentalOwner: rentalOwner,
    //         )));
    // if (check == true) {
    //   setState(() {});
    // }
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_rentalowners(rentalOwner: rentalOwner,)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this RentalOwner!",
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
            //  await RentalOwnerService().DeleteRentalOwners(rentalownerId: id);
            setState(() {
              // futureRentalOwners = RentalOwnerService().fetchRentalOwners("");
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  void handleDelete(unit_lease rental) {
    _showDeleteAlert(context, rental.leaseId!);
    // Handle delete action
    print('Delete ${rental.leaseId}');
  }

  late Future<List<unit_lease>> futureLease;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> roles = ['Manager', 'Employee', 'All'];
  String? selectedRole;
  String searchValue = "";
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
                    width < 400
                        ? Text("Status", style: TextStyle(color: Colors.white))
                        : Text("Status", style: TextStyle(color: Colors.white)),
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
                      padding: const EdgeInsets.only(bottom: 7, left: 5),
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
                    Text("Tenants", style: TextStyle(color: Colors.white)),
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
                    Text("   Type", style: TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Leases',
                style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(21, 43, 83, 1),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          if (MediaQuery.of(context).size.width < 500)
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
              child: FutureBuilder<List<unit_lease>>(
                future: futureLease,
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
                    return Center(child: Text('You don\'t have any lease for this unit right now ..'));
                  } else {
                    var data = snapshot.data!;
                    // if (searchValue == null || searchValue!.isEmpty) {
                    //   data = snapshot.data!;
                    // } else if (searchValue == "All") {
                    //   data = snapshot.data!;
                    // } else if (searchValue!.isNotEmpty) {
                    //   data = snapshot.data!
                    //       .where((rentals) => rentals.!
                    //       .toLowerCase()
                    //       .contains(searchValue!.toLowerCase()))
                    //       .toList();
                    // } else {
                    //   data = snapshot.data!
                    //       .where((rentals) =>
                    //   rentals.applianceName == searchValue)
                    //       .toList();
                    // }
                    // sortData(data);
                    final totalPages = (data.length / itemsPerPage).ceil();
                    final currentPageData = data
                        .skip(currentPage * itemsPerPage)
                        .take(itemsPerPage)
                        .toList();
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          _buildHeaders(),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: blueColor)),
                            child: Column(
                              children: currentPageData
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                bool isExpanded = expandedIndex == index;
                                unit_lease rentals = entry.value;
                                //return CustomExpansionTile(data: Propertytype, index: index);
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: blueColor),
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
                                                  margin: EdgeInsets.only(
                                                      left: 5),
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
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (context) =>
                                                    //             Rentalowners_summery(
                                                    //               rentalOwnersid: rentals.rentalownerId!,)));
                                                  },
                                                  child: Text((getStatus(
                                                      rentals.startDate!, rentals.endDate!)),

                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      .08),
                                              Expanded(
                                                child: Text(
                                                  '${rentals.tenantFirstName} ${rentals.tenantLastName}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      .08),
                                              Expanded(
                                                child: Text(
                                                  '${rentals.leaseType}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      .02),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isExpanded)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
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
                                                          ? FontAwesomeIcons
                                                          .sortUp
                                                          : FontAwesomeIcons
                                                          .sortDown,
                                                      size: 50,
                                                      color:
                                                      Colors.transparent,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                  'Start-End : ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      color:
                                                                      blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                  '${rentals.startDate} - ${rentals.endDate}',
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
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                context)
                                                                .size
                                                                .height *
                                                                .01,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                  'Rent : ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      color:
                                                                      blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                  '${rentals.amount}',
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
            FutureBuilder<List<unit_lease>>(
              future: futureLease,
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
                  return Center(child: Text('You don\'t have any lease for this unit right now ..'));
                } else {
                  List<unit_lease>? filteredData = [];
                  _tableData = snapshot.data!;
                  if (selectedRole == null && searchValue == "") {
                    filteredData = snapshot.data;
                  } else if (selectedRole == "All") {
                    filteredData = snapshot.data;
                  } else if (searchValue.isNotEmpty) {
                    filteredData = snapshot.data!
                        .where((staff) =>
                    staff.tenantFirstName!
                        .toLowerCase()
                        .contains(searchValue.toLowerCase()) ||
                        staff.leaseType!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()))
                        .toList();
                  }

                  _tableData = filteredData!;
                  totalrecords = _tableData.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0,),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: MediaQuery.of(context).size.width * .91,
                            child: Table(
                              defaultColumnWidth: IntrinsicColumnWidth(),
                              children: [
                                TableRow(
                                  decoration:
                                  BoxDecoration(border: Border.all()),
                                  children: [
                                    // TableCell(child: Text('yash')),
                                    // TableCell(child: Text('yash')),
                                    // TableCell(child: Text('yash')),
                                    // TableCell(child: Text('yash')),
                                    _buildHeader('Status', 0,
                                            (rental) => rental.startDate!),
                                    _buildHeader(
                                        'Start-End',
                                        1,
                                            (rental) =>
                                        rental.endDate!),
                                    _buildHeader(
                                        'Tenant',
                                        2,
                                            (rental) =>
                                        rental.tenantFirstName!),
                                    _buildHeader(
                                        'Type',
                                        3,
                                            (rental) =>
                                        rental.leaseType!),
                                    _buildHeader(
                                        'Type',
                                        4,
                                            (rental) =>
                                        rental.amount!),

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
                                        (getStatus(
                                            _pagedData[i].startDate!, _pagedData[i].endDate!)),
                                      ),
                                      // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                      _buildDataCell(
                                          '${_pagedData[i].startDate} - ${_pagedData[i].endDate}'),
                                      _buildDataCell(
                                          '${_pagedData[i].tenantFirstName} - ${_pagedData[i].tenantLastName}'
                                      ),
                                      _buildDataCell(
                                          '${_pagedData[i].leaseType}'
                                      ),
                                      _buildDataCell(
                                          '${_pagedData[i].amount}'
                                      ),

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
    );
  }
}

class Lease {
  final String status;
  final String startEndDate;
  final String tenant;
  final String type;
  final String rent;

  Lease({
    required this.status,
    required this.startEndDate,
    required this.tenant,
    required this.type,
    required this.rent,
  });
}

List<Lease> leases = [
  Lease(
    status: 'Active',
    startEndDate: '05-15-2024-06-15-2024',
    tenant: 'Alex Wilkins',
    type: 'Fixed',
    rent: '30',
  ),
  Lease(
    status: 'Active',
    startEndDate: '05-15-2024-06-15-2024',
    tenant: 'Alex Wilkins',
    type: 'Fixed',
    rent: '30',
  ),
  // Add more leases as needed
];

class AppliancesPart extends StatefulWidget {
  Rentals? properties;
  unit_properties? unit;

  AppliancesPart({
    this.unit,this.properties ,
});
  @override
  _AppliancesPartState createState() => _AppliancesPartState();
}

class _AppliancesPartState extends State<AppliancesPart> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _installedDate = TextEditingController();
  final UnitData leaseRepository = UnitData();
  List<unit_appliance> leases = [];

  bool isLoading = false;  Future<void> fetchLeases() async {
    //  try {
    final fetchedLeases =
    await leaseRepository.fetchApplianceData(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      leases = fetchedLeases;
      isLoading = false;
    });
    //} catch (e) {
    setState(() {
      isLoading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLeases();
    futureAppliences = UnitData().fetchApplianceData(widget.unit?.unitId ?? "");
  }
  reload_screen(){
    setState(() {
    });
  }
  DateTime? _selectedDate;
  //bool isLoading = false;
  bool iserror = false;

  //fortable

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(unit_appliance d)? getField) {
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

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCell(unit_appliance data) {
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

  //

  List<unit_appliance> _tableData = [];
  int totalrecords = 0;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<unit_appliance> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(unit_appliance d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);

        int result;
        if (aValue is String && bValue is String) {
          result = aValue
              .toString()
              .toLowerCase()
              .compareTo(bValue.toString().toLowerCase());
        } else {
          result = aValue.compareTo(bValue as T);
        }

        return _sortAscending ? result : -result;
      });
    });
  }

  void handleEdit(unit_appliance rentalOwner) async {
    // Handle edit action
    // print('Edit ${rentalOwner.rentalownerId}');
    // var check = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_rentalowners(
    //           rentalOwner: rentalOwner,
    //         )));
    // if (check == true) {
    //   setState(() {});
    // }
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_rentalowners(rentalOwner: rentalOwner,)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this RentalOwner!",
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
            //  await RentalOwnerService().DeleteRentalOwners(rentalownerId: id);
            setState(() {
              // futureRentalOwners = RentalOwnerService().fetchRentalOwners("");
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  void handleDelete(unit_appliance rental) {
    _showDeleteAlert(context, rental.applianceId!);
    // Handle delete action
    print('Delete ${rental.applianceId}');
  }



  late Future<List<unit_appliance>> futureAppliences;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> roles = ['Manager', 'Employee', 'All'];
  String? selectedRole;
  String searchValue = "";
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

  void sortData(List<unit_appliance> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.applianceName!.compareTo(b.applianceName!)
          : b.applianceName!.compareTo(a.applianceName!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.applianceDescription!.compareTo(b.applianceDescription!)
          : b.applianceDescription!.compareTo(a.applianceDescription!));
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
                    width < 400
                        ? Text("Name", style: TextStyle(color: Colors.white))
                        : Text("Name", style: TextStyle(color: Colors.white)),
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
                    Text("Description", style: TextStyle(color: Colors.white)),
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
                    Text("   Action", style: TextStyle(color: Colors.white)),
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
  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Appliances',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(21, 43, 83, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return
                                    AlertDialog(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      title: const Text('Add Appliances'),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomTextFormField(
                                              labelText: 'Name',
                                              hintText: 'Enter Name',
                                              keyboardType: TextInputType.text,
                                              controller: _name,
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty) {
                                              //     return 'Please enter name';
                                              //   }
                                              //   return null;
                                              // },
                                            ),
                                            CustomTextFormField(
                                              labelText: 'Description',
                                              hintText: 'Enter description',
                                              keyboardType: TextInputType.text,
                                              controller: _description,
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty) {
                                              //     return 'Please enter description';
                                              //   }
                                              //   return null;
                                              // },
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2100),
                                            builder: (BuildContext context, Widget? child) {
                                              return Theme(
                                                data: ThemeData.light().copyWith(
                                                  // primaryColor: Color.fromRGBO(21, 43, 83, 1),
                                                  //  hintColor: Color.fromRGBO(21, 43, 83, 1),
                                                  colorScheme: ColorScheme.light(
                                                    primary: Color.fromRGBO(21, 43, 83, 1),
                                                    // onPrimary:Color.fromRGBO(21, 43, 83, 1),
                                                    //  surface: Color.fromRGBO(21, 43, 83, 1),
                                                    onSurface: Colors.black,
                                                  ),
                                                  buttonTheme: ButtonThemeData(
                                                    textTheme: ButtonTextTheme.primary,
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                                ).then((date) {
                                                  if (date != null) {
                                                    setState(() {
                                                      _selectedDate = date;
                                                      _installedDate.text =
                                                          formatDate(date.toString());
                                                    });
                                                  }
                                                });
                                              },
                                              child: AbsorbPointer(
                                                child: CustomTextFormField(
                                                  labelText: 'Date',
                                                  hintText: 'Select Date',
                                                  keyboardType: TextInputType.datetime,
                                                  controller: _installedDate,
                                                  // validator: (value) {
                                                  //   if (value == null ||
                                                  //       value.isEmpty) {
                                                  //     return 'Please select date';
                                                  //   }
                                                  //   return null;
                                                  // },
                                                ),
                                              ),
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: 42,
                                                    width: 80,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                          const Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  8.0))),
                                                      // onPressed: () async {
                                                      //   if (_formKey.currentState?.validate() ?? false) {
                                                      //     setState(() {
                                                      //       isLoading = true;
                                                      //       iserror = false;
                                                      //     });
                                                      //     SharedPreferences prefs = await SharedPreferences.getInstance();
                                                      //     String? id = prefs.getString("adminId");
                                                      //
                                                      //     Properies_summery_Repo()
                                                      //         .addappliances(
                                                      //       appliancename: _name.text,
                                                      //       appliancedescription: _description.text,
                                                      //       installeddate: _installedDate.text,
                                                      //     )
                                                      //         .then((value) {
                                                      //       setState(() {
                                                      //         isLoading = false;
                                                      //       });
                                                      //       Navigator.pop(context, true);
                                                      //     })
                                                      //         .catchError((e) {
                                                      //       setState(() {
                                                      //         isLoading = false;
                                                      //       });
                                                      //     });
                                                      //   } else {
                                                      //     setState(() {
                                                      //       iserror = true;
                                                      //     });
                                                      //   }
                                                      // },
                                                      onPressed: () async {
                                                        if (_name.text.isEmpty || _description.text.isEmpty || _installedDate.text.isEmpty ) {
                                                          setState(() {
                                                            iserror = true;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            isLoading = true;
                                                            iserror = false;
                                                          });
                                                          SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                          String? id = prefs.getString("adminId");
                                                          print("calling");
                                                          Properies_summery_Repo()
                                                              .addappliances(
                                                            adminId: id,
                                                            unitId: widget.unit?.unitId,
                                                            appliancename: _name.text,
                                                            appliancedescription: _description.text,
                                                            installeddate: _installedDate.text,
                                                          ).then((value) {
                                                            print(widget.properties?.adminId);
                                                            print(widget.unit?.unitId);
                                                            setState(() {
                                                              isLoading = false;
                                                              leases.add(
                                                                unit_appliance(
                                                                  applianceName:_name.text,
                                                                  applianceDescription: _description.text,
                                                                  installedDate: _installedDate.text,
                                                                  adminId: id,
                                                                  unitId: widget.unit?.unitId,
                                                                )
                                                              );
                                                            });
                                                            reload_screen();

                                                            Navigator.pop(context,true);
                                                          }).catchError((e) {
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          });
                                                        }

                                                      },
                                                      child: const Text(
                                                        'Save',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.25),
                                                          spreadRadius: 0,
                                                          blurRadius: 15,
                                                          offset: const Offset(0.5,
                                                              0.5), // Shadow moved to the right and bottom
                                                        )
                                                      ],
                                                    ),
                                                    height: 40,
                                                    width: 70,
                                                    child: Center(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Cancel'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if(iserror)
                                              Text(
                                                "Please fill in all fields correctly.",
                                                style: TextStyle(color: Colors.redAccent),
                                              )
                                          ],
                                        ),
                                      ),
                                    );
                                },
                              );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                            width: 1,
                          ),
                        ),
                        height: 40,
                        width: 70,
                        child: const Center(
                          child: Text('Add'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              if (MediaQuery.of(context).size.width < 500)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder<List<unit_appliance>>(
                    future: futureAppliences,
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
                        return Center(child: Text('You don\'t have any applience for this unit right now ..'));
                      } else {
                        var data = snapshot.data!;
                        if (searchValue == null || searchValue!.isEmpty) {
                          data = snapshot.data!;
                        } else if (searchValue == "All") {
                          data = snapshot.data!;
                        } else if (searchValue!.isNotEmpty) {
                          data = snapshot.data!
                              .where((rentals) => rentals.applianceName!
                              .toLowerCase()
                              .contains(searchValue!.toLowerCase()))
                              .toList();
                        } else {
                          data = snapshot.data!
                              .where((rentals) =>
                          rentals.applianceName == searchValue)
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
                              SizedBox(height: 5),
                              _buildHeaders(),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: blueColor)),
                                child: Column(
                                  children: currentPageData
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    bool isExpanded = expandedIndex == index;
                                    unit_appliance rentals = entry.value;
                                    //return CustomExpansionTile(data: Propertytype, index: index);
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: blueColor),
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
                                                      margin: EdgeInsets.only(
                                                          left: 5),
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
                                                        // Navigator.push(
                                                        //     context,
                                                        //     MaterialPageRoute(
                                                        //         builder: (context) =>
                                                        //             Rentalowners_summery(
                                                        //               rentalOwnersid: rentals.rentalownerId!,)));
                                                      },
                                                      child: Text(
                                                        '   ${rentals.applianceName}',
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .08),
                                                  Expanded(
                                                    child: Text(
                                                      '${rentals.applianceDescription}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .08),
                                                  Expanded(
                                                    child: Container(
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          InkWell(
                                                            onTap: () async {
                                                              // var check = await Navigator
                                                              //     .push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //         builder: (context) =>
                                                              //             Edit_rentalowners(
                                                              //               rentalOwner: rentals,
                                                              //             )));
                                                              // if (check == true) {
                                                              //   setState(() {});
                                                              // }
                                                            },
                                                            child: Container(
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .edit,
                                                                size: 20,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              _showDeleteAlert(
                                                                  context,
                                                                  rentals
                                                                      .applianceId!);
                                                            },
                                                            child: Container(
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .trashCan,
                                                                size: 20,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .02),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isExpanded)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
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
                                                              ? FontAwesomeIcons
                                                              .sortUp
                                                              : FontAwesomeIcons
                                                              .sortDown,
                                                          size: 50,
                                                          color:
                                                          Colors.transparent,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                      'Install Date: ',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          color:
                                                                          blueColor), // Bold and black
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                      formatDate('${rentals.installedDate}'),
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
                                                              SizedBox(
                                                                height: MediaQuery.of(
                                                                    context)
                                                                    .size
                                                                    .height *
                                                                    .01,
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
                FutureBuilder<List<unit_appliance>>(
                  future: futureAppliences,
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
                      return Center(child: Text('You don\'t have any applience for this unit right now ..'));
                    } else {
                      List<unit_appliance>? filteredData = [];
                      _tableData = snapshot.data!;
                      if (selectedRole == null && searchValue == "") {
                        filteredData = snapshot.data;
                      } else if (selectedRole == "All") {
                        filteredData = snapshot.data;
                      } else if (searchValue.isNotEmpty) {
                        filteredData = snapshot.data!
                            .where((staff) =>
                        staff.applianceName!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                            staff.applianceDescription!
                                .toLowerCase()
                                .contains(searchValue.toLowerCase()))
                            .toList();
                      }

                      _tableData = filteredData!;
                      totalrecords = _tableData.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                width: MediaQuery.of(context).size.width * .91,
                                child: Table(
                                  defaultColumnWidth: IntrinsicColumnWidth(),
                                  children: [
                                    TableRow(
                                      decoration:
                                      BoxDecoration(border: Border.all()),
                                      children: [
                                        // TableCell(child: Text('yash')),
                                        // TableCell(child: Text('yash')),
                                        // TableCell(child: Text('yash')),
                                        // TableCell(child: Text('yash')),
                                        _buildHeader('Name', 0,
                                                (rental) => rental.applianceName!),
                                        _buildHeader(
                                            'Description',
                                            1,
                                                (rental) =>
                                            rental.applianceDescription!),
                                        _buildHeader(
                                            'InstalledDate',
                                            2,
                                                (rental) =>
                                            rental.installedDate!),
                                        _buildHeader('Actions', 3, null),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal: BorderSide.none),
                                      ),
                                      children: List.generate(
                                          4,
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
                                              _pagedData[i].applianceName!),
                                          // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                          _buildDataCell(
                                              _pagedData[i]
                                                  .applianceDescription!),
                                          _buildDataCell(
                                              formatDate(_pagedData[i]
                                                  .installedDate!)),
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
      ),
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  //final FormFieldValidator<String> validator;

  CustomTextFormField({
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
    // required this.validator,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: widget.controller,
        //validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        style: const TextStyle(fontSize: 16.0),
        keyboardType: widget.keyboardType,
        autofocus: _isFocused,
      ),
    );
  }
}
