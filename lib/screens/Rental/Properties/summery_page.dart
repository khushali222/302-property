import 'dart:convert';
import 'dart:io';

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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/provider/property_summery.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/unit.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/rental_widget.dart';

import '../../../Model/unit.dart';
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/properties_workorders.dart';
import '../../../model/unitsummery_propeties.dart';
import '../../../model/workordr.dart';
import '../../../provider/properties_workorders.dart';
import '../../../repository/properties_summery.dart';
import 'package:http/http.dart' as http;

import '../../../repository/unit_data.dart';
import '../../../repository/workorder.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../Maintenance/Workorder/Add_workorder.dart';

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

  //late Future<List<RentalSummary>> futuresummery;

  unit_properties? unit;
  DateTime? startdate;
  DateTime? enddate;
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
    futureworkordersummery = Properies_summery_Repo().fetchWorkOrders(widget.properties.rentalId!);
    // futuresummery = Properies_summery_Repo().fetchPropertiessummery(widget.properties.rentalId!);
    _tabController = TabController(length: 4, vsync: this);
    // street3.text = widget.unit!.rentalunitadress!;
    _fetchData();
   // fetchunits1();
    //fetchLeases();
   // fetchAndSetCounts(context);
    //workorder
    // fetchAndSetCounts(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {});

  }


  Future<Map<String, dynamic>> fetchDataOfCountWork(String rentalId) async {

    final response = await http.get(Uri.parse('$Api_url/api/work-order/rental_workorder/$rentalId'));

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
      final provider = Provider.of<WorkOrderCountProvider>(context, listen: false);
      provider.updateCount(newCount);
      provider.updateCompleteCount(newCompleteCount);
    } catch (error) {
      print('Error fetching counts: $error');
    }
  }



  File? _image;
  String? _uploadedFileName;
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${Api_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl,));
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
      });
      _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? fileName = await uploadImage(imageFile);
      setState(() {
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
  int unitCount = 0;
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

  final List<String> items = ['New', "In Progress", "On Hold","Completed","Over Due","All"];
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
            if (isBillable)
              Icon(Icons.check, color: blueColor),
            if(!isBillable)
              Icon(Icons.close, color: blueColor),
          ],
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

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget_302.App_Bar(context: context),
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
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Text('${widget.properties.rentalAddress}',
                  style: const TextStyle(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: [
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
                        height: 40,
                        width: 80,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: const Center(
                            child: Text(
                          "Back",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Text('${widget.properties.propertyTypeData?.propertyType}',
                  style: const TextStyle(
                      color: Color(0xFF8A95A8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
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
              //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
              indicatorColor: const Color.fromRGBO(21, 43, 81, 1),
              labelColor: const Color.fromRGBO(21, 43, 81, 1),
              unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
              tabs: [
                const Tab(text: 'Summary'),
                Tab(
                  text: 'Units($unitCount)',
                ),
                StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Tab(text: 'Tenant($tenentCount)');
                  },
                ),
                StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) setState) {
                    return Tab(text: 'Work(${!isChecked ? count : complete_count})');
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
    return
      Container(
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
              height: 250,
              width: MediaQuery.of(context).size.width * .94,
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
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
                        width: 150,
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
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Property Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('Address',
                          style: TextStyle(
                              color: Color(0xFF8A95A8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                          '${widget.properties.propertyTypeData?.propertyType}',
                          style: const TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text('${widget.properties.rentalAddress}',
                          style: const TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${widget.properties.rentalCity},',
                        style: const TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.properties.rentalState},',
                        style: const TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${widget.properties.rentalCountry},',
                        style: const TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.properties.rentalPostcode}',
                        style: const TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Rental Owners",
              style: TextStyle(
                  color: Color.fromRGBO(21, 43, 81, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder.all(color: Colors.black),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Field Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Company Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('E-mail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Phone Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Home Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Business Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border.symmetric(horizontal: BorderSide.none),
                    ),
                    children: [
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerFirstName}',
                            style: const TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                            child: Text(
                              '${widget.properties.rentalOwnerData?.rentalOwnerCompanyName}',
                              style: const TextStyle(
                                color: Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerPrimaryEmail}',
                            style: const TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerPhoneNumber}',
                            style: const TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerHomeNumber}',
                            style: const TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerBuisinessNumber}',
                            style: const TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Staff Details",
              style: TextStyle(
                  color: Color.fromRGBO(21, 43, 81, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Table(
              border: TableBorder.all(),
              children: [
                const TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Staff Member'),
                    ),
                  ),
                ]),
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${widget.properties.staffMemberData!.staffmemberName}'),
                    ),
                  ),
                ])
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Tenants(BuildContext context) {
    return FutureBuilder<List<TenantData>>(
      future: Properies_summery_Repo()
          .fetchPropertiessummery(widget.properties.rentalId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Center(
                child: SpinKitFadingCircle(
              color: Colors.black,
              size: 40.0,
            )),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<TenantData> tenants = snapshot.data ?? [];
          print(snapshot.data!.length);
          //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              // String fullName = '${tenants[index].leaseTenantData} ${tenants[index].tenantLastName}';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 165,
                  width: MediaQuery.of(context).size.width * .9,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color.fromRGBO(21, 43, 81, 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          Container(
                            height: 30,
                            width: 30,
                            // width: MediaQuery.of(context).size.width * .4,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(21, 43, 81, 1),
                              border: Border.all(
                                  color: const Color.fromRGBO(21, 43, 81, 1)),
                              // color: Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.user,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    // ('Tenant: ${rentalSummary.leaseTenantData[0].tenantData.tenantFirstName} ${rentalSummary.leaseTenantData[0].tenantData.tenantLastName}')
                                    //  '${tenants[index].leaseTenantData![0].tenantData?.tenantFirstName} ${tenants[index].leaseTenantData![0].tenantData?.
                                    //  tenantLastName}'
                                    '${tenants[index].firstName} ${tenants[index].lastName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    formatDate2(tenants[index].updatedAt!),
                                    // '${widget.properties.rentalAddress}',
                                    style: const TextStyle(
                                      fontSize: 11,
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  bool isChecked =
                                      false; // Moved isChecked inside the StatefulBuilder
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              const Row(
                                                children: [
                                                  SizedBox(
                                                    width: 0,
                                                  ),
                                                  Text(
                                                    "Move out Tenants",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1),
                                                        fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Row(
                                                children: [
                                                  SizedBox(
                                                    width: 0,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 0,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Material(
                                                elevation: 3,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  // height: 280,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .65,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                    // color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Table(
                                                          border:
                                                              TableBorder.all(
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                          children: [
                                                            const TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Address/Unit',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Lease Type',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Start End',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                            TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    '${widget.properties.rentalAddress}',
                                                                    style: const TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    ' ${tenants[index].leaseType}',
                                                                    style: const TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    ' ${tenants[index].createdAt} ${tenants[index].updatedAt}',
                                                                    style: const TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                            ])
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Table(
                                                          border:
                                                              TableBorder.all(
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                          children: [
                                                            const TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Tenants',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Notice Given Date',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Move-Out Date',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                            TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    ' ${tenants[index].firstName} ${tenants[index].lastName}',
                                                                    style: const TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                          width:
                                                                              2),
                                                                      Expanded(
                                                                        child:
                                                                            Material(
                                                                          elevation:
                                                                              4,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                50,
                                                                            width:
                                                                                MediaQuery.of(context).size.width * .4,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              border: Border.all(
                                                                                color: const Color(0xFF8A95A8),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Positioned.fill(
                                                                                  child: TextField(
                                                                                    onChanged: (value) {
                                                                                      setState(() {
                                                                                        // startdatederror = false;
                                                                                        // _selectDate(context);
                                                                                      });
                                                                                    },
                                                                                    controller: startdateController,
                                                                                    cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                    decoration: InputDecoration(
                                                                                      hintText: "mm/dd/yyyy",
                                                                                      hintStyle: TextStyle(
                                                                                        fontSize: MediaQuery.of(context).size.width * .037,
                                                                                        color: const Color(0xFF8A95A8),
                                                                                      ),
                                                                                      // enabledBorder: startdatederror
                                                                                      //     ? OutlineInputBorder(
                                                                                      //   borderRadius:
                                                                                      //   BorderRadius.circular(3),
                                                                                      //   borderSide: BorderSide(
                                                                                      //     color: Colors.red,
                                                                                      //   ),
                                                                                      // )
                                                                                      //     : InputBorder.none,
                                                                                      border: InputBorder.none,
                                                                                      contentPadding: const EdgeInsets.all(12),
                                                                                      suffixIcon: IconButton(
                                                                                        icon: const Icon(Icons.calendar_today),
                                                                                        onPressed: () => _startDate(context),
                                                                                      ),
                                                                                    ),
                                                                                    readOnly: true,
                                                                                    onTap: () {
                                                                                      _startDate(context);
                                                                                      setState(() {
                                                                                        //startdatederror = false;
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              2),
                                                                    ],
                                                                  ),
                                                                  // Text(
                                                                  //   '${widget.properties.staffMemberData!.staffmemberName}',
                                                                  //   style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                  // ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                          width:
                                                                              2),
                                                                      Expanded(
                                                                        child:
                                                                            Material(
                                                                          elevation:
                                                                              4,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                50,
                                                                            //width: MediaQuery.of(context).size.width * .6,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              border: Border.all(
                                                                                color: const Color(0xFF8A95A8),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Positioned.fill(
                                                                                  child: TextField(
                                                                                    onChanged: (value) {
                                                                                      setState(() {
                                                                                        // startdatederror = false;
                                                                                        // _selectDate(context);
                                                                                      });
                                                                                    },
                                                                                    controller: enddateController,
                                                                                    cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                    decoration: InputDecoration(
                                                                                      hintText: "mm/dd/yyyy",
                                                                                      hintStyle: TextStyle(
                                                                                        fontSize: MediaQuery.of(context).size.width * .037,
                                                                                        color: const Color(0xFF8A95A8),
                                                                                      ),
                                                                                      // enabledBorder: startdatederror
                                                                                      //     ? OutlineInputBorder(
                                                                                      //   borderRadius:
                                                                                      //   BorderRadius.circular(3),
                                                                                      //   borderSide: BorderSide(
                                                                                      //     color: Colors.red,
                                                                                      //   ),
                                                                                      // )
                                                                                      //     : InputBorder.none,
                                                                                      border: InputBorder.none,
                                                                                      contentPadding: const EdgeInsets.all(12),
                                                                                      suffixIcon: IconButton(
                                                                                        icon: const Icon(Icons.calendar_today),
                                                                                        onPressed: () => _endDate(context),
                                                                                      ),
                                                                                    ),
                                                                                    readOnly: true,
                                                                                    onTap: () {
                                                                                      _endDate(context);
                                                                                      setState(() {
                                                                                        //startdatederror = false;
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              2),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ])
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Material(
                                                      elevation: 3,
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                      child: Container(
                                                        height: 30,
                                                        width: 60,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        child: const Center(
                                                            child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1)),
                                                        )),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Material(
                                                    elevation: 3,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                    child: Container(
                                                      height: 30,
                                                      width: 80,
                                                      decoration: const BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(5),
                                                        ),
                                                      ),
                                                      child: const Center(
                                                          child: Text(
                                                        "Move Out",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 13),
                                                      )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
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
                            child: const Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.rightFromBracket,
                                  size: 17,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Move out",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 65,
                          ),
                          Text(
                            '${tenants[index].createdAt}  to',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 65,
                          ),
                          Text(
                            // '${tenants[index].updatedAt}',
                            '${tenants[index].updatedAt}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 65,
                          ),
                          const FaIcon(
                            FontAwesomeIcons.phone,
                            size: 15,
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${tenants[index].phoneNumber}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 65,
                          ),
                          const FaIcon(
                            FontAwesomeIcons.solidEnvelope,
                            size: 15,
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${tenants[index].email}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Unit_page(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                          )),
                          child: DataTable(
                            // headingRowColor: MaterialStateColor.resolveWith(
                            //         (states) => Color.fromRGBO(21, 43, 83, 1)),
                            headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            columnSpacing: 20,
                            dataRowHeight: 60,
                            columns: [
                              const DataColumn(
                                label: Text(
                                  'TENANTS',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'ACTION',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: data.map((unitData) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      ' ${tenentCount}',
                                      style:
                                          const TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        // showdetails = !showdetails;
                                        showdetails = true;
                                        unit = unitData;
                                      });

                                      // if (showdetails) {
                                      //   // Navigator.push(
                                      //   //   context,
                                      //   //   MaterialPageRoute(builder: (context) => unitScreen()),
                                      //   // );
                                      //   // unitScreen();
                                      //   Container(
                                      //       color: Colors.blue,
                                      //     child: Text("data"),
                                      //   );
                                      // }
                                    },
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.edit,
                                        size: 15,
                                        color: Color(0xFF8A95A8),
                                      ),
                                      onPressed: () {
                                        sqft3.text = unitData.rentalsqft!;
                                        if (widget.properties.propertyTypeData!
                                                    .isMultiunit! ==
                                                false &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Residential') {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked =
                                                  false; // Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
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
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
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
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: const Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
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
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
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
                                                                onTap:
                                                                    () async {
                                                                  if (sqft3.text
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
                                                                        await SharedPreferences
                                                                            .getInstance();

                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                            rentalsqft: sqft3
                                                                                .text,
                                                                            rentalunitadress: street3
                                                                                .text,
                                                                            rentalbath: bath3
                                                                                .text,
                                                                            rentalbed: bed3
                                                                                .text,
                                                                            unitId: unitData
                                                                                .unitId,
                                                                            adminId:
                                                                                id,
                                                                            rentalId: unitData
                                                                                .rentalId)
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                      reload_Screen();
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
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
                                        if (widget.properties.propertyTypeData!
                                                    .isMultiunit! ==
                                                false &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Commercial') {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked =
                                                  false; // Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
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
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
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
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: const Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
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
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
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
                                                                onTap:
                                                                    () async {
                                                                  if (sqft3.text
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
                                                                        await SharedPreferences
                                                                            .getInstance();
                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                      rentalsqft:
                                                                          sqft3
                                                                              .text,
                                                                      unitId: unitData
                                                                          .unitId!,
                                                                    )
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
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
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (widget.properties.propertyTypeData!.isMultiunit!)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.properties.propertyTypeData!.isMultiunit! &&
                          widget.properties.propertyTypeData!.propertyType ==
                              'Residential') {
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
                                            const Text(
                                              "Add Unit Details",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
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
                                                child: const Icon(Icons.close,
                                                    color: Colors.black),
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
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage().then((_) {
                                                  setState(
                                                      () {}); // Rebuild the widget after selecting the image
                                                });
                                              },
                                              child: const Text(
                                                '+ Add',
                                                style: TextStyle(
                                                    color: Colors.green),
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
                                                  )
                                                      .then((value) {
                                                    setState(() {
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
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
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
                                        const SizedBox(height: 8.0),
                                        if (iserror)
                                          const Text(
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
                      }
                      if (widget.properties.propertyTypeData!.isMultiunit! &&
                          widget.properties.propertyTypeData!.propertyType ==
                              'Commercial') {
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
                                            const Text(
                                              "Add Unit Details",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
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
                                                child: const Icon(Icons.close,
                                                    color: Colors.black),
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
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage().then((_) {
                                                  setState(
                                                      () {}); // Rebuild the widget after selecting the image
                                                });
                                              },
                                              child: const Text(
                                                '+ Add',
                                                style: TextStyle(
                                                    color: Colors.green),
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
                                                if (unitnum.text.isEmpty ||
                                                    street3.text.isEmpty ||
                                                    sqft3.text.isEmpty) {
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
                                                    rentalunitadress:
                                                        street3.text,
                                                    rentalsqft: sqft3.text,
                                                    rentalunit: unitnum.text,
                                                  )
                                                      .then((value) {
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
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
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
                                        const SizedBox(height: 8.0),
                                        if (iserror)
                                          const Text(
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
                      }
                    },
                    child: Material(
                      elevation: 3,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      child: Container(
                        height: 35,
                        width: 95,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 81, 1),
                          ),
                        ),
                        child: const Center(
                            child: Text(
                          "Add Unit",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(21, 43, 81, 1)),
                        )),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (!showdetails &&
                widget.properties.propertyTypeData!.isMultiunit! == true)
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
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                          )),
                          child: DataTable(
                            // headingRowColor: MaterialStateColor.resolveWith(
                            //         (states) => Color.fromRGBO(21, 43, 83, 1)),
                            headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            columnSpacing: 20,
                            dataRowHeight: 60,
                            columns: [
                              const DataColumn(
                                label: Text(
                                  'UNIT',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'ADDRESS',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'TENANTS',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'ACTION',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: data.map((unitData) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      ' ${unitData.rentalunit}',
                                      style:
                                          const TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        // showdetails = !showdetails;
                                        showdetails = true;
                                        unit = unitData;
                                      });

                                      // if (showdetails) {
                                      //   // Navigator.push(
                                      //   //   context,
                                      //   //   MaterialPageRoute(builder: (context) => unitScreen()),
                                      //   // );
                                      //   // unitScreen();
                                      //   Container(
                                      //       color: Colors.blue,
                                      //     child: Text("data"),
                                      //   );
                                      // }
                                    },
                                  ),
                                  DataCell(
                                    Text(
                                      ' ${unitData.rentalunitadress}',
                                      style:
                                          const TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      ' ${tenentCount}',
                                      style:
                                          const TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.edit,
                                        size: 15,
                                        color: Color(0xFF8A95A8),
                                      ),
                                      onPressed: () {
                                        unitnum.text = unitData.rentalunit!;
                                        street3.text =
                                            unitData.rentalunitadress!;
                                        sqft3.text = unitData.rentalsqft!;
                                        bath3.text = unitData.rentalbath!;
                                        bed3.text = unitData.rentalbed!;
                                        if (widget.properties.propertyTypeData!
                                                .isMultiunit! &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Residential') {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
// Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
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
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
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
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    unitnum,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                "Street Address",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    street3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                "SQFT",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                "bath",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: const Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
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
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
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
                                                                onTap:
                                                                    () async {
                                                                  if (unitnum.text.isEmpty ||
                                                                      street3
                                                                          .text
                                                                          .isEmpty ||
                                                                      sqft3.text
                                                                          .isEmpty ||
                                                                      bath3.text
                                                                          .isEmpty ||
                                                                      bed3.text
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
                                                                        await SharedPreferences
                                                                            .getInstance();

                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                            rentalunit: unitnum
                                                                                .text,
                                                                            rentalsqft: sqft3
                                                                                .text,
                                                                            rentalunitadress: street3
                                                                                .text,
                                                                            rentalbath: bath3
                                                                                .text,
                                                                            rentalbed: bed3
                                                                                .text,
                                                                            unitId: unitData
                                                                                .unitId,
                                                                            adminId:
                                                                                id,
                                                                            rentalId: unitData
                                                                                .rentalId)
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                      reload_Screen();
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
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
                                        if (widget.properties.propertyTypeData!
                                                .isMultiunit! &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Commercial') {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked =
                                                  false; // Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
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
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
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
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    unitnum,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                "Street Address",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    street3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                "SQFT",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
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
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(
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
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: const Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
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
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
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
                                                                onTap:
                                                                    () async {
                                                                  if (unitnum.text.isEmpty ||
                                                                      street3
                                                                          .text
                                                                          .isEmpty ||
                                                                      sqft3.text
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
                                                                        await SharedPreferences
                                                                            .getInstance();
                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                      rentalunit:
                                                                          unitnum
                                                                              .text,
                                                                      rentalsqft:
                                                                          sqft3
                                                                              .text,
                                                                      rentalunitadress:
                                                                          street3
                                                                              .text,
                                                                      unitId: unitData
                                                                          .unitId!,
                                                                    )
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
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
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                          height: 36,
                          width: 76,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showdetails = false;
                              });
                              // Navigator.pop(context);
                            },
                            child: const Text(
                              'Back',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 36,
                          width: 126,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(21, 43, 83, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0))),
                            onPressed: () async {
                              var data = Properies_summery_Repo()
                                  .Deleteunit(unitId: unit?.unitId!);
                              // Add your delete logic here
                              setState(() {
                                futureUnitsummery = Properies_summery_Repo()
                                    .fetchunit(widget.properties.rentalId!);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete unit',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    //  height: screenHeight * 0.30,
                    //width: screenWidth * 0.8,
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
                                onPressed: () {},
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 36,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
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
                          ),
                        ],
                      ),
                    ),
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
          AppliancesPart(unit: unit),
        ],
      ),
    );
  }

  Workorder(BuildContext context){
    return
      SingleChildScrollView(
        child:
        Column(
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
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 5),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 8),
                  Row(
                    children: [
                      Text("Billable To Tenants",style: TextStyle(
                          color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize:  MediaQuery.of(context).size.width > 500 ?
                                  20 :12
                      ),
                      ),
                      if (MediaQuery.of(context).size.width < 500)
                      SizedBox(width: 10,),
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
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => AddWorkorder(rentalid: widget.properties.rentalId,)));
                      if (result == true) {
                        setState(() {
                          futureworkordersummery = Properies_summery_Repo().fetchWorkOrders(widget.properties.rentalId!);
                        });
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 40
                          : MediaQuery.of(context).size.width * 0.063,

                      // height:  MediaQuery.of(context).size.width * 0.07,
                      // height:  40,
                      width: MediaQuery.of(context).size.width * 0.25,
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
                                  fontSize:  MediaQuery.of(context).size.width > 500 ?
                                  20 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 8),
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
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 8),
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
                              style:TextStyle(
                                  fontSize:  MediaQuery.of(context).size.width < 500 ? 12 : 14
                              ),
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
                                    fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18 ,
                                    // fontWeight: FontWeight.bold,
                                    color: Color(0xFF8A95A8),
                                  ),
                                  contentPadding:
                                  EdgeInsets.only(left: 5,bottom: 13,top: 14)
                              ),
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
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 5),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 8),
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
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
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
                        workorder.workSubject
                        !.toLowerCase()
                            .contains(searchvalue!.toLowerCase()) ||
                            workorder.workCategory!.toLowerCase()
                                .contains(searchvalue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((workorder) =>
                        workorder.status
                        ! == selectedValue)
                            .toList();
                        // count = data.where((workorder) => workorder.status != 'Completed').length;
                        // complete_count = data.where((workorder) => workorder.status == 'Completed').length;
                      }
                      if (isChecked) {
                        data = data.where((workorder) => workorder.status == 'Completed').toList();
                        Provider.of<WorkOrderCountProvider>(context).updateCount(data.length);

                      }
                      else{
                        data = data.where((workorder) => workorder.status != 'Completed').toList();
                        Provider.of<WorkOrderCountProvider>(context).updateCount(data.length);

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
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
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
                                                  child: Text(
                                                    '   ${workOrder.workSubject}',
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
                                                        .099),
                                                Expanded(
                                                  child: Text(
                                                    '${workOrder.status}',
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
                                                  child:
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      if (workOrder.isBillable == true)
                                                        Icon(
                                                          Icons.check,
                                                          color: blueColor,
                                                        ),
                                                      if(workOrder.isBillable == false)
                                                        Icon(
                                                          Icons.close,
                                                          color: blueColor,
                                                        ),

                                                    ],
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
                                                                    text:
                                                                    formatDate('${workOrder.createdAt}'),
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
                                                          CrossAxisAlignment.start,
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
                                                                    text: '${workOrder.staffmemberName}',
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
                                                                    text: formatDate('${workOrder.updatedAt}'),
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
                          .where((property) =>
                      property.status == selectedValue)
                          .toList();
                    }
                    if (isChecked) {
                      _tableData = snapshot.data!.where((workorder) => workorder.status == 'Completed').toList();
                    }else{
                      _tableData = snapshot.data!.where((workorder) => workorder.status != 'Completed').toList();
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
                                                      (property) => property
                                                      .workCategory!),
                                              _buildHeader(
                                                  'Billable',
                                                  2,
                                                      (property) => property
                                                      .isBillable!.toString()),
                                              _buildHeader(
                                                  'Assign',
                                                  3,
                                                      (property) => property
                                                      .staffmemberName!),
                                              _buildHeader(
                                                  'Status',
                                                  4,
                                                      (property) => property
                                                      .status!),
                                              _buildHeader(
                                                  'Created At', 5, null),
                                              _buildHeader(
                                                  'Updated At', 6, null),

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
                                                    .workSubject.toString()),
                                                _buildDataCell(_pagedData[i]
                                                    .workCategory.toString()),
                                                _buildDataCellBillable(_pagedData[i].isBillable == true),
                                                _buildDataCell(_pagedData[i]
                                                    .staffmemberName ??""),
                                                _buildDataCell(_pagedData[i]
                                                    .status.toString()),
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
    setState(() {});
  }
}
