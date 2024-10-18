import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/TenantsModule/screen/financial/payment/payment_service.dart';

import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/repository/lease.dart';

import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/drawer_tiles.dart';

import '../../../../model/setting.dart';
import '../../../../repository/setting.dart';
import '../../../../repository/tenants.dart';
import '../AddCard/CardModel.dart';
import 'charge_responce.dart';
import 'fetch_payment_table.dart';
import '../AddCard/AddCard.dart';

class MakePayment extends StatefulWidget {
  final String leaseId;
  final String tenantId;

  const MakePayment({required this.leaseId, required this.tenantId});

  @override
  State<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
  late Future<List<ChargeResponses>> futurectablecharge;
  bool _isLoading = false;
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController Memo = TextEditingController();
  late Future<Map<String, List<String>>> futureDropdownData;
  List<Map<String, dynamic>> charges = [];
  String? validationMessage;
  Map<String, List<String>> categorizedData = {};
  String? selectedAccount;
  bool isLoading = true;
  bool IsLoading = false;
  bool isloading = false;
  bool isLoadingamount = false;
  bool hasError = false;
  double chargeAmount = 0.0;
  double surchargeIncluded = 0.0;
  double totalAmount = 0.0;
  int? selectedcardindex;
  bool? futuredate;
  Setting1? surcharges;
  double? surchargecount = 0.0;
  double? finaltotal;
  String override_fee = "";
  Future<void> fetchSurchargeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Setting1 surcharg = await SurchargeRepository(baseUrl: '${Api_url}')
          .fetchSurchargeData('$id');

