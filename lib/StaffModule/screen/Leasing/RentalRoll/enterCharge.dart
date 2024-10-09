import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '../../../repository/lease.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

import '../../../../model/EnterChargeModel.dart';
import '../../../widgets/custom_drawer.dart';

class Chargedata {
  String? id;
  String? chargeId;
  String? adminId;
  String? tenantId;
  String? leaseId;
  List<Entrydata>? entry;
  double? totalAmount;
  bool? isLeaseAdded;
  String? type;
  List<dynamic>? uploadedFile;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isDelete;
  TenantData? tenantData;

  Chargedata({
    this.id,
    this.chargeId,
    this.adminId,
    this.tenantId,
    this.leaseId,
    this.entry,
    this.totalAmount,
    this.isLeaseAdded,
    this.type,
    this.uploadedFile,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.tenantData,
  });

  factory Chargedata.fromJson(Map<String, dynamic> json) {
    return Chargedata(
      id: json['_id'],
      chargeId: json['charge_id'],
      adminId: json['admin_id'],
      tenantId: json['tenant_id'],
      leaseId: json['lease_id'],
      entry: json['entry'] != null
          ? List<Entrydata>.from(
              json['entry'].map((x) => Entrydata.fromJson(x)))
          : [],
      totalAmount:
          json['total_amount'] != null ? json['total_amount'].toDouble() : 0.0,
      isLeaseAdded: json['is_leaseAdded'],
      type: json['type'],
      uploadedFile: json['uploaded_file'] ?? [],
      tenantData: json['tenantData'] != null
          ? TenantData.fromJson(json['tenantData'])
          : null,
    );
  }
}

class Entrydata {
  String? entryId;
  String? memo;
  String? account;
  double? amount;
  double? dueAmount;
  DateTime? date;
  bool? isPaid;
  bool? isLateFee;
  bool? isRepeatable;
  String? chargeType;
  String? id;

  Entrydata({
    this.entryId,
    this.memo,
    this.account,
    this.amount,
    this.dueAmount,
    this.date,
    this.isPaid,
    this.isLateFee,
    this.isRepeatable,
    this.chargeType,
    this.id,
  });

  factory Entrydata.fromJson(Map<String, dynamic> json) {
    return Entrydata(
      entryId: json['entry_id'],
      memo: json['memo'],
      account: json['account'],
      amount: json['amount'].toDouble(),
      dueAmount:
          json['due_amount'] != null ? json['due_amount'].toDouble() : 0.0,
      date: DateTime.parse(json['date']),
      isPaid: json['is_paid'],
      isLateFee: json['is_lateFee'],
      isRepeatable: json['is_repeatable'],
      chargeType: json['charge_type'],
      id: json['_id'],
    );
  }
}

class TenantData {
  EmergencyContact? emergencyContact;
  String? tenantId;
  String? adminId;
  String? tenantFirstName;
  String? tenantLastName;
  String? tenantPhoneNumber;
  String? tenantAlternativeNumber;
  String? tenantEmail;
  String? tenantAlternativeEmail;
  String? tenantBirthDate;
  String? taxPayerId;
  String? comments;
  bool? enableOverrideFee;

  TenantData({
    this.emergencyContact,
    this.tenantId,
    this.adminId,
    this.tenantFirstName,
    this.tenantLastName,
    this.tenantPhoneNumber,
    this.tenantAlternativeNumber,
    this.tenantEmail,
    this.tenantAlternativeEmail,
    this.tenantBirthDate,
    this.taxPayerId,
    this.comments,
    this.enableOverrideFee,
  });

  factory TenantData.fromJson(Map<String, dynamic> json) {
    return TenantData(
      emergencyContact: json['emergency_contact'] != null
          ? EmergencyContact.fromJson(json['emergency_contact'])
          : null,
      tenantId: json['tenant_id'],
      adminId: json['admin_id'],
      tenantFirstName: json['tenant_firstName'],
      tenantLastName: json['tenant_lastName'],
      tenantPhoneNumber: json['tenant_phoneNumber'],
      tenantAlternativeNumber: json['tenant_alternativeNumber'],
      tenantEmail: json['tenant_email'],
      tenantAlternativeEmail: json['tenant_alternativeEmail'],
      tenantBirthDate: json['tenant_birthDate'],
      taxPayerId: json['taxPayer_id'],
      comments: json['comments'],
      enableOverrideFee: json['enable_override_fee'],
    );
  }
}

