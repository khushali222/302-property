import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/Edit_workorder.dart';
import 'package:three_zero_two_property/repository/workorder.dart';

import '../../../constant/constant.dart';

import '../../../widgets/appbar.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/titleBar.dart';
import 'package:http/http.dart' as http;

import '../../Rental/Tenants/add_tenants.dart';

class ResponsiveEditWorkOrder extends StatefulWidget {
  EditData? property;
  final String workorderId;
  ResponsiveEditWorkOrder(
      {super.key, required this.workorderId, this.property});
  @override
  State<ResponsiveEditWorkOrder> createState() =>
      _ResponsiveEditWorkOrderState();
}

class _ResponsiveEditWorkOrderState extends State<ResponsiveEditWorkOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return EditWorkOrderForTablet(
              workorderId: widget.workorderId,
              property: widget.property,
            );
          } else {
            return EditWorkOrderForMobile(
              workorderId: widget.workorderId,
              property: widget.property,
            );
          }
        },
      ),
    );
  }
}

class EditWorkOrderForMobile extends StatefulWidget {
  EditData? property;
  final String workorderId;
  EditWorkOrderForMobile({super.key, required this.workorderId, this.property});
  @override
  State<EditWorkOrderForMobile> createState() => _EditWorkOrderForMobileState();
}

class _EditWorkOrderForMobileState extends State<EditWorkOrderForMobile> {
  final TextEditingController subject = TextEditingController();

  final TextEditingController other = TextEditingController();

  final TextEditingController perform = TextEditingController();
  final TextEditingController vendornote = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;
  bool _isLoading = true;
  bool _isLoadingvendors = true;
  bool _isLoadingstaff = true;
  bool _isLoadingtenant = false;
  bool _Loading = false;
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {}; // Mapping of unit_id to rental_unit
  String? _selectedPropertyId;
  String? _selectedProperty;
  String? _selectedUnitId;
  String? _selectedUnit;

  //for vendor
  Map<String, String> vendors = {};
  String? _selectedvendorsId;
  String? _selectedVendors;