      if (surcharg != null) {
        setState(() {
          surcharges = surcharg;
        });
      }
    } catch (e) {
      print('Failed to load surcharge data: $e');
    }
  }

  Future<void> checkTokenTenant() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${Api_url}/api/tenant/token_check'),
      headers: {
        // "authorization": "CRM $token",
        //"id":"CRM $id",
        "Content-Type": "application/json"
      },
      body: json.encode({"token": token}),
    );
    //  print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData['id'] != "") {
      //print(jsonData);
      setState(() {
        // print("object ${jsonData['override_fee']}");
        override_fee = jsonData['override_fee'].toString();
      });
      //prefs.setString('checkedToken',jsonData["token"]);
      // String? adminId = jsonData['data']['admin_id'];
      // print('Admin ID: $adminId');
    } else {
      print('Failed to check token');
    }
  }

  String companyName = '';
  Future<void> fetchCompany() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");

    if (adminId != null) {
      try {
        String fetchedCompanyName =
            await TenantsRepository().fetchCompanyName(adminId);
        setState(() {
          companyName = fetchedCompanyName;
        });
      } catch (e) {
        print('Failed to fetch company name: $e');
        // Handle error state, e.g., show error message to user
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkTokenTenant();
    fetchTenants();
    // fetchCompany();
    fetchDropdownData();

    //  fetchSurcharge();
    //totalAmount = chargeAmount + surchargeIncluded;
    // amountController.addListener(_updateTotalAmount);
  }

  void _updateTotalAmount() {
    setState(() {
      totalAmount = chargeAmount + surchargeIncluded;
    });
  }

  List<Map<String, String>> tenants = [];
  String? selectedTenantId;
  List<TextEditingController> controllers = [];
  List<BillingData> cardDetails = [];

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    final response = await http.get(
      Uri.parse('$Api_url/api/leases/get_leases/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    // print('$Api_url/api/leases/get_leases/${widget.tenantId}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final List<Map<String, String>> fetchedTenants = [];

      for (var tenant in data['data']['leases']) {
        fetchedTenants.add({
          'tenant_id': tenant['lease_id'],
          'tenant_name': '${tenant['rental_adress']}',
          'status': '${tenant['status']}',
          /*  'first_name': '${tenant['tenant_firstName']}',
          'last_name': '${tenant['tenant_lastName']}',
          'email': '${tenant['tenant_email']}'*/
        });
      }
      setState(() {
        tenants = fetchedTenants;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load tenants');
    }
  }

  Future<void> fetchDropdownData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //    SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? admin_id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      // print(token);
      //   print('lease ${widget.leaseId}');
      //   String? id = prefs.getString("adminId");
      final response = await http.get(
        Uri.parse('$Api_url/api/accounts/accounts/$admin_id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        Map<String, List<String>> fetchedData = {};
        // Adding static items to the "LIABILITY ACCOUNT" category
        fetchedData["Liability Account"] = [
          "Rent Income",
          "Pre-payments",
          "Security Deposit",
          "Rent Late Fee"
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

  List<double> charges_balances = [0];

  //Security Deposite
  // void addRow() {
  //   setState(() {
  //     rows.add({
  //       'account': null,
  //       'charge_type': null,
  //       'amount': Amount.text,
  //       'memo': Memo.text,
  //       'charge_amount':0.0,
  //       'date': _startDate.text,
  //     });
  //     controllers.add(TextEditingController(text: '0.0'));
  //   });
  // }
  //
  // void deleteRow(int index) {
  //   setState(() {
  //     totalAmount -= rows[index][Amount.text];
  //     controllers.removeAt(index);
  //     rows.removeAt(index);
  //   });
  //   validateAmounts();
  // }
  //
  // void updateAmount(int index, String value) {
  //   setState(() {
  //     double amount = double.tryParse(value) ?? 0.0;
  //     totalAmount -= rows[index][Amount.text];
  //     rows[index][Amount.text] = amount;
  //     totalAmount += amount;
  //     // rows[index]['amount'] = double.tryParse(value) ?? 0.0;
  //     // totalAmount = rows.fold(0.0, (sum, row) => sum + (row['amount'] ?? 0));
  //
  //   });
  //   validateAmounts();
  // }

  void validateAmounts() {
    double enteredAmount = double.tryParse(amountController.text) ?? 0.0;

    /* setState(() {
      totalAmount = enteredAmount;
    });*/
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
    //  print(totalAmount);
    surge_count();
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
    //print(pdfFile.path);
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

  final _formKey = GlobalKey<FormState>();

  //for payment

  String? _selectedPaymentMethod;

  String? _selectedHoldertype;
  double? surchage_percent;
  final List<String> _paymentMethods = [
    'Card',
    'Check',
    'Cash',
    'ACH',
    'Cashier \'s Check',
    'Money Order',
    'Manual'
  ];
  final List<String> _selecttype = ['Checking', 'Savings'];
  final List<String> _selectholder = ['Business', 'Personal'];
  bool showCardNumberField = false;
  bool showCheckNumberField = false;
  bool showACHFields = false;
  bool showCashiersFields = false;
  bool showMoneyorderFields = false;
  bool showMenualFields = false;
  int? customervaultid;
  TextEditingController reference = TextEditingController();

  void AddFields() {
    setState(() {
      showCardNumberField = _selectedPaymentMethod == 'Card';
      showCheckNumberField = _selectedPaymentMethod == 'Check';
      showACHFields = _selectedPaymentMethod == 'ACH';
      showCashiersFields = _selectedPaymentMethod == 'Cashier \'s Check';
      showMoneyorderFields = _selectedPaymentMethod == 'Money Order';
      showMenualFields = _selectedPaymentMethod == 'Manual';
    });
  }

  Map<String, dynamic>? lease_data;
  TextEditingController checknumber = TextEditingController();
  TextEditingController bankrountingnum = TextEditingController();
  TextEditingController accountnum = TextEditingController();
  TextEditingController achname = TextEditingController();
  Map<String, List<Map<String, dynamic>>> groupedCharges = {};

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

  double totalamount = 0.0;
  double surchargeamount = 0.0;
  double totalpayamount = 0.0;
//for payment
  Future<void> fetchChargesForSelectedTenant(String tenantId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      List<Entrycharge>? charges = await ChargeRepositorys()
          .fetchChargesTable(tenantId, widget.tenantId);
      List<Entrycharge> filteredCharges =
          charges?.where((entry) => entry.chargeAmount! > 0).toList() ?? [];

      // print('leaseid ${widget.leaseId}');
      // print('tenantid $tenantId');
      // print(charges!.length);
      // print("aaaa ${filteredCharges.length}");

      setState(() {
        rows = charges?.where((entry) => entry.chargeAmount! > 0).map((entry) {
              return {
                'entry_id': entry.entryId,
                'account': entry.account,
                'amount': 0.0,
                'charge_amount': entry.chargeAmount,
                'memo': entry.memo,
                'date': entry.date,
                'charge_type': entry.chargeType,
                'newfield': false,
              };
            }).toList() ??
            [];
        //     print(rows.length);
        //       print(filteredCharges.length);
        for (var i = 0; i < filteredCharges.length; i++) {
          print("calling");
          if (i == 0) {
            charges_balances[0] = filteredCharges[i].chargeAmount!;
          } else {
            charges_balances.add(filteredCharges[i].chargeAmount!);
          }
        }
        //   print("charges ${charges_balances}");
        // print(rows.length);
        /*  print(rows.first['account']);
        print(rows.first['charge_amount']);
        print(rows.first['charge_amount']);*/
        controllers = rows.map((row) {
          return TextEditingController(text: "".toString());
        }).toList();
        //    print(rows);
        totalAmount = rows.fold(
            0.0, (sum, row) => sum + (row[amountController.text] ?? 0));
        isLoading = false;
        //   print(controllers.length);
      });
    } catch (e) {
      print(e);
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchTotal_due_amountTenant(String leaseid) async {
    setState(() {
      isLoadingamount = true;
      hasError = false;
    });
    try {
      Map<String, dynamic>? charges = await ChargeRepositorys()
          .fetchtenant_due_amount(leaseid, widget.tenantId);
      setState(() {
        lease_data = charges;
        if (selected_account == "Full") {
          totalamount =
              double.parse(lease_data!["total_due_amount"].toString());
          totalpayamount =
              double.parse(lease_data!["total_due_amount"].toString());
          if (surCharge != null) {
            surchargeamount = totalamount * surCharge! / 100;
            totalpayamount = totalamount + surchargeamount;
          }
        } else {
          totalamount = 0.0;
          totalpayamount = 0.0;
          surchargeamount = 0.0;
        }

        isLoadingamount = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        hasError = true;
        isLoadingamount = false;
      });
    }
  }

  void addRow() {
    setState(() {
      rows.add({
        'account': null,
        'charge_type': null,
        'amount': 0.0,
        'memo': Memo.text,
        'charge_amount': 0.0,
        'date': _startDate.text,
        'newfield': true
      });

      charges_balances.add(0);
      controllers.add(TextEditingController());
    });
  }

  void deleteRow(int index) {
    setState(() {
      totalAmount -= rows[index]['amount'];
      charges_balances.removeAt(index);
      rows.removeAt(index);
    });
    validateAmounts();
  }

  // void updateAmount(int index, String value) {
  //   setState(() {
  //     double amount = double.tryParse(value) ?? 0.0;
  //     totalAmount -= rows[index]['amount'];
  //     rows[index]['amount'] = amount;
  //     totalAmount += amount;
  //   });
  //   validateAmounts();
  // }

  double initialBalance = 0.0;

  void updateAmount(int index, String value) {
    //print("object calling");
    setState(() {
      //print(value);
      if (value == "") {
        charges_balances[index] = rows[index]["charge_amount"];
        // totalAmount > rows[index]["charge_amount"] ? totalAmount - rows[index]["charge_amount"]: totalAmount;
      } else {
        if (rows[index]["newfield"] == true) {
          double amount = double.tryParse(value) ?? 0.0;
          double charge = rows[index]["charge_amount"];
          // print(charge);
          // print(amount);
          rows[index]['amount'] = amount;
          charges_balances[index] = (charge.toDouble() + amount).toDouble();
          totalAmount += amount;

          totalAmount = 0.0;

          for (var i = 0; i < rows.length; i++) {
            //     print(rows[i]["amount"]);
            if (rows[i]["amount"] != 0.0)
              totalAmount = totalAmount + rows[i]["amount"];
          }
        } else {
          double amount = double.tryParse(value) ?? 0.0;
          double charge = rows[index]["charge_amount"];
          // print(charge);
          // print(amount);
          rows[index]['amount'] = amount;
          charges_balances[index] = (charge.toDouble() - amount).toDouble();
          totalAmount += amount;

          totalAmount = 0.0;

          for (var i = 0; i < rows.length; i++) {
            // print(rows[i]["amount"]);
            if (rows[i]["amount"] != 0.0)
              totalAmount = totalAmount + rows[i]["amount"];
          }
        }

        // print(totalAmount);
        // totalAmount = rows.fold(0.0, (sum, row) => sum + (row['amount'] ?? 0.0));
      }

      //print(totalAmount);
    });
    //counttotal();
    validateAmounts();
  }

  Future<void> fetchcreditcard(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    setState(() {
      isLoading = true;
      isloading = true;
      cardDetails = []; // Clear previous card details
    });

    final response = await http.get(
      Uri.parse('$Api_url/api/creditcard/getCreditCards/$tenantId'),
      headers: {"id": "CRM $id", "authorization": "CRM $token"},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      customervaultid = jsonResponse['customer_vault_id'];
      List<dynamic> cardDetailsList = jsonResponse['card_detail'];

      // Debug print to check the response structure
      // print('JSON Response: $jsonResponse');

      for (var cardDetail in cardDetailsList) {
        // Debug print to check each card detail
        //    print('Card Detail: $cardDetail');

        //  BillingData billingData = BillingData.fromJson(cardDetail);
        // print('Parsed Billing ID: ${billingData.billingId}');

        // Assuming this is part of the logic to print billing_id
        //    print('Billing ID: ${cardDetail['billing_id']}');
      }

      CustomerData? customerData =
          await postBillingCustomerVault(customervaultid.toString());

      if (customerData != null) {
        setState(() {
          cardDetails = customerData.billing;
        });
      }
    } else if (response.statusCode == 404) {
      print('customer_vault_id not found');
    } else {
      throw Exception('Failed to load credit card data');
    }

    setState(() {
      isLoading = false;
      isloading = false;
    });
  }

  Future<String> binCheck(String ccBin) async {
    final String apiUrl = 'https://bin-ip-checker.p.rapidapi.com/?bin=$ccBin';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': '1bd772d3c3msh11c1022dee1c2aep1557bajsn0ac41ea04ef7',
        'X-RapidAPI-Host': 'bin-ip-checker.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('BIN check successful: ${jsonResponse['BIN']['type']}');
      return jsonResponse['BIN']['type'];
    } else {
      print('Failed to check BIN: ${response.statusCode}');
      return '';
    }
  }

  Future<CustomerData?> postBillingCustomerVault(String customerVaultId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": adminId.toString(),
    };

    final response = await http.post(
      Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
      headers: {
        'Content-Type': 'application/json',
        "id": "CRM $id",
        "authorization": "CRM $token",
      },
      body: json.encode(requestBody),
    );
    //  print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      //  print(jsonResponse);
      var customerJson = jsonResponse['data']['customer'];
      if (customerJson == null) {
        print('Failed to post data: ${response.statusCode}');
        return null;
      }
      CustomerData customerData = CustomerData.fromJson(customerJson);

      customerData.billing.forEach((billing) {
        print('CC Bin: ${billing.ccBin}');
      });

      List<String> binResults = await performBinChecks(customerData);

      for (int i = 0; i < customerData.billing.length; i++) {
        customerData.billing[i].binResult = binResults[i];
      }

      //  print('Number of BIN check results: ${binResults.length}');
      binResults.forEach((result) {
        print('BIN Check Result: $result');
      });

      return customerData;
    } else {
      print('Failed to post data: ${response.statusCode}');
      return null;
    }
  }

  static const int numItems = 20;
  List<bool> selected = List<bool>.generate(numItems, (int index) => false);

  Future<List<String>> performBinChecks(CustomerData customerData) async {
    List<String> binResults = [];
    for (BillingData billing in customerData.billing) {
      String binResult = await binCheck(billing.ccBin ?? '');
      binResults.add(binResult);
    }
    return binResults;
  }

  String? selected_account = "Full";
  Map<int, bool> selectedRows = {};
  int? surCharge;

  dynamic? surChargeAchper;
  dynamic? surChargeAchflat;
  bool partialamount = false;
  Future<void> fetchSurcharge() async {
    print("calling");
    //  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId') ?? '';
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    //  print(adminId);

    final response = await http.get(
      Uri.parse('$Api_url/api/surcharge/surcharge/getadmin/$adminId'),
      headers: {
        "id": "CRM $id",
        "authorization": "CRM $token",
      },
    );

    if (response.statusCode == 200) {
      //  print('Response: ${response.body}');
      var jsonResponse = jsonDecode(response.body);

      // Accessing the first element in the 'data' list
      var surchargeData = jsonResponse['data'][0];
      //  if (_selectedPaymentMethod == "Card") {
      if (cardDetails[selectedcardindex!].binResult == "CREDIT") {
        setState(() {
          surCharge = surchargeData['surcharge_percent'];
          if (totalamount > 0.0) {
            surchargeamount = totalamount * surCharge! / 100;
            totalpayamount = totalamount + surchargeamount;
          }
          print(totalamount);
        });
      } else {
        setState(() {
          if (override_fee == null ||
              override_fee == "null" ||
              override_fee.isEmpty) {
            surCharge = surchargeData['surcharge_percent_debit'] ?? 0;
            if (totalamount > 0.0) {
              surchargeamount = totalamount * surCharge! / 100;
              totalpayamount = totalamount + surchargeamount;
            }
            print(totalamount);
          } else {
            surCharge = int.parse(override_fee) ?? 0;
          }
        });
      }
      //  }

      setState(() {
        surChargeAchper = surchargeData['surcharge_percent_ACH'];
        surChargeAchflat = surchargeData['surcharge_flat_ACH'];
      });

      // print(surChargeAchper);
      // print(surChargeAchflat);
    } else {
      print('Failed to fetch the surcharge: ${response}');
      var jsonResponse = jsonDecode(response.body);
      String message = jsonResponse['message'];
      throw Exception('Failed to fetch the surcharge $message');
    }
    /* } catch (e) {
      print('Error: $e');
    }*/
  }

  String? _errorText;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  bool iserror = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: widget_302.App_Bar(
          context: context,
          onDrawerIconPressed: () {
            key.currentState!.openDrawer();
          },
        ),
        backgroundColor: Colors.white,
        drawer: CustomDrawer(
          currentpage: 'Financial',
        ),
        body:

        SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                /*  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(3)),
                    child: Center(
                      child: Text(
                        "Payment Card Details",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),*/
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(115, 119, 145, 1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(6)),
                    padding: EdgeInsets.only(left:18,top: 8,right: 8,bottom:8),
                    child:
                    FormField<String>(validator: (value) {
                      if (selectedcardindex == null) {
                        return 'Please select a card';
                      }
                      return null;
                    }, builder: (FormFieldState<String> state) {
                      return  Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Leases*",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: blueColor),
                          ),
                          SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: FormField<String>(
                              validator: (value) {
                                if (selectedTenantId == null) {
                                  return 'Please select a lease';
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> state) {
                                return Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: const Text('Select Lease'),
                                        value: selectedTenantId,
                                        items: tenants.map((tenant) {
                                          return DropdownMenuItem<String>(
                                            value: tenant['tenant_id'],
                                            child: Text(
                                                "${tenant['tenant_name']!} (${tenant['status']})"),
                                          );
                                        }).toList(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                            blueColor.withOpacity(.8)),
                                        onChanged: (value) async {
                                          setState(() {
                                            selectedTenantId = value;
                                            fetchTotal_due_amountTenant(
                                                value!);
                                            fetchChargesForSelectedTenant(
                                                value!);
                                            state.didChange(
                                                value); // Notify FormField of change
                                          });
                                          fetchcreditcard(widget.tenantId);
                                          state.reset();
                                          //   print('Selected tenant_id: $selectedTenantId');
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 50,
                                          width: 250,
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 14),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(6),
                                            border: Border.all(
                                                color: blueColor
                                                    .withOpacity(.6)),
                                            color: Colors.white,
                                          ),
                                          elevation: 0,
                                        ),
                                        iconStyleData: const IconStyleData(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          iconSize: 24,
                                          iconEnabledColor:
                                          Color(0xFFb0b6c3),
                                          iconDisabledColor: Colors.grey,
                                        ),
                                        dropdownStyleData:
                                        DropdownStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(6),
                                            color: Colors.white,
                                          ),
                                          scrollbarTheme:
                                          ScrollbarThemeData(
                                            radius:
                                            const Radius.circular(6),
                                            thickness:
                                            MaterialStateProperty.all(
                                                6),
                                            thumbVisibility:
                                            MaterialStateProperty.all(
                                                true),
                                          ),
                                        ),
                                        menuItemStyleData:
                                        const MenuItemStyleData(
                                          height: 45,
                                          padding: EdgeInsets.only(
                                              left: 14, right: 14),
                                        ),
                                      ),
                                    ),
                                    if (state.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, left: 5),
                                        child: Container(
                                          height: 15,
                                          child: Text(
                                            state.errorText ?? '',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            "Payment Card Details",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: blueColor),
                          ),
                          SizedBox(height: 10,),
                          cardDetails == null
                              ? Container()
                              :
                          Padding(
                            padding: EdgeInsets.only(left: 0, right: 10),
                            child: isloading
                                ? Container(
                              height:
                              MediaQuery.of(context).size.width *
                                  .2,
                              child:
                              Center(
                                child:
                                SpinKitFadingCircle(
                                  color: blueColor,
                                  size: 45.0,
                                ),
                              ),
                            )
                                :
                            cardDetails.isEmpty && selectedTenantId == null
                                ? Container(
                              height: 50,
                              child: Center(
                                  child: Text(
                                    'No Card Found. If you have not selected any lease, please select it first.',
                                    style: TextStyle(fontSize: 15,color: grey),

                                  )),
                            )
                                :
                            cardDetails.isEmpty
                                ? Container(
                              height: MediaQuery.of(context)
                                  .size
                                  .width *
                                  .2,
                              child: Center(
                                  child: Text(
                                    'No Cards Available',
                                    style: TextStyle(fontSize: 15),
                                  )),
                            )
                                :

                            Table(
                              columnWidths: {
                                0: FlexColumnWidth(.5), // Date
                                1: FlexColumnWidth(
                                    1.3), // Address
                                2: FlexColumnWidth(1), // Work
                                3: FlexColumnWidth(
                                    .5), // Performed
                                // Performed
                              },
                              defaultVerticalAlignment:
                              TableCellVerticalAlignment
                                  .middle,
                              children: [
                                ...cardDetails
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  BillingData item = entry.value;
                                  String month =
                                  item.ccExp!.substring(0, 2);
                                  String year =
                                  item.ccExp!.substring(2, 4);
                                  String currentMonth =
                                  DateTime.now()
                                      .month
                                      .toString()
                                      .padLeft(2, '0');
                                  String currentYear =
                                  DateTime.now()
                                      .year
                                      .toString()
                                      .substring(2);
                                  String currentMonthYear =
                                      currentMonth + currentYear;
                                  String expMonthYear =
                                  item.ccExp!;
                                  String expMonth = expMonthYear
                                      .substring(0, 2);
                                  String expYear = expMonthYear
                                      .substring(2, 4);
                                  bool isExpired = int.parse(
                                      expYear) <
                                      int.parse(
                                          currentYear) ||
                                      (int.parse(expYear) ==
                                          int.parse(
                                              currentYear) &&
                                          int.parse(expMonth) <
                                              int.parse(
                                                  currentMonth));

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(240, 243, 248, 1),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            8.0),

                                        child: Column(
                                          children: [
                                            isExpired == true
                                                ? Text(
                                              'Expired',
                                              style: TextStyle(
                                                  color: Colors
                                                      .red),
                                            )
                                                : Checkbox(
                                              activeColor:
                                              blueColor,
                                              // Color of your check mark
                                              checkColor:
                                              Colors
                                                  .white,
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(2),
                                              ),
                                              side:
                                              BorderSide(
                                                // ======> CHANGE THE BORDER COLOR HERE <======
                                                color:
                                                blueColor,
                                                // Give your checkbox border a custom width
                                                width: 1.5,
                                              ),
                                              value: selectedcardindex ==
                                                  index
                                                  ? true
                                                  : false,
                                              onChanged: (bool?
                                              value) async {
                                                setState(
                                                        () {
                                                      selectedcardindex =
                                                          index;
                                                    });
                                                await fetchSurcharge();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            "Card Number",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                          Text(
                                            item.ccNumber!,
                                            style: TextStyle(
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            "Card Type",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                          Text(
                                            '${item.binResult}',
                                            style: TextStyle(
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          _buildLogosBlocktablet(
                                              item.ccType!),
                                        ],
                                      ),
                                    ],
                                  );
                                }).expand((row) {
                              // Add space between rows
                              return [
                                row,
                                TableRow(
                                  children: [
                                    SizedBox(height: 8), // Add spacing between rows
                                    SizedBox(height: 8),
                                    SizedBox(height: 8),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ];
                            }).toList(),
                              ],
                            ),
                          ),
                         /* const SizedBox(
                            height: 10,
                          ),*/
                          Padding(
                            padding: const EdgeInsets.only(top: 5,left: 16,right: 16,bottom: 10),
                            child: Row(
                              children: [
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5),
                                    child: Text(
                                      state.errorText ?? '',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddCard()));
                            },
                            child: Container(
                              height: 45,
                              width: 140,
                              margin: EdgeInsets.only(left: 0, bottom: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: blueColor),
                              child: Center(
                                  child: Text(
                                    "Add New Card",
                                    style:
                                    TextStyle(fontSize: 14, color: Colors.white),
                                  )),
                            ),
                          )
                        ],
                      );
                    }),

                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(115, 119, 145, 1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(6)),
                    padding: EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      /*  Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Lease* : ",
                                  style: TextStyle(
                                      color: blueColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                if(iserror && selectedTenantId == null)
                                Text("")

                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: FormField<String>(
                                  validator: (value) {
                                    if (selectedTenantId == null) {
                                      return 'Please select a lease';
                                    }
                                    return null;
                                  },
                                  builder: (FormFieldState<String> state) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: const Text('Select Lease'),
                                            value: selectedTenantId,
                                            items: tenants.map((tenant) {
                                              return DropdownMenuItem<String>(
                                                value: tenant['tenant_id'],
                                                child: Text(
                                                    "${tenant['tenant_name']!} (${tenant['status']})"),
                                              );
                                            }).toList(),
                                            style: TextStyle(
                                                color:
                                                    blueColor.withOpacity(.8)),
                                            onChanged: (value) async {
                                              setState(() {
                                                selectedTenantId = value;
                                                fetchTotal_due_amountTenant(
                                                    value!);
                                                fetchChargesForSelectedTenant(
                                                    value!);
                                                state.didChange(
                                                    value); // Notify FormField of change
                                              });
                                              state.reset();
                                              //   print('Selected tenant_id: $selectedTenantId');
                                            },
                                            buttonStyleData: ButtonStyleData(
                                              height: 40,
                                              width: 250,
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 14),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: blueColor
                                                        .withOpacity(.6)),
                                                color: Colors.white,
                                              ),
                                              elevation: 0,
                                            ),
                                            iconStyleData: const IconStyleData(
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                              iconSize: 24,
                                              iconEnabledColor:
                                                  Color(0xFFb0b6c3),
                                              iconDisabledColor: Colors.grey,
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.white,
                                              ),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                radius:
                                                    const Radius.circular(6),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                        6),
                                                thumbVisibility:
                                                    MaterialStateProperty.all(
                                                        true),
                                              ),
                                            ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                              height: 45,
                                              padding: EdgeInsets.only(
                                                  left: 14, right: 14),
                                            ),
                                          ),
                                        ),
                                        if (state.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, left: 5),
                                            child: Container(
                                              height: 15,
                                              child: Text(
                                                state.errorText ?? '',
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),*/
                        if (isLoadingamount == false) ...[
                          Row(
                            children: [
                              Text(
                                'Current Balance : ',
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${lease_data != null ? lease_data!["total_due_amount"] : 0.0}',
                                style: TextStyle(
                                    color: Color.fromRGBO(115, 119, 145, 1),
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                'Choose Payment Amount : ',
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 30,
                                //  color: blueColor.withOpacity(.6),
                                child: Radio(
                                  value: "Full",
                                  activeColor: blueColor,
                                  groupValue: selected_account,
                                  fillColor: MaterialStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return blueColor;
                                      }
                                      return blueColor;
                                    },
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selected_account = "Full";
                                      partialamount = false;
                                      if(lease_data != null){
                                        totalamount =
                                       double.parse( lease_data!["total_due_amount"].toString());
                                        // totalAmount = double.tryParse(lease_data?["total_due_amount"]) ?? 0.0;

                                        if(surCharge != null){
                                          surchargeamount = totalamount * surCharge!/100;
                                        }
                                        totalpayamount = totalamount + surchargeamount;

                                      }

                                      //_site = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                'Pay Full Amount',
                                style:
                                    TextStyle(color: blueColor, fontSize: 16),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                height: 30,
                                //   color: blueColor.withOpacity(.6),
                                child: Radio(
                                  value: "Partial",
                                  activeColor: blueColor,
                                  fillColor: MaterialStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return blueColor;
                                      }
                                      return blueColor;
                                    },
                                  ),
                                  groupValue: selected_account,
                                  onChanged: (value) {
                                    setState(() {
                                      selected_account = "Partial";
                                      if(amountController.text.isNotEmpty){
                                        totalamount =double.parse(amountController.text);

                                        if(surCharge != null){
                                          surchargeamount = totalamount * surCharge!/100;
                                        }else{
                                          surchargeamount = 0.0;
                                        }
                                        totalpayamount = totalamount + surchargeamount;
                                        partialamount = true;
                                      }
                                      else {
                                        totalamount = 0.0;
                                        totalpayamount = 0.0;
                                        surchargeamount = 0.0;
                                        partialamount = true;
                                      }

                                      //_site = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                'Pay Partial Amount ',
                                style:
                                    TextStyle(color: blueColor, fontSize: 16),
                              )
                            ],
                          ),
                          if (partialamount) ...[
                            SizedBox(
                              height: 15,
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
                              controller: amountController,
                              onChanged: (value) {
                                setState(() {
                                  // Check if the value is not empty before processing
                                  if (value.isNotEmpty && lease_data != null) {
                                    double inputAmount =
                                        double.tryParse(value) ?? 0.0;

                                    // Validate if the input amount exceeds the total amount
                                    if (inputAmount >
                                        lease_data!["total_due_amount"]) {
                                      amountController.text =
                                          lease_data!["total_due_amount"]
                                              .toString();
                                      inputAmount =
                                          double.parse(amountController.text);
                                      /* amountController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: amountController.text.length), // Move cursor to the end
                                );*/
                                      // Optionally show an error message or handle accordingly
                                      // return;
                                    }

                                    // Update amounts and calculate surcharge
                                    totalamount = inputAmount;
                                    totalpayamount = inputAmount;

                                    if (surCharge != null) {
                                      surchargeamount =
                                          totalamount * surCharge! / 100;
                                      totalpayamount += surchargeamount;
                                    }
                                  } else {
                                    if (lease_data == null)
                                      amountController.text = "0";
                                    // Reset amounts when the input is empty
                                    totalamount = 0.0;
                                    totalpayamount = 0.0;
                                    surchargeamount = 0.0;
                                  }
                                });
                              },
                            ),
                          ],
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                'Payment  : ',
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${totalamount}',
                                style: TextStyle(
                                    color: Color.fromRGBO(115, 119, 145, 1),
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                'Surcharge : ',
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${surchargeamount}',
                                style: TextStyle(
                                    color: Color.fromRGBO(115, 119, 145, 1),
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                'Amount to Pay : ',
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${totalpayamount}',
                                style: TextStyle(
                                    color: Color.fromRGBO(115, 119, 145, 1),
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if ((_formKey.currentState?.validate() ??
                                  false)) {
                                if(totalpayamount > 0.0){
                                  print("valid");
                                  setState(() {
                                    iserror = false;
                                    IsLoading = true;
                                  });

                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  String? id = prefs.getString('adminId');
                                  String? first_name =
                                  prefs.getString("first_name");
                                  String? last_name =
                                  prefs.getString("last_name");
                                  String? email = prefs.getString("email");
                                  List<Map<String, String>> filteredTenants =
                                  tenants.where((tenant) {
                                    return tenant['tenant_id'] ==
                                        selectedTenantId;
                                  }).toList();
                                  Map<String, String> selectedTenant =
                                      filteredTenants.first;
                                  await PaymentService()
                                      .makePaymentforcard(
                                      adminId: id ?? "",
                                      firstName: first_name!,
                                      lastName: last_name!,
                                      emailName: email!,
                                      customerVaultId:
                                      cardDetails[selectedcardindex!]
                                          .customerVaultId!,
                                      billingId:
                                      cardDetails[selectedcardindex!]
                                          .billingId!,
                                      surcharge: "${surchargeamount}",
                                      amount: "${totalamount}",
                                      tenantId: widget.tenantId,
                                      date: _startDate.text,
                                      address1:
                                      cardDetails[selectedcardindex!]
                                          .address_1!,
                                      processorId: "",
                                      leaseid: selectedTenantId!,
                                      company_name: companyName,
                                      future_Date: false)
                                      .then((value) {
                                    Fluttertoast.showToast(msg: "$value");
                                    setState(() {
                                      IsLoading = false;
                                    });
                                    Navigator.pop(context, true);
                                  }).catchError((e) {
                                    setState(() {
                                      IsLoading = false;
                                    });
                                    //  print(e.toString().split("Exception")[1].toString().trimLeft());
                                    setState(() {
                                      IsLoading = false;
                                    });
                                    Alert(
                                      context: context,
                                      type: AlertType.warning,
                                      title: "Payment Failed!",
                                      desc:
                                      "${e.toString().split('Exception:')[1].toString().trimLeft()}",
                                      style: AlertStyle(
                                        backgroundColor: Colors.white,
                                        //  overlayColor: Colors.black.withOpacity(.8)
                                      ),
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "Ok",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          color: blueColor,
                                        ),
                                      ],
                                    ).show();

                                    Fluttertoast.showToast(
                                        msg: "Payment failed $e");
                                  });
                                }

                              }else{
                                setState(() {
                                  iserror = true;
                                   isLoading = false;
                                });
                              }
                            },
                            child: Container(
                              height: 45,
                              width: 130,
                              margin: EdgeInsets.only(left: 0, bottom: 0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: blueColor),
                              child:
                              IsLoading
                                  ? Center(
                                child: SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 42.0,
                                ),
                              )
                                  : Center(
                                  child: Text(
                                "Make Payment",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              )),
                            ),
                          )
                        ],
                        if (isLoadingamount)
                          Center(
                            child:
                            SpinKitFadingCircle(
                              color: Colors.black,
                              size: 45.0,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget buildAmountContainer(String label, double amount) {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          color: blueColor,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: blueColor,
              ),
            ),
            Text(
              '\$$amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(21, 43, 83, 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  surge_count() {
    try {
      if (_selectedPaymentMethod == "ACH" &&
          (surChargeAchper != null || surChargeAchper != 0.0) &&
          _selectedPaymentMethod == "ACH" &&
          (surChargeAchflat != null || surChargeAchflat != 0.0)) {
        setState(() {
          surchargecount =
              (double.parse(amountController.text) * surChargeAchper / 100) +
                  surChargeAchflat;
          finaltotal = double.parse(amountController.text) + surchargecount!;
        });
      } else if (_selectedPaymentMethod == "ACH" &&
          (surChargeAchflat != null || surChargeAchflat != 0.0)) {
        setState(() {
          surchargecount = double.parse(surChargeAchflat.toString());
          finaltotal = double.parse(amountController.text) + surchargecount!;
          // surchargecount = double.parse(amountController.text) * surChargeAchper /100;
        });
      } else if (_selectedPaymentMethod == "ACH" &&
          (surChargeAchper != null || surChargeAchper != 0.0)) {
        setState(() {
          surchargecount =
              (double.parse(amountController.text) * surChargeAchper / 100);
          finaltotal = double.parse(amountController.text) + surchargecount!;
        });
      }
    } catch (e) {
      setState(() {
        surchargecount = 0;
        finaltotal = 0;
      });
    }
  }

  Widget buildTextField(
    String label,
    String hintText,
    TextEditingController controller,
  ) {
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

  Widget _buildLogosBlock(String ccType) {
    String logoUrl =
        'https://logo.clearbit.com/${ccType.replaceAll(RegExp(r'[-\s]'), "").toLowerCase()}.com';
    return Image.network(
      logoUrl,
      height: 40,
      width: 40,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.credit_card,
          color: Colors.white,
          size: 30,
        );
      },
    );
  }

  Widget _buildLogosBlocktablet(String ccType) {
    String logoUrl =
        'https://logo.clearbit.com/${ccType.replaceAll(RegExp(r'[-\s]'), "").toLowerCase()}.com';
    return Image.network(
      logoUrl,
      height: 30,
      width: 30,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.credit_card,
          color: Colors.white,
          size: 30,
        );
      },
    );
  }
}
