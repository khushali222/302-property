import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/screen/RentalRoll/newAddLease.dart';
import 'package:three_zero_two_property/provider/property_summery.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/unit.dart';
import '../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/rental_widget.dart';

import '../../../Model/unit.dart';
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/properties_workorders.dart';
import '../../../model/unitsummery_propeties.dart';
import '../../../model/workordr.dart';
import '../../../provider/properties_workorders.dart';
import '../../repository/properties.dart';
import '../../repository/properties_summery.dart';
import 'package:http/http.dart' as http;

import '../../repository/unit_data.dart';
import '../../../repository/workorder.dart';
import '../../../widgets/drawer_tiles.dart';

import '../../widgets/custom_drawer.dart';
class Summery_page extends StatefulWidget {
  Rentals properties;
  TenantData? tenants;
  unit_properties? unit;

  //RentalSummary? tenantsummery;
  Summery_page({super.key, required this.properties, this.tenants, this.unit});
  @override
  _Summery_pageState createState() => _Summery_pageState();
}

class _Summery_pageState extends State<Summery_page>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late Future<List<TenantData>> futurePropertysummery;

  late Future<List<unit_properties>> futureUnitsummery;
  late Future<List<Rentals>> futurerentalowners;

  //late Future<List<RentalSummary>> futuresummery;

  unit_properties? unit;
  DateTime? startdate;
  DateTime? enddate;
  int unitCount = 0;
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  TextEditingController unitnum = TextEditingController();
  TextEditingController street3 = TextEditingController();
  TextEditingController sqft3 = TextEditingController();
  TextEditingController bath3 = TextEditingController();
  TextEditingController bed3 = TextEditingController();

  bool isLoading = false;
  bool iserror = false;
  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startdate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startdate) {
      setState(() {
        startdate = picked;
        startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this Tenants!",
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
            var data = Properies_summery_Repo()
                .Deleteunit(unitId: id);
            // Add your delete logic here
            setState(() {
              futureUnitsummery = Properies_summery_Repo()
                  .fetchunit(widget.properties.rentalId!);
              showdetails = false;
            });
           /* await TenantsRepository().deleteTenant(
                tenantId: id, companyName: companyName, tenantEmail: '');
            setState(() {
              futureTenants = TenantsRepository().fetchTenants();
            });*/
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }
  Future<void> _endDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: enddate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != enddate) {
      setState(() {
        enddate = picked;
        enddateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureUnitsummery =
        Properies_summery_Repo().fetchunit(widget.properties.rentalId!);

    futurePropertysummery = Properies_summery_Repo()
        .fetchPropertiessummery(widget.properties.rentalId!);
    futureworkordersummery =
        Properies_summery_Repo().fetchWorkOrders(widget.properties.rentalId!);
    // futuresummery = Properies_summery_Repo().fetchPropertiessummery(widget.properties.rentalId!);
    _tabController = TabController(length: 4, vsync: this);
    // street3.text = widget.unit!.rentalunitadress!;
    _fetchData();

    futurerentalowners = PropertiesRepository().fetchProperties();

    // fetchunits1();
    //fetchLeases();
    // fetchAndSetCounts(context);
    //workorder
    // fetchAndSetCounts(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<Map<String, dynamic>> fetchDataOfCountWork(String rentalId) async {
    final response = await http
        .get(Uri.parse('$Api_url/api/work-order/rental_workorder/$rentalId'));

    if (response.statusCode == 200) {
      // Parse the response body
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        "count": data['count'] ?? 0,
        "complete_count": data['complete_count'] ?? 0,
      };
    } else {
      throw Exception('Failed to load count data');
    }
  }

  Future<void> fetchAndSetCounts(BuildContext context) async {
    try {
      final data = await fetchDataOfCountWork(widget.properties.rentalId!);
      int newCount = data['count'] ?? 0;
      int newCompleteCount = data['complete_count'] ?? 0;
      print(newCompleteCount);
      print(newCount);
      final provider =
          Provider.of<WorkOrderCountProvider>(context, listen: false);
      provider.updateCount(newCount);
      provider.updateCompleteCount(newCompleteCount);
    } catch (error) {
      print('Error fetching counts: $error');
    }
  }

  File? _image;
  List<File> _images = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        _images.add(File(image.path));
      });
      _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? fileName = await uploadImage(imageFile);
      setState(() {
        _uploadedFileNames.add(fileName!);
        _uploadedFileName = fileName;
      });
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  bool showdetails = false;
  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  List<List<Widget>> propertyGroups = [];