  //for Staffmember
  Map<String, String> staffs = {};
  String? _selectedstaffId;
  String? _selectedStaffs;
  //for tenants
  Map<String, String> tenants = {};
  String? _selectedtenantId;
  String? _selectedTenants;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProperties();
    _loadVendor();
    _loadStaff();
    // _loadTenant();
    fetchWorkordersDetails(widget.workorderId);
    partsAndLabor.clear();
  }

  Future<void> fetchWorkordersDetails(String workorderId) async {
    //try {
    // await _loadProperties();
    EditData fetchedDetails =
        await WorkOrderRepository().fetchWorkordersDetails(workorderId);
    print(workorderId);

    print('Address ${fetchedDetails.propertyData?.address}');
    print('rentalid ${fetchedDetails.rentalId}');
    print('category ${fetchedDetails.workCategory}');
    print('vendors ${fetchedDetails.vendorId}');
    print('entry ${fetchedDetails.entryAllowed}');
    print('Staffff ${fetchedDetails.staffmemberId}');
    print('partt ${fetchedDetails.partsandchargeData}');
    // print('Fetched parts and charge data: ${fetchedDetails.partsandchargeData?.first.account}');
    String? entryAllowedString;
    if (fetchedDetails.entryAllowed != null) {
      entryAllowedString = fetchedDetails.entryAllowed! ? 'true' : 'false';
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // print(fetchedDetails.rental.rentalAddress);
      subject.text = fetchedDetails.workSubject!;
      _selectedstaffId = fetchedDetails.staffData?.staffName;
      _selectedCategory = fetchedDetails.workCategory;
      perform.text = fetchedDetails.workPerformed!;
      _selectedStatus = fetchedDetails.status!?? "";
      vendornote.text = fetchedDetails.vendorNotes ?? "";
      _dateController.text = fetchedDetails.date!;
      _selectedOption = fetchedDetails.priority ?? "";
      _selectedPropertyId = fetchedDetails.rentalId;
      renderId = fetchedDetails.rentalId!;
      _selectedUnitId = fetchedDetails.unitId;
      isChecked = fetchedDetails.isBillable!;
      _selectedvendorsId = fetchedDetails.vendorId!.isEmpty
          ? null
          : fetchedDetails.vendorId ?? null;
      _selectedstaffId = fetchedDetails.staffmemberId ?? null;
      _selectedtenantId = fetchedDetails.tenantId ?? null;
      _selectedEntry = entryAllowedString;
      partsAndLabor =
          fetchedDetails.partsandchargeData?.map<Map<String, dynamic>>((data) {
            TextEditingController qtyController = TextEditingController(text:data.partsQuantity!.toString() );
            TextEditingController priceController = TextEditingController(text: data.partsPrice!.toString());
            TextEditingController totalController = TextEditingController(text: data.amount!.toString());
            TextEditingController subtotalcontroller = TextEditingController();
            qtyController.addListener(() {
              calculateTotal(qtyController, priceController, totalController,
                  subtotalcontroller);
            });
            priceController.addListener(() {
              calculateTotal(qtyController, priceController, totalController,
                  subtotalcontroller);
            });
                print('part id ${data.partsQuantity}');
                return {
                  "parts_id": data.partsId,
                  "qtyController": qtyController,
                  "selectedAccount": data.account ?? '',
                  "descriptionController":
                      TextEditingController(text: data.description ?? ''),
                  "priceController": priceController,
                  "totalController": totalController,
                };
              }).toList() ??
              [];

      //   partsAndLabor.clear();
      updateTotalAmount();

      // totalAmount = calculateTotalAmount(partsAndLabor);
    });

    print(fetchedDetails.tenantId);
    _loadUnits(_selectedPropertyId!);
    if (_selectedUnitId != null) {
      _loadTenant(_selectedPropertyId!, _selectedUnitId!);
    }
    // _loadUnits(renderId)
    if (_selectedProperty != null) {
      await _loadUnits(_selectedProperty!);
    }
    setState(() {
      _selectedUnit = fetchedDetails.unitId;
      print('fetch unit ${fetchedDetails.unitId}');
    });
    //} catch (e) {
    //print('Failed to fetch lease details: $e');
    //}
  }

  Future<void> _loadProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/rentals/rentals/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('${Api_url}/api/rentals/rentals/$id');
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> addresses = {};
        jsonResponse.forEach((data) {
          addresses[data['rental_id'].toString()] =
              data['rental_adress'].toString();
        });
        setState(() {
          properties = addresses;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch properties: $e')),
      );
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('$Api_url/api/unit/rental_unit/$rentalId');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};
        jsonResponse.forEach((data) {
          unitAddresses[data['unit_id'].toString()] =
              data['rental_unit'].toString();
        });
        //  200 no hoy tyare _loadtennant
        setState(() {
          units = unitAddresses;
          _isLoading = false;
        });
      } else {
        _loadTenant(rentalId, unitId);
        throw Exception('Failed to load units');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //for vendor
  Future<void> _loadVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingvendors = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/vendor/vendors/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('${Api_url}/api/vendor/vendors/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> names = {};
        jsonResponse.forEach((data) {
          names[data['vendor_id'].toString()] = data['vendor_name'].toString();
        });

        setState(() {
          vendors = names;
          _isLoadingvendors = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingvendors = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: $e')),
      );
    }
  }

  Future<void> _loadStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/staffmember/staff_member/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> staffnames = {};
        jsonResponse.forEach((data) {
          staffnames[data['staffmember_id'].toString()] =
              data['staffmember_name'].toString();
        });
        setState(() {
          staffs = staffnames;
          _isLoadingstaff = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingstaff = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: $e')),
      );
    }
  }

  Future<void> _loadTenant(String rentalId, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingtenant = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/leases/get_tenants/$rentalId/$unitId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/leases/get_tenants/$rentalId/$unitId');
      print(response.body);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> tenantsnames = {};
        jsonResponse.forEach((data) {
          tenantsnames[data['tenant_id'].toString()] =
              data['tenant_firstName'].toString() +
                  " " +
                  data['tenant_lastName'].toString();
        });
        setState(() {
          tenants = tenantsnames;
          _isLoadingtenant = false;
        });
        print(tenants);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingtenant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tenants: $e')),
      );
    }
  }

  String? _selectedCategory;
  final List<String> _category = [
    'Complaint',
    'Contribution Request',
    'Feedback/Suggestion',
    'General Inquiry',
    'Maintenance Request',
    'Other'
  ];
  String? _selectedEntry;
  final List<String> _entry = [
    'true',
    'false',
  ];
  String? _selectedStatus;
  final List<String> _status = ['New', 'In Progress', 'On Hold', 'Completed','Pending'];
  final List<String> _account = [
    'Advertising',
    'Association Fees',
    'Bank Fees',
    'Auto and Travel',
    'Cleaning and Maintenance',
    'Commissions',
    'Depreciation Expense',
    'Insurance',
    'Legal and Professional Fees',
    'Licenses and Permits',
    'Management Fees',
    'Mortgage Interest',
    'Other Expenses',
    'Other Interest Expenses',
    'Postage and Delivery',
    'Repairs',
    'Other Expenses',
  ];

  List<Map<String, dynamic>> rows = [];
  bool _showTextField = false;
  String renderId = '';
  String unitId = '';
  String vendorId = '';
  String StaffId = '';
  String tenantId = '';
  bool isChecked = false;
  //for parts and lebours
  List<Map<String, dynamic>> partsAndLabor = [];

  void addRow() {
    setState(() {
      TextEditingController qtyController = TextEditingController();
      TextEditingController priceController = TextEditingController();
      TextEditingController totalController = TextEditingController();
      TextEditingController subtotalcontroller = TextEditingController();

      qtyController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });
      priceController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });

      partsAndLabor.add({

        'qtyController': qtyController,
        'accountController': TextEditingController(),
        'descriptionController': TextEditingController(),
        'priceController': priceController,
        'totalController': totalController,
        'subtotalcontroller': subtotalcontroller,
        'selectedAccount': null,
      });
    });
  }

  void deleteRow(int index) {
    setState(() {
      partsAndLabor.removeAt(index);
      updateTotalAmount();
    });
  }

  void calculateTotal(
      TextEditingController qtyController,
      TextEditingController priceController,
      TextEditingController totalController,
      TextEditingController subtotalcontroller) {
    double quantity = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    double total = quantity * price;
    totalController.text = total.toStringAsFixed(2);
    double subtotal = total += total;
    subtotalcontroller.text = subtotal.toStringAsFixed(2);
    updateTotalAmount();
  }

  double totalAmount = 0.0;
  void updateTotalAmount() {
    double total = 0.0;
    for (var item in partsAndLabor) {
      double itemTotal = double.tryParse(item['totalController'].text) ?? 0;
      total += itemTotal;
    }
    setState(() {
      totalAmount = total;
    });
  }

  Widget buildRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                deleteRow(index);
              },
            ),
          ),
          Text(
            "Quantity",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Quantity',
            controller: partsAndLabor[index]['qtyController'],
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          Text(
            "Account",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text('Select'),
              value: _account.contains(partsAndLabor[index]['selectedAccount'])
                  ? partsAndLabor[index]['selectedAccount']
                  : null,
              items: _account.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  partsAndLabor[index]['selectedAccount'] = newValue;
                });
                print(
                    'Selected account: ${partsAndLabor[index]['selectedAccount']}');
              },
              buttonStyleData: ButtonStyleData(
                height: 45,
                width: 200,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                elevation: 2,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                ),
                iconSize: 24,
                iconEnabledColor: Color(0xFFb0b6c3),
                iconDisabledColor: Colors.grey,
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(6),
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
          SizedBox(height: 10),
          Text(
            "Description",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Description',
            controller: partsAndLabor[index]['descriptionController'],
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 10),
          Text(
            "Price",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Price',
            controller: partsAndLabor[index]['priceController'],
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          Text(
            "Total",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Total',
            controller: partsAndLabor[index]['totalController'],
            keyboardType: TextInputType.number,
            readOnnly: true,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  String _selectedOption = 'button 1';

  void _handleRadioValueChange(String? value) {
    setState(() {
      _selectedOption = value!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: blueColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: blueColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }
  //for tenants

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
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
                      color: Colors.black,
                    ),
                    "Add Staff Member",
                    false),
                buildDropdownListTile(
                    context,
                    FaIcon(
                      FontAwesomeIcons.key,
                      size: 20,
                      color: Colors.black,
                    ),
                    "Rental",
                    ["Properties", "RentalOwner", "Tenants"],
                    selectedSubtopic: "Work Order"),
                buildDropdownListTile(
                    context,
                    FaIcon(
                      FontAwesomeIcons.thumbsUp,
                      size: 20,
                      color: Colors.black,
                    ),
                    "Leasing",
                    ["Rent Roll", "Applicants"],
                    selectedSubtopic: "Work Order"),
                buildDropdownListTile(
                    context,
                    Image.asset("assets/icons/maintence.png",
                        height: 20, width: 20),
                    "Maintenance",
                    ["Vendor", "Work Order"],
                    selectedSubtopic: "Work Order"),
              ],
            ),
          ),
        ),
        body: Form(
          key: _formkey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  titleBar(
                    width: MediaQuery.of(context).size.width * .91,
                    title: 'Edit Work Order',
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      // height: !form_valid ? 860 : 830,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subject *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Add subject',
                              controller: subject,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the subject';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Photo ',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 40,
                              width: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(21, 43, 83, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: () async {},
                                child: isLoading
                                    ? Center(
                                        child: SpinKitFadingCircle(
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                      )
                                    : Text(
                                        'Upload here',
                                        style:
                                            TextStyle(color: Color(0xFFf7f8f9)),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Property *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 2,
                            ),
                            _isLoading
                                ? const Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.black,
                                      size: 50.0,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField2<String>(
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          isExpanded: true,
                                          hint: const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Select Property',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFb0b6c3),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items:
                                              properties.keys.map((rentalId) {
                                            return DropdownMenuItem<String>(
                                              value: rentalId,
                                              child: Text(
                                                properties[rentalId]!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          value: properties.containsKey(_selectedPropertyId)
                                              ? _selectedPropertyId
                                              : null,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedUnitId = null;
                                              _selectedPropertyId = value;
                                              _selectedProperty = properties[
                                                  value]; // Store selected rental_adress

                                              renderId = value.toString();
                                              print(
                                                  'Selected Property: $_selectedProperty');
                                              // _loadUnits(
                                              //     value!);
                                              if (value != null) {
                                                _loadUnits(value);
                                              }
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                            ),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness:
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 40,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select an option';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      units.isNotEmpty
                                          ? const Text('Unit',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey))
                                          : Container(),
                                      const SizedBox(height: 0),
                                      units.isNotEmpty
                                          ? DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField2<
                                                  String>(
                                                decoration: InputDecoration(
                                                    border: InputBorder.none),
                                                isExpanded: true,
                                                hint: const Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Select Unit',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xFFb0b6c3),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                items: units.keys.map((unitId) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: unitId,
                                                    child: Text(
                                                      units[unitId]!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black87,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                }).toList(),
                                                value: _selectedUnitId,
                                                onChanged: (value) {
                                                  setState(() {
                                                    unitId = value.toString();
                                                    _selectedUnitId = value;
                                                    _selectedUnit = units[
                                                        value]; // Store selected rental_unit
                                                    _loadTenant(
                                                        _selectedPropertyId!,
                                                        unitId);
                                                    print(
                                                        'Selected Unit: $_selectedUnit');
                                                  });
                                                },
                                                buttonStyleData:
                                                    ButtonStyleData(
                                                  height: 45,
                                                  width: 160,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 14, right: 14),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: Colors.white,
                                                  ),
                                                  elevation: 2,
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Icon(
                                                      Icons.arrow_drop_down),
                                                  iconSize: 24,
                                                  iconEnabledColor:
                                                      Color(0xFFb0b6c3),
                                                  iconDisabledColor:
                                                      Colors.grey,
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: Colors.white,
                                                  ),
                                                  scrollbarTheme:
                                                      ScrollbarThemeData(
                                                    radius:
                                                        const Radius.circular(
                                                            6),
                                                    thickness:
                                                        MaterialStateProperty
                                                            .all(6),
                                                    thumbVisibility:
                                                        MaterialStateProperty
                                                            .all(true),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  height: 40,
                                                  padding: EdgeInsets.only(
                                                      left: 14, right: 14),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please select an option';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Category',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text('Select Category'),
                                value: _selectedCategory,
                                items: _category.map((method) {
                                  return DropdownMenuItem<String>(
                                    value: method,
                                    child: Text(method),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                    _showTextField =
                                        _selectedCategory == 'Other';
                                  });
                                  print(
                                      'Selected category: $_selectedCategory');
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: 200,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                  ),
                                  iconSize: 24,
                                  iconEnabledColor: Color(0xFFb0b6c3),
                                  iconDisabledColor: Colors.grey,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(6),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                            _showTextField
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: buildTextField('Other Category',
                                        'Enter Other Category', other),
                                  )
                                : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Vendors *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 2,
                            ),
                            _isLoadingvendors
                                ? const Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.black,
                                      size: 50.0,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField2<String>(
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          isExpanded: true,
                                          hint: const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Select here',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFb0b6c3),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items: vendors.keys.map((vender_id) {
                                            return DropdownMenuItem<String>(
                                              value: vender_id,
                                              child: Text(
                                                vendors[vender_id]!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          value: _selectedvendorsId,
                                          onChanged: (value) {
                                            setState(() {
                                              // _selectedUnitId = null;
                                              _selectedvendorsId = value;
                                              _selectedVendors = vendors[
                                                  value]; // Store selected rental_adress

                                              vendorId = value.toString();
                                              print(
                                                  'Selected Vendors: $_selectedVendors');
                                              _loadUnits(
                                                  value!); // Fetch units for the selected property
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                            ),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness:
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 40,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select an option';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Entery allowed ',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text('Select'),
                                value: _selectedEntry,
                                items: _entry.map((method) {
                                  return DropdownMenuItem<String>(
                                    value: method,
                                    child: Text(method),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedEntry = newValue;
                                    //_selectedPaymentMethod = addRow();
                                    // if(_selectedCategory == 'Other')
                                    // addRow();
                                  });
                                  print('Selected category: $_selectedEntry');
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: 200,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                  ),
                                  iconSize: 24,
                                  iconEnabledColor: Color(0xFFb0b6c3),
                                  iconDisabledColor: Colors.grey,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(6),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Assigned To *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 2,
                            ),
                            _isLoadingstaff
                                ? const Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.black,
                                      size: 50.0,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField2<String>(
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          isExpanded: true,
                                          hint: const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Select here',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFb0b6c3),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items:
                                              staffs.keys.map((staffmember_id) {
                                            return DropdownMenuItem<String>(
                                              value: staffmember_id,
                                              child: Text(
                                                staffs[staffmember_id]!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          value: _selectedstaffId,
                                          onChanged: (value) {
                                            setState(() {
                                              // _selectedUnitId = null;
                                              _selectedstaffId = value;
                                              _selectedStaffs = staffs[
                                                  value]; // Store selected rental_adress

                                              StaffId = value.toString();
                                              print(
                                                  'Selected Staffs: $_selectedStaffs');
                                              _loadUnits(
                                                  value!); // Fetch units for the selected property
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                            ),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness:
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 40,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select an option';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Welcome To Be Performed',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter here',
                              controller: perform,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      // height: !form_valid ? 860 : 830,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Parts And Labour :',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            ...partsAndLabor.asMap().entries.map((entry) {
                              int index = entry.key;
                              return buildRow(index);
                            }).toList(),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                // SizedBox(width: 10),
                                Text('Total :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      '\$${totalAmount.toStringAsFixed(2)}'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: addRow,
                              child: Text('Add Row'),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Vendors Note *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter here',
                              controller: vendornote,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the note here';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Billable To Tenants",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 24.0, // Standard width for checkbox
                                  height: 24.0,
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
                            SizedBox(
                              height: 10,
                            ),
                            if (isChecked)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _isLoadingtenant
                                      ? const Center(
                                          child: SpinKitFadingCircle(
                                            color: Colors.black,
                                            size: 50.0,
                                          ),
                                        )
                                      : tenants.isNotEmpty
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Tenant',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                SizedBox(height: 2),
                                                DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButtonFormField2<
                                                          String>(
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none),
                                                    isExpanded: true,
                                                    hint: const Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'Select Tenant',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color(
                                                                  0xFFb0b6c3),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    items: tenants.keys
                                                        .map((tenantId) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: tenantId,
                                                        child: Text(
                                                          tenants[tenantId]!,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    }).toList(),
                                                    value: _selectedtenantId,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantId =
                                                            value.toString();
                                                        _selectedtenantId =
                                                            value;
                                                        _selectedTenants = tenants[
                                                            value]; // Store selected tenant name
                                                        print(
                                                            'Selected Tenant: $_selectedTenants');
                                                      });
                                                    },
                                                    buttonStyleData:
                                                        ButtonStyleData(
                                                      height: 45,
                                                      width: 160,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 14,
                                                              right: 14),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.white,
                                                      ),
                                                      elevation: 2,
                                                    ),
                                                    iconStyleData:
                                                        const IconStyleData(
                                                      icon: Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 24,
                                                      iconEnabledColor:
                                                          Color(0xFFb0b6c3),
                                                      iconDisabledColor:
                                                          Colors.grey,
                                                    ),
                                                    dropdownStyleData:
                                                        DropdownStyleData(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.white,
                                                      ),
                                                      scrollbarTheme:
                                                          ScrollbarThemeData(
                                                        radius: const Radius
                                                            .circular(6),
                                                        thickness:
                                                            MaterialStateProperty
                                                                .all(6),
                                                        thumbVisibility:
                                                            MaterialStateProperty
                                                                .all(true),
                                                      ),
                                                    ),
                                                    menuItemStyleData:
                                                        const MenuItemStyleData(
                                                      height: 40,
                                                      padding: EdgeInsets.only(
                                                          left: 14, right: 14),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please select an option';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                ],
                              ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Priority",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: const Text(' High'),
                                  leading: Radio<String>(
                                    value: 'High ',
                                    groupValue: _selectedOption,
                                    onChanged: _handleRadioValueChange,
                                  ),
                                ),
                                ListTile(
                                  title: const Text(' Normal'),
                                  leading: Radio<String>(
                                    value: 'Normal',
                                    groupValue: _selectedOption,
                                    onChanged: _handleRadioValueChange,
                                  ),
                                ),
                                ListTile(
                                  title: const Text(' Low'),
                                  leading: Radio<String>(
                                    value: 'Low ',
                                    groupValue: _selectedOption,
                                    onChanged: _handleRadioValueChange,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Status *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text('New'),
                                value: _selectedStatus,
                                items: _status.map((method) {
                                  return DropdownMenuItem<String>(
                                    value: method,
                                    child: Text(method),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedStatus = newValue;
                                  });
                                  print('Selected category: $_selectedStatus');
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: 200,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                  ),
                                  iconSize: 24,
                                  iconEnabledColor: Color(0xFFb0b6c3),
                                  iconDisabledColor: Colors.grey,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(6),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            const Text('Due Date',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.0,
                                          1.0), // Shadow offset to the bottom right
                                      blurRadius:
                                          8.0, // How much to blur the shadow
                                      spreadRadius:
                                          0.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Color(0xFF8898aa), // Text color
                                  fontSize: 16.0, // Text size
                                  fontWeight: FontWeight.w400, // Text weight
                                ),
                                controller: _dateController,
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFFb0b6c3)),
                                  border: InputBorder.none,
                                  // labelText: 'Select Date',
                                  hintText: 'yyyy-mm-dd',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () {
                                      _selectDate(context);
                                    },
                                  ),
                                ),
                                readOnly: true,
                                onTap: () {
                                  _selectDate(context);
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(21, 43, 83, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: _submitForm,
                            child: isLoading
                                ? Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 55.0,
                                    ),
                                  )
                                : Text(
                                    'Edit Work Order',
                                    style: TextStyle(color: Color(0xFFf7f8f9)),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                            height: 50,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFffffff),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF748097)),
                                )))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 8.0),
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: FocusNode(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isLoading = false;
  bool formValid = true;

  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      String? rentalId = _selectedPropertyId;
      String? unitId = _selectedUnitId;

      List<Map<String, dynamic>> parts = partsAndLabor.map((part) {
        return {
          'parts_id':part['parts_id'],
          "parts_quantity": int.tryParse(part['qtyController'].text) ?? 0,
          "account": part['selectedAccount'],
          "description": part['descriptionController'].text,
          "charge_type": "Workorder Charge",
          "parts_price": double.tryParse(part['priceController'].text) ?? 0.0,
          "amount": double.tryParse(part['totalController'].text) ?? 0.0,
        };
      }).toList();

      WorkOrderRepository()
          .EditWorkOrder(
        adminId: id,
        workOrderid: widget.workorderId,
        workSubject: subject.text,
        staffMemberName: _selectedstaffId,
        workCategory: _selectedCategory,
        workPerformed: perform.text,
        status: _selectedStatus,
        rentalAddress: properties[_selectedPropertyId],
        rentalUnit: units[_selectedUnitId],
        tenant: tenantId,
        rentalid: rentalId,
        unitid: unitId,
        workOrderImages: [],
        vendorId: vendorId,
        vendorNotes: vendornote.text,
        priority: _selectedOption,
        isBillable: isChecked,
        workChargeTo: isChecked == 'Tenants',
        date: _dateController.text,
        entry: _selectedEntry == 'yes',
        parts: parts,
      )
          .then((value) {
        setState(() {
          widget.property?.workSubject = subject.text;
        });
        // Success
        Fluttertoast.showToast(
          msg: "Work order updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context, true);
      }).catchError((e) {
        // Error
        Fluttertoast.showToast(
          msg: "Failed to edit work order: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print(e);
      }).whenComplete(() {
        // Final cleanup
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        formValid = false;
      });
      print('Form is invalid');
    }
  }
}