class EmergencyContact {
  String? name;
  String? relation;
  String? email;
  String? phoneNumber;

  EmergencyContact({
    this.name,
    this.relation,
    this.email,
    this.phoneNumber,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      relation: json['relation'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class enterCharge extends StatefulWidget {
  final String leaseId;
  String? chargeid;

  enterCharge({required this.leaseId, this.chargeid});

  @override
  State<enterCharge> createState() => _enterChargeState();
}

class _enterChargeState extends State<enterCharge> {
  bool _isLoading = false;
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController Amount = TextEditingController();
  final TextEditingController Memo = TextEditingController();
  late Future<Map<String, List<String>>> futureDropdownData;
  String? validationMessage;
  Map<String, List<String>> categorizedData = {};
  String? selectedAccount;
  bool isLoading = true;
  bool hasError = false;
  List<FocusNode> focusNodes = [];
  List<Map<String, String>> tenants = [];
  String? selectedTenantId;

  @override
  void initState() {
    super.initState();
    fetchTenants();
    fetchDropdownData();
    if (widget.chargeid != null) {
      fetchchargeData();
    }
  }

  Future<void> fetchchargeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    String? sid = prefs.getString("staff_id");
    final response = await http.get(
      Uri.parse('$Api_url/api/charge/charge/${widget.chargeid}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $sid",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];
      print(data);

      Chargedata fetchedCharge = Chargedata.fromJson(data);

      setState(() {
        selectedTenantId = fetchedCharge!.tenantId;
        Amount.text = fetchedCharge.totalAmount.toString();
        _startDate.text =
            formatDate(fetchedCharge.entry!.first!.date.toString());
        Memo.text = fetchedCharge.entry!.first.memo!;
        double total = 0;

        //  Memo.text = fetchedCharge["entry"]![0]["memo"];

        for (var i = 0; i < fetchedCharge.entry!.length; i++) {
          print(fetchedCharge.entry![i].amount);
          rows.add({
            'account': fetchedCharge.entry![i].account,
            'charge_type': fetchedCharge.entry![i].chargeType,
            'amount': fetchedCharge.entry![i].amount,
            'memo': Memo.text,
            'date': _startDate.text,
          });
          total += fetchedCharge.entry![i].amount!;
          totalAmount = total;
          focusNodes.add(FocusNode());
        }
      });
      /*setState(() {
        tenants = fetchedTenants;
      });*/
    } else {
      throw Exception('Failed to load tenants');
    }
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    String? sid = prefs.getString("staff_id");
    final response = await http.get(
      Uri.parse('$Api_url/api/leases/lease_tenant/${widget.leaseId}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $sid",
      },
    );

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

  Future<void> fetchDropdownData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String adminId = prefs.getString('adminId') ?? '';
      String? token = prefs.getString('token');
      String? sid = prefs.getString("staff_id");
      print(token);
      print('lease ${widget.leaseId}');
      String? id = prefs.getString("adminId");
      final response = await http.get(
        Uri.parse('$Api_url/api/accounts/accounts/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $sid",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        Map<String, List<String>> fetchedData = {};
        // Adding static items to the "LIABILITY ACCOUNT" category
        fetchedData["Liability Account"] = [
          "Late Fee Income",
          "Pre-payments",
          "Security Deposit",
          'Rent Income'
        ];

        for (var item in jsonResponse) {
          String chargeType = item['charge_type'];
          String account = item['account'];

          if (!fetchedData.containsKey(chargeType)) {
            fetchedData[chargeType] = [];
          }
          fetchedData[chargeType]!.add(account);
        }

        setState(() {
          categorizedData = fetchedData;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> rows = [];
  double totalAmount = 0.0;
  void addRow() {
    setState(() {
      rows.add({
        'account': null,
        'charge_type': null,
        'amount': 0.0,
        'memo': Memo.text,
        'date': _startDate.text,
      });
      focusNodes.add(FocusNode());
    });
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
    //final String uploadUrl = '${Api_url}/api/images/upload';
    final String uploadUrl = '${image_upload_url}/api/images/upload';

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

  final _formKey = GlobalKey<FormState>();
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
      ],
    );
  }

  final FocusNode _nodeText1 = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawer(
          currentpage: "Rent Roll",
          dropdown: true,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width < 500 ? 16 : 35,
                  right: MediaQuery.of(context).size.width < 500 ? 16 : 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        width: MediaQuery.of(context).size.width * .91,
                        margin: const EdgeInsets.only(bottom: 6.0),
                        //Same as `blurRadius` i guess
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color:blueColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: widget.chargeid != null
                            ? const Text(
                                "Edit Charge",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )
                            : const Text(
                                "Add Charge",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          const Text('Received From *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(
                            height: 8,
                          ),
                        if (MediaQuery.of(context).size.width < 500)
                          DropdownButtonHideUnderline(
                            child: FormField<String>(
                              validator: (value) {
                                if (selectedTenantId == null) {
                                  return 'Please select a tenant';
                                }
                                return null; // No error if valid
                              },
                              builder: (FormFieldState<String> state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: const Text('Select Tenant'),
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
                                          state.didChange(
                                              value); // Notify form field state
                                        });
                                        state.reset();
                                        print(
                                            'Selected tenant_id: $selectedTenantId');
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 50,
                                        width: 200,
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
                                              MaterialStateProperty.all(true),
                                        ),
                                      ),
                                      menuItemStyleData:
                                          const MenuItemStyleData(
                                        height: 40,
                                        padding: EdgeInsets.only(
                                            left: 14, right: 14),
                                      ),
                                    ),
                                    if (state.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          state.errorText!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(
                            height: 20,
                          ),
                        if (MediaQuery.of(context).size.width < 500)
                          const Text('Date',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(
                            height: 8,
                          ),
                        if (MediaQuery.of(context).size.width < 500)
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
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(
                            height: 8,
                          ),
                        if (MediaQuery.of(context).size.width > 500)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // First Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Received From *',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                      SizedBox(height: 8),
                                      tenants.isEmpty
                                          ? const Center(
                                              child: SpinKitFadingCircle(
                                                color: Colors.black,
                                                size: 50.0,
                                              ),
                                            )
                                          : DropdownButtonHideUnderline(
                                              child: FormField<String>(
                                                validator: (value) {
                                                  print(selectedTenantId);
                                                  if (selectedTenantId ==
                                                      null) {
                                                    return 'Please select a tenant sss';
                                                  }
                                                  return ""; // No error if valid
                                                },
                                                builder: (FormFieldState<String>
                                                    state) {
                                                  print(state.hasError);
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      DropdownButton2<String>(
                                                        isExpanded: true,
                                                        hint: const Text(
                                                            'Select Tenant'),
                                                        value: selectedTenantId,
                                                        items: tenants
                                                            .map((tenant) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: tenant[
                                                                'tenant_id'],
                                                            child: Text(tenant[
                                                                'tenant_name']!),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedTenantId =
                                                                value;
                                                            state.didChange(
                                                                value); // Notify form field state
                                                          });
                                                          state.reset();
                                                          print(
                                                              'Selected tenant_id: $selectedTenantId');
                                                        },
                                                        buttonStyleData:
                                                            ButtonStyleData(
                                                          height: 50,
                                                          width: 200,
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
                                                          icon: Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                          ),
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
                                                      ),
                                                      if (state.hasError)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Text(
                                                            state.errorText!,
                                                            style:
                                                                const TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Date',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                      SizedBox(height: 5),
                                      CustomTextField(
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            locale: const Locale('en', 'US'),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data:
                                                    ThemeData.light().copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                    primary: Color.fromRGBO(
                                                        21,
                                                        43,
                                                        83,
                                                        1), // header background color
                                                    onPrimary: Colors
                                                        .white, // header text color
                                                    onSurface: Color.fromRGBO(
                                                        21,
                                                        43,
                                                        83,
                                                        1), // body text color
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor: const Color
                                                          .fromRGBO(21, 43, 83,
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
                                            icon: const Icon(
                                                Icons.date_range_rounded)),
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
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Amount',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 8,
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
                        const SizedBox(height: 8),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Memo',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 8,
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
                      ],
                    ),
                  ),
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
                  Table(
                    border: TableBorder.all(width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                    },
                    children: [
 TableRow(children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Account',
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Amount',
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Actions',
                                style: TextStyle(
                                    color: blueColor,
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                style: TextStyle(fontSize: 14),
                                value: row['account'],
                                items: [
                                  ...categorizedData.entries.expand((entry) {
                                    return [
                                      DropdownMenuItem<String>(
                                        enabled: false,
                                        child: Text(
                                          entry.key,
                                          style:  TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: blueColor,
                                          ),
                                        ),
                                      ),
                                      ...entry.value.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 0.0),
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ];
                                  }).toList(),
                                  // Add an "Other" category if the selected account is not in the list
                                  if (row['account'] != null && !categorizedData.values.expand((v) => v).contains(row['account']))
                                    DropdownMenuItem<String>(
                                      value: row['account'],
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0.0),
                                        child: Text(
                                          row['account']!,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                                onChanged: (value) {
                                  String? chargeType;
                                  // Find the charge type for the selected account
                                  for (var entry in categorizedData.entries) {
                                    if (entry.value.contains(value)) {
                                      chargeType = entry.key;
                                      break;
                                    }
                                  }

                                  // If the value is not in the list, assign it to "Uncategorized" or any custom group
                                  if (chargeType == null && value != null) {
                                    chargeType = 'Uncategorized';
                                    categorizedData.putIfAbsent(chargeType, () => []).add(value);
                                  }

                                  setState(() {
                                    rows[index]['account'] = value;
                                    rows[index]['charge_type'] = chargeType;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: 220,
                                  padding: const EdgeInsets.only(left: 8, right: 5),
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
                                  width: 250,
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
                                hint: const Text('Select an account'),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 50,
                                child: KeyboardActions(
                                  config: _buildConfig(context),
                                  child: TextFormField(
                                    initialValue: widget.chargeid != null
                                        ? rows[index]["amount"].toString()
                                        : "0", // Make sure 0 is a string,
                                    focusNode: focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        updateAmount(index, value),
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter amount',
                                        hintStyle: TextStyle(fontSize: 14),
                                        contentPadding:
                                            EdgeInsets.only(top: 7, left: 7)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteRow(index),
                            ),
                          ),
                        ]);
                      }).toList(),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('\$${totalAmount.toStringAsFixed(2)}'),
                        ),
                        const SizedBox.shrink(),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width < 500
                                  ? 16
                                  : 70,
                              right: MediaQuery.of(context).size.width < 500
                                  ? 16
                                  : 70,
                              top: 10,
                              bottom: 10),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  elevation: 0,
                                  backgroundColor: Colors.white),
                              onPressed: addRow,
                              child: Text(
                                'Add Row',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 16
                                          : 18,
                                  color: blueColor,
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
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: blueColor,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Upload Files',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF152b51))),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 50,
                            width: 95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF152b51),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: _pickPdfFiles,
                              child: const Text('Upload'),
                            ),
                          ),

                          const SizedBox(height: 10),
                          // Flexible(
                          //   fit: FlexFit.loose,
                          //   child: ListView.builder(
                          //     shrinkWrap: true,
                          //     itemCount: _uploadedFileNames.length,
                          //     itemBuilder: (context, index) {
                          //       return ListTile(
                          //         title: Text(_uploadedFileNames[index],
                          //             style: const TextStyle(
                          //                 fontSize: 16,
                          //                 fontWeight: FontWeight.w500,
                          //                 color: Color(0xFF748097))),
                          //         trailing: IconButton(
                          //             onPressed: () {
                          //               setState(() {
                          //                 _uploadedFileNames.removeAt(index);
                          //               });
                          //             },
                          //             icon: const FaIcon(
                          //               FontAwesomeIcons.remove,
                          //               color: Color(0xFF748097),
                          //             )),
                          //       );
                          //     },
                          //   ),
                          // ),
                          if (_uploadedFileNames.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _uploadedFileNames.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      _uploadedFileNames[index],
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
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      // SizedBox(width: 5,),
                      Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? 130
                              : 150,
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
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  print(rows
                                      .where((e) => e["charge_type"] == null));

                                  if (validationMessage == null) {
                                    if (widget.chargeid != null) {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String adminId =
                                          prefs.getString('adminId').toString();

                                      List<Entry> entryList = rows.map((row) {
                                        return Entry(
                                          account: row['account'],
                                          amount: row['amount']?.toInt() ?? 0,
                                          dueAmount:
                                              0, // Adjust according to your requirement
                                          memo: row['memo'],
                                          date: reverseFormatDate(row['date']),
                                          chargeType: row['charge_type'],
                                          isRepeatable:
                                              false, // Adjust according to your requirement
                                        );
                                      }).toList();

                                      print("amount ${Amount.text}");
                                      int totalAmount =
                                          int.tryParse(Amount.text) ?? 0;
                                      Charge charge = Charge(
                                        adminId: adminId,
                                        isLeaseAdded: false,
                                        leaseId: widget.leaseId,
                                        tenantId: selectedTenantId!,
                                        totalAmount: totalAmount,
                                        uploadedFile: _uploadedFileNames,
                                        entry: entryList,
                                      );
                                      print('file ${_uploadedFileNames}');

                                      LeaseRepository apiService =
                                          LeaseRepository();
                                      int statusCode =
                                          await apiService.EditCharge(
                                              charge, widget.chargeid!);

                                      if (statusCode == 200) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        Fluttertoast.showToast(
                                          msg: "Charge Edited successfully",
                                        );
                                        Navigator.pop(context, true);
                                      } else {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        Fluttertoast.showToast(
                                          msg: "Failed to post charge",
                                        );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    } else {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String adminId =
                                          prefs.getString('adminId').toString();

                                      List<Entry> entryList = rows.map((row) {
                                        return Entry(
                                          account: row['account'],
                                          amount: row['amount']?.toInt() ?? 0,
                                          dueAmount:
                                              0, // Adjust according to your requirement
                                          memo: row['memo'],
                                          date: reverseFormatDate(row['date']),
                                          chargeType: row['charge_type'],
                                          isRepeatable:
                                              false, // Adjust according to your requirement
                                        );
                                      }).toList();

                                      int totalAmount =
                                          int.tryParse(Amount.text) ?? 0;
                                      Charge charge = Charge(
                                        adminId: adminId,
                                        isLeaseAdded: false,
                                        leaseId: widget.leaseId,
                                        tenantId: selectedTenantId!,
                                        totalAmount: totalAmount,
                                        uploadedFile: _uploadedFileNames,
                                        entry: entryList,
                                      );
                                      print('file ${_uploadedFileNames}');

                                      LeaseRepository apiService =
                                          LeaseRepository();
                                      int statusCode =
                                          await apiService.postCharge(charge);

                                      if (statusCode == 200) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        Fluttertoast.showToast(
                                          msg: "Charge posted successfully",
                                        );
                                        Navigator.pop(context, true);
                                      } else {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        Fluttertoast.showToast(
                                          msg: "Failed to post charge",
                                        );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  }

                                  //charges
                                } else {
                                  print('invalid');
                                  print(selectedTenantId);
                                  print(rows);
                                  print(totalAmount);
                                  print(_startDate.text);
                                  print(Amount.text);
                                  print(Memo.text);
                                }
                              },
                              child: widget.chargeid != null
                                  ? Text(
                                      'Edit charge',
                                      style: TextStyle(
                                          color: Color(0xFFf7f8f9),
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 16
                                              : 18),
                                    )
                                  : Text(
                                      'Add charge',
                                      style: TextStyle(
                                          color: Color(0xFFf7f8f9),
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 16
                                              : 18),
                                    ))),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                          height: 50,
                          width: 100,
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
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: blueColor),
                              )))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
