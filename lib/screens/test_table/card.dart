import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../widgets/drawer_tiles.dart';
import '../Rental/Tenants/add_tenants.dart';

class Cardpayment extends StatefulWidget {
  final String leaseId;
   Cardpayment({ required this.leaseId});
  @override
  _CardpaymentState createState() => _CardpaymentState();
}

class _CardpaymentState extends State<Cardpayment> {
  List<Map<String, dynamic>> rows = [];
  List<Map<String, dynamic>> check = [];
  Map<String, List<Map<String, dynamic>>> groupedCharges = {};
  void addcheck(){
    setState(() {
      check.add({
        "checkController": TextEditingController(),
      });
    });
  }
  void removecheck(int index) {
    setState(() {
      rows.removeAt(index);
    });
  }
  void addRow() {
    setState(() {
      rows.add({
        "accountController": TextEditingController(),
        "balanceController": TextEditingController(),
        "amountController": TextEditingController(),
        "selectedChargeId": null,
      });
    });
  }
  void removeRow(int index) {
    setState(() {
      rows.removeAt(index);
    });
  }

  List<DropdownMenuItem<String>> groupedItems = [];

  Future<void> fetchCharges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
   // String adminId = prefs.getString('adminId').toString();
    String?  id = prefs.getString('adminId');
    final response = await http.get(Uri.parse('$Api_url/api/accounts/accounts/$id'), headers: {"authorization" : "CRM $token","id":"CRM $id",});

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      categorizeCharges(data);
    } else {
      throw Exception('Failed to load charges');
    }
  }

  void categorizeCharges(List<dynamic> data) {
    final Map<String, List<Map<String, dynamic>>> categorizedData = {};

    categorizedData['LIABILITY ACCOUNT'] = [
      {'_id': 'static_1', 'account': 'Last-month payment'},
      {'_id': 'static_3', 'account': 'Pre-payment'},
      {'_id': 'static_2', 'account': 'Security deposit liability'},
    ];

    for (var charge in data) {
      String chargeType = charge['charge_type'];
      if (!categorizedData.containsKey(chargeType)) {
        categorizedData[chargeType] = [];
      }
      categorizedData[chargeType]!.add(charge);
    }

    setState(() {
      groupedCharges = categorizedData;
    });
  }
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController Amount = TextEditingController();
  final TextEditingController Memo = TextEditingController();
  List<Map<String, String>> tenants = [];
  String? selectedTenantId;

  @override
  void initState() {
    super.initState();
    fetchTenants();
    fetchCharges();
    /* fetchDropdownData().then((fetchedItems) {
      setState(() {
        items = fetchedItems;
        groupedItems = buildGroupedItems(items);
      });
    });*/
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http
        .get(Uri.parse('$Api_url/api/leases/lease_tenant/${widget.leaseId}'),
      headers: {"authorization" : "CRM $token","id":"CRM $id",},);
   print(response.body);
   print(widget.leaseId);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final List<Map<String, String>> fetchedTenants = [];

      for (var tenant in data['data']['tenants']) {
        fetchedTenants.add({
          'tenant_id': tenant['tenant_id'],
          'tenant_name':
          '${tenant['tenant_firstName']} ${tenant['tenant_lastName']}',
        });
      }
      setState(() {
        tenants = fetchedTenants;
      });
    } else {
      throw Exception('Failed to load tenants');
    }
  }

  String? _selectedChargeId;
  String? selectedValue;
  List<String> items = [];
  /*Future<List<String>> fetchDropdownData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId').toString();
    String? token = prefs.getString('token');
    print("$Api_url/api/accounts/accounts/$adminId");
    print("headers: {authorization : CRM $token}");
    final response =
    await http.get(Uri.parse('$Api_url/api/accounts/accounts/$adminId'),  headers: {"authorization" : "CRM $token"},);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<String> fetchedItems =
      jsonResponse.map((item) => item['name'] as String).toList();

      // Add static items
      fetchedItems.addAll(['Yash', 'Jay']);

      return fetchedItems;
    } else {
      throw Exception('Failed to load data');
    }
  }*/
  List<DropdownMenuItem<String>> buildGroupedItems(List<String> items) {
    List<DropdownMenuItem<String>> result = [];

    // Add the Local group
    result.add(
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'LIABILITY ACCOUNT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromRGBO(21, 43, 83, 1),
          ),
        ),
      ),
    );
    result.addAll(
      items.where((item) => item == 'Yash' || item == 'Jay').map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );

    // Add the Dynamic group
    result.add(
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'RECURRING CHARGES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromRGBO(21, 43, 83, 1),
          ),
        ),
      ),
    );
    result.addAll(
      items.where((item) => item != 'Yash' && item != 'Jay').map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
    result.add(
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'ONE TIME CHARGES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromRGBO(21, 43, 83, 1),
          ),
        ),
      ),
    );
    result.addAll(
      items.where((item) => item != 'Yash' && item != 'Jay').map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );

    return result;
  }
  String? _selectedPaymentMethod;
  String? _selectedAccount;
  String? _selectedHoldertype;

  final List<String> _paymentMethods = ['Card', 'Check', 'Cash', 'ACH'];
  final List<String> _selecttype = ['Checking', 'Savings'];
  final List<String> _selectholder= ['Business', 'Personal'];

  final _formKey = GlobalKey<FormState>();

  bool showCardNumberField = false;
  bool showCheckNumberField = false;
  bool showACHFields = false;

  void AddFields() {
    setState(() {
      showCardNumberField = _selectedPaymentMethod == 'Card';
      showCheckNumberField = _selectedPaymentMethod == 'Check';
      showACHFields = _selectedPaymentMethod == 'ACH';
    });
  }
  TextEditingController checknumber = TextEditingController();
  TextEditingController bankrountingnum = TextEditingController();
  TextEditingController accountnum = TextEditingController();
  TextEditingController achname = TextEditingController();