class EditWorkOrderForTablet extends StatefulWidget {
  EditData? property;
  final String workorderId;
  EditWorkOrderForTablet({super.key, required this.workorderId, this.property});
  @override
  State<EditWorkOrderForTablet> createState() => _EditWorkOrderForTabletState();
}

class _EditWorkOrderForTabletState extends State<EditWorkOrderForTablet> {
  final TextEditingController subject = TextEditingController();

  final TextEditingController other = TextEditingController();

  final TextEditingController perform = TextEditingController();
  final TextEditingController vendornote = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;
  bool _isLoading = true;
  bool _isLoadingvendors = true;
  bool _isLoadingstaff = true;
  bool _isLoadingtenant = false;
  bool _Loading = false;
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {}; // Mapping of unit_id to rental_unit
  String? _selectedPropertyId;
  String? _selectedProperty;
  String? _selectedUnitId;
  String? _selectedUnit;

  //for vendor
  Map<String, String> vendors = {};
  String? _selectedvendorsId;
  String? _selectedVendors;

  //for Staffmember
  Map<String, String> staffs = {};
  String? _selectedstaffId;
  String? _selectedStaffs;
  //for tenants
  Map<String, String> tenants = {};
  String? _selectedtenantId;
  String? _selectedTenants;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProperties();
    _loadVendor();
    _loadStaff();
    if (_selectedPropertyId != null && _selectedUnitId != null) {
      _loadTenant(_selectedPropertyId!, _selectedUnitId!);
    }
    // _loadTenant();
    fetchWorkordersDetails(widget.workorderId);
    partsAndLabor.clear();
  }

  Future<void> fetchWorkordersDetails(String workorderId) async {
    //try {
    // await _loadProperties();
    EditData fetchedDetails =
        await WorkOrderRepository().fetchWorkordersDetails(workorderId);
    print(workorderId);

    print('Address ${fetchedDetails.propertyData?.address}');
    print('rentalid ${fetchedDetails.rentalId}');
    print('category ${fetchedDetails.workCategory}');
    print('vendors ${fetchedDetails.vendorId}');
    print('entry ${fetchedDetails.entryAllowed}');
    print('entry ${fetchedDetails.staffmemberId}');
    // print('Fetched parts and charge data: ${fetchedDetails.partsandchargeData?.first.account}');
    String? entryAllowedString;
    if (fetchedDetails.entryAllowed != null) {
      entryAllowedString = fetchedDetails.entryAllowed! ? 'true' : 'false';
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // print(fetchedDetails.rental.rentalAddress);
      subject.text = fetchedDetails.workSubject!;
      _selectedstaffId = fetchedDetails.staffData?.staffName;
      _selectedCategory = fetchedDetails.workCategory;
      perform.text = fetchedDetails.workPerformed!;
      _selectedStatus = fetchedDetails.status!;
      vendornote.text = fetchedDetails.vendorNotes ?? "";
      _dateController.text = fetchedDetails.date!;
      _selectedOption = fetchedDetails.priority ?? "";
      _selectedPropertyId = fetchedDetails.rentalId?.isEmpty ?? true ? null : fetchedDetails.rentalId;
      renderId = fetchedDetails.rentalId!;
      _selectedUnitId = fetchedDetails.unitId;
      isChecked = fetchedDetails.isBillable!;
      _selectedvendorsId = fetchedDetails.vendorId!.isEmpty
          ? null
          : fetchedDetails.vendorId ?? null;
      //_selectedstaffId = fetchedDetails.staffmemberId ?? null;
      _selectedstaffId = fetchedDetails.staffmemberId?.isEmpty ?? true ? null : fetchedDetails.staffmemberId;
      _selectedtenantId = fetchedDetails.tenantId ?? null;
      _selectedEntry = entryAllowedString;
      partsAndLabor =
          fetchedDetails.partsandchargeData?.map<Map<String, dynamic>>((data) {
            TextEditingController qtyController = TextEditingController(text:data.partsQuantity!.toString() );
            TextEditingController priceController = TextEditingController(text: data.partsPrice!.toString());
            TextEditingController totalController = TextEditingController(text: data.amount!.toString());
            TextEditingController subtotalcontroller = TextEditingController();
            qtyController.addListener(() {
              calculateTotal(qtyController, priceController, totalController,
                  subtotalcontroller);
            });
            priceController.addListener(() {
              calculateTotal(qtyController, priceController, totalController,
                  subtotalcontroller);
            });
            print('part id ${data.partsQuantity}');
            return {
              "parts_id": data.partsId,
              "qtyController": qtyController,
              "selectedAccount": data.account ?? '',
              "descriptionController":
              TextEditingController(text: data.description ?? ''),
              "priceController": priceController,
              "totalController": totalController,
            };
          }).toList() ??
              [];

      updateTotalAmount();

      // totalAmount = calculateTotalAmount(partsAndLabor);
    });

    print(fetchedDetails.tenantId);
    _loadUnits(_selectedPropertyId!);
    if (_selectedUnitId != null) {
      _loadTenant(_selectedPropertyId!, _selectedUnitId!);
    }
    // _loadUnits(renderId)
    if (_selectedProperty != null) {
      await _loadUnits(_selectedProperty!);
    }
    setState(() {
      _selectedUnit = fetchedDetails.unitId;
    });
    //} catch (e) {
    //print('Failed to fetch lease details: $e');
    //}
  }

  Future<void> _loadProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/rentals/rentals/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('${Api_url}/api/rentals/rentals/$id');
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> addresses = {};
        jsonResponse.forEach((data) {
          addresses[data['rental_id'].toString()] =
              data['rental_adress'].toString();
        });
        setState(() {
          properties = addresses;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch properties: $e')),
      );
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('$Api_url/api/unit/rental_unit/$rentalId');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};
        jsonResponse.forEach((data) {
          unitAddresses[data['unit_id'].toString()] =
              data['rental_unit'].toString();
        });
        //  200 no hoy tyare _loadtennant
        setState(() {
          units = unitAddresses;
          _isLoading = false;
        });
      } else {
        _loadTenant(rentalId, unitId);
        throw Exception('Failed to load units');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //for vendor
  Future<void> _loadVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingvendors = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/vendor/vendors/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('${Api_url}/api/vendor/vendors/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> names = {};
        jsonResponse.forEach((data) {
          names[data['vendor_id'].toString()] = data['vendor_name'].toString();
        });

        setState(() {
          vendors = names;
          _isLoadingvendors = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingvendors = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: $e')),
      );
    }
  }

  Future<void> _loadStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/staffmember/staff_member/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> staffnames = {};
        jsonResponse.forEach((data) {
          staffnames[data['staffmember_id'].toString()] =
              data['staffmember_name'].toString();
        });

        setState(() {
          staffs = staffnames;
          _isLoadingstaff = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingstaff = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: $e')),
      );
    }
  }

  Future<void> _loadTenant(String rentalId, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingtenant = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/leases/get_tenants/$rentalId/$unitId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/leases/get_tenants/$rentalId/$unitId');
      print(response.body);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> tenantsnames = {};
        jsonResponse.forEach((data) {
          tenantsnames[data['tenant_id'].toString()] =
              data['tenant_firstName'].toString() +
                  " " +
                  data['tenant_lastName'].toString();
        });
        setState(() {
          tenants = tenantsnames;
          _isLoadingtenant = false;
        });
        print(tenants);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingtenant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tenants: $e')),
      );
    }
  }

  String? _selectedCategory;
  final List<String> _category = [
    'Complaint',
    'Contribution Request',
    'Feedback/Suggestion',
    'General Inquiry',
    'Maintenance Request',
    'Other'
  ];
  String? _selectedEntry;
  final List<String> _entry = [
    'true',
    'false',
  ];
  String? _selectedStatus;
  final List<String> _status = ['New', 'In Progress', 'On Hold', 'Completed'];
  final List<String> _account = [
    'Advertising',
    'Association Fees',
    'Bank Fees',
    'Auto and Travel',
    'Cleaning and Maintenance',
    'Commissions',
    'Depreciation Expense',
    'Insurance',
    'Legal and Professional Fees',
    'Licenses and Permits',
    'Management Fees',
    'Mortgage Interest',
    'Other Expenses',
    'Other Interest Expenses',
    'Postage and Delivery',
    'Repairs',
    'Other Expenses',
  ];

  List<Map<String, dynamic>> rows = [];
  bool _showTextField = false;
  String renderId = '';
  String unitId = '';
  String vendorId = '';
  String StaffId = '';
  String tenantId = '';
  bool isChecked = false;
  //for parts and lebours
  List<Map<String, dynamic>> partsAndLabor = [];

  void addRow() {
    setState(() {
      TextEditingController qtyController = TextEditingController();
      TextEditingController priceController = TextEditingController();
      TextEditingController totalController = TextEditingController();
      TextEditingController subtotalcontroller = TextEditingController();

      qtyController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });
      priceController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });

      partsAndLabor.add({
        'qtyController': qtyController,
        'accountController': TextEditingController(),
        'descriptionController': TextEditingController(),
        'priceController': priceController,
        'totalController': totalController,
        'subtotalcontroller': subtotalcontroller,
        'selectedAccount': null,
      });
    });
  }

  void deleteRow(int index) {
    setState(() {
      partsAndLabor.removeAt(index);
      updateTotalAmount();
    });
  }

  void calculateTotal(
      TextEditingController qtyController,
      TextEditingController priceController,
      TextEditingController totalController,
      TextEditingController subtotalcontroller) {
    double quantity = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    double total = quantity * price;
    totalController.text = total.toStringAsFixed(2);
    double subtotal = total += total;
    subtotalcontroller.text = subtotal.toStringAsFixed(2);
    updateTotalAmount();
  }

  double totalAmount = 0.0;
  void updateTotalAmount() {
    double total = 0.0;
    for (var item in partsAndLabor) {
      double itemTotal = double.tryParse(item['totalController'].text) ?? 0;
      total += itemTotal;
    }
    setState(() {
      totalAmount = total;
    });
  }

  Widget buildRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                deleteRow(index);
              },
            ),
          ),
          Text(
            "Quantity",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Quantity',
            controller: partsAndLabor[index]['qtyController'],
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          Text(
            "Account",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text('Select'),
              value: partsAndLabor[index]['selectedAccount'],
              items: _account.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  partsAndLabor[index]['selectedAccount'] = newValue;
                });
                print(
                    'Selected account: ${partsAndLabor[index]['selectedAccount']}');
              },
              buttonStyleData: ButtonStyleData(
                height: 45,
                width: 200,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                elevation: 2,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                ),
                iconSize: 24,
                iconEnabledColor: Color(0xFFb0b6c3),
                iconDisabledColor: Colors.grey,
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(6),
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
          SizedBox(height: 10),
          Text(
            "Description",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Description',
            controller: partsAndLabor[index]['descriptionController'],
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 10),
          Text(
            "Price",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Price',
            controller: partsAndLabor[index]['priceController'],
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          Text(
            "Total",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 5),
          CustomTextField(
            hintText: 'Total',
            controller: partsAndLabor[index]['totalController'],
            keyboardType: TextInputType.number,
            readOnnly: true,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  String _selectedOption = 'button 1';

  void _handleRadioValueChange(String? value) {
    setState(() {
      _selectedOption = value!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: blueColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: blueColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }
  //for tenants

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
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
                        color: Colors.black,
                      ),
                      "Add Staff Member",
                      false),
                  buildDropdownListTile(
                      context,
                      FaIcon(
                        FontAwesomeIcons.key,
                        size: 20,
                        color: Colors.black,
                      ),
                      "Rental",
                      ["Properties", "RentalOwner", "Tenants"],
                      selectedSubtopic: "Work Order"),
                  buildDropdownListTile(
                      context,
                      FaIcon(
                        FontAwesomeIcons.thumbsUp,
                        size: 20,
                        color: Colors.black,
                      ),
                      "Leasing",
                      ["Rent Roll", "Applicants"],
                      selectedSubtopic: "Work Order"),
                  buildDropdownListTile(
                      context,
                      Image.asset("assets/icons/maintence.png",
                          height: 20, width: 20),
                      "Maintenance",
                      ["Vendor", "Work Order"],
                      selectedSubtopic: "Work Order"),
                ],
              ),
            ),
          ),
          body: Form(
            key: _formkey,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    titleBar(
                      width: MediaQuery.of(context).size.width * .91,
                      title: 'Edit Work Order',
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .04),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              width: double.infinity,
                              // height: !form_valid ? 860 : 830,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Color.fromRGBO(21, 43, 103, 1),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Subject *',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    CustomTextField(
                                      keyboardType: TextInputType.text,
                                      hintText: 'Add subject',
                                      controller: subject,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'please enter the subject';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    /*  Text('Photo ',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    SizedBox(
                                      height: 10,
                                    ),*/
                                    // Container(
                                    //   height: 50,
                                    //   width: 150,
                                    //   decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(8.0),
                                    //   ),
                                    //   child: ElevatedButton(
                                    //     style: ElevatedButton.styleFrom(
                                    //       backgroundColor: Color.fromRGBO(21, 43, 83, 1),
                                    //       shape: RoundedRectangleBorder(
                                    //         borderRadius: BorderRadius.circular(8.0),
                                    //       ),
                                    //     ),
                                    //     onPressed: () async {
                                    //
                                    //     },
                                    //     child: isLoading
                                    //         ? Center(
                                    //       child: SpinKitFadingCircle(
                                    //         color: Colors.white,
                                    //         size: 55.0,
                                    //       ),
                                    //     )
                                    //         : Text(
                                    //       'Upload here',
                                    //       style: TextStyle(color: Color(0xFFf7f8f9)),
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Property *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField2<
                                                    String>(
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none),
                                                  isExpanded: true,
                                                  hint: const Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Select Property',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFFb0b6c3),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  items: properties.keys
                                                      .map((rentalId) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: rentalId,
                                                      child: Text(
                                                        properties[rentalId]!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value:  properties.containsKey(_selectedPropertyId)
                                                      ? _selectedPropertyId
                                                      : null,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedUnitId = null;
                                                      _selectedPropertyId =
                                                          value;
                                                      _selectedProperty =
                                                          properties[
                                                              value]; // Store selected rental_adress

                                                      renderId =
                                                          value.toString();

                                                      print(
                                                          'Selected Property: $_selectedProperty');
                                                      // _loadUnits(
                                                      //     value!);
                                                      if (value != null) {
                                                        _loadUnits(value);
                                                      }
                                                    });
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 45,
                                                    width: 160,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    iconSize: 24,
                                                    iconEnabledColor:
                                                        Color(0xFFb0b6c3),
                                                    iconDisabledColor:
                                                        Colors.grey,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              6),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please select an option';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              units.isNotEmpty
                                                  ? const Text('Unit',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey))
                                                  : Container(),
                                              const SizedBox(height: 0),
                                              units.isNotEmpty
                                                  ? DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButtonFormField2<
                                                              String>(
                                                        decoration:
                                                            InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none),
                                                        isExpanded: true,
                                                        hint: const Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'Select Unit',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color(
                                                                      0xFFb0b6c3),
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        items: units.keys
                                                            .map((unitId) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: unitId,
                                                            child: Text(
                                                              units[unitId]!,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          );
                                                        }).toList(),
                                                        value: _selectedUnitId,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            unitId = value
                                                                .toString();
                                                            _selectedUnitId =
                                                                value;
                                                            _selectedUnit = units[
                                                                value]; // Store selected rental_unit
                                                            _loadTenant(
                                                                _selectedPropertyId!,
                                                                unitId);
                                                            print(
                                                                'Selected Unit: $_selectedUnit');
                                                          });
                                                        },
                                                        buttonStyleData:
                                                            ButtonStyleData(
                                                          height: 45,
                                                          width: 160,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 14,
                                                                  right: 14),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            color: Colors.white,
                                                          ),
                                                          elevation: 2,
                                                        ),
                                                        iconStyleData:
                                                            const IconStyleData(
                                                          icon: Icon(Icons
                                                              .arrow_drop_down),
                                                          iconSize: 24,
                                                          iconEnabledColor:
                                                              Color(0xFFb0b6c3),
                                                          iconDisabledColor:
                                                              Colors.grey,
                                                        ),
                                                        dropdownStyleData:
                                                            DropdownStyleData(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            color: Colors.white,
                                                          ),
                                                          scrollbarTheme:
                                                              ScrollbarThemeData(
                                                            radius: const Radius
                                                                .circular(6),
                                                            thickness:
                                                                MaterialStateProperty
                                                                    .all(6),
                                                            thumbVisibility:
                                                                MaterialStateProperty
                                                                    .all(true),
                                                          ),
                                                        ),
                                                        menuItemStyleData:
                                                            const MenuItemStyleData(
                                                          height: 40,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 14,
                                                                  right: 14),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please select an option';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),

                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Category',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  hint: Text('Select Category'),
                                                  value: _selectedCategory,
                                                  items:
                                                      _category.map((method) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: method,
                                                      child: Text(method),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _selectedCategory =
                                                          newValue;
                                                      _showTextField =
                                                          _selectedCategory ==
                                                              'Other';
                                                    });
                                                    print(
                                                        'Selected category: $_selectedCategory');
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 45,
                                                    width: 250,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    iconSize: 24,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              6),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 50,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Entery allowed ',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  hint: Text('Select'),
                                                  value: _selectedEntry,
                                                  items: _entry.map((method) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: method,
                                                      child: Text(method),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _selectedEntry = newValue;
                                                      // _selectedPaymentMethod = addRow();
                                                      // if(_selectedCategory == 'Other')
                                                      // addRow();
                                                    });
                                                    print(
                                                        'Selected category: $_selectedEntry');
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 45,
                                                    width: 200,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    iconSize: 24,
                                                    iconEnabledColor:
                                                        Color(0xFFb0b6c3),
                                                    iconDisabledColor:
                                                        Colors.grey,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              6),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Assigned To *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              _isLoadingstaff
                                                  ? const Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        color: Colors.black,
                                                        size: 50.0,
                                                      ),
                                                    )
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        DropdownButtonHideUnderline(
                                                          child:
                                                              DropdownButtonFormField2<
                                                                  String>(
                                                            decoration:
                                                                InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none),
                                                            isExpanded: true,
                                                            hint: const Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    'Select here',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Color(
                                                                          0xFFb0b6c3),
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            items: staffs.keys.map(
                                                                (staffmember_id) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value:
                                                                    staffmember_id,
                                                                child: Text(
                                                                  staffs[
                                                                      staffmember_id]!,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              );
                                                            }).toList(),
                                                            value:
                                                                _selectedstaffId,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                // _selectedUnitId = null;
                                                                _selectedstaffId =
                                                                    value;
                                                                _selectedStaffs =
                                                                    staffs[
                                                                        value]; // Store selected rental_adress

                                                                StaffId = value
                                                                    .toString();
                                                                print(
                                                                    'Selected Staffs: $_selectedStaffs');
                                                                _loadUnits(
                                                                    value!); // Fetch units for the selected property
                                                              });
                                                            },
                                                            buttonStyleData:
                                                                ButtonStyleData(
                                                              height: 45,
                                                              width: 160,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 14,
                                                                      right:
                                                                          14),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              elevation: 2,
                                                            ),
                                                            iconStyleData:
                                                                const IconStyleData(
                                                              icon: Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                              ),
                                                              iconSize: 24,
                                                              iconEnabledColor:
                                                                  Color(
                                                                      0xFFb0b6c3),
                                                              iconDisabledColor:
                                                                  Colors.grey,
                                                            ),
                                                            dropdownStyleData:
                                                                DropdownStyleData(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              scrollbarTheme:
                                                                  ScrollbarThemeData(
                                                                radius:
                                                                    const Radius
                                                                        .circular(
                                                                        6),
                                                                thickness:
                                                                    MaterialStateProperty
                                                                        .all(6),
                                                                thumbVisibility:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                            true),
                                                              ),
                                                            ),
                                                            menuItemStyleData:
                                                                const MenuItemStyleData(
                                                              height: 40,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 14,
                                                                      right:
                                                                          14),
                                                            ),
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Please select an option';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 18),
                                                Text('Vendors *',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                _isLoadingvendors
                                                    ? const Center(
                                                        child:
                                                            SpinKitFadingCircle(
                                                          color: Colors.black,
                                                          size: 50.0,
                                                        ),
                                                      )
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButtonFormField2<
                                                                    String>(
                                                              decoration: InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                              isExpanded: true,
                                                              hint: const Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      'Select here',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Color(
                                                                            0xFFb0b6c3),
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              items: vendors
                                                                  .keys
                                                                  .map(
                                                                      (vender_id) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      vender_id,
                                                                  child: Text(
                                                                    vendors[
                                                                        vender_id]!,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              value:
                                                                  _selectedvendorsId,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  // _selectedUnitId = null;
                                                                  _selectedvendorsId =
                                                                      value;
                                                                  _selectedVendors =
                                                                      vendors[
                                                                          value]; // Store selected rental_adress

                                                                  vendorId = value
                                                                      .toString();
                                                                  print(
                                                                      'Selected Vendors: $_selectedVendors');
                                                                  _loadUnits(
                                                                      value!); // Fetch units for the selected property
                                                                });
                                                              },
                                                              buttonStyleData:
                                                                  ButtonStyleData(
                                                                height: 45,
                                                                width: 160,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            14,
                                                                        right:
                                                                            14),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                elevation: 2,
                                                              ),
                                                              iconStyleData:
                                                                  const IconStyleData(
                                                                icon: Icon(
                                                                  Icons
                                                                      .arrow_drop_down,
                                                                ),
                                                                iconSize: 24,
                                                                iconEnabledColor:
                                                                    Color(
                                                                        0xFFb0b6c3),
                                                                iconDisabledColor:
                                                                    Colors.grey,
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                scrollbarTheme:
                                                                    ScrollbarThemeData(
                                                                  radius: const Radius
                                                                      .circular(
                                                                      6),
                                                                  thickness:
                                                                      MaterialStateProperty
                                                                          .all(
                                                                              6),
                                                                  thumbVisibility:
                                                                      MaterialStateProperty
                                                                          .all(
                                                                              true),
                                                                ),
                                                              ),
                                                              menuItemStyleData:
                                                                  const MenuItemStyleData(
                                                                height: 40,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            14,
                                                                        right:
                                                                            14),
                                                              ),
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Please select an option';
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Welcome To Be Performed',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                CustomTextField(
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  hintText: 'Enter here',
                                                  controller: perform,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              width: double.infinity,
                              // height: !form_valid ? 860 : 830,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Color.fromRGBO(21, 43, 103, 1),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Parts And Labour ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    /*   ...partsAndLabor.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      return buildRow(index);
                                    }).toList(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        // SizedBox(width: 10),
                                        Text('Total :',
                                            style:
                                            TextStyle(fontWeight: FontWeight.bold,)),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                          Text('\$${totalAmount.toStringAsFixed(2)}'),
                                        ),
                                      ],
                                    ),*/
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Table(
                                      border: TableBorder.all(width: 1),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(3),
                                        2: FlexColumnWidth(3),
                                        3: FlexColumnWidth(2),
                                        4: FlexColumnWidth(2),
                                      },
                                      children: [
                                        const TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('QTY',
                                                style: TextStyle(
                                                    color:
                                                    Color.fromRGBO(21, 43, 83, 1),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Account',
                                                style: TextStyle(
                                                    color:
                                                    Color.fromRGBO(21, 43, 83, 1),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Description',
                                                style: TextStyle(
                                                    color:
                                                    Color.fromRGBO(21, 43, 83, 1),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Price',
                                                style: TextStyle(
                                                    color:
                                                    Color.fromRGBO(21, 43, 83, 1),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Amount',
                                                style: TextStyle(
                                                    color:
                                                    Color.fromRGBO(21, 43, 83, 1),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('',
                                                style: TextStyle(
                                                    color:
                                                    Color.fromRGBO(21, 43, 83, 1),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ]),
                                        /* ...summery.partsandchargeData!.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        PartsandchargeData row = entry.value;
                                        grandTotal += (row.partsQuantity! * row.partsPrice!);
                                        return TableRow(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:Text("${row.partsQuantity}"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:Text("${row.account}"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:Text("${row.description}"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:Text("\$${row.partsPrice}"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:Text("\$${(row.partsPrice! * row.partsQuantity!)}"),
                                          ),
                                        ]);
                                      }).toList(),*/
                                        ...partsAndLabor.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          return  TableRow(children: [

                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CustomTextField(
                                                hintText: 'Quantity',
                                                controller: partsAndLabor[index]['qtyController'],
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:   DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  hint: Text('Select'),
                                                  value: partsAndLabor[index]['selectedAccount'],
                                                  items: _account.map((method) {
                                                    return DropdownMenuItem<String>(
                                                      value: method,
                                                      child: Text(method),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      partsAndLabor[index]['selectedAccount'] = newValue;
                                                    });
                                                    print('Selected account: ${partsAndLabor[index]['selectedAccount']}');
                                                  },
                                                  buttonStyleData: ButtonStyleData(
                                                    height: 45,
                                                    // width: 300,
                                                    //  padding: const EdgeInsets.only(left: 14, right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData: const IconStyleData(
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    iconSize: 24,
                                                    iconEnabledColor: Color(0xFFb0b6c3),
                                                    iconDisabledColor: Colors.grey,
                                                  ),
                                                  dropdownStyleData: DropdownStyleData(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme: ScrollbarThemeData(
                                                      radius: const Radius.circular(6),
                                                      thickness: MaterialStateProperty.all(6),
                                                      thumbVisibility: MaterialStateProperty.all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData: const MenuItemStyleData(
                                                    height: 50,
                                                    padding: EdgeInsets.only(left: 14, right: 14),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CustomTextField(
                                                hintText: 'Description',
                                                controller: partsAndLabor[index]['descriptionController'],
                                                keyboardType: TextInputType.text,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:  CustomTextField(
                                                hintText: 'Price',
                                                controller: partsAndLabor[index]['priceController'],
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:  CustomTextField(
                                                hintText: 'Total',
                                                controller: partsAndLabor[index]['totalController'],
                                                keyboardType: TextInputType.number,
                                                readOnnly: true,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:  IconButton(
                                                icon: Icon(Icons.close, color:Colors.black),
                                                onPressed: () {
                                                  deleteRow(index);
                                                },
                                              ),
                                            ),
                                            /* Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("\$${grandTotal.toString()}",style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                        ),*/

                                            /* Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '\$${totalAmount.toStringAsFixed(2)}'),
                          ),*/

                                          ]);
                                        }).toList(),

                                        TableRow(children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Total',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ),

                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          /* const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),*/
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child:Text('\$${totalAmount.toStringAsFixed(2)}'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child:Text(''),
                                          ),

                                          /* Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '\$${totalAmount.toStringAsFixed(2)}'),
                          ),*/

                                        ]),
                                        /*TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 34,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1),
                                  borderRadius:
                                  BorderRadius.circular(10.0)),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            10.0)),
                                    elevation: 0,
                                    backgroundColor: Colors.white),
                                onPressed: addRow,
                                child: const Text(
                                  'Add Row',
                                  style: TextStyle(
                                    color:
                                    Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox.shrink(),
                          const SizedBox.shrink(),
                        ]),*/
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: addRow,
                                      child: Text('Add Row'),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Billable To Tenants",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width:
                                              24.0, // Standard width for checkbox
                                          height: 24.0,
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
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        if (isChecked)
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  _isLoadingtenant
                                                      ? const Center(
                                                          child:
                                                              SpinKitFadingCircle(
                                                            color: Colors.black,
                                                            size: 50.0,
                                                          ),
                                                        )
                                                      : tenants.isNotEmpty
                                                          ? Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 3,
                                                                ),
                                                                Text('Tenant',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .grey)),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                DropdownButtonHideUnderline(
                                                                  child:
                                                                      DropdownButtonFormField2<
                                                                          String>(
                                                                    decoration:
                                                                        InputDecoration(
                                                                            border:
                                                                                InputBorder.none),
                                                                    isExpanded:
                                                                        true,
                                                                    hint:
                                                                        const Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            'Select Tenant',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Color(0xFFb0b6c3),
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    items: tenants
                                                                        .keys
                                                                        .map(
                                                                            (tenantId) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            tenantId,
                                                                        child:
                                                                            Text(
                                                                          tenants[
                                                                              tenantId]!,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                    value:
                                                                        _selectedtenantId,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        tenantId =
                                                                            value.toString();
                                                                        _selectedtenantId =
                                                                            value;
                                                                        _selectedTenants =
                                                                            tenants[value]; // Store selected tenant name
                                                                        print(
                                                                            'Selected Tenant: $_selectedTenants');
                                                                      });
                                                                    },
                                                                    buttonStyleData:
                                                                        ButtonStyleData(
                                                                      height:
                                                                          45,
                                                                      width:
                                                                          160,
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              14,
                                                                          right:
                                                                              14),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6),
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      elevation:
                                                                          2,
                                                                    ),
                                                                    iconStyleData:
                                                                        const IconStyleData(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .arrow_drop_down),
                                                                      iconSize:
                                                                          24,
                                                                      iconEnabledColor:
                                                                          Color(
                                                                              0xFFb0b6c3),
                                                                      iconDisabledColor:
                                                                          Colors
                                                                              .grey,
                                                                    ),
                                                                    dropdownStyleData:
                                                                        DropdownStyleData(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6),
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      scrollbarTheme:
                                                                          ScrollbarThemeData(
                                                                        radius: const Radius
                                                                            .circular(
                                                                            6),
                                                                        thickness:
                                                                            MaterialStateProperty.all(6),
                                                                        thumbVisibility:
                                                                            MaterialStateProperty.all(true),
                                                                      ),
                                                                    ),
                                                                    menuItemStyleData:
                                                                        const MenuItemStyleData(
                                                                      height:
                                                                          40,
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              14,
                                                                          right:
                                                                              14),
                                                                    ),
                                                                    validator:
                                                                        (value) {
                                                                      if (value ==
                                                                              null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return 'Please select an option';
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Vendors Note *',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey)),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  CustomTextField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    hintText: 'Enter here',
                                                    controller: vendornote,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'please enter the note here';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    /* Row(
                                  children: [
                                    Text("Billable To Tenants",style: TextStyle(
                                        color: Colors.grey
                                    ),),
                                    SizedBox(width: 10,),
                                    SizedBox(
                                      width: 24.0, // Standard width for checkbox
                                      height: 24.0,
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
                                SizedBox(
                                  height: 10,
                                ),
                                if(isChecked)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _isLoadingtenant
                                          ? const Center(
                                        child: SpinKitFadingCircle(
                                          color: Colors.black,
                                          size: 50.0,
                                        ),
                                      )
                                          : tenants.isNotEmpty
                                          ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Tenant',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 2),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField2<String>(
                                              decoration: InputDecoration(border: InputBorder.none),
                                              isExpanded: true,
                                              hint: const Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Select Tenant',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xFFb0b6c3),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              items: tenants.keys.map((tenantId) {
                                                return DropdownMenuItem<String>(
                                                  value: tenantId,
                                                  child: Text(
                                                    tenants[tenantId]!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              value: _selectedtenantId,
                                              onChanged: (value) {
                                                setState(() {
                                                  tenantId = value.toString();
                                                  _selectedtenantId = value;
                                                  _selectedTenants = tenants[value]; // Store selected tenant name
                                                  print('Selected Tenant: $_selectedTenants');
                                                });
                                              },
                                              buttonStyleData: ButtonStyleData(
                                                height: 45,
                                                width: 160,
                                                padding: const EdgeInsets.only(left: 14, right: 14),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                elevation: 2,
                                              ),
                                              iconStyleData: const IconStyleData(
                                                icon: Icon(Icons.arrow_drop_down),
                                                iconSize: 24,
                                                iconEnabledColor: Color(0xFFb0b6c3),
                                                iconDisabledColor: Colors.grey,
                                              ),
                                              dropdownStyleData: DropdownStyleData(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                scrollbarTheme: ScrollbarThemeData(
                                                  radius: const Radius.circular(6),
                                                  thickness: MaterialStateProperty.all(6),
                                                  thumbVisibility: MaterialStateProperty.all(true),
                                                ),
                                              ),
                                              menuItemStyleData: const MenuItemStyleData(
                                                height: 40,
                                                padding: EdgeInsets.only(left: 14, right: 14),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please select an option';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                          : Container(),
                                    ],
                                  ),
                                SizedBox(
                                  height: 15,
                                ),*/
                                    Row(
                                      children: [
                                        Text(
                                          "Priority",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: ListTile(
                                            title: const Text('High'),
                                            leading: Radio<String>(
                                              value: 'High',
                                              groupValue: _selectedOption,
                                              onChanged:
                                                  _handleRadioValueChange,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: ListTile(
                                            title: const Text('Normal'),
                                            leading: Radio<String>(
                                              value: 'Normal',
                                              groupValue: _selectedOption,
                                              onChanged:
                                                  _handleRadioValueChange,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: ListTile(
                                            title: const Text('Low'),
                                            leading: Radio<String>(
                                              value: 'Low',
                                              groupValue: _selectedOption,
                                              onChanged:
                                                  _handleRadioValueChange,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: ListTile(
                                            title: const Text(''),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Status *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  hint: Text('New'),
                                                  value: _selectedStatus,
                                                  items: _status.map((method) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: method,
                                                      child: Text(method),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _selectedStatus =
                                                          newValue;
                                                    });
                                                    print(
                                                        'Selected category: $_selectedStatus');
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 45,
                                                    width: 200,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    iconSize: 24,
                                                    iconEnabledColor:
                                                        Color(0xFFb0b6c3),
                                                    iconDisabledColor:
                                                        Colors.grey,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              6),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Due Date',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                height: 46,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      const BoxShadow(
                                                        color: Colors.black26,
                                                        offset: Offset(1.0,
                                                            1.0), // Shadow offset to the bottom right
                                                        blurRadius:
                                                            8.0, // How much to blur the shadow
                                                        spreadRadius:
                                                            0.0, // How much the shadow should spread
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                        width: 0,
                                                        color: Colors.white),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0)),
                                                child: TextFormField(
                                                  style: const TextStyle(
                                                    color: Color(
                                                        0xFF8898aa), // Text color
                                                    fontSize: 16.0, // Text size
                                                    fontWeight: FontWeight
                                                        .w400, // Text weight
                                                  ),
                                                  controller: _dateController,
                                                  decoration: InputDecoration(
                                                    hintStyle: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFFb0b6c3)),
                                                    border: InputBorder.none,
                                                    // labelText: 'Select Date',
                                                    hintText: 'yyyy-mm-dd',
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(
                                                          Icons.calendar_today),
                                                      onPressed: () {
                                                        _selectDate(context);
                                                      },
                                                    ),
                                                  ),
                                                  readOnly: true,
                                                  onTap: () {
                                                    _selectDate(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: ListTile(
                                            title: const Text(''),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(21, 43, 83, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: _submitForm,
                                    child: isLoading
                                        ? Center(
                                            child: SpinKitFadingCircle(
                                              color: Colors.white,
                                              size: 55.0,
                                            ),
                                          )
                                        : Text(
                                            'Edit Work Order',
                                            style: TextStyle(
                                                color: Color(0xFFf7f8f9)),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                    height: 50,
                                    width: 120,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFffffff),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0))),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Color(0xFF748097)),
                                        )))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget buildTextField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 8.0),
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: FocusNode(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isLoading = false;
  bool formValid = true;

  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      String? rentalId = _selectedPropertyId;
      String? unitId = _selectedUnitId;

      List<Map<String, dynamic>> parts = partsAndLabor.map((part) {
        return {
          'parts_id':part['parts_id'],
          "parts_quantity": int.tryParse(part['qtyController'].text) ?? 0,
          "account": part['selectedAccount'],
          "description": part['descriptionController'].text,
          "charge_type": "Workorder Charge",
          "parts_price": double.tryParse(part['priceController'].text) ?? 0.0,
          "amount": double.tryParse(part['totalController'].text) ?? 0.0,
        };
      }).toList();
      log(parts.toString());
      print('staff id:${_selectedstaffId}');
      WorkOrderRepository()
          .EditWorkOrder(
        adminId: id,
        workOrderid: widget.workorderId,
        workSubject: subject.text,
        staffMemberName: _selectedstaffId,
        workCategory: _selectedCategory,
        workPerformed: perform.text,
        status: _selectedStatus,
        rentalAddress: properties[_selectedPropertyId],
        rentalUnit: units[_selectedUnitId],
        tenant: tenantId,
        rentalid: rentalId,
        unitid: unitId,
        workOrderImages: [],
        vendorId: vendorId,
        vendorNotes: vendornote.text,
        priority: _selectedOption,
        isBillable: isChecked,
        workChargeTo: isChecked == 'Tenants',
        date: _dateController.text,
        entry: _selectedEntry == 'yes',
        parts: parts,
      )
          .then((value) {
        setState(() {
          widget.property?.workSubject = subject.text;
        });
        // Success
        Fluttertoast.showToast(
          msg: "Work order updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context, true);
      }).catchError((e) {
        // Error
        Fluttertoast.showToast(
          msg: "Failed to edit work order: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print(e);
      }).whenComplete(() {
        // Final cleanup
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        formValid = false;
      });
      print('Form is invalid');
    }
  }
}