//  List<List<TextEditingController>> propertyGroupControllers = [];
  List<File?> propertyGroupImages = [];
  List<String?> propertyGroupImagenames = [];
  Widget customTextField(String label, TextEditingController Controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: TextFormField(
        controller: Controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: label,
          // labelText: label,
          // labelStyle: TextStyle(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: Color(0xFF8A95A8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }

  final Properies_summery_Repo unitRepository = Properies_summery_Repo();
  //int unitCount = 0;
  int tenentCount = 0;
  int count = 0;
  int complete_count = 0;

  Future<void> _fetchData() async {
    try {
      final data = await unitRepository.fetchunit(widget.properties.rentalId!);
      final data1 = await Properies_summery_Repo()
          .fetchPropertiessummery(widget.properties.rentalId!);
      final data2 = await Properies_summery_Repo()
          .fetchWorkOrders(widget.properties.rentalId!);
      setState(() {
        unitCount = data.length;
        tenentCount = data1.length;
        count = data2.length;
        complete_count = data2.length;
      });
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  List<unit_properties> data = [];
  final Properies_summery_Repo unit1Repository = Properies_summery_Repo();
  Future<void> fetchunits1() async {
    //  try {
    final fetchedunit1 = await unit1Repository.fetchunit(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      data = fetchedunit1;
      isLoading = false;
    });
    //} catch (e) {
    setState(() {
      isLoading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }

  //lease table

  final UnitData leaseRepository = UnitData();

  List<unit_lease> leases = [];

  bool isloading = true;

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
      isloading = false;
    });
    //} catch (e) {
    setState(() {
      isloading = false;
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

  //work order
  int totalrecords = 0;
  late Future<List<propertiesworkData>> futureworkordersummery;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  void sortData(List<propertiesworkData> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.workSubject!.compareTo(b.workSubject!)
          : b.workSubject!.compareTo(a.workSubject!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.workSubject!.compareTo(b.workSubject!)
          : b.workSubject!.compareTo(a.workSubject!));
    }
  }

  int? expandedIndex;
  Set<int> expandedIndices = {};
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;
  bool isChecked = false;
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
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
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
                        ? Text("Work Order ",
                            style: TextStyle(color: Colors.white))
                        : Text("Work Order",
                            style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 1),
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
                    Text("   Status", style: TextStyle(color: Colors.white)),
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
                    Text("   Billable ", style: TextStyle(color: Colors.white)),
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

  final List<String> items = [
    'New',
    "In Progress",
    "On Hold",
    "Completed",
    "Over Due",
    "All"
  ];
  String? selectedValue;
  String searchvalue = "";
  List<propertiesworkData> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<propertiesworkData> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(propertiesworkData d) getField,
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

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(propertiesworkData d)? getField) {
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

  Widget _buildDataCellBillable(bool isBillable) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isBillable) Icon(Icons.check, color: blueColor),
            if (!isBillable) Icon(Icons.close, color: blueColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int numorpages = 1;
    numorpages = (totalrecordsmulti / _rowsPerPage).ceil();

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
                items: [10, 25, 50, 100].map((int value) {
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
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
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

  //for multiunit table

  int totalrecordsmulti = 0;

  int rowsPerPagemulti = 5;
  int sortColumnIndexmulti = 0;
  bool sortAscendingmulti = true;
  int currentPagemulti = 0;
  int itemsPerPagemulti = 10;
  List<int> itemsPerPageOptionsmulti = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  void sortDatamulti(List<unit_properties> data) {
    if (sorting1multi) {
      data.sort((a, b) => ascending1multi
          ? a.rentalunit!.compareTo(b.rentalunit!)
          : b.rentalunit!.compareTo(a.rentalunit!));
    } else if (sorting2multi) {
      data.sort((a, b) => ascending2multi
          ? a.rentalunitadress!.compareTo(b.rentalunitadress!)
          : b.rentalunitadress!.compareTo(a.rentalunitadress!));
    } else if (sorting3multi) {
      data.sort((a, b) => ascending3multi
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }
  }

  int? expandedIndexmulti;
  Set<int> expandedIndicesmulti = {};
  late bool isExpandedmulti;
  bool sorting1multi = false;
  bool sorting2multi = false;
  bool sorting3multi = false;
  bool ascending1multi = false;
  bool ascending2multi = false;
  bool ascending3multi = false;


  countupdateunit(int cnt){
    setState(() {
      unitCount = cnt;
    });
  }
  Widget _buildHeadersmulti() {
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
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
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
                    if (sorting1multi == true) {
                      sorting2multi = false;
                      sorting3multi = false;
                      ascending1multi = sorting1multi ? !ascending1multi : true;
                      ascending2multi = false;
                      ascending3multi = false;
                    } else {
                      sorting1multi = !sorting1multi;
                      sorting2multi = false;
                      sorting3multi = false;
                      ascending1multi = sorting1multi ? !ascending1multi : true;
                      ascending2multi = false;
                      ascending3multi = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text("Unit ", style: TextStyle(color: Colors.white))
                        : Text("Unit", style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                    ascending1multi
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
                    if (sorting2multi) {
                      sorting1multi = false;
                      sorting2multi = sorting2multi;
                      sorting3multi = false;
                      ascending2multi = sorting2multi ? !ascending2multi : true;
                      ascending1multi = false;
                      ascending3multi = false;
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
                    Text("Address", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    ascending2multi
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
                    if (sorting3multi) {
                      sorting1multi = false;
                      sorting2multi = false;
                      sorting3multi = sorting3multi;
                      ascending3multi = sorting3multi ? !ascending3multi : true;
                      ascending2multi = false;
                      ascending1multi = false;
                    } else {
                      sorting1multi = false;
                      sorting2multi = false;
                      sorting3multi = !sorting3multi;
                      ascending3multi = sorting3multi ? !ascending3multi : true;
                      ascending2multi = false;
                      ascending1multi = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("Action", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    ascending3multi
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

  // void handleEdit(unit_properties property) async {
  //   // Handle edit action
  //   print('Edit ${property.unitId}');
  //   var check = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => Edit_property_type(
  //             property: property,
  //           )));
  //   if (check == true) {
  //     setState(() {});
  //   }
  // final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => Edit_property_type(
  //               property: property,
  //             )));
  /* if (result == true) {
      setState(() {
        futureUnitsummery = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  // }
  // void _showAlertmulti(BuildContext context, String id) {
  //   Alert(
  //     context: context,
  //     type: AlertType.warning,
  //     title: "Are you sure?",
  //     desc: "Once deleted, you will not be able to recover this property!",
  //     style: AlertStyle(
  //       backgroundColor: Colors.white,
  //     ),
  //     buttons: [
  //       DialogButton(
  //         child: Text(
  //           "Cancel",
  //           style: TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //         onPressed: () => Navigator.pop(context),
  //         color: Colors.grey,
  //       ),
  //       DialogButton(
  //         child: Text(
  //           "Delete",
  //           style: TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //         onPressed: () async {
  //          // var data = PropertyTypeRepository().DeletePropertyType(id: id);
  //           // Add your delete logic here
  //           setState(() {
  //             // futureUnitsummery =
  //             //     PropertyTypeRepository().fetchPropertyTypes();
  //           });
  //           Navigator.pop(context);
  //         },
  //         color: Colors.red,
  //       )
  //     ],
  //   ).show();
  // }
  List<unit_properties> _tableDatamulti = [];
  int _rowsPerPagemulti = 10;
  int _currentPagemulti = 0;
  int? _sortColumnIndexmulti;
  bool _sortAscendingmulti = true;

  List<unit_properties> get _pagedDatamulti {
    int startIndex = _currentPagemulti * _rowsPerPagemulti;
    int endIndex = startIndex + _rowsPerPagemulti;
    return _tableDatamulti.sublist(startIndex,
        endIndex > _tableDatamulti.length ? _tableDatamulti.length : endIndex);
  }

  void _changeRowsPerPagemulti(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPagemulti = selectedRowsPerPage;
      _currentPagemulti =
          0; // Reset to the first page when changing rows per page
    });
  }

  void _sortmulti<T>(Comparable<T> Function(unit_properties d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndexmulti = columnIndex;
      _sortAscendingmulti = ascending;
      _tableDatamulti.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        final result = aValue.compareTo(bValue as T);
        return _sortAscendingmulti ? result : -result;
      });
    });
  }

  Widget _buildHeadermulti<T>(String text, int columnIndex,
      Comparable<T> Function(unit_properties d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null
            ? () {
                _sortmulti(getField, columnIndex, !_sortAscendingmulti);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              if (_sortColumnIndexmulti == columnIndex)
                Icon(_sortAscendingmulti
                    ? Icons.arrow_drop_down_outlined
                    : Icons.arrow_drop_up_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCellmulti(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16, bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCellmulti(unit_properties data) {
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
                  // handleEdit(data);
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
                  //  handleDelete(data);
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

  Widget _buildPaginationControlsmulti() {
    int numorpages = 1;
    numorpages = (totalrecords / _rowsPerPagemulti).ceil();

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
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _changeRowsPerPagemulti(newValue);
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
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: _currentPagemulti == 0
                ? Colors.grey
                : Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: _currentPagemulti == 0
              ? null
              : () {
                  setState(() {
                    _currentPagemulti--;
                  });
                },
        ),
        Text(
          'Page ${_currentPagemulti + 1} of $numorpages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPagemulti + 1) * _rowsPerPagemulti >=
                    _tableDatamulti.length
                ? Colors.grey
                : Color.fromRGBO(
                    21, 43, 83, 1), // Change color based on availability
          ),
          onPressed: (_currentPagemulti + 1) * _rowsPerPagemulti >=
                  _tableDatamulti.length
              ? null
              : () {
                  setState(() {
                    _currentPagemulti++;
                  });
                },
        ),
      ],
    );
  }

//rentalowners

  int rowsPerPagerent = 5;
  int sortColumnIndexrent = 0;
  bool sortAscendingrent = true;
  final List<String> rolesrent = ['Manager', 'Employee', 'All'];
  String? selectedRolerent;
  String searchValuerent = "";
  int currentPagerent = 0;
  int itemsPerPagerent = 10;
  int? expandedIndexrent;
  Set<int> expandedIndicesrent = {};

  List<int> itemsPerPageOptionsrent = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page
  late bool isExpandedrentrent;
  bool sorting1rent = false;
  bool sorting2rent = false;
  bool sorting3rent = false;
  bool ascending1rent = false;
  bool ascending2rent = false;
  bool ascending3rent = false;

  Widget _buildHeadersrent() {
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
                    if (sorting1rent == true) {
                      sorting2rent = false;
                      sorting3rent = false;
                      ascending1rent = sorting1rent ? !ascending1rent : true;
                      ascending2rent = false;
                      ascending3rent = false;
                    } else {
                      sorting1rent = !sorting1rent;
                      sorting2rent = false;
                      sorting3rent = false;
                      ascending1rent = sorting1rent ? !ascending1rent : true;
                      ascending2rent = false;
                      ascending3rent = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text(" Contact\nName", textAlign: TextAlign.center,style: TextStyle(color: Colors.white,))
                        : Text(" Contact\nName",textAlign: TextAlign.center, style: TextStyle(color: Colors.white,)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2rent) {
                      sorting1rent = false;
                      sorting2rent = sorting2rent;
                      sorting3rent = false;
                      ascending2rent = sorting2rent ? !ascending2rent : true;
                      ascending1rent = false;
                      ascending3rent = false;
                    } else {
                      sorting1rent = false;
                      sorting2rent = !sorting2rent;
                      sorting3rent = false;
                      ascending2rent = sorting2rent ? !ascending2rent : true;
                      ascending1rent = false;
                      ascending3rent = false;
                    }
                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("  Company \nName",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting3rent) {
                      sorting1rent = false;
                      sorting2rent = false;
                      sorting3rent = sorting3rent;
                      ascending3rent = sorting3rent ? !ascending3rent : true;
                      ascending2rent = false;
                      ascending1rent = false;
                    } else {
                      sorting1rent = false;
                      sorting2rent = false;
                      sorting3rent = !sorting3rent;
                      ascending3rent = sorting3rent ? !ascending3rent : true;
                      ascending2rent = false;
                      ascending1rent = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("   Phone\n  Number",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Rentals> _tableDatarent = [];
  int totalrecordsrent = 0;
  int _rowsPerPagerent = 10;
  int _currentPagerent = 0;
  int? _sortColumnIndexrent;
  bool _sortColumnIndexrentrent = true;

  List<Rentals> get _pagedDatarent {
    int startIndex = _currentPagerent * _rowsPerPagerent;
    int endIndex = startIndex + _rowsPerPagerent;
    return _tableDatarent.sublist(startIndex,
        endIndex > _tableDatarent.length ? _tableDatarent.length : endIndex);
  }

  void _changeRowsPerPagerent(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPagerent = selectedRowsPerPage;
      _currentPagerent =
          0; // Reset to the first page when changing rows per page
    });
  }

  void _sortrent<T>(Comparable<T> Function(Rentals d) getField, int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndexrent = columnIndex;
      _sortColumnIndexrentrent = ascending;
      _tableDatarent.sort((a, b) {
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

        return _sortColumnIndexrentrent ? result : -result;
      });
    });
  }

  final _scrollController = ScrollController();

  Widget _buildHeaderrent<T>(String text, int columnIndex,
      Comparable<T> Function(Rentals d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null ? () {} : null,
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

  Widget _buildDataCellrent(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16, bottom: 15),
        child: InkWell(
            onTap: () {},
            child: Text(text?.isNotEmpty == true ? text! : 'N/A', style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  Widget _buildPaginationControlsrent() {
    int numorpages = 1;
    numorpages = (totalrecordsrent / _rowsPerPagerent).ceil();
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
                value: _rowsPerPagerent,
                items: [10, 2, 5, 1].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _changeRowsPerPagerent(newValue);
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
            color: _currentPagerent == 0
                ? Colors.grey
                : Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: _currentPagerent == 0
              ? null
              : () {
                  setState(() {
                    _currentPagerent--;
                  });
                },
        ),
        Text(
          'Page ${_currentPagerent + 1} of $numorpages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPagerent + 1) * _rowsPerPagerent >=
                    _tableDatarent.length
                ? Colors.grey
                : Color.fromRGBO(
                    21, 43, 83, 1), // Change color based on availability
          ),
          onPressed:
              (_currentPagerent + 1) * _rowsPerPagerent >= _tableDatarent.length
                  ? null
                  : () {
                      setState(() {
                        _currentPagerent++;
                      });
                    },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawer(currentpage: 'Properties',),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              Text('${widget.properties.rentalAddress}',
                  style: TextStyle(
                    color: Color.fromRGBO(21, 43, 81, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 20,
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              Text('${widget.properties.propertyTypeData?.propertyType}',
                  style: TextStyle(
                    color: Color(0xFF8A95A8),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width < 500 ? 13 : 20,
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
              // color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorWeight: 5,
              labelStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 20,
                // fontWeight: FontWeight.bold,
              ),
              //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
              indicatorColor: const Color.fromRGBO(21, 43, 81, 1),
              labelColor: const Color.fromRGBO(21, 43, 81, 1),
              unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
              tabs: [
                Tab(
                  text: 'Summary',
                ),
                Tab(
                  text: 'Units',
                ),
                StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Tab(text: 'Tenant');
                  },
                ),
                StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Tab(
                        text: 'Work');
                  },
                ),
                // Consumer<WorkOrderCountProvider>(
                //   builder: (context, provider, child) {
                //     return Tab(text: 'Work(${provider.isChecked ? provider.count : provider.count})');
                //   },
                // ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Summary_page(),
                // showdetails
                //     ? unitScreen(properties: widget.properties
                //         //properties: widget.properties,
                //       //  unit: unit,
                //       )
                //     : Unit_page(),
                // showdetails ? unitScreen1(context, unit!) : Unit_page(context),
                showdetails ? unitScreen1(context, unit!) : Unit_page(context),

                // unitScreen(),
                // Center(child: Text('Content of Tab 2')),
                //  Container(color:Colors.blue),
                Tenants(context),
                Workorder(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Summary_page() {
    print("$image_url${widget.properties.rentalImage}");
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              // height: 150,
              // width: MediaQuery.of(context).size.width * .94,
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const SizedBox(
                    //   height: 4,
                    // ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        // Container(
                        //   // height: 150,
                        //   width: 150,
                        //   decoration: BoxDecoration(color: Colors.blue),
                        //   child: Image.network(
                        //     "$image_url${widget.properties.rentalImage}"??'https://st.depositphotos.com/1763233/3344/i/450/depositphotos_33445577-stock-photo-wooden-house.jpg',
                        //     fit: BoxFit.fill,
                        //     height: 100,
                        //   ),
                        // ),
                        Container(
                          width: MediaQuery.of(context).size.width < 500
                              ? 150
                              : 250,
                          height: MediaQuery.of(context).size.width < 500
                              ? 120
                              : 200,
                          decoration: const BoxDecoration(color: Colors.blue),
                          child: Image.network(
                            widget.properties.rentalImage != null &&
                                    widget.properties.rentalImage!.isNotEmpty
                                ? "$image_url${widget.properties.rentalImage}"
                                : 'https://i.pinimg.com/originals/59/11/81/591181790b40c5e1f8cc04b55ebdbf25.jpg',
                            fit: BoxFit.fill,
                            height: 100,
                          ),
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          SizedBox(
                            width: 15,
                          ),
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(
                            width: 25,
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Property Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 14
                                            : 22,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Address',
                                    style: TextStyle(
                                      color: Color(0xFF8A95A8),
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 13
                                              : 18,
                                    )),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    '${widget.properties.propertyTypeData?.propertyType}',
                                    style: TextStyle(
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 13
                                              : 18,
                                    )),
                              ],
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width > 500 ? 200: 150,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  '${widget.properties?.rentalAddress}',
                                  maxLines: 2, // Set maximum number of lines
                                  overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 500 ? 13 : 18,
                                    color: blueColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${widget.properties.rentalCity},',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 13
                                            : 18,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  '${widget.properties.rentalState},',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 13
                                            : 18,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${widget.properties.rentalCountry},',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 13
                                            : 18,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  '${widget.properties.rentalPostcode}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 13
                                            : 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    // const SizedBox(height: 5),
                    // const
                    // Row(
                    //   children: [
                    //     SizedBox(
                    //       width: 10,
                    //     ),
                    //     Text(
                    //       'Property Details',
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: Color.fromRGBO(21, 43, 81, 1),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 3),
                    // const Row(
                    //   children: [
                    //     SizedBox(
                    //       width: 10,
                    //     ),
                    //     Text('Address',
                    //         style: TextStyle(
                    //             color: Color(0xFF8A95A8),
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 12)),
                    //   ],
                    // ),
                    // const SizedBox(height: 3),
                    // Row(
                    //   children: [
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //     Text(
                    //         '${widget.properties.propertyTypeData?.propertyType}',
                    //         style: const TextStyle(
                    //             color: Color.fromRGBO(21, 43, 81, 1),
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 12)),
                    //   ],
                    // ),
                    // const SizedBox(height: 3),
                    // Row(
                    //   children: [
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //     Text('${widget.properties.rentalAddress}',
                    //         style: const TextStyle(
                    //           color: Color.fromRGBO(21, 43, 81, 1),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12,
                    //         )),
                    //   ],
                    // ),
                    // const SizedBox(height: 3),
                    // Row(
                    //   children: [
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //     Text(
                    //       '${widget.properties.rentalCity},',
                    //       style: const TextStyle(
                    //           color: Color.fromRGBO(21, 43, 81, 1),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12),
                    //     ),
                    //     const SizedBox(width: 3),
                    //     Text(
                    //       '${widget.properties.rentalState},',
                    //       style: const TextStyle(
                    //           color: Color.fromRGBO(21, 43, 81, 1),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12),
                    //     ),
                    //   ],
                    // ),
                    // Row(
                    //   children: [
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //     Text(
                    //       '${widget.properties.rentalCountry},',
                    //       style: const TextStyle(
                    //           color: Color.fromRGBO(21, 43, 81, 1),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12),
                    //     ),
                    //     const SizedBox(width: 3),
                    //     Text(
                    //       '${widget.properties.rentalPostcode}',
                    //       style: const TextStyle(
                    //           color: Color.fromRGBO(21, 43, 81, 1),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                if (MediaQuery.of(context).size.width > 500)
                  SizedBox(
                    width: 6,
                  ),
                if (MediaQuery.of(context).size.width < 500)
                  SizedBox(
                    width: 10,
                  ),
                Text(
                  "Rental Owners",
                  style: TextStyle(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 16 : 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Table(
            //     defaultColumnWidth: const IntrinsicColumnWidth(),
            //     border: TableBorder.all(color: Colors.black),
            //     children: [
            //       const TableRow(
            //         decoration: BoxDecoration(),
            //         children: [
            //           TableCell(
            //             child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text(
            //                 'Field Name',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize:
            //                   20,
            //                   color: Color.fromRGBO(21, 43, 81, 1),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           TableCell(
            //             child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text('Company Name',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontSize:
            //                     20,
            //                     color: Color.fromRGBO(21, 43, 81, 1),
            //                   )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text('E-mail',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontSize:
            //                     20,
            //                     color: Color.fromRGBO(21, 43, 81, 1),
            //                   )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text('Phone Number',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontSize:
            //                     20,
            //                     color: Color.fromRGBO(21, 43, 81, 1),
            //                   )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text('Home Number',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontSize:
            //                     20,
            //                     color: Color.fromRGBO(21, 43, 81, 1),
            //                   )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text('Business Number',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontSize:
            //                     20,
            //                     color: Color.fromRGBO(21, 43, 81, 1),
            //                   )),
            //             ),
            //           ),
            //         ],
            //       ),
            //       TableRow(
            //         decoration: const BoxDecoration(
            //           border: Border.symmetric(horizontal: BorderSide.none),
            //         ),
            //         children: [
            //           TableCell(
            //             child: Container(
            //               height: 40,
            //               child: Center(
            //                   child: Text(
            //                 '${widget.properties.rentalOwnerData?.rentalOwnerFirstName}',
            //                 style: const TextStyle(
            //                   color: Color.fromRGBO(21, 43, 81, 1),
            //                 ),
            //               )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Container(
            //               height: 40,
            //               child: Center(
            //                 child: Text(
            //                   '${widget.properties.rentalOwnerData?.rentalOwnerCompanyName}',
            //                   style: const TextStyle(
            //                     color: Color.fromRGBO(21, 43, 81, 1),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           TableCell(
            //             child: Container(
            //               height: 40,
            //               child: Center(
            //                   child: Text(
            //                 '${widget.properties.rentalOwnerData?.rentalOwnerPrimaryEmail}',
            //                 style: const TextStyle(
            //                   color: Color.fromRGBO(21, 43, 81, 1),
            //                 ),
            //               )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Container(
            //               height: 40,
            //               child: Center(
            //                   child: Text(
            //                 '${widget.properties.rentalOwnerData?.rentalOwnerPhoneNumber}',
            //                 style: const TextStyle(
            //                   color: Color.fromRGBO(21, 43, 81, 1),
            //                 ),
            //               )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Container(
            //               height: 40,
            //               child: Center(
            //                   child: Text(
            //                 '${widget.properties.rentalOwnerData?.rentalOwnerHomeNumber}',
            //                 style: const TextStyle(
            //                   color: Color.fromRGBO(21, 43, 81, 1),
            //                 ),
            //               )),
            //             ),
            //           ),
            //           TableCell(
            //             child: Container(
            //               height: 40,
            //               child: Center(
            //                   child: Text(
            //                 '${widget.properties.rentalOwnerData?.rentalOwnerBuisinessNumber}',
            //                 style: const TextStyle(
            //                   color: Color.fromRGBO(21, 43, 81, 1),
            //                 ),
            //               )),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            if (MediaQuery.of(context).size.width > 500) SizedBox(height: 10),
            if (MediaQuery.of(context).size.width > 500) SizedBox(height: 5),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: FutureBuilder<List<Rentals>>(
                  future: futurerentalowners,
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
                      return Center(child: Text('No data available'));
                    } else {
                      var data = snapshot.data!;
                      if (searchValuerent == null || searchValuerent!.isEmpty) {
                        data = snapshot.data!;
                      } else if (searchValuerent == "All") {
                        data = snapshot.data!;
                      } else if (searchValuerent!.isNotEmpty) {
                        data = snapshot.data!
                            .where((rentals) => rentals
                                .rentalOwnerData!.rentalOwnerName!
                                .toLowerCase()
                                .contains(searchValuerent!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((rentals) =>
                                rentals.rentalOwnerData!.rentalOwnerCompanyName! ==
                                searchValuerent)
                            .toList();
                      }
                      data = data.where((e)=>e.rentalId == widget.properties.rentalId).toList();
                      final totalPages = (data.length / itemsPerPage).ceil();
                      final currentPageData = data
                          .skip(currentPage * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();
                      print("currentpage data ${currentPageData.length}");
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            _buildHeadersrent(),
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
                                  Rentals rentals = entry.value;
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
                                                    onTap: () {},
                                                    child: Text(
                                                      '   ${(rentals.rentalOwnerData?.rentalOwnerName??"").isEmpty ?'N/A':rentals.rentalOwnerData?.rentalOwnerName} ',
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
                                                    '${(rentals.rentalOwnerData?.rentalOwnerCompanyName??"").isEmpty ?'N/A':rentals.rentalOwnerData?.rentalOwnerCompanyName}',
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
                                                    '${(rentals.rentalOwnerData?.rentalOwnerPhoneNumber??"").isEmpty ?'N/A':rentals.rentalOwnerData?.rentalOwnerPhoneNumber}',
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
                                                                        'E-mail: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${(rentals.rentalOwnerData?.rentalOwnerPrimaryEmail??"").isEmpty ?'N/A':rentals.rentalOwnerData?.rentalOwnerPrimaryEmail}',
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
                                                                        'Home Number: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${(rentals.rentalOwnerData?.rentalOwnerHomeNumber??"").isEmpty ?'N/A':rentals.rentalOwnerData?.rentalOwnerHomeNumber}',
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
                                                                        'Business Number: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${(rentals.rentalOwnerData?.rentalOwnerBuisinessNumber??"").isEmpty ?'N/A':rentals.rentalOwnerData?.rentalOwnerBuisinessNumber}',
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
              FutureBuilder<List<Rentals>>(
                future: futurerentalowners,
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
                    return Center(child: Text('No data available'));
                  } else {
                    List<Rentals>? filteredData = [];
                    _tableDatarent = snapshot.data!;
                    if (selectedRolerent == null && searchValuerent == "") {
                      filteredData = snapshot.data;
                    } else if (selectedRolerent == "All") {
                      filteredData = snapshot.data;
                    } else if (searchValuerent.isNotEmpty) {
                      filteredData = snapshot.data!
                          .where((staff) =>
                              staff.rentalOwnerData!.rentalOwnerName!
                                  .toLowerCase()
                                  .contains(searchValuerent.toLowerCase()) ||
                              staff.rentalOwnerData!.rentalOwnerPhoneNumber!
                                  .toLowerCase()
                                  .contains(searchValuerent.toLowerCase()))
                          .toList();
                    }

                    _tableDatarent = filteredData!;
                    totalrecordsrent = _tableDatarent.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              // width: MediaQuery.of(context).size.width * .91,
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
                                      _buildHeaderrent(
                                          'Contact Name',
                                          0,
                                          (rental) => rental.rentalOwnerData!
                                              .rentalOwnerFirstName!),
                                      _buildHeaderrent(
                                          'Company Name',
                                          1,
                                          (rental) => rental.rentalOwnerData!
                                              .rentalOwnerCompanyName!),
                                      _buildHeaderrent(
                                          'Email',
                                          2,
                                          (rental) => rental.rentalOwnerData!
                                              .rentalOwnerPrimaryEmail!),
                                      _buildHeaderrent(
                                          'Phone Number',
                                          3,
                                          (rental) => rental.rentalOwnerData!
                                              .rentalOwnerPhoneNumber!),
                                      _buildHeaderrent(
                                          'Home Number',
                                          4,
                                          (rental) => rental.rentalOwnerData!
                                              .rentalOwnerHomeNumber!),
                                      _buildHeaderrent(
                                          'Business Number',
                                          5,
                                          (rental) => rental.rentalOwnerData!
                                              .rentalOwnerBuisinessNumber!),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide.none),
                                    ),
                                    children: List.generate(
                                        6,
                                        (index) => TableCell(
                                            child: Container(height: 20))),
                                  ),
                                  for (var i = 0;
                                      i < _pagedDatarent.length;
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
                                          bottom: i == _pagedDatarent.length - 1
                                              ? BorderSide(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1))
                                              : BorderSide.none,
                                        ),
                                      ),
                                      children: [
                                        _buildDataCellrent(
                                            '${_pagedDatarent[i].rentalOwnerData!.rentalOwnerName!}'),
                                        // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                        _buildDataCellrent(
                                          _pagedDatarent[i]
                                              .rentalOwnerData!
                                              .rentalOwnerCompanyName!,
                                        ),
                                        _buildDataCellrent(_pagedDatarent[i]
                                            .rentalOwnerData!
                                            .rentalOwnerPrimaryEmail!),
                                        _buildDataCellrent(_pagedDatarent[i]
                                            .rentalOwnerData!
                                            .rentalOwnerPhoneNumber!),
                                        _buildDataCellrent(_pagedDatarent[i]
                                            .rentalOwnerData!
                                            .rentalOwnerHomeNumber!),
                                        _buildDataCellrent(_pagedDatarent[i]
                                            .rentalOwnerData!
                                            .rentalOwnerBuisinessNumber!),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_tableDatarent.isEmpty)
                            Text("No Search Records Found"),
                          SizedBox(height: 25),
                          _buildPaginationControlsrent(),
                        ],
                      ),
                    );
                  }
                },
              ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                if (MediaQuery.of(context).size.width > 500)
                  SizedBox(
                    width: 6,
                  ),
                if (MediaQuery.of(context).size.width < 500)
                  SizedBox(
                    width: 5,
                  ),
                Text(
                  "Staff Details",
                  style: TextStyle(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 17 : 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Table(
                border: TableBorder.all(color: blueColor),
                children: [
                  TableRow(
                      decoration: BoxDecoration(
                        color: blueColor,
                        //  borderRadius: BorderRadius.circular(10),
                      ),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Staff Member',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 16
                                          : 19,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ]),
                  TableRow(children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.properties.staffMemberData?.staffmemberName !=
                                      null &&
                                  widget.properties.staffMemberData!
                                      .staffmemberName!.isNotEmpty
                              ? '${widget.properties.staffMemberData!.staffmemberName}'
                              : 'N/A',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 16
                                : 19,
                          ),
                        ),
                      ),
                    ),
                  ])
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Tenants(BuildContext context) {
    return
      LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;

        return FutureBuilder<List<TenantData>>(
          future: Properies_summery_Repo()
              .fetchPropertiessummery(widget.properties.rentalId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 40.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<TenantData> tenants = snapshot.data ?? [];
              if(snapshot.data!.length == 0){
                return Center(child: Text("No Data Availabel"));
              }
              return isTablet
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 35,
                          right: 35,
                          top: 30,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: MediaQuery.of(context).size.width * 0.03,
                          runSpacing: MediaQuery.of(context).size.width * 0.035,
                          children: List.generate(
                            tenants.length,
                            (index) => Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 220,
                                width: MediaQuery.of(context).size.width * .44,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white, // Change as per your need
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: buildTenantCard(tenants[index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: MediaQuery.of(context).size.width * 0.03,
                        runSpacing: MediaQuery.of(context).size.width * 0.02,
                        children: List.generate(
                          tenants.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20,),
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 205,
                                //  width: MediaQuery.of(context).size.width * .44,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white, // Change as per your need
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: buildTenantCard(
                                    tenants[index]

                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
            }
          },
        );
      },
    );


  }

  Widget buildTenantCard(TenantData tenant) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 15),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(21, 43, 81, 1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.user,
                  size: MediaQuery.of(context).size.width < 500 ? 16 : 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 2),
                    Text(
                      '${tenant.firstName} ${tenant.lastName}',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 500 ? 16 : 19,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(21, 43, 81, 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 2),
                    Text(
                      formatDate2(tenant.updatedAt!),
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 500 ? 15 : 17,
                        color: Color(0xFF8A95A8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: () {


              },
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    size: 17,
                    color: Color.fromRGBO(21, 43, 81, 1),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Move out",
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 15 : 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(21, 43, 81, 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const SizedBox(width: 65),
            Text(
              '${tenant.createdAt} to',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 16,
                color: Color.fromRGBO(21, 43, 81, 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 65),
            Text(
              '${tenant.updatedAt}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 16,
                color: Color.fromRGBO(21, 43, 81, 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 65),
            const FaIcon(
              FontAwesomeIcons.phone,
              size: 15,
              color: Color.fromRGBO(21, 43, 81, 1),
            ),
            const SizedBox(width: 5),
            Text(
              '${tenant.phoneNumber}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 16,
                color: Color.fromRGBO(21, 43, 81, 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 65),
            const FaIcon(
              FontAwesomeIcons.solidEnvelope,
              size: 15,
              color: Color.fromRGBO(21, 43, 81, 1),
            ),
            const SizedBox(width: 5),
            Text(
              '${tenant.email}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 16,
                color: Color.fromRGBO(21, 43, 81, 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Unit_page(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            //  this for single unit table show
            //    if (!showdetails &&
            //        widget.properties.propertyTypeData!.isMultiunit! == false)
            //      Padding(
            //        padding: const EdgeInsets.all(10.0),
            //        child: FutureBuilder<List<unit_properties>>(
            //          future: Properies_summery_Repo()
            //              .fetchunit(widget.properties.rentalId!),
            //          builder: (context, snapshot) {
            //            if (snapshot.connectionState == ConnectionState.waiting) {
            //              return const Center(
            //                  child: SpinKitFadingCircle(
            //                color: Colors.black,
            //                size: 40.0,
            //              ));
            //            } else if (snapshot.hasError) {
            //              return Center(child: Text('Error: ${snapshot.error}'));
            //            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //              return const Center(child: Text('No data available'));
            //            }
            //            final data = snapshot.data!;
            //            return SingleChildScrollView(
            //              scrollDirection: Axis.horizontal,
            //              child: Padding(
            //                padding: const EdgeInsets.all(2.0),
            //                child: Container(
            //                  decoration: BoxDecoration(
            //                      border: Border.all(
            //                    color: const Color.fromRGBO(21, 43, 83, 1),
            //                  )),
            //                  child: DataTable(
            //                    // headingRowColor: MaterialStateColor.resolveWith(
            //                    //         (states) => Color.fromRGBO(21, 43, 83, 1)),
            //                    headingTextStyle: const TextStyle(
            //                        color: Colors.white,
            //                        fontWeight: FontWeight.bold),
            //                    columnSpacing: 20,
            //                    dataRowHeight: 60,
            //                    columns: [
            //                      const DataColumn(
            //                        label: Text(
            //                          'TENANTS',
            //                          style: TextStyle(
            //                            color: Color.fromRGBO(21, 43, 81, 1),
            //                            fontWeight: FontWeight.bold,
            //                          ),
            //                        ),
            //                      ),
            //                      const DataColumn(
            //                        label: Text(
            //                          'ACTION',
            //                          style: TextStyle(
            //                            color: Color.fromRGBO(21, 43, 81, 1),
            //                            fontWeight: FontWeight.bold,
            //                          ),
            //                        ),
            //                      ),
            //                    ],
            //                    rows: data.map((unitData) {
            //                      return DataRow(
            //                        cells: [
            //                          DataCell(
            //                            Text(
            //                              ' ${tenentCount}',
            //                              style:
            //                                  const TextStyle(color: Color(0xFF8A95A8)),
            //                            ),
            //                            onTap: () {
            //                              setState(() {
            //                                // showdetails = !showdetails;
            //                                showdetails = true;
            //                                unit = unitData;
            //                              });
            //
            //                              // if (showdetails) {
            //                              //   // Navigator.push(
            //                              //   //   context,
            //                              //   //   MaterialPageRoute(builder: (context) => unitScreen()),
            //                              //   // );
            //                              //   // unitScreen();
            //                              //   Container(
            //                              //       color: Colors.blue,
            //                              //     child: Text("data"),
            //                              //   );
            //                              // }
            //                            },
            //                          ),
            //                          DataCell(
            //                            IconButton(
            //                              icon: const FaIcon(
            //                                FontAwesomeIcons.edit,
            //                                size: 15,
            //                                color: Color(0xFF8A95A8),
            //                              ),
            //                              onPressed: () {
            //                                sqft3.text = unitData.rentalsqft!;
            //                                if (widget.properties.propertyTypeData!
            //                                            .isMultiunit! ==
            //                                        false &&
            //                                    widget.properties.propertyTypeData!
            //                                            .propertyType ==
            //                                        'Residential') {
            //                                  showDialog(
            //                                    context: context,
            //                                    builder: (BuildContext context) {
            //                                      bool isChecked =
            //                                          false; // Moved isChecked inside the StatefulBuilder
            //                                      return StatefulBuilder(
            //                                        builder: (BuildContext context,
            //                                            StateSetter setState) {
            //                                          return AlertDialog(
            //                                            backgroundColor:
            //                                                Colors.white,
            //                                            surfaceTintColor:
            //                                                Colors.white,
            //                                            content:
            //                                                SingleChildScrollView(
            //                                              child: Column(
            //                                                children: [
            //                                                  Row(
            //                                                    children: [
            //                                                      const Text(
            //                                                        "Add Unit Details",
            //                                                        style:
            //                                                            TextStyle(
            //                                                          color: Color
            //                                                              .fromRGBO(
            //                                                                  21,
            //                                                                  43,
            //                                                                  81,
            //                                                                  1),
            //                                                          fontWeight:
            //                                                              FontWeight
            //                                                                  .bold,
            //                                                        ),
            //                                                      ),
            //                                                      const Spacer(),
            //                                                      Align(
            //                                                        alignment: Alignment
            //                                                            .centerRight,
            //                                                        child: InkWell(
            //                                                          onTap: () {
            //                                                            Navigator.pop(
            //                                                                context);
            //                                                          },
            //                                                          child: const Icon(
            //                                                              Icons
            //                                                                  .close,
            //                                                              color: Colors
            //                                                                  .black),
            //                                                        ),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  const Row(
            //                                                    children: [
            //                                                      Text(
            //                                                        "SQFT",
            //                                                        style: TextStyle(
            //                                                            color: Color(
            //                                                                0xFF8A95A8),
            //                                                            fontWeight:
            //                                                                FontWeight
            //                                                                    .bold),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  Padding(
            //                                                    padding:
            //                                                        const EdgeInsets
            //                                                            .symmetric(
            //                                                            vertical:
            //                                                                1),
            //                                                    child: Material(
            //                                                      elevation: 3,
            //                                                      borderRadius:
            //                                                          BorderRadius
            //                                                              .circular(
            //                                                                  3),
            //                                                      child:
            //                                                          TextFormField(
            //                                                        controller:
            //                                                            sqft3,
            //                                                        cursorColor:
            //                                                            Colors
            //                                                                .black,
            //                                                        decoration:
            //                                                            InputDecoration(
            //                                                          //  hintText: label,
            //                                                          // labelText: label,
            //                                                          // labelStyle: TextStyle(color: Colors.grey[700]),
            //                                                          filled: true,
            //                                                          fillColor:
            //                                                              Colors
            //                                                                  .white,
            //                                                          border:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                BorderSide
            //                                                                    .none,
            //                                                          ),
            //                                                          enabledBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                const BorderSide(
            //                                                                    color:
            //                                                                        Color(0xFF8A95A8)),
            //                                                          ),
            //                                                          focusedBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide: const BorderSide(
            //                                                                color: Color(
            //                                                                    0xFF8A95A8),
            //                                                                width:
            //                                                                    2),
            //                                                          ),
            //                                                          contentPadding: const EdgeInsets.symmetric(
            //                                                              vertical:
            //                                                                  10.0,
            //                                                              horizontal:
            //                                                                  10.0),
            //                                                        ),
            //                                                      ),
            //                                                    ),
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  const Row(
            //                                                    children: [
            //                                                      Text(
            //                                                        "bath",
            //                                                        style: TextStyle(
            //                                                            color: Color(
            //                                                                0xFF8A95A8),
            //                                                            fontWeight:
            //                                                                FontWeight
            //                                                                    .bold),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  Padding(
            //                                                    padding:
            //                                                        const EdgeInsets
            //                                                            .symmetric(
            //                                                            vertical:
            //                                                                1),
            //                                                    child: Material(
            //                                                      elevation: 3,
            //                                                      borderRadius:
            //                                                          BorderRadius
            //                                                              .circular(
            //                                                                  3),
            //                                                      child:
            //                                                          TextFormField(
            //                                                        controller:
            //                                                            bath3,
            //                                                        cursorColor:
            //                                                            Colors
            //                                                                .black,
            //                                                        decoration:
            //                                                            InputDecoration(
            //                                                          //  hintText: label,
            //                                                          // labelText: label,
            //                                                          // labelStyle: TextStyle(color: Colors.grey[700]),
            //                                                          filled: true,
            //                                                          fillColor:
            //                                                              Colors
            //                                                                  .white,
            //                                                          border:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                BorderSide
            //                                                                    .none,
            //                                                          ),
            //                                                          enabledBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                const BorderSide(
            //                                                                    color:
            //                                                                        Color(0xFF8A95A8)),
            //                                                          ),
            //                                                          focusedBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide: const BorderSide(
            //                                                                color: Color(
            //                                                                    0xFF8A95A8),
            //                                                                width:
            //                                                                    2),
            //                                                          ),
            //                                                          contentPadding: const EdgeInsets.symmetric(
            //                                                              vertical:
            //                                                                  10.0,
            //                                                              horizontal:
            //                                                                  10.0),
            //                                                        ),
            //                                                      ),
            //                                                    ),
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  const Row(
            //                                                    children: [
            //                                                      Text(
            //                                                        "bed",
            //                                                        style: TextStyle(
            //                                                            color: Color(
            //                                                                0xFF8A95A8),
            //                                                            fontWeight:
            //                                                                FontWeight
            //                                                                    .bold),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  Padding(
            //                                                    padding:
            //                                                        const EdgeInsets
            //                                                            .symmetric(
            //                                                            vertical:
            //                                                                1),
            //                                                    child: Material(
            //                                                      elevation: 3,
            //                                                      borderRadius:
            //                                                          BorderRadius
            //                                                              .circular(
            //                                                                  3),
            //                                                      child:
            //                                                          TextFormField(
            //                                                        controller:
            //                                                            bed3,
            //                                                        cursorColor:
            //                                                            Colors
            //                                                                .black,
            //                                                        decoration:
            //                                                            InputDecoration(
            //                                                          //  hintText: label,
            //                                                          // labelText: label,
            //                                                          // labelStyle: TextStyle(color: Colors.grey[700]),
            //                                                          filled: true,
            //                                                          fillColor:
            //                                                              Colors
            //                                                                  .white,
            //                                                          border:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                BorderSide
            //                                                                    .none,
            //                                                          ),
            //                                                          enabledBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                const BorderSide(
            //                                                                    color:
            //                                                                        Color(0xFF8A95A8)),
            //                                                          ),
            //                                                          focusedBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide: const BorderSide(
            //                                                                color: Color(
            //                                                                    0xFF8A95A8),
            //                                                                width:
            //                                                                    2),
            //                                                          ),
            //                                                          contentPadding: const EdgeInsets.symmetric(
            //                                                              vertical:
            //                                                                  10.0,
            //                                                              horizontal:
            //                                                                  10.0),
            //                                                        ),
            //                                                      ),
            //                                                    ),
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  const Row(
            //                                                    children: [
            //                                                      Text(
            //                                                        'Photo',
            //                                                        style: TextStyle(
            //                                                            color: Colors
            //                                                                .black),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(height: 8.0),
            //                                                  Row(
            //                                                    children: [
            //                                                      GestureDetector(
            //                                                        onTap: () {
            //                                                          _pickImage()
            //                                                              .then(
            //                                                                  (_) {
            //                                                            setState(
            //                                                                () {}); // Rebuild the widget after selecting the image
            //                                                          });
            //                                                        },
            //                                                        child: const Text(
            //                                                          '+ Add',
            //                                                          style: TextStyle(
            //                                                              color: Colors
            //                                                                  .green),
            //                                                        ),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  _image != null
            //                                                      ? Column(
            //                                                          children: [
            //                                                            Image.file(
            //                                                              _image!,
            //                                                              height:
            //                                                                  80,
            //                                                              width: 80,
            //                                                              fit: BoxFit
            //                                                                  .cover,
            //                                                            ),
            //                                                            Text(
            //                                                                _uploadedFileName ??
            //                                                                    ""),
            //                                                          ],
            //                                                        )
            //                                                      : const Text(''),
            //                                                  const SizedBox(height: 8.0),
            //                                                  Row(
            //                                                    children: [
            //                                                      const SizedBox(
            //                                                        width: 0,
            //                                                      ),
            //                                                      GestureDetector(
            //                                                        onTap:
            //                                                            () async {
            //                                                          if (sqft3.text
            //                                                              .isEmpty) {
            //                                                            setState(
            //                                                                () {
            //                                                              iserror =
            //                                                                  true;
            //                                                            });
            //                                                          } else {
            //                                                            setState(
            //                                                                () {
            //                                                              isLoading =
            //                                                                  true;
            //                                                              iserror =
            //                                                                  false;
            //                                                            });
            //                                                            SharedPreferences
            //                                                                prefs =
            //                                                                await SharedPreferences
            //                                                                    .getInstance();
            //
            //                                                            String? id =
            //                                                                prefs.getString(
            //                                                                    "adminId");
            //                                                            Properies_summery_Repo()
            //                                                                .Editunit(
            //                                                                    rentalsqft: sqft3
            //                                                                        .text,
            //                                                                    rentalunitadress: street3
            //                                                                        .text,
            //                                                                    rentalbath: bath3
            //                                                                        .text,
            //                                                                    rentalbed: bed3
            //                                                                        .text,
            //                                                                    unitId: unitData
            //                                                                        .unitId,
            //                                                                    adminId:
            //                                                                        id,
            //                                                                    rentalId: unitData
            //                                                                        .rentalId)
            //                                                                .then(
            //                                                                    (value) {
            //                                                              setState(
            //                                                                  () {
            //                                                                isLoading =
            //                                                                    false;
            //                                                              });
            //                                                              Navigator.of(
            //                                                                      context)
            //                                                                  .pop(
            //                                                                      true);
            //                                                              reload_Screen();
            //                                                            }).catchError(
            //                                                                    (e) {
            //                                                              setState(
            //                                                                  () {
            //                                                                isLoading =
            //                                                                    false;
            //                                                              });
            //                                                            });
            //                                                          }
            //                                                        },
            //                                                        child: Material(
            //                                                          elevation: 3,
            //                                                          borderRadius:
            //                                                              const BorderRadius
            //                                                                  .all(
            //                                                            Radius
            //                                                                .circular(
            //                                                                    5),
            //                                                          ),
            //                                                          child:
            //                                                              Container(
            //                                                            height: 30,
            //                                                            width: 80,
            //                                                            decoration:
            //                                                                const BoxDecoration(
            //                                                              color: Color
            //                                                                  .fromRGBO(
            //                                                                      21,
            //                                                                      43,
            //                                                                      81,
            //                                                                      1),
            //                                                              borderRadius:
            //                                                                  BorderRadius
            //                                                                      .all(
            //                                                                Radius.circular(
            //                                                                    5),
            //                                                              ),
            //                                                            ),
            //                                                            child: const Center(
            //                                                                child: Text(
            //                                                              "Save",
            //                                                              style: TextStyle(
            //                                                                  fontWeight: FontWeight
            //                                                                      .w500,
            //                                                                  color:
            //                                                                      Colors.white),
            //                                                            )),
            //                                                          ),
            //                                                        ),
            //                                                      ),
            //                                                      const SizedBox(
            //                                                          width: 10),
            //                                                      GestureDetector(
            //                                                        onTap: () {
            //                                                          Navigator.pop(
            //                                                              context);
            //                                                        },
            //                                                        child: Material(
            //                                                          elevation: 3,
            //                                                          borderRadius:
            //                                                              const BorderRadius
            //                                                                  .all(
            //                                                            Radius
            //                                                                .circular(
            //                                                                    5),
            //                                                          ),
            //                                                          child:
            //                                                              Container(
            //                                                            height: 30,
            //                                                            width: 80,
            //                                                            decoration:
            //                                                                const BoxDecoration(
            //                                                              color: Colors
            //                                                                  .white,
            //                                                              borderRadius:
            //                                                                  BorderRadius
            //                                                                      .all(
            //                                                                Radius.circular(
            //                                                                    5),
            //                                                              ),
            //                                                            ),
            //                                                            child: const Center(
            //                                                                child: Text(
            //                                                              "Cancel",
            //                                                              style: TextStyle(
            //                                                                  fontWeight: FontWeight
            //                                                                      .w500,
            //                                                                  color: Color.fromRGBO(
            //                                                                      21,
            //                                                                      43,
            //                                                                      81,
            //                                                                      1)),
            //                                                            )),
            //                                                          ),
            //                                                        ),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(height: 8.0),
            //                                                  if (iserror)
            //                                                    const Text(
            //                                                      "Please fill in all fields correctly.",
            //                                                      style: TextStyle(
            //                                                          color: Colors
            //                                                              .redAccent),
            //                                                    ),
            //                                                ],
            //                                              ),
            //                                            ),
            //                                          );
            //                                        },
            //                                      );
            //                                    },
            //                                  );
            //                                }
            //                                if (widget.properties.propertyTypeData!
            //                                            .isMultiunit! ==
            //                                        false &&
            //                                    widget.properties.propertyTypeData!
            //                                            .propertyType ==
            //                                        'Commercial') {
            //                                  showDialog(
            //                                    context: context,
            //                                    builder: (BuildContext context) {
            //                                      bool isChecked =
            //                                          false; // Moved isChecked inside the StatefulBuilder
            //                                      return StatefulBuilder(
            //                                        builder: (BuildContext context,
            //                                            StateSetter setState) {
            //                                          return AlertDialog(
            //                                            backgroundColor:
            //                                                Colors.white,
            //                                            surfaceTintColor:
            //                                                Colors.white,
            //                                            content:
            //                                                SingleChildScrollView(
            //                                              child: Column(
            //                                                children: [
            //                                                  Row(
            //                                                    children: [
            //                                                      const Text(
            //                                                        "Add Unit Details",
            //                                                        style:
            //                                                            TextStyle(
            //                                                          color: Color
            //                                                              .fromRGBO(
            //                                                                  21,
            //                                                                  43,
            //                                                                  81,
            //                                                                  1),
            //                                                          fontWeight:
            //                                                              FontWeight
            //                                                                  .bold,
            //                                                        ),
            //                                                      ),
            //                                                      const Spacer(),
            //                                                      Align(
            //                                                        alignment: Alignment
            //                                                            .centerRight,
            //                                                        child: InkWell(
            //                                                          onTap: () {
            //                                                            Navigator.pop(
            //                                                                context);
            //                                                          },
            //                                                          child: const Icon(
            //                                                              Icons
            //                                                                  .close,
            //                                                              color: Colors
            //                                                                  .black),
            //                                                        ),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  const Row(
            //                                                    children: [
            //                                                      Text(
            //                                                        "SQFT",
            //                                                        style: TextStyle(
            //                                                            color: Color(
            //                                                                0xFF8A95A8),
            //                                                            fontWeight:
            //                                                                FontWeight
            //                                                                    .bold),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  Padding(
            //                                                    padding:
            //                                                        const EdgeInsets
            //                                                            .symmetric(
            //                                                            vertical:
            //                                                                1),
            //                                                    child: Material(
            //                                                      elevation: 3,
            //                                                      borderRadius:
            //                                                          BorderRadius
            //                                                              .circular(
            //                                                                  3),
            //                                                      child:
            //                                                          TextFormField(
            //                                                        controller:
            //                                                            sqft3,
            //                                                        cursorColor:
            //                                                            Colors
            //                                                                .black,
            //                                                        decoration:
            //                                                            InputDecoration(
            //                                                          //  hintText: label,
            //                                                          // labelText: label,
            //                                                          // labelStyle: TextStyle(color: Colors.grey[700]),
            //                                                          filled: true,
            //                                                          fillColor:
            //                                                              Colors
            //                                                                  .white,
            //                                                          border:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                BorderSide
            //                                                                    .none,
            //                                                          ),
            //                                                          enabledBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide:
            //                                                                const BorderSide(
            //                                                                    color:
            //                                                                        Color(0xFF8A95A8)),
            //                                                          ),
            //                                                          focusedBorder:
            //                                                              OutlineInputBorder(
            //                                                            borderRadius:
            //                                                                BorderRadius
            //                                                                    .circular(3),
            //                                                            borderSide: const BorderSide(
            //                                                                color: Color(
            //                                                                    0xFF8A95A8),
            //                                                                width:
            //                                                                    2),
            //                                                          ),
            //                                                          contentPadding: const EdgeInsets.symmetric(
            //                                                              vertical:
            //                                                                  10.0,
            //                                                              horizontal:
            //                                                                  10.0),
            //                                                        ),
            //                                                      ),
            //                                                    ),
            //                                                  ),
            //                                                  const SizedBox(
            //                                                    height: 10,
            //                                                  ),
            //                                                  const Row(
            //                                                    children: [
            //                                                      Text(
            //                                                        'Photo',
            //                                                        style: TextStyle(
            //                                                            color: Colors
            //                                                                .black),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(height: 8.0),
            //                                                  Row(
            //                                                    children: [
            //                                                      GestureDetector(
            //                                                        onTap: () {
            //                                                          _pickImage()
            //                                                              .then(
            //                                                                  (_) {
            //                                                            setState(
            //                                                                () {}); // Rebuild the widget after selecting the image
            //                                                          });
            //                                                        },
            //                                                        child: const Text(
            //                                                          '+ Add',
            //                                                          style: TextStyle(
            //                                                              color: Colors
            //                                                                  .green),
            //                                                        ),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(height: 8.0),
            //                                                  _image != null
            //                                                      ? Column(
            //                                                          children: [
            //                                                            Image.file(
            //                                                              _image!,
            //                                                              height:
            //                                                                  80,
            //                                                              width: 80,
            //                                                              fit: BoxFit
            //                                                                  .cover,
            //                                                            ),
            //                                                            Text(
            //                                                                _uploadedFileName ??
            //                                                                    ""),
            //                                                          ],
            //                                                        )
            //                                                      : const Text(''),
            //                                                  const SizedBox(height: 8.0),
            //                                                  Row(
            //                                                    children: [
            //                                                      const SizedBox(
            //                                                        width: 0,
            //                                                      ),
            //                                                      GestureDetector(
            //                                                        onTap:
            //                                                            () async {
            //                                                          if (sqft3.text
            //                                                              .isEmpty) {
            //                                                            setState(
            //                                                                () {
            //                                                              iserror =
            //                                                                  true;
            //                                                            });
            //                                                          } else {
            //                                                            setState(
            //                                                                () {
            //                                                              isLoading =
            //                                                                  true;
            //                                                              iserror =
            //                                                                  false;
            //                                                            });
            //                                                            SharedPreferences
            //                                                                prefs =
            //                                                                await SharedPreferences
            //                                                                    .getInstance();
            //                                                            String? id =
            //                                                                prefs.getString(
            //                                                                    "adminId");
            //                                                            Properies_summery_Repo()
            //                                                                .Editunit(
            //                                                              rentalsqft:
            //                                                                  sqft3
            //                                                                      .text,
            //                                                              unitId: unitData
            //                                                                  .unitId!,
            //                                                            )
            //                                                                .then(
            //                                                                    (value) {
            //                                                              setState(
            //                                                                  () {
            //                                                                isLoading =
            //                                                                    false;
            //                                                              });
            //
            //                                                              Navigator.of(
            //                                                                      context)
            //                                                                  .pop(
            //                                                                      true);
            //                                                            }).catchError(
            //                                                                    (e) {
            //                                                              setState(
            //                                                                  () {
            //                                                                isLoading =
            //                                                                    false;
            //                                                              });
            //                                                            });
            //                                                          }
            //                                                        },
            //                                                        child: Material(
            //                                                          elevation: 3,
            //                                                          borderRadius:
            //                                                              const BorderRadius
            //                                                                  .all(
            //                                                            Radius
            //                                                                .circular(
            //                                                                    5),
            //                                                          ),
            //                                                          child:
            //                                                              Container(
            //                                                            height: 30,
            //                                                            width: 80,
            //                                                            decoration:
            //                                                                const BoxDecoration(
            //                                                              color: Color
            //                                                                  .fromRGBO(
            //                                                                      21,
            //                                                                      43,
            //                                                                      81,
            //                                                                      1),
            //                                                              borderRadius:
            //                                                                  BorderRadius
            //                                                                      .all(
            //                                                                Radius.circular(
            //                                                                    5),
            //                                                              ),
            //                                                            ),
            //                                                            child: const Center(
            //                                                                child: Text(
            //                                                              "Save",
            //                                                              style: TextStyle(
            //                                                                  fontWeight: FontWeight
            //                                                                      .w500,
            //                                                                  color:
            //                                                                      Colors.white),
            //                                                            )),
            //                                                          ),
            //                                                        ),
            //                                                      ),
            //                                                      const SizedBox(
            //                                                          width: 10),
            //                                                      GestureDetector(
            //                                                        onTap: () {
            //                                                          Navigator.pop(
            //                                                              context);
            //                                                        },
            //                                                        child: Material(
            //                                                          elevation: 3,
            //                                                          borderRadius:
            //                                                              const BorderRadius
            //                                                                  .all(
            //                                                            Radius
            //                                                                .circular(
            //                                                                    5),
            //                                                          ),
            //                                                          child:
            //                                                              Container(
            //                                                            height: 30,
            //                                                            width: 80,
            //                                                            decoration:
            //                                                                const BoxDecoration(
            //                                                              color: Colors
            //                                                                  .white,
            //                                                              borderRadius:
            //                                                                  BorderRadius
            //                                                                      .all(
            //                                                                Radius.circular(
            //                                                                    5),
            //                                                              ),
            //                                                            ),
            //                                                            child: const Center(
            //                                                                child: Text(
            //                                                              "Cancel",
            //                                                              style: TextStyle(
            //                                                                  fontWeight: FontWeight
            //                                                                      .w500,
            //                                                                  color: Color.fromRGBO(
            //                                                                      21,
            //                                                                      43,
            //                                                                      81,
            //                                                                      1)),
            //                                                            )),
            //                                                          ),
            //                                                        ),
            //                                                      ),
            //                                                    ],
            //                                                  ),
            //                                                  const SizedBox(height: 8.0),
            //                                                  if (iserror)
            //                                                    const Text(
            //                                                      "Please fill in all fields correctly.",
            //                                                      style: TextStyle(
            //                                                          color: Colors
            //                                                              .redAccent),
            //                                                    ),
            //                                                ],
            //                                              ),
            //                                            ),
            //                                          );
            //                                        },
            //                                      );
            //                                    },
            //                                  );
            //                                }
            //                              },
            //                            ),
            //                          ),
            //                        ],
            //                      );
            //                    }).toList(),
            //                  ),
            //                ),
            //              ),
            //            );
            //          },
            //        ),
            //      ),

            //this is for mutiunit add button show
            /*this for single unit*/
            if (!showdetails &&
                widget.properties.propertyTypeData!.isMultiunit! == false)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<unit_properties>>(
                  future: Properies_summery_Repo()
                      .fetchunit(widget.properties.rentalId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 40.0,
                      ));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available'));
                    }
                    final data = snapshot.data!;
                    //print('rentalimage${data.first.rentalImages}');
                    //print('$image_url${data[0].rentalImages}');
                    // print('hii$image_url${data[0].rentalImages!.first}');
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       left: 10, right: 10, bottom: 10),
                          //   child: Container(
                          //     //height: screenHeight * 0.82,
                          //     width: double.infinity,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(12.0),
                          //       color: Colors.white,
                          //       border: Border.all(
                          //         color: const Color.fromRGBO(21, 43, 83, 1),
                          //         width: 1,
                          //       ),
                          //     ),
                          //     child: Column(
                          //       // mainAxisAlignment: MainAxisAlignment.start,
                          //       // crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: [
                          //         SizedBox(
                          //           height: 10,
                          //         ),
                          //         Row(
                          //           children: [
                          //             SizedBox(
                          //               width: 5,
                          //             ),
                          //             Padding(
                          //               padding: const EdgeInsets.all(8.0),
                          //               child: Container(
                          //                 height: 36,
                          //                 width: 100,
                          //                 child: ElevatedButton(
                          //                   onPressed: () {
                          //                     sqft3.text = data[0].rentalsqft!;
                          //                     bath3.text = data[0].rentalbath!;
                          //                     bed3.text = data[0].rentalbed!;
                          //                     street3.text =
                          //                         data[0].rentalunitadress!;
                          //                     unitnum.text =
                          //                         data[0].rentalunit!;
                          //                     //_image = data[0].p;
                          //                     if (widget
                          //                                 .properties
                          //                                 .propertyTypeData!
                          //                                 .isMultiunit! ==
                          //                             false &&
                          //                         widget
                          //                                 .properties
                          //                                 .propertyTypeData!
                          //                                 .propertyType ==
                          //                             'Residential') {
                          //                       showDialog(
                          //                         context: context,
                          //                         builder:
                          //                             (BuildContext context) {
                          //                           bool isChecked =
                          //                               false; // Moved isChecked inside the StatefulBuilder
                          //                           return StatefulBuilder(
                          //                             builder:
                          //                                 (BuildContext context,
                          //                                     StateSetter
                          //                                         setState) {
                          //                               return AlertDialog(
                          //                                 backgroundColor:
                          //                                     Colors.white,
                          //                                 surfaceTintColor:
                          //                                     Colors.white,
                          //                                 content:
                          //                                     SingleChildScrollView(
                          //                                   child: Column(
                          //                                     children: [
                          //                                       Row(
                          //                                         children: [
                          //                                           const Text(
                          //                                             "Edit Unit Details",
                          //                                             style:
                          //                                                 TextStyle(
                          //                                               color: Color.fromRGBO(
                          //                                                   21,
                          //                                                   43,
                          //                                                   81,
                          //                                                   1),
                          //                                               fontWeight:
                          //                                                   FontWeight.bold,
                          //                                             ),
                          //                                           ),
                          //                                           const Spacer(),
                          //                                           Align(
                          //                                             alignment:
                          //                                                 Alignment
                          //                                                     .centerRight,
                          //                                             child:
                          //                                                 InkWell(
                          //                                               onTap:
                          //                                                   () {
                          //                                                 Navigator.pop(
                          //                                                     context);
                          //                                               },
                          //                                               child: const Icon(
                          //                                                   Icons
                          //                                                       .close,
                          //                                                   color:
                          //                                                       Colors.black),
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       const Row(
                          //                                         children: [
                          //                                           Text(
                          //                                             "SQFT",
                          //                                             style: TextStyle(
                          //                                                 color: Color(
                          //                                                     0xFF8A95A8),
                          //                                                 fontWeight:
                          //                                                     FontWeight.bold),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       Padding(
                          //                                         padding: const EdgeInsets
                          //                                             .symmetric(
                          //                                             vertical:
                          //                                                 1),
                          //                                         child:
                          //                                             Material(
                          //                                           elevation:
                          //                                               3,
                          //                                           borderRadius:
                          //                                               BorderRadius
                          //                                                   .circular(3),
                          //                                           child:
                          //                                               TextFormField(
                          //                                             controller:
                          //                                                 sqft3,
                          //                                             cursorColor:
                          //                                                 Colors
                          //                                                     .black,
                          //                                             decoration:
                          //                                                 InputDecoration(
                          //                                               //  hintText: label,
                          //                                               // labelText: label,
                          //                                               // labelStyle: TextStyle(color: Colors.grey[700]),
                          //                                               filled:
                          //                                                   true,
                          //                                               fillColor:
                          //                                                   Colors.white,
                          //                                               border:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     BorderSide.none,
                          //                                               ),
                          //                                               enabledBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     const BorderSide(color: Color(0xFF8A95A8)),
                          //                                               ),
                          //                                               focusedBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide: const BorderSide(
                          //                                                     color: Color(0xFF8A95A8),
                          //                                                     width: 2),
                          //                                               ),
                          //                                               contentPadding: const EdgeInsets
                          //                                                   .symmetric(
                          //                                                   vertical:
                          //                                                       10.0,
                          //                                                   horizontal:
                          //                                                       10.0),
                          //                                             ),
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       const Row(
                          //                                         children: [
                          //                                           Text(
                          //                                             "bath",
                          //                                             style: TextStyle(
                          //                                                 color: Color(
                          //                                                     0xFF8A95A8),
                          //                                                 fontWeight:
                          //                                                     FontWeight.bold),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       Padding(
                          //                                         padding: const EdgeInsets
                          //                                             .symmetric(
                          //                                             vertical:
                          //                                                 1),
                          //                                         child:
                          //                                             Material(
                          //                                           elevation:
                          //                                               3,
                          //                                           borderRadius:
                          //                                               BorderRadius
                          //                                                   .circular(3),
                          //                                           child:
                          //                                               TextFormField(
                          //                                             controller:
                          //                                                 bath3,
                          //                                             cursorColor:
                          //                                                 Colors
                          //                                                     .black,
                          //                                             decoration:
                          //                                                 InputDecoration(
                          //                                               //  hintText: label,
                          //                                               // labelText: label,
                          //                                               // labelStyle: TextStyle(color: Colors.grey[700]),
                          //                                               filled:
                          //                                                   true,
                          //                                               fillColor:
                          //                                                   Colors.white,
                          //                                               border:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     BorderSide.none,
                          //                                               ),
                          //                                               enabledBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     const BorderSide(color: Color(0xFF8A95A8)),
                          //                                               ),
                          //                                               focusedBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide: const BorderSide(
                          //                                                     color: Color(0xFF8A95A8),
                          //                                                     width: 2),
                          //                                               ),
                          //                                               contentPadding: const EdgeInsets
                          //                                                   .symmetric(
                          //                                                   vertical:
                          //                                                       10.0,
                          //                                                   horizontal:
                          //                                                       10.0),
                          //                                             ),
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       const Row(
                          //                                         children: [
                          //                                           Text(
                          //                                             "bed",
                          //                                             style: TextStyle(
                          //                                                 color: Color(
                          //                                                     0xFF8A95A8),
                          //                                                 fontWeight:
                          //                                                     FontWeight.bold),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       Padding(
                          //                                         padding: const EdgeInsets
                          //                                             .symmetric(
                          //                                             vertical:
                          //                                                 1),
                          //                                         child:
                          //                                             Material(
                          //                                           elevation:
                          //                                               3,
                          //                                           borderRadius:
                          //                                               BorderRadius
                          //                                                   .circular(3),
                          //                                           child:
                          //                                               TextFormField(
                          //                                             controller:
                          //                                                 bed3,
                          //                                             cursorColor:
                          //                                                 Colors
                          //                                                     .black,
                          //                                             decoration:
                          //                                                 InputDecoration(
                          //                                               //  hintText: label,
                          //                                               // labelText: label,
                          //                                               // labelStyle: TextStyle(color: Colors.grey[700]),
                          //                                               filled:
                          //                                                   true,
                          //                                               fillColor:
                          //                                                   Colors.white,
                          //                                               border:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     BorderSide.none,
                          //                                               ),
                          //                                               enabledBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     const BorderSide(color: Color(0xFF8A95A8)),
                          //                                               ),
                          //                                               focusedBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide: const BorderSide(
                          //                                                     color: Color(0xFF8A95A8),
                          //                                                     width: 2),
                          //                                               ),
                          //                                               contentPadding: const EdgeInsets
                          //                                                   .symmetric(
                          //                                                   vertical:
                          //                                                       10.0,
                          //                                                   horizontal:
                          //                                                       10.0),
                          //                                             ),
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       const Row(
                          //                                         children: [
                          //                                           Text(
                          //                                             'Photo',
                          //                                             style: TextStyle(
                          //                                                 color:
                          //                                                     Colors.black),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                           height:
                          //                                               8.0),
                          //                                       Row(
                          //                                         children: [
                          //                                           GestureDetector(
                          //                                             onTap:
                          //                                                 () {
                          //                                               _pickImage()
                          //                                                   .then((_) {
                          //                                                 setState(
                          //                                                     () {}); // Rebuild the widget after selecting the image
                          //                                               });
                          //                                             },
                          //                                             child:
                          //                                                 const Text(
                          //                                               '+ Add',
                          //                                               style: TextStyle(
                          //                                                   color:
                          //                                                       Colors.green),
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       _image != null
                          //                                           ? Column(
                          //                                               children: [
                          //                                                 Image
                          //                                                     .file(
                          //                                                   _image!,
                          //                                                   height:
                          //                                                       80,
                          //                                                   width:
                          //                                                       80,
                          //                                                   fit:
                          //                                                       BoxFit.cover,
                          //                                                 ),
                          //                                                 Text(_uploadedFileName ??
                          //                                                     ""),
                          //                                               ],
                          //                                             )
                          //                                           : const Text(
                          //                                               ''),
                          //                                       const SizedBox(
                          //                                           height:
                          //                                               8.0),
                          //                                       Row(
                          //                                         children: [
                          //                                           const SizedBox(
                          //                                             width: 0,
                          //                                           ),
                          //                                           GestureDetector(
                          //                                             onTap:
                          //                                                 () async {
                          //                                               if (sqft3
                          //                                                   .text
                          //                                                   .isEmpty) {
                          //                                                 setState(
                          //                                                     () {
                          //                                                   iserror =
                          //                                                       true;
                          //                                                 });
                          //                                               } else {
                          //                                                 setState(
                          //                                                     () {
                          //                                                   isLoading =
                          //                                                       true;
                          //                                                   iserror =
                          //                                                       false;
                          //                                                 });
                          //                                                 SharedPreferences
                          //                                                     prefs =
                          //                                                     await SharedPreferences.getInstance();
                          //
                          //                                                 String?
                          //                                                     id =
                          //                                                     prefs.getString("adminId");
                          //                                                 Properies_summery_Repo()
                          //                                                     .Editunit(rentalsqft: sqft3.text, rentalunitadress: street3.text, rentalbath: bath3.text, rentalbed: bed3.text, unitId: unit?.unitId, adminId: id, rentalId: unit?.rentalId)
                          //                                                     .then((value) {
                          //                                                   setState(() {
                          //                                                     isLoading = false;
                          //                                                   });
                          //                                                   Navigator.of(context).pop(true);
                          //                                                   reload_Screen();
                          //                                                 }).catchError((e) {
                          //                                                   setState(() {
                          //                                                     isLoading = false;
                          //                                                   });
                          //                                                 });
                          //                                               }
                          //                                             },
                          //                                             child:
                          //                                                 Material(
                          //                                               elevation:
                          //                                                   3,
                          //                                               borderRadius:
                          //                                                   const BorderRadius.all(
                          //                                                 Radius.circular(
                          //                                                     5),
                          //                                               ),
                          //                                               child:
                          //                                                   Container(
                          //                                                 height:
                          //                                                     30,
                          //                                                 width:
                          //                                                     80,
                          //                                                 decoration:
                          //                                                     const BoxDecoration(
                          //                                                   color: Color.fromRGBO(
                          //                                                       21,
                          //                                                       43,
                          //                                                       81,
                          //                                                       1),
                          //                                                   borderRadius:
                          //                                                       BorderRadius.all(
                          //                                                     Radius.circular(5),
                          //                                                   ),
                          //                                                 ),
                          //                                                 child: const Center(
                          //                                                     child: Text(
                          //                                                   "Save",
                          //                                                   style:
                          //                                                       TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                          //                                                 )),
                          //                                               ),
                          //                                             ),
                          //                                           ),
                          //                                           const SizedBox(
                          //                                               width:
                          //                                                   10),
                          //                                           GestureDetector(
                          //                                             onTap:
                          //                                                 () {
                          //                                               Navigator.pop(
                          //                                                   context);
                          //                                             },
                          //                                             child:
                          //                                                 Material(
                          //                                               elevation:
                          //                                                   3,
                          //                                               borderRadius:
                          //                                                   const BorderRadius.all(
                          //                                                 Radius.circular(
                          //                                                     5),
                          //                                               ),
                          //                                               child:
                          //                                                   Container(
                          //                                                 height:
                          //                                                     30,
                          //                                                 width:
                          //                                                     80,
                          //                                                 decoration:
                          //                                                     const BoxDecoration(
                          //                                                   color:
                          //                                                       Colors.white,
                          //                                                   borderRadius:
                          //                                                       BorderRadius.all(
                          //                                                     Radius.circular(5),
                          //                                                   ),
                          //                                                 ),
                          //                                                 child: const Center(
                          //                                                     child: Text(
                          //                                                   "Cancel",
                          //                                                   style:
                          //                                                       TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                          //                                                 )),
                          //                                               ),
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                           height:
                          //                                               8.0),
                          //                                       if (iserror)
                          //                                         const Text(
                          //                                           "Please fill in all fields correctly.",
                          //                                           style: TextStyle(
                          //                                               color: Colors
                          //                                                   .redAccent),
                          //                                         ),
                          //                                     ],
                          //                                   ),
                          //                                 ),
                          //                               );
                          //                             },
                          //                           );
                          //                         },
                          //                       );
                          //                     }
                          //                     if (widget
                          //                                 .properties
                          //                                 .propertyTypeData!
                          //                                 .isMultiunit! ==
                          //                             false &&
                          //                         widget
                          //                                 .properties
                          //                                 .propertyTypeData!
                          //                                 .propertyType ==
                          //                             'Commercial') {
                          //                       showDialog(
                          //                         context: context,
                          //                         builder:
                          //                             (BuildContext context) {
                          //                           bool isChecked =
                          //                               false; // Moved isChecked inside the StatefulBuilder
                          //                           return StatefulBuilder(
                          //                             builder:
                          //                                 (BuildContext context,
                          //                                     StateSetter
                          //                                         setState) {
                          //                               return AlertDialog(
                          //                                 backgroundColor:
                          //                                     Colors.white,
                          //                                 surfaceTintColor:
                          //                                     Colors.white,
                          //                                 content:
                          //                                     SingleChildScrollView(
                          //                                   child: Column(
                          //                                     children: [
                          //                                       Row(
                          //                                         children: [
                          //                                           const Text(
                          //                                             "Edit Unit Details",
                          //                                             style:
                          //                                                 TextStyle(
                          //                                               color: Color.fromRGBO(
                          //                                                   21,
                          //                                                   43,
                          //                                                   81,
                          //                                                   1),
                          //                                               fontWeight:
                          //                                                   FontWeight.bold,
                          //                                             ),
                          //                                           ),
                          //                                           const Spacer(),
                          //                                           Align(
                          //                                             alignment:
                          //                                                 Alignment
                          //                                                     .centerRight,
                          //                                             child:
                          //                                                 InkWell(
                          //                                               onTap:
                          //                                                   () {
                          //                                                 Navigator.pop(
                          //                                                     context);
                          //                                               },
                          //                                               child: const Icon(
                          //                                                   Icons
                          //                                                       .close,
                          //                                                   color:
                          //                                                       Colors.black),
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       const Row(
                          //                                         children: [
                          //                                           Text(
                          //                                             "SQFT",
                          //                                             style: TextStyle(
                          //                                                 color: Color(
                          //                                                     0xFF8A95A8),
                          //                                                 fontWeight:
                          //                                                     FontWeight.bold),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       Padding(
                          //                                         padding: const EdgeInsets
                          //                                             .symmetric(
                          //                                             vertical:
                          //                                                 1),
                          //                                         child:
                          //                                             Material(
                          //                                           elevation:
                          //                                               3,
                          //                                           borderRadius:
                          //                                               BorderRadius
                          //                                                   .circular(3),
                          //                                           child:
                          //                                               TextFormField(
                          //                                             controller:
                          //                                                 sqft3,
                          //                                             cursorColor:
                          //                                                 Colors
                          //                                                     .black,
                          //                                             decoration:
                          //                                                 InputDecoration(
                          //                                               //  hintText: label,
                          //                                               // labelText: label,
                          //                                               // labelStyle: TextStyle(color: Colors.grey[700]),
                          //                                               filled:
                          //                                                   true,
                          //                                               fillColor:
                          //                                                   Colors.white,
                          //                                               border:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     BorderSide.none,
                          //                                               ),
                          //                                               enabledBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide:
                          //                                                     const BorderSide(color: Color(0xFF8A95A8)),
                          //                                               ),
                          //                                               focusedBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.circular(3),
                          //                                                 borderSide: const BorderSide(
                          //                                                     color: Color(0xFF8A95A8),
                          //                                                     width: 2),
                          //                                               ),
                          //                                               contentPadding: const EdgeInsets
                          //                                                   .symmetric(
                          //                                                   vertical:
                          //                                                       10.0,
                          //                                                   horizontal:
                          //                                                       10.0),
                          //                                             ),
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                       const SizedBox(
                          //                                         height: 10,
                          //                                       ),
                          //                                       const Row(
                          //                                         children: [
                          //                                           Text(
                          //                                             'Photo',
                          //                                             style: TextStyle(
                          //                                                 color:
                          //                                                     Colors.black),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                           height:
                          //                                               8.0),
                          //                                       Row(
                          //                                         children: [
                          //                                           GestureDetector(
                          //                                             onTap:
                          //                                                 () {
                          //                                               _pickImage()
                          //                                                   .then((_) {
                          //                                                 setState(
                          //                                                     () {}); // Rebuild the widget after selecting the image
                          //                                               });
                          //                                             },
                          //                                             child:
                          //                                                 const Text(
                          //                                               '+ Add',
                          //                                               style: TextStyle(
                          //                                                   color:
                          //                                                       Colors.green),
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                           height:
                          //                                               8.0),
                          //                                       _image != null
                          //                                           ? Column(
                          //                                               children: [
                          //                                                 Image
                          //                                                     .file(
                          //                                                   _image!,
                          //                                                   height:
                          //                                                       80,
                          //                                                   width:
                          //                                                       80,
                          //                                                   fit:
                          //                                                       BoxFit.cover,
                          //                                                 ),
                          //                                                 Text(_uploadedFileName ??
                          //                                                     ""),
                          //                                               ],
                          //                                             )
                          //                                           : const Text(
                          //                                               ''),
                          //                                       const SizedBox(
                          //                                           height:
                          //                                               8.0),
                          //                                       Row(
                          //                                         children: [
                          //                                           const SizedBox(
                          //                                             width: 0,
                          //                                           ),
                          //                                           GestureDetector(
                          //                                             onTap:
                          //                                                 () async {
                          //                                               if (sqft3
                          //                                                   .text
                          //                                                   .isEmpty) {
                          //                                                 setState(
                          //                                                     () {
                          //                                                   iserror =
                          //                                                       true;
                          //                                                 });
                          //                                               } else {
                          //                                                 setState(
                          //                                                     () {
                          //                                                   isLoading =
                          //                                                       true;
                          //                                                   iserror =
                          //                                                       false;
                          //                                                 });
                          //                                                 SharedPreferences
                          //                                                     prefs =
                          //                                                     await SharedPreferences.getInstance();
                          //                                                 String?
                          //                                                     id =
                          //                                                     prefs.getString("adminId");
                          //                                                 Properies_summery_Repo()
                          //                                                     .Editunit(
                          //                                                   rentalsqft:
                          //                                                       sqft3.text,
                          //                                                   unitId:
                          //                                                       unit?.unitId,
                          //                                                 )
                          //                                                     .then((value) {
                          //                                                   setState(() {
                          //                                                     isLoading = false;
                          //                                                   });
                          //
                          //                                                   Navigator.of(context).pop(true);
                          //                                                 }).catchError((e) {
                          //                                                   setState(() {
                          //                                                     isLoading = false;
                          //                                                   });
                          //                                                 });
                          //                                               }
                          //                                             },
                          //                                             child:
                          //                                                 Material(
                          //                                               elevation:
                          //                                                   3,
                          //                                               borderRadius:
                          //                                                   const BorderRadius.all(
                          //                                                 Radius.circular(
                          //                                                     5),
                          //                                               ),
                          //                                               child:
                          //                                                   Container(
                          //                                                 height:
                          //                                                     30,
                          //                                                 width:
                          //                                                     80,
                          //                                                 decoration:
                          //                                                     const BoxDecoration(
                          //                                                   color: Color.fromRGBO(
                          //                                                       21,
                          //                                                       43,
                          //                                                       81,
                          //                                                       1),
                          //                                                   borderRadius:
                          //                                                       BorderRadius.all(
                          //                                                     Radius.circular(5),
                          //                                                   ),
                          //                                                 ),
                          //                                                 child: const Center(
                          //                                                     child: Text(
                          //                                                   "Save",
                          //                                                   style:
                          //                                                       TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                          //                                                 )),
                          //                                               ),
                          //                                             ),
                          //                                           ),
                          //                                           const SizedBox(
                          //                                               width:
                          //                                                   10),
                          //                                           GestureDetector(
                          //                                             onTap:
                          //                                                 () {
                          //                                               Navigator.pop(
                          //                                                   context);
                          //                                             },
                          //                                             child:
                          //                                                 Material(
                          //                                               elevation:
                          //                                                   3,
                          //                                               borderRadius:
                          //                                                   const BorderRadius.all(
                          //                                                 Radius.circular(
                          //                                                     5),
                          //                                               ),
                          //                                               child:
                          //                                                   Container(
                          //                                                 height:
                          //                                                     30,
                          //                                                 width:
                          //                                                     80,
                          //                                                 decoration:
                          //                                                     const BoxDecoration(
                          //                                                   color:
                          //                                                       Colors.white,
                          //                                                   borderRadius:
                          //                                                       BorderRadius.all(
                          //                                                     Radius.circular(5),
                          //                                                   ),
                          //                                                 ),
                          //                                                 child: const Center(
                          //                                                     child: Text(
                          //                                                   "Cancel",
                          //                                                   style:
                          //                                                       TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                          //                                                 )),
                          //                                               ),
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       const SizedBox(
                          //                                           height:
                          //                                               8.0),
                          //                                       if (iserror)
                          //                                         const Text(
                          //                                           "Please fill in all fields correctly.",
                          //                                           style: TextStyle(
                          //                                               color: Colors
                          //                                                   .redAccent),
                          //                                         ),
                          //                                     ],
                          //                                   ),
                          //                                 ),
                          //                               );
                          //                             },
                          //                           );
                          //                         },
                          //                       );
                          //                     }
                          //                   },
                          //                   child: const Text(
                          //                     'Update unit',
                          //                     style: TextStyle(
                          //                         fontSize: 12,
                          //                         color: Colors.white),
                          //                   ),
                          //                   style: ElevatedButton.styleFrom(
                          //                       backgroundColor:
                          //                           const Color.fromRGBO(
                          //                               21, 43, 83, 1),
                          //                       shape: RoundedRectangleBorder(
                          //                           borderRadius:
                          //                               BorderRadius.circular(
                          //                                   12.0))),
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //         SizedBox(
                          //           height: 10,
                          //         ),
                          //         Container(
                          //           width: 150,
                          //           decoration:
                          //               const BoxDecoration(color: Colors.blue),
                          //           child: Image.network(
                          //             data[0].rentalImages!.first != null
                          //                 ? "$image_url${data[0].rentalImages!.first}"
                          //                 : 'https://i.pinimg.com/originals/59/11/81/591181790b40c5e1f8cc04b55ebdbf25.jpg',
                          //             fit: BoxFit.fill,
                          //             height: 100,
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.all(16.0),
                          //           child: Container(
                          //             width: double.infinity,
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(left: 16),
                          //                   child: Text(
                          //                     'ADDRESS',
                          //                     style: TextStyle(
                          //                         fontSize: 12,
                          //                         color: Colors.grey[800]),
                          //                   ),
                          //                 ),
                          //                 Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(left: 16),
                          //                   child: Text(
                          //                     '${widget.properties?.rentalAddress}',
                          //                     style: TextStyle(
                          //                         fontSize: 12,
                          //                         color: Colors.grey[800]),
                          //                   ),
                          //                 ),
                          //                 Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(left: 16),
                          //                   child: Text(
                          //                     '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                          //                     style: TextStyle(
                          //                         fontSize: 12,
                          //                         color: Colors.grey[800]),
                          //                   ),
                          //                 ),
                          //                 Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(left: 16),
                          //                   child: Text(
                          //                     '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                          //                     style: TextStyle(
                          //                         fontSize: 12,
                          //                         color: Colors.grey[800]),
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.all(8.0),
                          //           child: Container(
                          //             // height: screenHeight * 0.26,
                          //             width: double.infinity,
                          //             decoration: BoxDecoration(
                          //               borderRadius:
                          //                   BorderRadius.circular(12.0),
                          //               color: Colors.white,
                          //               border: Border.all(
                          //                 color: const Color.fromRGBO(
                          //                     21, 43, 83, 1),
                          //                 width: 1,
                          //               ),
                          //             ),
                          //             child: Column(
                          //               children: [
                          //                 const Padding(
                          //                   padding: EdgeInsets.all(8.0),
                          //                   child: SizedBox(
                          //                     width: double.infinity,
                          //                     child: Text(
                          //                       'Add Lease',
                          //                       style: TextStyle(
                          //                         fontSize: 12,
                          //                         color: Color.fromRGBO(
                          //                             21, 43, 83, 1),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 Padding(
                          //                   padding: const EdgeInsets.all(8.0),
                          //                   child: Container(
                          //                     height: 36,
                          //                     width: double.infinity,
                          //                     child: ElevatedButton(
                          //                       onPressed: () {
                          //                         Navigator.push(
                          //                             context,
                          //                             MaterialPageRoute(
                          //                                 builder: (context) =>
                          //                                     addLease3()));
                          //                       },
                          //                       child: const Text(
                          //                         'Add Lease',
                          //                         style: TextStyle(
                          //                             fontSize: 12,
                          //                             color: Colors.white),
                          //                       ),
                          //                       style: ElevatedButton.styleFrom(
                          //                           backgroundColor:
                          //                               const Color.fromRGBO(
                          //                                   21, 43, 83, 1),
                          //                           shape:
                          //                               RoundedRectangleBorder(
                          //                                   borderRadius:
                          //                                       BorderRadius
                          //                                           .circular(
                          //                                               10.0))),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 const Padding(
                          //                   padding: EdgeInsets.all(8.0),
                          //                   child: SizedBox(
                          //                     width: double.infinity,
                          //                     child: Text(
                          //                       'Rental Applicant',
                          //                       style: TextStyle(
                          //                         fontSize: 12,
                          //                         color: Color.fromRGBO(
                          //                             21, 43, 83, 1),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 Padding(
                          //                   padding: const EdgeInsets.all(8.0),
                          //                   child: Container(
                          //                     height: 36,
                          //                     width: double.infinity,
                          //                     child: ElevatedButton(
                          //                       onPressed: () {
                          //                         Navigator.push(
                          //                             context,
                          //                             MaterialPageRoute(
                          //                                 builder: (context) =>
                          //                                     AddApplicant()));
                          //                       },
                          //                       child: const Text(
                          //                         'Create Applicant',
                          //                         style: TextStyle(
                          //                             fontSize: 12,
                          //                             color: Colors.white),
                          //                       ),
                          //                       style: ElevatedButton.styleFrom(
                          //                           backgroundColor:
                          //                               const Color.fromRGBO(
                          //                                   21, 43, 83, 1),
                          //                           shape:
                          //                               RoundedRectangleBorder(
                          //                                   borderRadius:
                          //                                       BorderRadius
                          //                                           .circular(
                          //                                               10.0))),
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
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
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 36
                                              : 45,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 100
                                              : 150,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              sqft3.text = data[0].rentalsqft!;
                                              bath3.text = data[0].rentalbath!;
                                              bed3.text = data[0].rentalbed!;
                                              street3.text =
                                                  data[0].rentalunitadress!;
                                              unitnum.text =
                                                  data[0].rentalunit!;
                                              //_image = data[0].p;
                                              if (widget
                                                          .properties
                                                          .propertyTypeData!
                                                          .isMultiunit! ==
                                                      false &&
                                                  widget
                                                          .properties
                                                          .propertyTypeData!
                                                          .propertyType ==
                                                      'Residential') {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    bool isChecked =
                                                        false; // Moved isChecked inside the StatefulBuilder
                                                    return StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                              StateSetter
                                                                  setState) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          surfaceTintColor:
                                                              Colors.white,
                                                          content:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      "Edit Unit Details",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Icon(
                                                                            Icons
                                                                                .close,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    Text(
                                                                      "SQFT",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1),
                                                                  child:
                                                                      Material(
                                                                    elevation:
                                                                        3,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          sqft3,
                                                                      cursorColor:
                                                                          Colors
                                                                              .black,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        //  hintText: label,
                                                                        // labelText: label,
                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.white,
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              BorderSide.none,
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              const BorderSide(color: Color(0xFF8A95A8)),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide: const BorderSide(
                                                                              color: Color(0xFF8A95A8),
                                                                              width: 2),
                                                                        ),
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                10.0,
                                                                            horizontal:
                                                                                10.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    Text(
                                                                      "bath",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1),
                                                                  child:
                                                                      Material(
                                                                    elevation:
                                                                        3,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          bath3,
                                                                      cursorColor:
                                                                          Colors
                                                                              .black,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        //  hintText: label,
                                                                        // labelText: label,
                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.white,
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              BorderSide.none,
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              const BorderSide(color: Color(0xFF8A95A8)),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide: const BorderSide(
                                                                              color: Color(0xFF8A95A8),
                                                                              width: 2),
                                                                        ),
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                10.0,
                                                                            horizontal:
                                                                                10.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    Text(
                                                                      "bed",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1),
                                                                  child:
                                                                      Material(
                                                                    elevation:
                                                                        3,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          bed3,
                                                                      cursorColor:
                                                                          Colors
                                                                              .black,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        //  hintText: label,
                                                                        // labelText: label,
                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.white,
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              BorderSide.none,
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              const BorderSide(color: Color(0xFF8A95A8)),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide: const BorderSide(
                                                                              color: Color(0xFF8A95A8),
                                                                              width: 2),
                                                                        ),
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                10.0,
                                                                            horizontal:
                                                                                10.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    Text(
                                                                      'Photo',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _pickImage()
                                                                            .then((_) {
                                                                          setState(
                                                                              () {}); // Rebuild the widget after selecting the image
                                                                        });
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        '+ Add',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                _image != null
                                                                    ? Column(
                                                                        children: [
                                                                          Image
                                                                              .file(
                                                                            _image!,
                                                                            height:
                                                                                80,
                                                                            width:
                                                                                80,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                          Text(_uploadedFileName ??
                                                                              ""),
                                                                        ],
                                                                      )
                                                                    : const Text(
                                                                        ''),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width: 0,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        if (sqft3
                                                                            .text
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            iserror =
                                                                                true;
                                                                          });
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            isLoading =
                                                                                true;
                                                                            iserror =
                                                                                false;
                                                                          });
                                                                          SharedPreferences
                                                                              prefs =
                                                                              await SharedPreferences.getInstance();

                                                                          String?
                                                                              id =
                                                                              prefs.getString("adminId");
                                                                          Properies_summery_Repo()
                                                                              .Editunit(rentalsqft: sqft3.text, rentalunitadress: street3.text, rentalbath: bath3.text, rentalbed: bed3.text, unitId: unit?.unitId, adminId: id, rentalId: unit?.rentalId)
                                                                              .then((value) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                            Navigator.of(context).pop(true);
                                                                            reload_Screen();
                                                                          }).catchError((e) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          Material(
                                                                        elevation:
                                                                            3,
                                                                        borderRadius:
                                                                            const BorderRadius.all(
                                                                          Radius.circular(
                                                                              5),
                                                                        ),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              80,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            borderRadius:
                                                                                BorderRadius.all(
                                                                              Radius.circular(5),
                                                                            ),
                                                                          ),
                                                                          child: const Center(
                                                                              child: Text(
                                                                            "Save",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                                                          )),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Material(
                                                                        elevation:
                                                                            3,
                                                                        borderRadius:
                                                                            const BorderRadius.all(
                                                                          Radius.circular(
                                                                              5),
                                                                        ),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              80,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            borderRadius:
                                                                                BorderRadius.all(
                                                                              Radius.circular(5),
                                                                            ),
                                                                          ),
                                                                          child: const Center(
                                                                              child: Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                                                                          )),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                if (iserror)
                                                                  const Text(
                                                                    "Please fill in all fields correctly.",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .redAccent),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                              if (widget
                                                          .properties
                                                          .propertyTypeData!
                                                          .isMultiunit! ==
                                                      false &&
                                                  widget
                                                          .properties
                                                          .propertyTypeData!
                                                          .propertyType ==
                                                      'Commercial') {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    bool isChecked =
                                                        false; // Moved isChecked inside the StatefulBuilder
                                                    return StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                              StateSetter
                                                                  setState) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          surfaceTintColor:
                                                              Colors.white,
                                                          content:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      "Edit Unit Details",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Icon(
                                                                            Icons
                                                                                .close,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    Text(
                                                                      "SQFT",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1),
                                                                  child:
                                                                      Material(
                                                                    elevation:
                                                                        3,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          sqft3,
                                                                      cursorColor:
                                                                          Colors
                                                                              .black,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        //  hintText: label,
                                                                        // labelText: label,
                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.white,
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              BorderSide.none,
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide:
                                                                              const BorderSide(color: Color(0xFF8A95A8)),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(3),
                                                                          borderSide: const BorderSide(
                                                                              color: Color(0xFF8A95A8),
                                                                              width: 2),
                                                                        ),
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                10.0,
                                                                            horizontal:
                                                                                10.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    Text(
                                                                      'Photo',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _pickImage()
                                                                            .then((_) {
                                                                          setState(
                                                                              () {}); // Rebuild the widget after selecting the image
                                                                        });
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        '+ Add',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                _image != null
                                                                    ? Column(
                                                                        children: [
                                                                          Image
                                                                              .file(
                                                                            _image!,
                                                                            height:
                                                                                80,
                                                                            width:
                                                                                80,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                          Text(_uploadedFileName ??
                                                                              ""),
                                                                        ],
                                                                      )
                                                                    : const Text(
                                                                        ''),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width: 0,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        if (sqft3
                                                                            .text
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            iserror =
                                                                                true;
                                                                          });
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            isLoading =
                                                                                true;
                                                                            iserror =
                                                                                false;
                                                                          });
                                                                          SharedPreferences
                                                                              prefs =
                                                                              await SharedPreferences.getInstance();
                                                                          String?
                                                                              id =
                                                                              prefs.getString("adminId");
                                                                          Properies_summery_Repo()
                                                                              .Editunit(
                                                                            rentalsqft:
                                                                                sqft3.text,
                                                                            unitId:
                                                                                unit?.unitId,
                                                                          )
                                                                              .then((value) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });

                                                                            Navigator.of(context).pop(true);
                                                                          }).catchError((e) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          Material(
                                                                        elevation:
                                                                            3,
                                                                        borderRadius:
                                                                            const BorderRadius.all(
                                                                          Radius.circular(
                                                                              5),
                                                                        ),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              80,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            borderRadius:
                                                                                BorderRadius.all(
                                                                              Radius.circular(5),
                                                                            ),
                                                                          ),
                                                                          child: const Center(
                                                                              child: Text(
                                                                            "Save",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                                                          )),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Material(
                                                                        elevation:
                                                                            3,
                                                                        borderRadius:
                                                                            const BorderRadius.all(
                                                                          Radius.circular(
                                                                              5),
                                                                        ),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              80,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            borderRadius:
                                                                                BorderRadius.all(
                                                                              Radius.circular(5),
                                                                            ),
                                                                          ),
                                                                          child: const Center(
                                                                              child: Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                                                                          )),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                if (iserror)
                                                                  const Text(
                                                                    "Please fill in all fields correctly.",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .redAccent),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            child: Text(
                                              'Update unit',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 13
                                                          : 18,
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0))),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      SizedBox(
                                        //  height: screenHeight * 0.30,
                                        //width: screenWidth * 0.8,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image(
                                            image: NetworkImage(
                                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRe_jcaXNfnjMStYxu0ScZHngqxm-cTA9lJbB9DrbhxHQ6G-aAvZFZFu9-xSz31R5gKgjM&usqp=CAU'),
                                            fit: BoxFit.fill,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 150
                                                : 220,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Text(
                                              'ADDRESS',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 20,
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Text(
                                              '${widget.properties?.rentalAddress}',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 13
                                                          : 18,
                                                  color: Colors.grey[800]),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Text(
                                              '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 13
                                                          : 18,
                                                  color: Colors.grey[800]),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Text(
                                              '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 13
                                                          : 18,
                                                  color: Colors.grey[800]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      if (MediaQuery.of(context).size.width >
                                          500)
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              width: 250,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 83, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    // width: double.infinity,
                                                    child: Text(
                                                      'Add Lease',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 36
                                                              : 48,
                                                      // width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {},
                                                        child: Text(
                                                          '       Add Lease    ',
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 14
                                                                  : 18,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0))),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                 /* Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    child: SizedBox(
                                                      //  width: double.infinity,
                                                      child: Text(
                                                        'Rental Applicant',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 36
                                                              : 48,
                                                      //  width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {},
                                                        child: Text(
                                                          'Create Applicant',
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 14
                                                                  : 18,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0))),
                                                      ),
                                                    ),
                                                  ),*/
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(16.0),
                                  //   child:
                                  //   Container(
                                  //     width: double.infinity,
                                  //     child:
                                  //     Column(
                                  //       crossAxisAlignment: CrossAxisAlignment.start,
                                  //       children: [
                                  //         Padding(
                                  //           padding: const EdgeInsets.only(left: 16),
                                  //           child: Text(
                                  //             'ADDRESS',
                                  //             style: TextStyle(
                                  //                 fontSize:
                                  //                 MediaQuery.of(context).size.width < 500
                                  //                 ? 12
                                  //                 : 20, color: Colors.grey[800],fontWeight: FontWeight.bold),
                                  //           ),
                                  //         ),
                                  //         Padding(
                                  //           padding: const EdgeInsets.only(left: 16),
                                  //           child: Text(
                                  //             '${widget.properties?.rentalAddress}',
                                  //             style: TextStyle(
                                  //                 fontSize:
                                  //                 MediaQuery.of(context).size.width < 500
                                  //                     ? 12
                                  //                     : 18, color: Colors.grey[800]),
                                  //           ),
                                  //         ),
                                  //         Padding(
                                  //           padding: const EdgeInsets.only(left: 16),
                                  //           child: Text(
                                  //             '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                                  //             style: TextStyle(
                                  //                 fontSize:
                                  //                 MediaQuery.of(context).size.width < 500
                                  //                     ? 12
                                  //                     : 18, color: Colors.grey[800]),
                                  //           ),
                                  //         ),
                                  //         Padding(
                                  //           padding: const EdgeInsets.only(left: 16),
                                  //           child: Text(
                                  //             '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                                  //             style: TextStyle(
                                  //                 fontSize:
                                  //                 MediaQuery.of(context).size.width < 500
                                  //                     ? 12
                                  //                     : 18, color: Colors.grey[800]),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  if (MediaQuery.of(context).size.width < 500)
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        // height: screenHeight * 0.26,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color.fromRGBO(
                                                21, 43, 83, 1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  'Add Lease',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 36
                                                    : 48,
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    'Add Lease',
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0))),
                                                ),
                                              ),
                                            ),
                                         /*   Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  'Rental Applicant',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 36
                                                    : 48,
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    'Create Applicant',
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0))),
                                                ),
                                              ),
                                            ),*/
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (MediaQuery.of(context).size.width > 500)
                                    const SizedBox(
                                      height: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          LeasesTable(unit: widget.unit),
                          AppliancesPart(
                            unit: widget.unit,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            //this for add ubit button
            if (widget.properties.propertyTypeData!.isMultiunit!)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.properties.propertyTypeData!.isMultiunit! &&
                          widget.properties.propertyTypeData!.propertyType ==
                              'Residential')
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            bool isChecked =
                                false; // Moved isChecked inside the StatefulBuilder
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Add Unit Details",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Unit Number",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: unitnum,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Street Address",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: street3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "SQFT",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: sqft3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "bath",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: bath3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "bed",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: bed3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Photo',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage().then((_) {
                                                  setState(
                                                      () {}); // Rebuild the widget after selecting the image
                                                });
                                              },
                                              child: Text(
                                                '+ Add',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _images.isNotEmpty
                                            ? Wrap(
                                          spacing: 8.0, // Horizontal spacing between items
                                          runSpacing: 8.0, // Vertical spacing between rows
                                          children: List.generate(
                                            _images.length,
                                                (index) {
                                              return SizedBox(
                                                width: MediaQuery.of(context).size.width / 3 - 24, // Half of screen width minus padding
                                                child: Row(
                                                  children: [
                                                    Image.file(
                                                      _images[index],
                                                      height: 80,
                                                      width: 80,
                                                      fit: BoxFit.cover,
                                                    ),

                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                            : Center(
                                          child: Text("No images selected."),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 0,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if (unitnum.text.isEmpty ||
                                                    street3.text.isEmpty ||
                                                    sqft3.text.isEmpty ||
                                                    bath3.text.isEmpty ||
                                                    bed3.text.isEmpty) {
                                                  setState(() {
                                                    iserror = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    isLoading = true;
                                                    iserror = false;
                                                  });
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String? id = prefs
                                                      .getString("adminId");
                                                  Properies_summery_Repo()
                                                      .addUnit(
                                                    adminId: id!,
                                                    rentalId: widget
                                                        .properties.rentalId,
                                                    rentalunit: unitnum.text,
                                                    rentalunitadress:
                                                        street3.text,
                                                    rentalsqft: sqft3.text,
                                                    rentalbath: bath3.text,
                                                    rentalbed: bed3.text,
                                                    rentalImages: _uploadedFileNames!
                                                  )
                                                      .then((value) {
                                                    setState(() {
                                                      futureUnitsummery =
                                                          Properies_summery_Repo().fetchunit(widget.properties.rentalId!);
                                                      isLoading = false;
                                                      data.add(unit_properties(
                                                        adminId: id!,
                                                        rentalId: widget
                                                            .properties
                                                            .rentalId,
                                                        rentalunit:
                                                            unitnum.text,
                                                        rentalunitadress:
                                                            street3.text,
                                                        rentalsqft: sqft3.text,
                                                        rentalbath: bath3.text,
                                                        rentalbed: bed3.text,

                                                      ));
                                                    });
                                                    reload_Screen();
                                                    Navigator.pop(
                                                        context, true);
                                                  }).catchError((e) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  });
                                                }
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Save",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        if (iserror)
                                          Text(
                                            "Please fill in all fields correctly.",
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      if (widget.properties.propertyTypeData!.isMultiunit! &&
                          widget.properties.propertyTypeData!.propertyType ==
                              'Commercial')
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            bool isChecked =
                                false; // Moved isChecked inside the StatefulBuilder
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Add Unit Details",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Unit Number",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: unitnum,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Street Address",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: street3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "SQFT",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: sqft3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Photo',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage().then((_) {
                                                  setState(
                                                      () {}); // Rebuild the widget after selecting the image
                                                });
                                              },
                                              child: Text(
                                                '+ Add',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        _images.isNotEmpty
                                            ? Wrap(
                                          spacing: 8.0, // Horizontal spacing between items
                                          runSpacing: 8.0, // Vertical spacing between rows
                                          children: List.generate(
                                            _images.length,
                                                (index) {
                                              return SizedBox(
                                                width: MediaQuery.of(context).size.width / 3 - 24, // Half of screen width minus padding
                                                child: Row(
                                                  children: [
                                                    Image.file(
                                                      _images[index],
                                                      height: 80,
                                                      width: 80,
                                                      fit: BoxFit.cover,
                                                    ),

                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                            : Center(
                                          child: Text("No images selected."),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 0,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if (unitnum.text.isEmpty ||
                                                    street3.text.isEmpty ||
                                                    sqft3.text.isEmpty) {
                                                  setState(() {
                                                    iserror = true;
                                                  });
                                                } else {
                                                  print("unit calling");
                                                  setState(() {
                                                    isLoading = true;
                                                    iserror = false;
                                                  });
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String? id = prefs
                                                      .getString("adminId");
                                                  Properies_summery_Repo()
                                                      .addUnit(
                                                    adminId: id!,
                                                    rentalId: widget
                                                        .properties.rentalId,
                                                    rentalunitadress:
                                                        street3.text,
                                                    rentalsqft: sqft3.text,
                                                    rentalunit: unitnum.text,
                                                    rentalImages: _uploadedFileNames!
                                                  )
                                                      .then((value) {
                                                        print("valuesss....${value}");
                                                    setState(() {

                                                      isLoading = false;
                                                      data.add(unit_properties(
                                                        adminId: id!,
                                                        rentalId: widget
                                                            .properties
                                                            .rentalId,
                                                        rentalunitadress:
                                                            street3.text,
                                                        rentalsqft: sqft3.text,
                                                        rentalunit:
                                                            unitnum.text,
                                                      ));
                                                    });
                                                    reload_Screen();
                                                    Navigator.pop(
                                                        context, true);
                                                  }).catchError((e) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  });
                                                }
                                                print("calling.............");


                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Save",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        if (iserror)
                                          Text(
                                            "Please fill in all fields correctly.",
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                    },
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      child: Container(
                        height: 35,
                        width: 95,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                        ),
                        child: Center(
                            child: Text(
                          "Add Unit",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(21, 43, 81, 1)),
                        )),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),

            //and this is mutiunit table show this is as it is
            if (!showdetails &&
                widget.properties.propertyTypeData!.isMultiunit! == true)
              if (MediaQuery.of(context).size.width < 500)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder<List<unit_properties>>(
                    future: futureUnitsummery,
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
                        return Center(child: Text('No data available'));
                      } else {
                        print("data update...");
                        var data = snapshot.data!;
                        if (selectedValue == null && searchvalue!.isEmpty) {
                          data = snapshot.data!;
                        } else if (selectedValue == "All") {
                          data = snapshot.data!;
                        } else if (searchvalue!.isNotEmpty) {
                          data = snapshot.data!;
                          //       .where((property) =>
                          //   property.propertyType!
                          //       .toLowerCase()
                          //       .contains(searchvalue!.toLowerCase()) ||
                          //       property.propertysubType!
                          //           .toLowerCase()
                          //           .contains(searchvalue!.toLowerCase()))
                          //       .toList();
                          // } else {
                          //   data = snapshot.data!
                          //       .where((property) =>
                          //   property.propertyType == selectedValue)
                          //       .toList();
                        }
                        // sortData(data);
                        //countupdateunit(data.length);
                        final totalPages =
                            (data.length / itemsPerPagemulti).ceil();
                        final currentPageData = data
                            .skip(currentPagemulti * itemsPerPagemulti)
                            .take(itemsPerPagemulti)
                            .toList();
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              _buildHeadersmulti(),
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
                                    unit_properties Propertytype = entry.value;
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
                                              padding:
                                                  const EdgeInsets.all(2.0),
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
                                                        setState(() {
                                                          showdetails = true;
                                                          unit = Propertytype;
                                                        });
                                                      },
                                                      child: Text(
                                                        '   ${Propertytype.rentalunit}',
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
                                                      '${Propertytype.rentalunitadress}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
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
                                                            onTap: () {
                                                              unitnum.text =
                                                                  Propertytype
                                                                      .rentalunit!;
                                                              street3.text =
                                                                  Propertytype
                                                                      .rentalunitadress!;
                                                              sqft3.text =
                                                                  Propertytype
                                                                      .rentalsqft!;
                                                              bath3.text =
                                                                  Propertytype
                                                                      .rentalbath!;
                                                              bed3.text =
                                                                  Propertytype
                                                                      .rentalbed!;
                                                              if (widget
                                                                      .properties
                                                                      .propertyTypeData!
                                                                      .isMultiunit! &&
                                                                  widget
                                                                          .properties
                                                                          .propertyTypeData!
                                                                          .propertyType ==
                                                                      'Residential') {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    // Moved isChecked inside the StatefulBuilder
                                                                    return StatefulBuilder(
                                                                      builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              setState) {
                                                                        return AlertDialog(
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          surfaceTintColor:
                                                                              Colors.white,
                                                                          content:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    const Text(
                                                                                      "Edit Unit Details",
                                                                                      style: TextStyle(
                                                                                        color: Color.fromRGBO(21, 43, 81, 1),
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    Align(
                                                                                      alignment: Alignment.centerRight,
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: const Icon(Icons.close, color: Colors.black),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Unit Number",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: unitnum,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Street Address",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: street3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "SQFT",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: sqft3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "bath",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: bath3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "bed",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: bed3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Photo',
                                                                                      style: TextStyle(color: Colors.black),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        _pickImage().then((_) {
                                                                                          setState(() {}); // Rebuild the widget after selecting the image
                                                                                        });
                                                                                      },
                                                                                      child: const Text(
                                                                                        '+ Add',
                                                                                        style: TextStyle(color: Colors.green),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                _image != null
                                                                                    ? Column(
                                                                                        children: [
                                                                                          Image.file(
                                                                                            _image!,
                                                                                            height: 80,
                                                                                            width: 80,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                          Text(_uploadedFileName ?? ""),
                                                                                        ],
                                                                                      )
                                                                                    : const Text(''),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 0,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        if (unitnum.text.isEmpty || street3.text.isEmpty || sqft3.text.isEmpty || bath3.text.isEmpty || bed3.text.isEmpty) {
                                                                                          setState(() {
                                                                                            iserror = true;
                                                                                          });
                                                                                        } else {
                                                                                          setState(() {
                                                                                            isLoading = true;
                                                                                            iserror = false;
                                                                                          });
                                                                                          SharedPreferences prefs = await SharedPreferences.getInstance();

                                                                                          String? id = prefs.getString("adminId");
                                                                                          Properies_summery_Repo().Editunit(rentalunit: unitnum.text, rentalsqft: sqft3.text, rentalunitadress: street3.text, rentalbath: bath3.text, rentalbed: bed3.text, unitId: Propertytype.unitId, adminId: id, rentalId: Propertytype.rentalId).then((value) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });

                                                                                            Navigator.of(context).pop(true);
                                                                                            reload_Screen();
                                                                                          }).catchError((e) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Color.fromRGBO(21, 43, 81, 1),
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Save",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 10),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Cancel",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                if (iserror)
                                                                                  const Text(
                                                                                    "Please fill in all fields correctly.",
                                                                                    style: TextStyle(color: Colors.redAccent),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                              if (widget
                                                                      .properties
                                                                      .propertyTypeData!
                                                                      .isMultiunit! &&
                                                                  widget
                                                                          .properties
                                                                          .propertyTypeData!
                                                                          .propertyType ==
                                                                      'Commercial') {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    bool
                                                                        isChecked =
                                                                        false; // Moved isChecked inside the StatefulBuilder
                                                                    return StatefulBuilder(
                                                                      builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              setState) {
                                                                        return AlertDialog(
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          surfaceTintColor:
                                                                              Colors.white,
                                                                          content:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    const Text(
                                                                                      "Edit Unit Details",
                                                                                      style: TextStyle(
                                                                                        color: Color.fromRGBO(21, 43, 81, 1),
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    Align(
                                                                                      alignment: Alignment.centerRight,
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: const Icon(Icons.close, color: Colors.black),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Unit Number",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: unitnum,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Street Address",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: street3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "SQFT",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: sqft3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Photo',
                                                                                      style: TextStyle(color: Colors.black),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        _pickImage().then((_) {
                                                                                          setState(() {}); // Rebuild the widget after selecting the image
                                                                                        });
                                                                                      },
                                                                                      child: const Text(
                                                                                        '+ Add',
                                                                                        style: TextStyle(color: Colors.green),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                _image != null
                                                                                    ? Column(
                                                                                        children: [
                                                                                          Image.file(
                                                                                            _image!,
                                                                                            height: 80,
                                                                                            width: 80,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                          Text(_uploadedFileName ?? ""),
                                                                                        ],
                                                                                      )
                                                                                    : const Text(''),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 0,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        if (unitnum.text.isEmpty || street3.text.isEmpty || sqft3.text.isEmpty) {
                                                                                          setState(() {
                                                                                            iserror = true;
                                                                                          });
                                                                                        } else {
                                                                                          setState(() {
                                                                                            isLoading = true;
                                                                                            iserror = false;
                                                                                          });
                                                                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                          String? id = prefs.getString("adminId");
                                                                                          Properies_summery_Repo()
                                                                                              .Editunit(
                                                                                            rentalunit: unitnum.text,
                                                                                            rentalsqft: sqft3.text,
                                                                                            rentalunitadress: street3.text,
                                                                                            unitId: Propertytype.unitId!,
                                                                                          )
                                                                                              .then((value) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                            Navigator.of(context).pop(true);
                                                                                          }).catchError((e) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Color.fromRGBO(21, 43, 81, 1),
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Save",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 10),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Cancel",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                if (iserror)
                                                                                  const Text(
                                                                                    "Please fill in all fields correctly.",
                                                                                    style: TextStyle(color: Colors.redAccent),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
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
                                              margin:
                                                  EdgeInsets.only(bottom: 20),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        FaIcon(
                                                          isExpanded
                                                              ? FontAwesomeIcons
                                                                  .sortUp
                                                              : FontAwesomeIcons
                                                                  .sortDown,
                                                          size: 50,
                                                          color: Colors
                                                              .transparent,
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
                                                                          'Tenant :',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              blueColor), // Bold and black
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          '${tenentCount}',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Colors.grey), // Light and grey
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
                                              value: itemsPerPagemulti,
                                              items: itemsPerPageOptionsmulti
                                                  .map((int value) {
                                                return DropdownMenuItem<int>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  itemsPerPagemulti = newValue!;
                                                  currentPagemulti =
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
                                          color: currentPagemulti == 0
                                              ? Colors.grey
                                              : Color.fromRGBO(21, 43, 83, 1),
                                        ),
                                        onPressed: currentPagemulti == 0
                                            ? null
                                            : () {
                                                setState(() {
                                                  currentPagemulti--;
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
                                          'Page ${currentPagemulti + 1} of $totalPages'),
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
                                          color: currentPagemulti <
                                                  totalPages - 1
                                              ? Color.fromRGBO(21, 43, 83, 1)
                                              : Colors.grey,
                                        ),
                                        onPressed:
                                            currentPagemulti < totalPages - 1
                                                ? () {
                                                    setState(() {
                                                      currentPagemulti++;
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
              FutureBuilder<List<unit_properties>>(
                future: futureUnitsummery,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 55.0,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    _tableDatamulti = snapshot.data!;
                    if (selectedValue == null && searchvalue.isEmpty) {
                      _tableDatamulti = snapshot.data!;
                    } else if (selectedValue == "All") {
                      _tableDatamulti = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      _tableDatamulti = snapshot.data!
                          .where((property) =>
                              property.rentalunit!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()) ||
                              property.rentalunitadress!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      _tableDatamulti = snapshot.data!
                          .where((property) =>
                              property.rentalunit == selectedValue)
                          .toList();
                    }
                    totalrecordsmulti = _tableDatamulti.length;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 5),
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .91,
                                      child: Table(
                                        defaultColumnWidth:
                                            IntrinsicColumnWidth(),
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  // color: blueColor
                                                  ),
                                            ),
                                            children: [
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              _buildHeadermulti(
                                                  'Unit',
                                                  0,
                                                  (rental) =>
                                                      rental.rentalunit!),
                                              _buildHeadermulti(
                                                  'Adress',
                                                  1,
                                                  (rental) =>
                                                      rental.rentalunitadress!),
                                              _buildHeadermulti(
                                                  'Tenants',
                                                  2,
                                                  (rental) =>
                                                      rental.tenantCount!),
                                              _buildHeadermulti(
                                                  'Actions', 3, null),
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
                                                    child:
                                                        Container(height: 20))),
                                          ),
                                          for (var i = 0;
                                              i < _pagedDatamulti.length;
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
                                                  bottom: i ==
                                                          _pagedDatamulti
                                                                  .length -
                                                              1
                                                      ? BorderSide(
                                                          color: Color.fromRGBO(
                                                              21, 43, 81, 1))
                                                      : BorderSide.none,
                                                ),
                                              ),
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      showdetails = true;
                                                      unit =
                                                          _tableDatamulti.first;
                                                    });
                                                  },
                                                  child: _buildDataCellmulti(
                                                      _pagedDatamulti[i]
                                                          .rentalunit!),
                                                ),
                                                // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                                _buildDataCellmulti(
                                                    _pagedDatamulti[i]
                                                        .rentalunitadress!),
                                                _buildDataCellmulti(
                                                    _pagedDatamulti[i]
                                                        .tenantCount!
                                                        .toString()),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 13,
                                                    ),
                                                    Container(
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              unitnum.text =
                                                                  _tableDatamulti
                                                                      .first
                                                                      .rentalunit!;
                                                              street3.text =
                                                                  _tableDatamulti
                                                                      .first
                                                                      .rentalunitadress!;
                                                              sqft3.text =
                                                                  _tableDatamulti
                                                                      .first
                                                                      .rentalsqft!!;
                                                              bath3.text =
                                                                  _tableDatamulti
                                                                      .first
                                                                      .rentalbath!;
                                                              bed3.text =
                                                                  _tableDatamulti
                                                                      .first
                                                                      .rentalbed!;
                                                              if (widget
                                                                      .properties
                                                                      .propertyTypeData!
                                                                      .isMultiunit! &&
                                                                  widget
                                                                          .properties
                                                                          .propertyTypeData!
                                                                          .propertyType ==
                                                                      'Residential') {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    // Moved isChecked inside the StatefulBuilder
                                                                    return StatefulBuilder(
                                                                      builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              setState) {
                                                                        return AlertDialog(
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          surfaceTintColor:
                                                                              Colors.white,
                                                                          content:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    const Text(
                                                                                      "Edit Unit Details",
                                                                                      style: TextStyle(
                                                                                        color: Color.fromRGBO(21, 43, 81, 1),
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    Align(
                                                                                      alignment: Alignment.centerRight,
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: const Icon(Icons.close, color: Colors.black),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Unit Number",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: unitnum,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Street Address",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: street3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "SQFT",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: sqft3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "bath",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: bath3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "bed",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: bed3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Photo',
                                                                                      style: TextStyle(color: Colors.black),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        _pickImage().then((_) {
                                                                                          setState(() {}); // Rebuild the widget after selecting the image
                                                                                        });
                                                                                      },
                                                                                      child: const Text(
                                                                                        '+ Add',
                                                                                        style: TextStyle(color: Colors.green),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                _image != null
                                                                                    ? Column(
                                                                                        children: [
                                                                                          Image.file(
                                                                                            _image!,
                                                                                            height: 80,
                                                                                            width: 80,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                          Text(_uploadedFileName ?? ""),
                                                                                        ],
                                                                                      )
                                                                                    : const Text(''),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 0,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        if (unitnum.text.isEmpty || street3.text.isEmpty || sqft3.text.isEmpty || bath3.text.isEmpty || bed3.text.isEmpty) {
                                                                                          setState(() {
                                                                                            iserror = true;
                                                                                          });
                                                                                        } else {
                                                                                          setState(() {
                                                                                            isLoading = true;
                                                                                            iserror = false;
                                                                                          });
                                                                                          SharedPreferences prefs = await SharedPreferences.getInstance();

                                                                                          String? id = prefs.getString("adminId");
                                                                                          Properies_summery_Repo().Editunit(rentalunit: unitnum.text, rentalsqft: sqft3.text, rentalunitadress: street3.text, rentalbath: bath3.text, rentalbed: bed3.text, unitId: _tableDatamulti.first.unitId!, adminId: id, rentalId: _tableDatamulti.first.rentalId!).then((value) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });

                                                                                            Navigator.of(context).pop(true);
                                                                                            reload_Screen();
                                                                                          }).catchError((e) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Color.fromRGBO(21, 43, 81, 1),
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Save",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 10),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Cancel",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                if (iserror)
                                                                                  const Text(
                                                                                    "Please fill in all fields correctly.",
                                                                                    style: TextStyle(color: Colors.redAccent),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                              if (widget
                                                                      .properties
                                                                      .propertyTypeData!
                                                                      .isMultiunit! &&
                                                                  widget
                                                                          .properties
                                                                          .propertyTypeData!
                                                                          .propertyType ==
                                                                      'Commercial') {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    bool
                                                                        isChecked =
                                                                        false; // Moved isChecked inside the StatefulBuilder
                                                                    return StatefulBuilder(
                                                                      builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              setState) {
                                                                        return AlertDialog(
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          surfaceTintColor:
                                                                              Colors.white,
                                                                          content:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    const Text(
                                                                                      "Edit Unit Details",
                                                                                      style: TextStyle(
                                                                                        color: Color.fromRGBO(21, 43, 81, 1),
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    Align(
                                                                                      alignment: Alignment.centerRight,
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: const Icon(Icons.close, color: Colors.black),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Unit Number",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: unitnum,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Street Address",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: street3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      "SQFT",
                                                                                      style: TextStyle(color: Color(0xFF8A95A8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                                  child: Material(
                                                                                    elevation: 3,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    child: TextFormField(
                                                                                      controller: sqft3,
                                                                                      cursorColor: Colors.black,
                                                                                      decoration: InputDecoration(
                                                                                        //  hintText: label,
                                                                                        // labelText: label,
                                                                                        // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                                        filled: true,
                                                                                        fillColor: Colors.white,
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(3),
                                                                                          borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Photo',
                                                                                      style: TextStyle(color: Colors.black),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        _pickImage().then((_) {
                                                                                          setState(() {}); // Rebuild the widget after selecting the image
                                                                                        });
                                                                                      },
                                                                                      child: const Text(
                                                                                        '+ Add',
                                                                                        style: TextStyle(color: Colors.green),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                _image != null
                                                                                    ? Column(
                                                                                        children: [
                                                                                          Image.file(
                                                                                            _image!,
                                                                                            height: 80,
                                                                                            width: 80,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                          Text(_uploadedFileName ?? ""),
                                                                                        ],
                                                                                      )
                                                                                    : const Text(''),
                                                                                const SizedBox(height: 8.0),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 0,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        if (unitnum.text.isEmpty || street3.text.isEmpty || sqft3.text.isEmpty) {
                                                                                          setState(() {
                                                                                            iserror = true;
                                                                                          });
                                                                                        } else {
                                                                                          setState(() {
                                                                                            isLoading = true;
                                                                                            iserror = false;
                                                                                          });
                                                                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                          String? id = prefs.getString("adminId");
                                                                                          Properies_summery_Repo()
                                                                                              .Editunit(
                                                                                            rentalunit: unitnum.text,
                                                                                            rentalsqft: sqft3.text,
                                                                                            rentalunitadress: street3.text,
                                                                                            unitId: _tableDatamulti.first.unitId!,
                                                                                          )
                                                                                              .then((value) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                            Navigator.of(context).pop(true);
                                                                                          }).catchError((e) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Color.fromRGBO(21, 43, 81, 1),
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Save",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 10),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 3,
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          Radius.circular(5),
                                                                                        ),
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          width: 80,
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(5),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Center(
                                                                                              child: Text(
                                                                                            "Cancel",
                                                                                            style: TextStyle(fontWeight: FontWeight.w500, color: Color.fromRGBO(21, 43, 81, 1)),
                                                                                          )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 8.0),
                                                                                if (iserror)
                                                                                  const Text(
                                                                                    "Please fill in all fields correctly.",
                                                                                    style: TextStyle(color: Colors.redAccent),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
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
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 25),
                                  _buildPaginationControlsmulti(),
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

  unitScreen1(BuildContext context, unit_properties unit) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height:
                              MediaQuery.of(context).size.width < 500 ? 36 : 50,
                          width:
                              MediaQuery.of(context).size.width < 500 ? 76 : 80,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showdetails = false;
                              });
                              // Navigator.pop(context);
                            },
                            child: Text(
                              'Back',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 14
                                          : 20,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(21, 43, 83, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          height:
                              MediaQuery.of(context).size.width < 500 ? 36 : 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? 120
                              : 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(21, 43, 83, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0))),
                            onPressed: () async {
                              _showDeleteAlert(context,unit.unitId!);
                             /* var data = Properies_summery_Repo()
                                  .Deleteunit(unitId: unit?.unitId!);
                              // Add your delete logic here
                              setState(() {
                                futureUnitsummery = Properies_summery_Repo()
                                    .fetchunit(widget.properties.rentalId!);
                              });*/
                             // Navigator.pop(context);
                            },
                            child: Text(
                              'Delete unit',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 14
                                          : 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.width < 500
                              ? 36
                              : 48,
                          width: 120,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>addLease3()));
                            },
                            child: Text(
                              'Add Lease',
                              style: TextStyle(
                                  fontSize:
                                  MediaQuery.of(context).size.width <
                                      500
                                      ? 14
                                      : 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      SizedBox(
                        //  height: screenHeight * 0.30,
                        //width: screenWidth * 0.8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image(
                            image: NetworkImage(
                                unit.rentalImages != null ? unit.rentalImages!.length >0 ? "$image_url${unit.rentalImages!.first}" : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRe_jcaXNfnjMStYxu0ScZHngqxm-cTA9lJbB9DrbhxHQ6G-aAvZFZFu9-xSz31R5gKgjM&usqp=CAU' :

                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRe_jcaXNfnjMStYxu0ScZHngqxm-cTA9lJbB9DrbhxHQ6G-aAvZFZFu9-xSz31R5gKgjM&usqp=CAU'),
                            fit: BoxFit.fill,
                            height: MediaQuery.of(context).size.width < 500
                                ? 140
                                : 220,
                            width: MediaQuery.of(context).size.width < 500
                                ? 160
                                : 220,
                          ),
                        ),
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '${unit!.rentalunit}',
                              style: TextStyle(
                                  fontSize:
                                  MediaQuery.of(context).size.width < 500
                                      ? 14
                                      : 20,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              'ADDRESS',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 14
                                          : 20,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width > 500 ? 200: 150,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${widget.properties?.rentalAddress}',
                                maxLines: 2, // Set maximum number of lines
                                overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width < 500 ? 13 : 18,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width > 500 ? 200: 150,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                maxLines: 2,
                                '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 13
                                            : 18,
                                    color: Colors.grey[800]),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 13
                                          : 18,
                                  color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      if (MediaQuery.of(context).size.width > 500)
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(21, 43, 83, 1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    // width: double.infinity,
                                    child: Text(
                                      'Add Lease',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 14
                                                : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(21, 43, 83, 1),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 36
                                              : 48,
                                      // width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text(
                                          '       Add Lease    ',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    21, 43, 83, 1),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0))),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                /*  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: SizedBox(
                                      //  width: double.infinity,
                                      child: Text(
                                        'Rental Applicant',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14
                                              : 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 36
                                              : 48,
                                      //  width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Create Applicant',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    21, 43, 83, 1),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0))),
                                      ),
                                    ),
                                  ),*/
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child:
                  //   Container(
                  //     width: double.infinity,
                  //     child:
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Padding(
                  //           padding: const EdgeInsets.only(left: 16),
                  //           child: Text(
                  //             'ADDRESS',
                  //             style: TextStyle(
                  //                 fontSize:
                  //                 MediaQuery.of(context).size.width < 500
                  //                 ? 12
                  //                 : 20, color: Colors.grey[800],fontWeight: FontWeight.bold),
                  //           ),
                  //         ),
                  //         Padding(
                  //           padding: const EdgeInsets.only(left: 16),
                  //           child: Text(
                  //             '${widget.properties?.rentalAddress}',
                  //             style: TextStyle(
                  //                 fontSize:
                  //                 MediaQuery.of(context).size.width < 500
                  //                     ? 12
                  //                     : 18, color: Colors.grey[800]),
                  //           ),
                  //         ),
                  //         Padding(
                  //           padding: const EdgeInsets.only(left: 16),
                  //           child: Text(
                  //             '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                  //             style: TextStyle(
                  //                 fontSize:
                  //                 MediaQuery.of(context).size.width < 500
                  //                     ? 12
                  //                     : 18, color: Colors.grey[800]),
                  //           ),
                  //         ),
                  //         Padding(
                  //           padding: const EdgeInsets.only(left: 16),
                  //           child: Text(
                  //             '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                  //             style: TextStyle(
                  //                 fontSize:
                  //                 MediaQuery.of(context).size.width < 500
                  //                     ? 12
                  //                     : 18, color: Colors.grey[800]),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  if (MediaQuery.of(context).size.width < 500)

                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(
                      height: 20,
                    ),
                ],
              ),
            ),
          ),
          LeasesTable(
            unit: unit,
          ),
          // LeasesTable1(context,unit!),
          // LeasesTable(context),
          AppliancesPart(
            unit: unit,
          ),
        ],
      ),
    );
  }

  Workorder(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          //add Data
          Padding(
            padding: const EdgeInsets.only(left: 13, right: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (MediaQuery.of(context).size.width < 500) SizedBox(width: 5),
                if (MediaQuery.of(context).size.width > 500) SizedBox(width: 8),
                Row(
                  children: [
                    Text(
                      "Billable To Tenants",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width > 500
                              ? 20
                              : 12),
                    ),
                    if (MediaQuery.of(context).size.width < 500)
                      SizedBox(
                        width: 10,
                      ),
                    if (MediaQuery.of(context).size.width > 500)
                      SizedBox(width: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 500 ? 24 : 50,
                      height: MediaQuery.of(context).size.width < 500 ? 24 : 50,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        activeColor: isChecked
                            ? Color.fromRGBO(21, 43, 81, 1)
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                GestureDetector(
                 /* onTap: () async {
                    final result =
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ResponsiveAddWorkOrder(
                                  rentalid: widget.properties.rentalId,
                                )));
                    if (result == true) {
                      setState(() {
                        futureworkordersummery = Properies_summery_Repo()
                            .fetchWorkOrders(widget.properties.rentalId!);
                      });
                    }
                  },*/
                  child: Container(
                    height: (MediaQuery.of(context).size.width < 500)
                        ? 40
                        : MediaQuery.of(context).size.width * 0.063,

                    // height:  MediaQuery.of(context).size.width * 0.07,
                    // height:  40,
                    width: MediaQuery.of(context).size.width * 0.29,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add Work Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width > 500
                                  ? 20
                                  : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width < 500) SizedBox(width: 2),
                if (MediaQuery.of(context).size.width > 500) SizedBox(width: 8),
              ],
            ),
          ),
          // SizedBox(height: 15),
          if (MediaQuery.of(context).size.width > 500) SizedBox(height: 20),
          if (MediaQuery.of(context).size.width < 500) SizedBox(height: 15),
          //search
          Padding(
            padding: const EdgeInsets.only(left: 13, right: 13),
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width < 500) SizedBox(width: 2),
                if (MediaQuery.of(context).size.width > 500) SizedBox(width: 8),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    // height: 40,
                    height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                    width: MediaQuery.of(context).size.width < 500
                        ? MediaQuery.of(context).size.width * .52
                        : MediaQuery.of(context).size.width * .49,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
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
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 14
                                          : 18,
                                  // fontWeight: FontWeight.bold,
                                  color: Color(0xFF8A95A8),
                                ),
                                contentPadding: EdgeInsets.only(
                                    left: 5, bottom: 13, top: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
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
                        height:
                            MediaQuery.of(context).size.width < 500 ? 40 : 50,
                        // width: 180,
                        width: MediaQuery.of(context).size.width < 500
                            ? MediaQuery.of(context).size.width * .35
                            : MediaQuery.of(context).size.width * .4,
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
                        maxHeight: 250,
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
                if (MediaQuery.of(context).size.width < 500) SizedBox(width: 5),
                if (MediaQuery.of(context).size.width > 500) SizedBox(width: 8),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width > 500) SizedBox(height: 25),
          if (MediaQuery.of(context).size.width < 500)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<List<propertiesworkData>>(
                future: futureworkordersummery,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 40.0,
                    ));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    var data = snapshot.data!;
                    if (selectedValue == null && searchvalue!.isEmpty) {
                      data = snapshot.data!;
                    } else if (selectedValue == "All") {
                      data = snapshot.data!;
                    } else if (searchvalue!.isNotEmpty) {
                      data = snapshot.data!
                          .where((workorder) =>
                              workorder.workSubject!
                                  .toLowerCase()
                                  .contains(searchvalue!.toLowerCase()) ||
                              workorder.workCategory!
                                  .toLowerCase()
                                  .contains(searchvalue!.toLowerCase()))
                          .toList();
                    } else {
                      data = snapshot.data!
                          .where(
                              (workorder) => workorder.status! == selectedValue)
                          .toList();
                      count = data
                          .where((workorder) => workorder.status != 'Completed')
                          .length;
                      complete_count = data
                          .where((workorder) => workorder.status == 'Completed')
                          .length;
                    }
                    if (isChecked) {
                      data = data
                          .where((workorder) => workorder.status == 'Completed')
                          .toList();
                      Provider.of<WorkOrderCountProvider>(context)
                          .updateCount(data.length);
                    } else {
                      data = data
                          .where((workorder) => workorder.status != 'Completed')
                          .toList();
                      Provider.of<WorkOrderCountProvider>(context)
                          .updateCount(data.length);
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
                          _buildHeaders(),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int index = entry.key;
                                bool isExpanded = expandedIndex == index;
                                propertiesworkData workOrder = entry.value;
                                //return CustomExpansionTile(data: Data, index: index);
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
                                                  margin:
                                                      EdgeInsets.only(left: 5),
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
                                                child: Text(
                                                  '   ${workOrder.workSubject}',
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
                                                      .099),
                                              Expanded(
                                                child: Text(
                                                  '${workOrder.status}',
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
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (workOrder.isBillable ==
                                                        true)
                                                      Icon(
                                                        Icons.check,
                                                        color: blueColor,
                                                      ),
                                                    if (workOrder.isBillable ==
                                                        false)
                                                      Icon(
                                                        Icons.close,
                                                        color: blueColor,
                                                      ),
                                                  ],
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
                                                      color: Colors.transparent,
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
                                                                      ' Category : ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${workOrder.workCategory}',
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
                                                            height: 5,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Created At : ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text: formatDate(
                                                                      '${workOrder.createdAt}'),
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
                                                    SizedBox(width: 5),
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
                                                                      'Assign ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${workOrder.staffmemberName}',
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
                                                            height: 5,
                                                          ),
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
                                                                      '${workOrder.updatedAt}'),
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
                                        border: Border.all(color: Colors.grey),
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
            FutureBuilder<List<propertiesworkData>>(
              future: futureworkordersummery,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 55.0,
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
                            property.workSubject!
                                .toLowerCase()
                                .contains(searchvalue.toLowerCase()) ||
                            property.workCategory!
                                .toLowerCase()
                                .contains(searchvalue.toLowerCase()))
                        .toList();
                  } else {
                    _tableData = snapshot.data!
                        .where((property) => property.status == selectedValue)
                        .toList();
                  }
                  if (isChecked) {
                    _tableData = snapshot.data!
                        .where((workorder) => workorder.status == 'Completed')
                        .toList();
                  } else {
                    _tableData = snapshot.data!
                        .where((workorder) => workorder.status != 'Completed')
                        .toList();
                  }
                  totalrecords = _tableData.length;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    // width: MediaQuery.of(context).size.width *
                                    //     .91,
                                    child: Table(
                                      defaultColumnWidth:
                                          IntrinsicColumnWidth(),
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                // color: blueColor
                                                ),
                                          ),
                                          children: [
                                            // TableCell(child: Text('yash')),
                                            // TableCell(child: Text('yash')),
                                            // TableCell(child: Text('yash')),
                                            // TableCell(child: Text('yash')),
                                            // TableCell(child: Text('yash')),
                                            _buildHeader(
                                                'Work Orders',
                                                0,
                                                (property) =>
                                                    property.workSubject!),
                                            _buildHeader(
                                                'Category',
                                                1,
                                                (property) =>
                                                    property.workCategory!),
                                            _buildHeader(
                                                'Billable',
                                                2,
                                                (property) => property
                                                    .isBillable!
                                                    .toString()),
                                            _buildHeader(
                                                'Assign',
                                                3,
                                                (property) =>
                                                    property.staffmemberName!),
                                            _buildHeader('Status', 4,
                                                (property) => property.status!),
                                            _buildHeader('Created At', 5, null),
                                            _buildHeader('Updated At', 6, null),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                horizontal: BorderSide.none),
                                          ),
                                          children: List.generate(
                                              7,
                                              (index) => TableCell(
                                                  child:
                                                      Container(height: 20))),
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
                                                bottom: i ==
                                                        _pagedData.length - 1
                                                    ? BorderSide(
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1))
                                                    : BorderSide.none,
                                              ),
                                            ),
                                            children: [
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // Text(
                                              //     '${_pagedData[i].propertyType!}'),
                                              // Text(
                                              //     '${_pagedData[i].propertysubType!}'),
                                              // Text(
                                              //     '${formatDate(_pagedData[i].createdAt!)}'),
                                              // Text(
                                              //     '${formatDate(_pagedData[i].updatedAt!)}'),
                                              _buildDataCell(_pagedData[i]
                                                  .workSubject
                                                  .toString()),
                                              _buildDataCell(_pagedData[i]
                                                  .workCategory
                                                  .toString()),
                                              _buildDataCellBillable(
                                                  _pagedData[i].isBillable ==
                                                      true),
                                              _buildDataCell(_pagedData[i]
                                                      .staffmemberName ??
                                                  ""),
                                              _buildDataCell(_pagedData[i]
                                                  .status
                                                  .toString()),
                                              _buildDataCell(
                                                formatDate(
                                                    _pagedData[i].createdAt!),
                                              ),
                                              _buildDataCell(
                                                formatDate(
                                                    _pagedData[i].updatedAt!),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),
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
    );
  }

  reload_Screen() {
    setState(() {
      futureUnitsummery =
          Properies_summery_Repo().fetchunit(widget.properties.rentalId!);
    });
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
    futureLease = UnitData().fetchUnitLeases(widget.unit?.unitId ?? "");
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
        padding: const EdgeInsets.only(top: 20.0, left: 16, bottom: 20),
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

  void _sort<T>(Comparable<T> Function(unit_lease d) getField, int columnIndex,
      bool ascending) {
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width < 500)
                  SizedBox(
                    width: 10,
                  ),
                if (MediaQuery.of(context).size.width > 500)
                  SizedBox(
                    width: 20,
                  ),
                Text(
                  'Leases',
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 17 : 20,
                      color: Color.fromRGBO(21, 43, 83, 1),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width < 500)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                    return Center(
                        child: Text(
                            'You don\'t have any lease for this unit right now ..'));
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
                          SizedBox(height: 10),
                          _buildHeaders(),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
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
                                                  margin:
                                                      EdgeInsets.only(left: 5),
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
                                                  child: Text(
                                                    (getStatus(
                                                        rentals.startDate!,
                                                        rentals.endDate!)),
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
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .08),
                                              Expanded(
                                                child: Text(
                                                  '${rentals.tenantFirstName} ${rentals.tenantLastName}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
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
                                                  '${rentals.leaseType}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
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
                                                      color: Colors.transparent,
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
                                        border: Border.all(color: Colors.grey),
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
                  return Center(
                      child: Text(
                          'You don\'t have any lease for this unit right now ..'));
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
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
                                    _buildHeader('Start-End', 1,
                                        (rental) => rental.endDate!),
                                    _buildHeader('Tenant', 2,
                                        (rental) => rental.tenantFirstName!),
                                    _buildHeader('Type', 3,
                                        (rental) => rental.leaseType!),
                                    _buildHeader(
                                        'Type', 4, (rental) => rental.amount!),
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
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1)),
                                        right: BorderSide(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1)),
                                        top: BorderSide(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1)),
                                        bottom: i == _pagedData.length - 1
                                            ? BorderSide(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1))
                                            : BorderSide.none,
                                      ),
                                    ),
                                    children: [
                                      _buildDataCell(
                                        (getStatus(_pagedData[i].startDate!,
                                            _pagedData[i].endDate!)),
                                      ),
                                      // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                      _buildDataCell(
                                          '${_pagedData[i].startDate} - ${_pagedData[i].endDate}'),
                                      _buildDataCell(
                                          '${_pagedData[i].tenantFirstName} - ${_pagedData[i].tenantLastName}'),
                                      _buildDataCell(
                                          '${_pagedData[i].leaseType}'),
                                      _buildDataCell('${_pagedData[i].amount}'),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (_tableData.isEmpty) Text("No Search Records Found"),
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
    this.unit,
    this.properties,
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

  bool isLoading = false;
  Future<void> fetchLeases() async {
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

  reload_screen() {
    setState(() {
      futureAppliences = UnitData().fetchApplianceData(widget.unit?.unitId ?? "");
    });
  }

  DateTime? _selectedDate;
  //bool isLoading = false;
  bool iserror = false;

  //for table

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
        padding: const EdgeInsets.only(top: 20.0, left: 16, bottom: 10),
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
            await Properies_summery_Repo().Deleteapplences(appliance_id: id);
            setState(() {
              futureAppliences =
                  UnitData().fetchApplianceData(widget.unit?.unitId ?? "");
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

  String? rentalOwnersid;
  int rentalownerCount = 0;
  int rentalOwnerCountLimit = 0;
  Future<void> fetchRentalOwneradded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/rental_owner/limitation/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      print(rentalownerCount);
      print(rentalOwnerCountLimit);
      setState(() {
        rentalownerCount = jsonData['rentalownerCount'];
        print(rentalownerCount);
        rentalOwnerCountLimit = jsonData['rentalOwnerCountLimit'];
        print(rentalOwnerCountLimit);
      });
    } else {
      throw Exception('Failed to load data');
    }
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
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(
                      width: 10,
                    ),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(
                      width: 20,
                    ),
                  Text(
                    'Appliances',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 17 : 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(21, 43, 83, 1),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
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
                                              builder: (BuildContext context,
                                                  Widget? child) {
                                                return Theme(
                                                  data: ThemeData.light()
                                                      .copyWith(
                                                    // primaryColor: Color.fromRGBO(21, 43, 83, 1),
                                                    //  hintColor: Color.fromRGBO(21, 43, 83, 1),
                                                    colorScheme:
                                                        ColorScheme.light(
                                                      primary: Color.fromRGBO(
                                                          21, 43, 83, 1),
                                                      // onPrimary:Color.fromRGBO(21, 43, 83, 1),
                                                      //  surface: Color.fromRGBO(21, 43, 83, 1),
                                                      onSurface: Colors.black,
                                                    ),
                                                    buttonTheme:
                                                        ButtonThemeData(
                                                      textTheme: ButtonTextTheme
                                                          .primary,
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
                                                      formatDate(
                                                          date.toString());
                                                });
                                              }
                                            });
                                          },
                                          child: AbsorbPointer(
                                            child: CustomTextFormField(
                                              labelText: 'Date',
                                              hintText: 'Select Date',
                                              keyboardType:
                                                  TextInputType.datetime,
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 42,
                                                width: 80,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
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
                                                    if (_name.text.isEmpty ||
                                                        _description
                                                            .text.isEmpty ||
                                                        _installedDate
                                                            .text.isEmpty) {
                                                      setState(() {
                                                        iserror = true;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        isLoading = true;
                                                        iserror = false;
                                                      });
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      String? id = prefs
                                                          .getString("adminId");
                                                      print("calling");
                                                      Properies_summery_Repo()
                                                          .addappliances(
                                                        adminId: id,
                                                        unitId:
                                                            widget.unit?.unitId,
                                                        appliancename:
                                                            _name.text,
                                                        appliancedescription:
                                                            _description.text,
                                                        installeddate:
                                                            _installedDate.text,
                                                      )
                                                          .then((value) {
                                                        print(widget.properties
                                                            ?.adminId);
                                                        print(widget
                                                            .unit?.unitId);
                                                        setState(() {
                                                          isLoading = false;

                                                          leases.add(
                                                              unit_appliance(
                                                            applianceName:
                                                                _name.text,
                                                            applianceDescription:
                                                                _description
                                                                    .text,
                                                            installedDate:
                                                                _installedDate
                                                                    .text,
                                                            adminId: id,
                                                            unitId: widget
                                                                .unit?.unitId,
                                                          ));
                                                        });
                                                        reload_screen();

                                                        Navigator.pop(
                                                            context, true);
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (iserror)
                                          Text(
                                            "Please fill in all fields correctly.",
                                            style: TextStyle(
                                                color: Colors.redAccent),
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
                            color: Color.fromRGBO(21, 43, 83, 1),
                            width: 1,
                          ),
                        ),
                        height:
                            MediaQuery.of(context).size.width < 500 ? 40 : 50,
                        width:
                            MediaQuery.of(context).size.width < 500 ? 70 : 80,
                        child: Center(
                          child: Text(
                            'Add',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 14
                                        : 20,
                                color: blueColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (MediaQuery.of(context).size.width < 500)
                SizedBox(
                  height: 1,
                ),
              if (MediaQuery.of(context).size.width > 500)
                SizedBox(
                  height: 5,
                ),
              if (MediaQuery.of(context).size.width < 500)
                Padding(
                  padding: const EdgeInsets.all(5.0),
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
                        return Center(
                            child: Text(
                                'You don\'t have any applience for this unit right now ..'));
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
                                              padding:
                                                  const EdgeInsets.all(2.0),
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
                                                              _name.text = rentals
                                                                  .applianceName!;
                                                              _description
                                                                      .text =
                                                                  rentals
                                                                      .applianceDescription!;
                                                              _installedDate
                                                                      .text =
                                                                  rentals
                                                                      .installedDate!;
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return StatefulBuilder(
                                                                    builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                                      return AlertDialog(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        surfaceTintColor:
                                                                            Colors.white,
                                                                        title: const Text(
                                                                            'Edit Appliances'),
                                                                        content:
                                                                            Form(
                                                                          key:
                                                                              _formKey,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
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
                                                                                        _installedDate.text = formatDate(date.toString());
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
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Container(
                                                                                      height: 42,
                                                                                      width: 80,
                                                                                      child: ElevatedButton(
                                                                                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(21, 43, 83, 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                                                                        onPressed: () async {
                                                                                          if (_name.text.isEmpty || _description.text.isEmpty || _installedDate.text.isEmpty) {
                                                                                            setState(() {
                                                                                              iserror = true;
                                                                                            });
                                                                                          } else {
                                                                                            setState(() {
                                                                                              isLoading = true;
                                                                                              iserror = false;
                                                                                            });
                                                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                            String? id = prefs.getString("adminId");
                                                                                            print("calling");
                                                                                            Properies_summery_Repo()
                                                                                                .Editappliances(
                                                                                              applianceid: rentals.applianceId,
                                                                                              adminId: id,
                                                                                              unitId: widget.unit?.unitId,
                                                                                              appliancename: _name.text,
                                                                                              appliancedescription: _description.text,
                                                                                              installeddate: _installedDate.text,
                                                                                            )
                                                                                                .then((value) {
                                                                                              print(widget.properties?.adminId);
                                                                                              print(widget.unit?.unitId);
                                                                                              setState(() {
                                                                                                isLoading = false;
                                                                                              });
                                                                                              reload_screen();

                                                                                              Navigator.pop(context, true);
                                                                                            }).catchError((e) {
                                                                                              setState(() {
                                                                                                isLoading = false;
                                                                                              });
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child: const Text(
                                                                                          'Save',
                                                                                          style: TextStyle(fontSize: 14, color: Colors.white),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                        boxShadow: [
                                                                                          BoxShadow(
                                                                                            color: Colors.black.withOpacity(0.25),
                                                                                            spreadRadius: 0,
                                                                                            blurRadius: 15,
                                                                                            offset: const Offset(0.5, 0.5), // Shadow moved to the right and bottom
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
                                                                              if (iserror)
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
                                              margin:
                                                  EdgeInsets.only(bottom: 20),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        FaIcon(
                                                          isExpanded
                                                              ? FontAwesomeIcons
                                                                  .sortUp
                                                              : FontAwesomeIcons
                                                                  .sortDown,
                                                          size: 50,
                                                          color: Colors
                                                              .transparent,
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
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              blueColor), // Bold and black
                                                                    ),
                                                                    TextSpan(
                                                                      text: formatDate(
                                                                          '${rentals.installedDate}'),
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Colors.grey), // Light and grey
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
                      return Center(
                          child: Text(
                              'You don\'t have any applience for this unit right now ..'));
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
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                                        _buildHeader('InstalledDate', 2,
                                            (rental) => rental.installedDate!),
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
                                          _buildDataCell(_pagedData[i]
                                              .applianceDescription!),
                                          _buildDataCell(
                                              _pagedData[i].installedDate!),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 14,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 25,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      _name.text = _tableData
                                                          .first.applianceName!;
                                                      _description.text = _tableData
                                                          .first
                                                          .applianceDescription!;
                                                      _installedDate.text =
                                                          _tableData.first
                                                              .installedDate!;
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return AlertDialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                surfaceTintColor:
                                                                    Colors
                                                                        .white,
                                                                title: const Text(
                                                                    'Edit Appliances'),
                                                                content: Form(
                                                                  key: _formKey,
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      CustomTextFormField(
                                                                        labelText:
                                                                            'Name',
                                                                        hintText:
                                                                            'Enter Name',
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        controller:
                                                                            _name,
                                                                        // validator: (value) {
                                                                        //   if (value == null || value.isEmpty) {
                                                                        //     return 'Please enter name';
                                                                        //   }
                                                                        //   return null;
                                                                        // },
                                                                      ),
                                                                      CustomTextFormField(
                                                                        labelText:
                                                                            'Description',
                                                                        hintText:
                                                                            'Enter description',
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        controller:
                                                                            _description,
                                                                        // validator: (value) {
                                                                        //   if (value == null || value.isEmpty) {
                                                                        //     return 'Please enter description';
                                                                        //   }
                                                                        //   return null;
                                                                        // },
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          showDatePicker(
                                                                            context:
                                                                                context,
                                                                            initialDate:
                                                                                DateTime.now(),
                                                                            firstDate:
                                                                                DateTime(2000),
                                                                            lastDate:
                                                                                DateTime(2100),
                                                                            builder:
                                                                                (BuildContext context, Widget? child) {
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
                                                                          ).then(
                                                                              (date) {
                                                                            if (date !=
                                                                                null) {
                                                                              setState(() {
                                                                                _selectedDate = date;
                                                                                _installedDate.text = formatDate(date.toString());
                                                                              });
                                                                            }
                                                                          });
                                                                        },
                                                                        child:
                                                                            AbsorbPointer(
                                                                          child:
                                                                              CustomTextFormField(
                                                                            labelText:
                                                                                'Date',
                                                                            hintText:
                                                                                'Select Date',
                                                                            keyboardType:
                                                                                TextInputType.datetime,
                                                                            controller:
                                                                                _installedDate,
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
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Container(
                                                                              height: 42,
                                                                              width: 80,
                                                                              child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(21, 43, 83, 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                                                                onPressed: () async {
                                                                                  if (_name.text.isEmpty || _description.text.isEmpty || _installedDate.text.isEmpty) {
                                                                                    setState(() {
                                                                                      iserror = true;
                                                                                    });
                                                                                  } else {
                                                                                    setState(() {
                                                                                      isLoading = true;
                                                                                      iserror = false;
                                                                                    });
                                                                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                    String? id = prefs.getString("adminId");
                                                                                    print("calling");
                                                                                    Properies_summery_Repo()
                                                                                        .Editappliances(
                                                                                      applianceid: _tableData.first.applianceId,
                                                                                      adminId: id,
                                                                                      unitId: widget.unit?.unitId,
                                                                                      appliancename: _name.text,
                                                                                      appliancedescription: _description.text,
                                                                                      installeddate: _installedDate.text,
                                                                                    )
                                                                                        .then((value) {
                                                                                      print(widget.properties?.adminId);
                                                                                      print(widget.unit?.unitId);
                                                                                      setState(() {
                                                                                        isLoading = false;
                                                                                      });
                                                                                      reload_screen();

                                                                                      Navigator.pop(context, true);
                                                                                    }).catchError((e) {
                                                                                      setState(() {
                                                                                        isLoading = false;
                                                                                      });
                                                                                    });
                                                                                  }
                                                                                },
                                                                                child: const Text(
                                                                                  'Save',
                                                                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(8),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.black.withOpacity(0.25),
                                                                                    spreadRadius: 0,
                                                                                    blurRadius: 15,
                                                                                    offset: const Offset(0.5, 0.5), // Shadow moved to the right and bottom
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
                                                                      if (iserror)
                                                                        Text(
                                                                          "Please fill in all fields correctly.",
                                                                          style:
                                                                              TextStyle(color: Colors.redAccent),
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
                                                      child: FaIcon(
                                                        FontAwesomeIcons.edit,
                                                        size: 20,
                                                        color: Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      _showDeleteAlert(
                                                          context,
                                                          _tableData.first
                                                              .applianceId!);
                                                    },
                                                    child: Container(
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .trashCan,
                                                        size: 20,
                                                        color: Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
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