//for file
  List<File> _pdfFiles = [];

  List<String> _uploadedFileNames = [];

  Future<void> _pickPdfFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      if (files.length > 10) {
        Fluttertoast.showToast(msg: 'You can only select up to 10 files.');
        return; // Exit the method if more than 10 files are selected
      }

      setState(() {
        _pdfFiles = files;
      });

      for (var file in _pdfFiles) {
        await _uploadPdf(file);
      }
    }
  }

  Future<void> _uploadPdf(File pdfFile) async {
    try {
      String? fileName = await uploadPdf(pdfFile);
      setState(() {
        if (fileName != null) {
          _uploadedFileNames.add(fileName);
        }
      });
    } catch (e) {
      print('PDF upload failed: $e');
    }
  }

  Future<String?> uploadPdf(File pdfFile) async {
    print(pdfFile.path);
    final String uploadUrl = '${Api_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', pdfFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      Fluttertoast.showToast(msg: 'PDF added successfully');
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  //for payment

  Map<String, List<String>> categorizedData = {};
  double totalAmount = 0.0;
  String? validationMessage;
  bool hasError = false;

  void validateAmounts() {
    double enteredAmount = double.tryParse(Amount.text) ?? 0.0;
    if (enteredAmount != totalAmount) {
      setState(() {
        validationMessage =
        "The charge's amount must match the total applied to balance. The difference is ${(enteredAmount - totalAmount).abs().toStringAsFixed(2)}";
      });
    } else {
      setState(() {
        validationMessage = null;
      });
    }
  }
  void deleteRow(int index) {
    setState(() {
      totalAmount -= rows[index]['amount'];
      rows.removeAt(index);
    });
    validateAmounts();
  }
  void updateAmount(int index, String value) {
    setState(() {
      double amount = double.tryParse(value) ?? 0.0;
      totalAmount -= rows[index]['amount'];
      rows[index]['amount'] = amount;
      totalAmount += amount;
    });
    validateAmounts();
  }
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
                  selectedSubtopic: "Rent Roll"),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Rent Roll"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Rent Roll"),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller:_scrollController,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(left: 5,right: 5,top: 10,bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child:
                        Container(
                          height: 50.0,
                          padding: const EdgeInsets.only(top: 14, left: 10),
                          width: MediaQuery.of(context).size.width * .91,
                          margin: const EdgeInsets.only(bottom: 6.0),
                          //Same as `blurRadius` i guess
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color.fromRGBO(21, 43, 81, 1),
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: const Text(
                            "Make Payment",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            const Text('Received From *',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 8,
                            ),
                            tenants.isEmpty
                                ? const Center(
                              child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 50.0,
                              ),
                            )
                                : DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text('Select Resident'),
                                value: selectedTenantId,
                                items: tenants.map((tenant) {
                                  return DropdownMenuItem<String>(
                                    value: tenant['tenant_id'],
                                    child: Text(tenant['tenant_name']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTenantId = value;
                                  });
                                  print(
                                      'Selected tenant_id: $selectedTenantId');
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
                                  padding:
                                  EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            /*  DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text('Select Name'),
                              value: selectedValue,
                              items: groupedItems,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                width: 160,
                                padding:
                                const EdgeInsets.only(left: 14, right: 14),
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
                                  thumbVisibility:
                                  MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),*/
                            const Text('Amount',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              hintText: 'Enter Amount',
                              controller: Amount,
                              onChanged: (value) => validateAmounts(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Date',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  locale: const Locale('en', 'US'),
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color.fromRGBO(21, 43, 83,
                                              1), // header background color
                                          onPrimary:
                                          Colors.white, // header text color
                                          onSurface: Color.fromRGBO(
                                              21, 43, 83, 1), // body text color
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: const Color.fromRGBO(
                                                21,
                                                43,
                                                83,
                                                1), // button text color
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                  setState(() {
                                    _startDate.text = formattedDate;
                                  });
                                }
                              },
                              readOnnly: true,
                              suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.date_range_rounded)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select start date';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              hintText: 'dd-mm-yyyy',
                              controller: _startDate,
                            ),
                            const SizedBox(
                              height: 13,
                            ),
                            const Text('Payment Method',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 12,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text('Select Method'),
                                value: _selectedPaymentMethod,
                                items: _paymentMethods.map((method) {
                                  return DropdownMenuItem<String>(
                                    value: method,
                                    child: Text(method),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  // setState(() {
                                  //   _selectedPaymentMethod = newValue;
                                  //   //_selectedPaymentMethod = addRow();
                                  //   if(_selectedPaymentMethod == 'Card')
                                  //   addRow();
                                  //   if(_selectedPaymentMethod == 'Check')
                                  //    Text("hello");
                                  //
                                  // });
                                  setState(() {
                                    _selectedPaymentMethod = newValue;
                                    AddFields();
                                  });
                                  print('Selected payment method: $_selectedPaymentMethod');
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
                            const SizedBox(
                              height: 12,
                            ),
                            if (showCardNumberField) ...[
                              SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                               color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                     SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          SizedBox(width: 10,),
                                          Text("Cards",style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                     SizedBox(
                                       height: 20,
                                     ),
                                     Row(
                                      children: [
                                        SizedBox(width: 10,),
                                        GestureDetector(
                                          onTap: () async {

                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5.0),
                                            child: Container(
                                              height: MediaQuery.of(context).size.height * .04,
                                              // width: MediaQuery.of(context).size.width * .36,
                                              width: MediaQuery.of(context).size.width * .2,
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
                                              child: Center(
                                                child: isLoading
                                                    ? SpinKitFadingCircle(
                                                  color: Colors.white,
                                                  size: 25.0,
                                                )
                                                    : Text(
                                                  "Add Card",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .025),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                            ],
                            if (showCheckNumberField) ...[
                              SizedBox(height: 10),
                              buildTextField('Check Number', "Enter check number", checknumber),
                              SizedBox(height: 10),
                            ],
                            if (showACHFields) ...[
                              SizedBox(height: 10),
                              buildTextField('Bank Routing Number', "Enter routing number", bankrountingnum),
                              SizedBox(height: 10),
                              buildTextField('Bank Account Number', "Enter account number", accountnum),
                              SizedBox(height: 10),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text('Select Account'),
                                  value: _selectedAccount,
                                  items: _selecttype.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    // setState(() {
                                    //   _selectedPaymentMethod = newValue;
                                    //   //_selectedPaymentMethod = addRow();
                                    //   if(_selectedPaymentMethod == 'Card')
                                    //   addRow();
                                    //   if(_selectedPaymentMethod == 'Check')
                                    //    Text("hello");
                                    //
                                    // });
                                    setState(() {
                                      _selectedAccount = newValue;

                                    });
                                    print('Selected payment method: $_selectedAccount');
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
                              buildTextField('Name of the ACH account', "Enter account name", achname),
                              SizedBox(height: 10),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text('Select Account Holder Type'),
                                  value: _selectedHoldertype,
                                  items: _selectholder.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    // setState(() {
                                    //   _selectedPaymentMethod = newValue;
                                    //   //_selectedPaymentMethod = addRow();
                                    //   if(_selectedPaymentMethod == 'Card')
                                    //   addRow();
                                    //   if(_selectedPaymentMethod == 'Check')
                                    //    Text("hello");
                                    //
                                    // });
                                    setState(() {
                                      _selectedHoldertype = newValue;
                                    });
                                    print('Selected payment method: $_selectedHoldertype');
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
                            ],
                            const Text('Memo',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter memo';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Memo',
                              controller: Memo,
                            ),
                            SizedBox(height: 15),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Apply Payment to Balances',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            isLoading
                                ? const Center(
                              child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 50.0,
                              ),
                            )
                                : hasError
                                ? const Center(child: Text('Failed to load data'))
                                : Table(
                              border: TableBorder.all(width: 1),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(1),
                              },
                              children: [
                                const TableRow(children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text('Account',
                                          style: TextStyle(
                                              color:
                                              Color.fromRGBO(21, 43, 83, 1),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text('Amount',
                                          style: TextStyle(
                                              color:
                                              Color.fromRGBO(21, 43, 83, 1),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text('Actions',
                                          style: TextStyle(
                                              color:
                                              Color.fromRGBO(21, 43, 83, 1),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ]),
                                ...rows.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> row = entry.value;
                                  return TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                      DropdownButtonHideUnderline(
                                                      child: DropdownButton2<String>(
                                                        isExpanded: true,
                                                        hint: Text('Select account'),
                                                        value: row['selectedChargeId'],
                                                        items: groupedCharges.entries.expand((entry) {
                                                          List<DropdownMenuItem<String>> items = [];
                                                          items.add(DropdownMenuItem<String>(
                                                            enabled: false,
                                                            value: entry.key,
                                                            child: Text(
                                                              entry.key,
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ));
                                                          items.addAll(entry.value.map((charge) {
                                                            return DropdownMenuItem<String>(
                                                              value: charge['_id'],
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(left: 16.0),
                                                                child: Text(charge['account']),
                                                              ),
                                                            );
                                                          }));
                                                          return items;
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            row['selectedChargeId'] = newValue;
                                                          });
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
                                                      ),
                                                    ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) =>
                                            updateAmount(index, value),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Enter amount',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => deleteRow(index),
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                                TableRow(children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        '\$${totalAmount.toStringAsFixed(2)}'),
                                  ),
                                  const SizedBox.shrink(),
                                ]),
                                TableRow(children: [
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
                                ]),
                              ],
                            ),
                            if (validationMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  validationMessage!,
                                  style: TextStyle(
                                      color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(height: 16),
                            /*this is for card type*/
                            Text('Apply Payments to Balances',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(height: 5),
                            ...rows.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> row = entry.value;
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Material(
                                  elevation: 3,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Row ${index + 1}', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: IconButton(
                                                  icon: Icon(Icons.close),
                                                  onPressed: () {
                                                    removeRow(index);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.0),
                                          Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
                                          SizedBox(height: 12,),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              hint: Text('Select Charge'),
                                              value: row['selectedChargeId'],
                                              items: groupedCharges.entries.expand((entry) {
                                                List<DropdownMenuItem<String>> items = [];
                                                items.add(DropdownMenuItem<String>(
                                                  enabled: false,
                                                  value: entry.key,
                                                  child: Text(
                                                    entry.key,
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ));
                                                items.addAll(entry.value.map((charge) {
                                                  return DropdownMenuItem<String>(
                                                    value: charge['_id'],
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 16.0),
                                                      child: Text(charge['account']),
                                                    ),
                                                  );
                                                }));
                                                return items;
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  row['selectedChargeId'] = newValue;
                                                });
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
                                            ),
                                          ),
                                          SizedBox(height: 12.0),
                                          buildTextField('Balance', 'Enter Balance', row['balanceController']),
                                          SizedBox(height: 12.0),
                                          buildTextField('Amount', 'Enter Amount', row['amountController']),
                                          SizedBox(height: 12.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 15),

                            Row(
                              children: [
                                SizedBox(width: 5,),
                                GestureDetector(
                                  onTap: () async {
                                    addRow();
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * .05,
                                      // width: MediaQuery.of(context).size.width * .36,
                                      width: MediaQuery.of(context).size.width * .33,
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
                                      child: Center(
                                        child: isLoading
                                            ? SpinKitFadingCircle(
                                          color: Colors.white,
                                          size: 25.0,
                                        )
                                            : Text(
                                          "Add Row",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  .032),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(height: 10),
                            // Text('Upload Files (Maximum of 10)',
                            //     style: TextStyle(
                            //         fontSize: 14,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.grey)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 5,),
                                GestureDetector(
                                  onTap: () async {
                                    _pickPdfFiles();
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * .05,
                                      // width: MediaQuery.of(context).size.width * .36,
                                      width: MediaQuery.of(context).size.width * .33,
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
                                      child: Center(
                                        child: isLoading
                                            ? SpinKitFadingCircle(
                                          color: Colors.white,
                                          size: 25.0,
                                        )
                                            : Text(
                                          "Choose Files",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  .032),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            SingleChildScrollView(
                              child: Column(
                                children: _uploadedFileNames.map((fileName) {
                                  int index = _uploadedFileNames.indexOf(fileName);
                                  return ListTile(
                                    title: Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF748097),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _uploadedFileNames.removeAt(index);
                                        });
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.remove,
                                        color: Color(0xFF748097),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height:20
                    ),
                    Row(
                      children: [
                        Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: blueColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8.0))),
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    print('valid');
                                    print(selectedTenantId);
                                    //charges
                                  } else {
                                    print('invalid');
                                    print(selectedTenantId);
                                  }
                                },
                                child: const Text(
                                  'Make Payment',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))),
                        const SizedBox(
                          width: 12,
                        ),
                        Container(
                            height: 50,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFffffff),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8.0))),
                                onPressed: () {
                                   Navigator.pop(context);
                                  // firstName.clear();
                                  // lastName.clear();
                                  // email.clear();
                                  // mobileNumber.clear();
                                  // bussinessNumber.clear();
                                  // homeNumber.clear();
                                  // telePhoneNumber.clear();
                                  // _selectedProperty = null;
                                  // _selectedUnit = null;
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF748097)),
                                ))),

                      ],
                    ),
                    SizedBox(
                      height: 10,
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
  Widget buildTextField(String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
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
}
