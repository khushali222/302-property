import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/repository/lease.dart';

import '../../../../Model/LeaseLedgerModel.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

import '../../../model/EnterChargeModel.dart';
import '../../../../model/payments/fetch_payment_table.dart';
import '../../../../model/setting.dart';
import '../../../../provider/Plan Purchase/plancheckProvider.dart';
import '../../../repository/payment/charge_responce.dart';
import '../../../repository/payment/payment_service.dart';
import '../../../repository/setting.dart';
import '../../../repository/tenants.dart';
import '../../../../provider/dateProvider.dart';
import 'addcard/AddCard.dart';
import 'addcard/CardModel.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:three_zero_two_property/TenantsModule/screen/financial/AddAchAccount/AddAchAccount.dart';

class MakePayment extends StatefulWidget {
  final String leaseId;
  final String tenantId;
  bool? isEdit;
  Data? data;

  MakePayment(
      {required this.leaseId, required this.tenantId, this.isEdit, this.data});

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
  // Live "Amount cannot exceed $999,999.99" inline error (QA ticket parity with
  // Enter/Edit Charge); 999999.99 is the max of the DECIMAL(8,2) amount column.
  String? _amountLimitError;
  Map<String, List<String>> categorizedData = {};
  String? selectedAccount;
  bool isLoading = true;
  bool hasError = false;
  double chargeAmount = 0.0;
  double surchargeIncluded = 0.0;
  double totalAmount = 0.0;
  int? selectedcardindex;
  bool? futuredate = false;
  Setting1? surcharges;
  double? surchargecount = 0.0;
  double? finaltotal;
  String? tenantname;
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
    if (widget.isEdit != null) editpayment();
    super.initState();
    fetchTenants();
    fetchCompany();
    fetchDropdownData();
    fetchSurcharge();
    //totalAmount = chargeAmount + surchargeIncluded;
    // amountController.addListener(_updateTotalAmount);
    fetchChargesAndBalance(widget.leaseId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dateProvider = Provider.of<DateProvider>(context);
    _startDate.text = dateProvider.formatCurrentDate(
      _startDate.text.isNotEmpty ? _startDate.text : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  editpayment() {
    Data c_data = widget.data!;
    setState(() {
      selectedTenantId = widget.tenantId;
      tenantname =
          "${(c_data.tenantData ?? {})["tenant_firstName"]} ${(c_data.tenantData ?? {})["tenant_lastName"]}";
      _startDate.text = (c_data.entry?.isNotEmpty ?? false)
          ? (c_data.entry!.first.date ?? "")
          : "";
      amountController.text = c_data.totalAmount.toString();
      _selectedPaymentMethod = c_data.paymenttype;

      print('charge details ${charges!.length}');
      rows = c_data.entry?.map((entry) {
            return {
              'entry_id': entry.entryId,
              'account': entry.account,
              'amount': 0.0,
              'charge_amount': entry.amount,
              'memo': entry.memo?.isNotEmpty == true ? entry.memo : "Payment",
              'date': entry.date,
              'charge_type': entry.chargeType,
              'newfield': false,
            };
          }).toList() ??
          [];
      for (var i = 0; i < (c_data.entry ?? []).length; i++) {
        if (i == 0) {
          charges_balances[0] = (c_data.entry![i].amount ?? 0).ceil().toDouble();
        } else {
          charges_balances.add((c_data.entry![i].amount ?? 0).ceil().toDouble());
        }
      }
      print("rows length:- ${rows!.length}");
      /*  print(rows.first['account']);
        print(rows.first['charge_amount']);
        print(rows.first['charge_amount']);*/
      controllers = rows.map((row) {
        return TextEditingController(text: row["charge_amount"].toString());
      }).toList();
      print(rows);
      totalAmount = c_data.totalAmount ?? 0.0;
      isLoading = false;
    });
    AddFields();
  }

  void _updateTotalAmount() {
    setState(() {
      totalAmount = chargeAmount + surchargeIncluded;
    });
  }

  String processor_id = "";
  List<Map<String, String>> tenants = [];
  String? selectedTenantId;
  List<TextEditingController> controllers = [];
  List<BillingData> cardDetails = [];
  List<Map<String, dynamic>> achAccounts = [];
  int? selectedAchIndex;
  bool isLoadingAch = false;
  TextEditingController reference = TextEditingController();

  static String? _extractVaultString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    if (v is num) return v.toString();
    if (v is Map && v.isEmpty) return null;
    if (v is Map) return null;
    return v.toString();
  }

  /// Same POST as tenant flow: resolves saved ACH rows from billing vault for Make Payment.
  Future<void> fetchAchFromBillingVault() async {
    if (customervaultid == null) {
      if (mounted) {
        setState(() {
          achAccounts = [];
          selectedAchIndex = null;
          isLoadingAch = false;
        });
      }
      return;
    }
    setState(() => isLoadingAch = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? hdrId = prefs.getString('staff_id');
      String? adminId = prefs.getString('adminId');
      String? token = prefs.getString('token');
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
        headers: {
          'Content-Type': 'application/json',
          'id': 'CRM $hdrId',
          'authorization': 'CRM $token',
        },
        body: json.encode({
          'customer_vault_id': customervaultid.toString(),
          'admin_id': adminId ?? '',
        }),
      );
      if (response.statusCode == 200 && mounted) {
        final jsonResponse = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        final data =
            jsonResponse is Map<String, dynamic> ? jsonResponse['data'] : null;
        final customer = data is Map ? data['customer'] : null;
        final billing = customer is Map ? customer['billing'] : null;
        if (billing is List) {
          for (final item in billing) {
            if (item is! Map) continue;
            final checkAccount = _extractVaultString(item['check_account']);
            final checkName = _extractVaultString(item['check_name']);
            if ((checkAccount != null && checkAccount.isNotEmpty) ||
                (checkName != null && checkName.isNotEmpty)) {
              final attrs = item['@attributes'];
              final billingId =
                  attrs is Map ? _extractVaultString(attrs['id']) : null;
              list.add({
                'account_name': checkName ?? '',
                'account_holder_name': checkName ?? '',
                'account_number': checkAccount ?? '',
                'routing_number': _extractVaultString(item['check_aba']) ?? '',
                'account_type': _extractVaultString(item['account_type']) ?? '',
                'account_holder_type':
                    _extractVaultString(item['account_holder_type']) ?? '',
                'billing_id': billingId ?? '',
              });
            }
          }
        }
        setState(() {
          achAccounts = list;
          if (selectedAchIndex != null && selectedAchIndex! >= list.length) {
            selectedAchIndex = list.isEmpty ? null : 0;
          }
          isLoadingAch = false;
        });
      } else if (mounted) {
        setState(() {
          achAccounts = [];
          selectedAchIndex = null;
          isLoadingAch = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          achAccounts = [];
          selectedAchIndex = null;
          isLoadingAch = false;
        });
      }
    }
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    final response = await apiGet(
      Uri.parse('$Api_url/api/leases/lease_tenant/${widget.leaseId}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
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
          'first_name': '${tenant['tenant_firstName']}',
          'last_name': '${tenant['tenant_lastName']}',
          'email': '${tenant['tenant_email']}',
          'overridefee': '${tenant['override_fee']}',
          'enableoverridefee': '${tenant['enable_override_fee']}',
        });
      }
      setState(() {
        tenants = fetchedTenants;
        if (tenants.length == 1) {
          selectedTenantId = tenants.first["tenant_id"];
          fetchChargesForSelectedTenant(selectedTenantId!);
          fetchcreditcard(selectedTenantId!);
          fetchPaymentSettings();
        } else if (tenants.length > 1) {
          // If there are multiple tenants, select the first tenant and fetch their charges
          selectedTenantId = tenants.first["tenant_id"];
          tenantname = tenants.first["tenant_name"]!;
        }
        // if (selectedTenantId != null) {
        //   fetchChargesForSelectedTenant(selectedTenantId!);
        //   fetchcreditcard(selectedTenantId!);
        // }
        final inner = data['data'];
        processor_id = inner is Map
            ? (inner['processor_id']?.toString() ?? '')
            : '';
      });
    } else {
      throw Exception('Failed to load tenants');
    }
  }

  String? getOverrideFee(String tenantId) {
    for (var tenant in tenants) {
      if (tenant['tenant_id'] == tenantId) {
        return tenant['overridefee'];
      }
    }
    return null; // or you could return an empty string or any default value
  }

  bool getEnableOverrideFee(String tenantId) {
    for (var tenant in tenants) {
      if (tenant['tenant_id'] == tenantId) {
        final v = tenant['enableoverridefee'];
        return v == 'true' || v == '1';
      }
    }
    return false;
  }

  Future<void> fetchDropdownData() async {
    // try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId') ?? '';
    String? token = prefs.getString('token');

    // print(token); // removed: do not log auth token
    print('lease ${widget.leaseId}');
    String? id = prefs.getString("adminId");
    final response = await apiGet(
      Uri.parse('$Api_url/api/accounts/accounts/$adminId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM ${prefs.getString('staff_id') ?? id}",
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body)['data'];
      // log("accounts data $jsonResponse");
      Map<String, List<String>> fetchedData = {};
      // Adding static items to the "LIABILITY ACCOUNT" category
      fetchedData["Rent"] = ["Rent Income"];
      fetchedData["Late Fee Income"] = ["Late Fee Income"];
      fetchedData["Pre-payments"] = ["Pre-payments"];
      fetchedData["Security Deposit"] = ["Security Deposit"];

      for (var item in jsonResponse) {
        String chargeType = item['charge_type'] ?? "One Time Charge";
        String account = item['account'];
        print(chargeType);
        if (!fetchedData.containsKey(chargeType)) {
          fetchedData[chargeType] = [];
        }

        fetchedData[chargeType]!.add(account);
      }

      setState(() {
        categorizedData = fetchedData;
        print("fetch charge data ${categorizedData}");
        isLoading = false;
      });
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
    // } catch (e) {
    //   print(e);
    //   setState(() {
    //     hasError = true;
    //     isLoading = false;
    //   });
    // }
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
            "The charge's amount must match the total applied to balance. The difference is ${NumberFormat('#,##0.00', 'en_US').format((enteredAmount - totalAmount).abs())}";
      });
    } else {
      setState(() {
        validationMessage = null;
      });
    }
    print(totalAmount);
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
    print(pdfFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', pdfFile.path));

    var response = await apiSend(request);
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
  // Payment methods list
  List<String> _paymentMethods = [];

  // Initialize payment methods
  void _initializePaymentMethods({bool isExternal = false}) {
    print("payment methods calling ${_paymentMethods}");
    print("achaccepted ${achaccepted}");
    if (isExternal) {
      _paymentMethods = ['Cash', 'Money Order', 'Manual'];
    } else {
      _paymentMethods = [
        'Card',
        'Check',
        'Cash',
        'ACH',
        'Cashier \'s Check',
        'Money Order',
        'Manual'
      ].map((method) {
        if (method == 'ACH' && !achaccepted) {
          return 'ACH (not available)';
        }
        return method;
      }).toList();
    }
    // Clear selected method if it's not in the new list (avoids RangeError when changing tenant/method)
    if (_selectedPaymentMethod != null &&
        !_paymentMethods.contains(_selectedPaymentMethod)) {
      _selectedPaymentMethod = null;
    }
  }

  final List<String> _paymentMethodsforfree = ['Check', 'Cash'];
  final List<String> _selecttype = ['Checking', 'Savings'];
  final List<String> _selectholder = ['Business', 'Personal'];
  bool showCardNumberField = false;
  bool showCheckNumberField = false;
  bool showACHFields = false;
  int? customervaultid;
  bool showCashiersFields = false;
  bool showMoneyorderFields = false;
  bool showMenualFields = false;

  // Helper function to check if a card type is accepted
  bool isCardTypeAccepted(String cardType) {
    print("cardType ${cardType}");
    cardType = cardType.toUpperCase();
    if (cardType == 'CREDIT') {
      return creditcard;
    } else if (cardType == 'DEBIT') {
      return debitcard;
    }
    return false;
  }

  // Payment acceptance flags — WEB parity: fail-open like Staffaddpayment.jsx
  // (credit/debit default accepted, ACH not, until payment_settings loads).
  bool creditcard = true;
  bool achaccepted = false;
  bool debitcard = true;
  bool isChecked = false;

  // Mirrors Admin's resetFields(): used by "Make Another Payment" to clear the
  // form and reload charges instead of popping the screen after a payment.
  void resetFields() {
    fetchChargesForSelectedTenant(selectedTenantId!);
    setState(() {
      amountController.clear();
      Memo.clear();
      checknumber.clear();
      bankrountingnum.clear();
      accountnum.clear();
      achname.clear();
      reference.clear();
      _selectedPaymentMethod = null;
      selectedAccount = null;
      _selectedHoldertype = null;
      selectedcardindex = null;
      totalAmount = 0.0;
      validationMessage = null;
      _uploadedFileNames.clear();
      _pdfFiles.clear();
      for (var controller in controllers) {
        controller.clear();
      }
      isChecked = false;
    });
  }

  Future<void> fetchPaymentSettings() async {
    if (selectedTenantId == null || selectedTenantId!.isEmpty) {
      print("No tenant selected, skipping payment settings fetch");
      return;
    }

    print("calling payment card check");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? id = prefs.getString("adminId");
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    try {
      final response = await apiGet(
        Uri.parse(
            '${Api_url}/api/tenant/payment_settings/$selectedTenantId/${widget.leaseId}'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM ${prefs.getString('staff_id') ?? id}",
        },
      );

      final jsonData = json.decode(response.body);
      print(' rental added ${jsonData}');
      print(
          ' rental url ${Api_url}/api/tenant/payment_settings/$selectedTenantId/${widget.leaseId}');
      print("lease id ${widget.leaseId}");
      print("tenant id $selectedTenantId");
      print("jsonData ${jsonData}");
      print("achaccepted ${achaccepted}");

      if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
        setState(() {
          achaccepted = jsonData['data']['achAccepted'] ?? false;
          creditcard = jsonData['data']['creditCardAccepted'] ?? true;
          debitcard = jsonData['data']['debitCardAccepted'] ?? true;
          print(' credit card accepted ${creditcard}');
          // Update payment methods to reflect availability
          _initializePaymentMethods();
        });
      } else {
        print("Failed to fetch payment settings: ${jsonData["message"]}");
      }
    } catch (e) {
      print("Error fetching payment settings: $e");
    }
  }

  void AddFields() {
    setState(() {
      showCardNumberField = _selectedPaymentMethod == 'Card';
      showCheckNumberField = _selectedPaymentMethod == 'Check';
      showACHFields = _selectedPaymentMethod == 'ACH' && achaccepted;
      showCashiersFields = _selectedPaymentMethod == 'Cashier \'s Check';
      showMoneyorderFields = _selectedPaymentMethod == 'Money Order';
      showMenualFields = _selectedPaymentMethod == 'Manual';

      // Show toast if payment method is not accepted
      if (_selectedPaymentMethod == 'ACH' && !achaccepted) {
        Fluttertoast.showToast(
          msg: "ACH payments are not accepted by the rental owner",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
  }

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

  double balance = 0.00;
  Future<void> fetchChargesAndBalance(String leaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');

    try {
      final response = await apiGet(
        Uri.parse('$Api_url/api/charge/tenant_charges/$leaseId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM ${prefs.getString('staff_id') ?? id}",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('totalCharges') &&
            jsonResponse['totalCharges'] is List) {
          List<dynamic> totalCharges = jsonResponse['totalCharges'];
          double balanceValue = jsonResponse['balance']?.toDouble() ?? 0.00;

          setState(() {
            balance = balanceValue; // Directly set the balance as a double
          });
        } else {
          throw Exception('No charges found');
        }
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

//for payment
//   Future<void> fetchChargesForSelectedTenant(String tenantId) async {
//     setState(() {
//       isLoading = true;
//       hasError = false;
//     });
//     try {
//       List<Entrycharge>? charges = await ChargeRepositorys().fetchChargesTable(
//         widget.leaseId,
//       );
//       List<Entrycharge> filteredCharges =
//           charges?.where((entry) => entry.chargeAmount! > 0).toList() ?? [];
//
//       print('leaseid ${widget.leaseId}');
//       print('tenantid $tenantId');
//
//       setState(() {
//         rows = charges?.where((entry) => entry.chargeAmount! > 0).map((entry) {
//               return {
//                 'entry_id': entry.entryId,
//                 'account': entry.account,
//                 'amount': 0.0,
//                 'charge_amount': entry.chargeAmount,
//                 'memo': entry.memo?.isNotEmpty == true ? entry.memo : "Payment",
//                 'date': entry.date,
//                 'charge_type': entry.chargeType,
//                 'newfield': false,
//               };
//             }).toList() ??
//             [];
//         for (var i = 0; i < filteredCharges!.length; i++) {
//           if (i == 0) {
//             charges_balances[0] = filteredCharges[i].chargeAmount!.toDouble();
//           } else {
//             charges_balances.add(filteredCharges[i].chargeAmount!.toDouble());
//           }
//         }
//
//         /*  print(rows.first['account']);
//         print(rows.first['charge_amount']);
//         print(rows.first['charge_amount']);*/
//         controllers = rows.map((row) {
//           return TextEditingController(text: "".toString());
//         }).toList();
//         print(rows);
//         totalAmount = rows.fold(
//             0.0, (sum, row) => sum + (row[amountController.text] ?? 0));
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//     }
//   }
  Future<void> fetchChargesForSelectedTenant(String tenantId) async {
    print('fetch tenant charges calling');
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      List<Entrycharge>? charges =
          await ChargeRepositorys().fetchChargesTable(widget.leaseId);
      print('charge details ${charges!.length}');
      List<Entrycharge> filteredCharges =
          charges?.where((entry) => entry.chargeAmount! > 0).toList() ?? [];
      print("charges length:- ${charges!.length}");
      print('leaseid ${widget.leaseId}');

      print('tenantid '
          '$tenantId');

      setState(() {
        charges_balances = [0.0];
        rows = charges?.where((entry) => entry.chargeAmount! > 0).map((entry) {
              // String chargeType = categorizedData.entries.firstWhere(
              //       (entryData) => entryData.value.contains(entry.account),
              //   orElse: () => MapEntry("Unknown", []), // Default if not found
              // ).key;
              String? chargeType = (entry.account == "Late Fee Income" ||
                      entry.account == "Pre-payments" ||
                      entry.account == "Security Deposit")
                  ? entry.account
                  : entry.account == "Rent Income"
                      ? "Rent"
                      : categorizedData.entries.firstWhere(
                          (entryData) =>
                              entryData.value.contains(entry.account),
                          orElse: () {
                            // If the chargeType is not found, add it dynamically
                            final fallbackType =
                                entry.chargeType ?? 'One Time Charge';
                            categorizedData[fallbackType] = [
                              ...(categorizedData[fallbackType] ?? []),
                              entry.account ?? '',
                            ];
                            return MapEntry(fallbackType, []);
                          },
                        ).key;
              print(chargeType);
              return {
                'entry_id': entry.entryId,
                'account': entry.account,
                'amount': 0.0,
                'charge_amount': entry.chargeAmount,
                'memo': entry.memo?.isNotEmpty == true ? entry.memo : "Payment",
                'date': entry.date,
                'charge_type': chargeType, // Set matched charge type libity
                'sub_charge_type':
                    entry.chargeType, // Set original charge type onetime
                'newfield': false,
              };
            }).toList() ??
            [];

        for (var i = 0; i < filteredCharges!.length; i++) {
          if (i == 0) {
            double chargeAmount = filteredCharges[i].chargeAmount!.toDouble();
            String formattedChargeAmount = chargeAmount.toStringAsFixed(2);
            charges_balances[0] = double.parse(formattedChargeAmount);
            //charges_balances[0] = filteredCharges[i].chargeAmount!.toDouble();
          } else {
            double chargeAmount = filteredCharges[i].chargeAmount!.toDouble();
            String formattedChargeAmount = chargeAmount.toStringAsFixed(2);
            //charges_balances[0] = double.parse(formattedChargeAmount);
            charges_balances.add(double.parse(formattedChargeAmount));
          }
        }
        print("charges length ${charges_balances.length}");
        print("rows length:- ${rows!.length}");
        /*  print(rows.first['account']);
        print(rows.first['charge_amount']);
        print(rows.first['charge_amount']);*/
        controllers = rows.map((row) {
          return TextEditingController(text: "".toString());
        }).toList();
        print(rows);
        totalAmount = rows.fold(
            0.0, (sum, row) => sum + (row[amountController.text] ?? 0));
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void addRow() {
    setState(() {
      rows.add({
        'account': null,
        'charge_type': null,
        'amount': 0.0,
        'memo': Memo.text.isNotEmpty ? Memo.text : "Payment",
        'charge_amount': 0.0,
        'date': reverseFormatDate(_startDate.text),
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
      // charge_amount/amount come from the model as num? — a whole-dollar charge
      // (e.g. 1200) decodes as int, and an untouched Edit row can be null. Coerce
      // every read to double: assigning an int/null into charges_balances
      // (List<double>) or adding it to totalAmount (double) would throw and crash
      // the screen while the user types. (Web behaviour otherwise preserved.)
      final double charge =
          (rows[index]["charge_amount"] as num?)?.toDouble() ?? 0.0;
      if (value == "") {
        // Field cleared: this charge applies 0, so restore its full balance.
        rows[index]['amount'] = 0.0;
        charges_balances[index] = charge;
      } else {
        final double amount = double.tryParse(value) ?? 0.0;
        rows[index]['amount'] = amount;
        // New rows add to the balance; existing rows reduce it.
        charges_balances[index] =
            rows[index]["newfield"] == true ? charge + amount : charge - amount;
      }
      // Recompute the total applied across all rows (empty/untouched counts as 0).
      totalAmount = 0.0;
      for (var i = 0; i < rows.length; i++) {
        totalAmount += (rows[i]["amount"] as num?)?.toDouble() ?? 0.0;
      }
    });
    //counttotal();
    validateAmounts();
  }

  Future<void> fetchcreditcard(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    setState(() {
      isLoading = true;
      cardDetails = []; // Clear previous card details
      selectedcardindex = null; // Avoid RangeError when list is rebuilt
      selectedAchIndex = null;
      achAccounts = [];
    });

    final response = await apiGet(
      Uri.parse('$Api_url/api/creditcard/getCreditCards/$tenantId'),
      headers: {"id": "CRM $id", "authorization": "CRM $token"},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      customervaultid = jsonResponse['customer_vault_id'];
      if (customervaultid != null) {
        await fetchAchFromBillingVault();
      } else {
        setState(() {
          achAccounts = [];
          selectedAchIndex = null;
          isLoadingAch = false;
        });
      }
      List<dynamic> cardDetailsList = jsonResponse['card_detail'];

      // Debug print to check the response structure
      print('JSON Response: $jsonResponse');

      for (var cardDetail in cardDetailsList) {
        // Debug print to check each card detail
        print('Card Detail: $cardDetail');

        //  BillingData billingData = BillingData.fromJson(cardDetail);
        // print('Parsed Billing ID: ${billingData.billingId}');

        // Assuming this is part of the logic to print billing_id
        print('Billing ID: ${cardDetail['billing_id']}');
      }

      CustomerData? customerData = await postBillingCustomerVault(
          customervaultid.toString(), cardDetailsList);

      if (customerData != null) {
        setState(() {
          // Web UI shows only CREDIT/DEBIT cards; filter out ACH + incomplete rows.
          cardDetails = customerData.billing.where((b) {
            final type = (b.binResult ?? '').toUpperCase();
            final hasNumber = (b.ccNumber ?? '').toString().trim().isNotEmpty;
            return (type == 'CREDIT' || type == 'DEBIT') && hasNumber;
          }).toList();
          // Keep selected index only if still in range (avoids RangeError)
          if (selectedcardindex != null &&
              (selectedcardindex! < 0 ||
                  selectedcardindex! >= cardDetails.length)) {
            selectedcardindex = null;
          }
        });
      }
    } else if (response.statusCode == 404) {
      print('customer_vault_id not found');
    } else {
      throw Exception('Failed to load credit card data');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<CustomerData?> postBillingCustomerVault(
      String customerVaultId, List<dynamic> cardDetailsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": adminId.toString(),
    };

    final response = await apiPost(
      Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
      headers: {
        'Content-Type': 'application/json',
        "id": "CRM $id",
        "authorization": "CRM $token",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var customerJson = jsonResponse['data']['customer'];
      if (customerJson == null) {
        print('Failed to post data: ${response.statusCode}');
        return null;
      }
      CustomerData customerData = CustomerData.fromJson(customerJson);

      customerData.billing.forEach((billing) {
        print('CC Bin: ${billing.ccBin}');
      });

      // Map card types to billing records safely (avoids index mismatch and nulls).
      final Map<String, String> cardTypeByBillingId = {};
      for (final dynamic item in cardDetailsList) {
        if (item is Map) {
          final billingId = item['billing_id']?.toString();
          final cardType = item['card_type']?.toString();
          if (billingId != null && billingId.isNotEmpty && cardType != null) {
            cardTypeByBillingId[billingId] = cardType;
          }
        }
      }

      for (final billing in customerData.billing) {
        final id = billing.billingId;
        if (id != null && cardTypeByBillingId.containsKey(id)) {
          billing.binResult = cardTypeByBillingId[id];
        }
      }

      return customerData;
    } else {
      print('Failed to post data: ${response.statusCode}');
      return null;
    }
  }

  static const int numItems = 20;
  List<bool> selected = List<bool>.generate(numItems, (int index) => false);

  Map<int, bool> selectedRows = {};
  double? surCharge;

  dynamic? surChargeAchper;
  dynamic? surChargeAchflat;

  Future<void> fetchSurcharge() async {
    //  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId') ?? '';
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    print(adminId);

    final response = await apiGet(
      Uri.parse('$Api_url/api/surcharge/surcharge/getadmin/$adminId'),
      headers: {
        "id": "CRM $id",
        "authorization": "CRM $token",
      },
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      var jsonResponse = jsonDecode(response.body);

      // Accessing the first element in the 'data' list
      var surchargeData = jsonResponse['data'][0] ?? "";
      if (_selectedPaymentMethod == "Card") {
        if (selectedcardindex == null ||
            selectedcardindex! < 0 ||
            selectedcardindex! >= cardDetails.length) {
          setState(() {
            surCharge = 0.0;
          });
          return;
        }

        final String cardType =
            (cardDetails[selectedcardindex!].binResult ?? '').toUpperCase();
        if (cardType == "CREDIT") {
          setState(() {
            surCharge =
                num.tryParse('${surchargeData['surcharge_percent'] ?? 0}')
                        ?.toDouble() ??
                    0.0;
          });
        } else if (cardType == "DEBIT") {
          setState(() {
            String? overrideFee = getOverrideFee(selectedTenantId!);
            bool enableOverrideFee = getEnableOverrideFee(selectedTenantId!);
            print("overrideFee   ${overrideFee}");
            if (enableOverrideFee &&
                overrideFee != null &&
                overrideFee.isNotEmpty &&
                overrideFee != "null")
              surCharge = double.tryParse(overrideFee) ?? 0.0;
            else
              surCharge = num.tryParse(
                          '${surchargeData['surcharge_percent_debit'] ?? 0}')
                      ?.toDouble() ??
                  0.0;
          });
        } else {
          setState(() {
            surCharge = 0.0;
          });
        }
      }

      setState(() {
        surChargeAchper = num.tryParse(
                    '${surchargeData['surcharge_percent_ACH'] ?? 0}')
                ?.toDouble() ??
            0.0;
        surChargeAchflat = num.tryParse(
                    '${surchargeData['surcharge_flat_ACH'] ?? 0}')
                ?.toDouble() ??
            0.0;
      });

      print(surChargeAchper);
      print(surChargeAchflat);
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

  void showFailedPaymentAlert(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Failed!",
      desc: "Processor ID is not selected for this property!\n\n" +
          "1. To select the Processor ID, go to the properties table.\n" +
          "2. Click on the edit icon for the desired property.\n" +
          "3. Click on the edit icon from Rental Owner Information.\n" +
          "4. If no Processor ID exists, add one and check the checkbox, then save your changes.",
      buttons: [
        DialogButton(
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  String? _errorText;
  @override
  Widget build(BuildContext context) {
    bool isFreePlan = Provider.of<checkPlanPurchaseProiver>(context)
            .checkplanpurchaseModel
            ?.data
            ?.planDetail
            ?.planName ==
        'Free Plan';

    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(bottom: 6.0),
                  //Same as `blurRadius` i guess
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: blueColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4, left: 8),
                    child: Text(
                      "Make Payment",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width < 500 ? 18 : 35,
                    right: MediaQuery.of(context).size.width < 500 ? 18 : 35),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFCED4DA),
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            if (MediaQuery.of(context).size.width < 500)
                              Text('Received From *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
                            if (MediaQuery.of(context).size.width < 500)
                              const SizedBox(
                                height: 8,
                              ),
                            if (MediaQuery.of(context).size.width < 500)
                              FormField<String>(
                                validator: (value) {
                                  if (selectedTenantId == null ||
                                      selectedTenantId!.isEmpty) {
                                    return 'Please select a tenant';
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
                                          hint: const Text(
                                            'Select Tenant',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFb0b6c3)),
                                          ),
                                          value: selectedTenantId,
                                          items: [
                                            ...tenants.map((tenant) {
                                              return DropdownMenuItem<String>(
                                                value: tenant['tenant_id'],
                                                child: Text(
                                                    tenant['tenant_name']!),
                                              );
                                            }).toList(),
                                            // Add a special menu item for "Add New Tenant"
                                            const DropdownMenuItem<String>(
                                              value: 'external_source',
                                              child: Text(
                                                'External Source',
                                                style: TextStyle(),
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) async {
                                            state.didChange(value);
                                            setState(() {
                                              selectedTenantId = value;
                                              if (value == 'external_source') {
                                                // Fetch all charges if "Add New Tenant" is selected
                                                fetchChargesForSelectedTenant(
                                                    value!);
                                                // Update available payment methods
                                                setState(() {
                                                  _initializePaymentMethods(
                                                      isExternal: true);
                                                });
                                              } else {
                                                tenantname = tenants.firstWhere(
                                                    (tenant) =>
                                                        tenant['tenant_id'] ==
                                                        value)['tenant_name']!;
                                                fetchChargesForSelectedTenant(
                                                    value!);
                                                setState(() {
                                                  _initializePaymentMethods();
                                                });
                                              }

                                              // tenantname = tenants.firstWhere(
                                              //     (tenant) =>
                                              //         tenant['tenant_id'] ==
                                              //         value)['tenant_name']!;
                                              // fetchChargesForSelectedTenant(
                                              //     value!);
                                            });
                                            state.reset();
                                            await fetchcreditcard(value!);
                                            print(
                                                'Selected tenant_id: $selectedTenantId');
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            // width: 250,
                                            padding: const EdgeInsets.only(
                                                left: 2, right: 14),
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
                                            height: 45,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                        ),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Text(
                                            state.errorText ?? '',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            if (MediaQuery.of(context).size.width < 500)
                              const SizedBox(
                                height: 20,
                              ),
                            if (MediaQuery.of(context).size.width < 500)
                              Text('Date *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
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
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2101),
                                    locale: const Locale('en', 'US'),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Color.fromRGBO(21, 43, 83,
                                                1), // header background color
                                            onPrimary: Colors
                                                .white, // header text color
                                            onSurface: Color.fromRGBO(21, 43,
                                                83, 1), // body text color
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  const Color.fromRGBO(
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
                                    bool isfuture =
                                        pickedDate.isAfter(DateTime.now());
                                    final dateProvider = Provider.of<DateProvider>(context, listen: false);
                                    String formattedDate = dateProvider.formatCurrentDate(DateFormat('yyyy-MM-dd').format(pickedDate));
                                    setState(() {
                                      futuredate = isfuture;
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
                                label: "Select the date",
                                keyboardType: TextInputType.text,
                                hintText: 'YYYY-MM-DD',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                  color: blueColor)),
                                          const SizedBox(height: 5),
                                          tenants.isEmpty
                                              ? const Center(
                                                  child: SpinKitFadingCircle(
                                                    color: Colors.black,
                                                    size: 50.0,
                                                  ),
                                                )
                                              : DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton2<String>(
                                                    isExpanded: true,
                                                    hint: const Text(
                                                        'Select Tenant'),
                                                    value: selectedTenantId,
                                                    items:
                                                        tenants.map((tenant) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value:
                                                            tenant['tenant_id'],
                                                        child: Text(tenant[
                                                            'tenant_name']!),
                                                      );
                                                    }).toList(),
                                                    // onChanged: (value) {
                                                    //   setState(() {
                                                    //     selectedTenantId = value;
                                                    //     fetchChargesForSelectedTenant(widget.tenantId,);
                                                    //    // ChargeRepositorys().fetchChargesTable(widget.leaseId, widget.tenantId);
                                                    //   });
                                                    //   print(
                                                    //       'Selected tenant_id: $selectedTenantId');
                                                    // },
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        selectedTenantId =
                                                            value;
                                                        fetchChargesForSelectedTenant(
                                                            value!);
                                                      });
                                                      await fetchcreditcard(
                                                          value!);
                                                      await fetchPaymentSettings();
                                                      print(
                                                          'Selected tenant_id: $selectedTenantId');
                                                    },
                                                    buttonStyleData:
                                                        ButtonStyleData(
                                                      height:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 45
                                                              : 55,
                                                      width: 250,
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
                                                      height: 45,
                                                      padding: EdgeInsets.only(
                                                          left: 14, right: 14),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
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
                                                  color: blueColor)),
                                          const SizedBox(height: 5),
                                          CustomTextField(
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2101),
                                                locale:
                                                    const Locale('en', 'US'),
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  return Theme(
                                                    data: ThemeData.light()
                                                        .copyWith(
                                                      colorScheme:
                                                          const ColorScheme
                                                              .light(
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
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              blueColor, // button text color
                                                        ),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (pickedDate != null) {
                                                bool isfuture = pickedDate
                                                    .isAfter(DateTime.now());
                                                final dateProvider = Provider.of<DateProvider>(context, listen: false);
                                                String formattedDate = dateProvider.formatCurrentDate(DateFormat('yyyy-MM-dd').format(pickedDate));
                                                setState(() {
                                                  futuredate = isfuture;
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
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select start date';
                                              }
                                              return null;
                                            },
                                            label: "Select the date",
                                            keyboardType: TextInputType.text,
                                            hintText: 'dd-mm-yyyy',
                                            controller: _startDate,
                                          ),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text('Amount *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            const SizedBox(
                              height: 8,
                            ),
                            CustomTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                final raw = value.trim().replaceAll(',', '');
                                final parsed = double.tryParse(raw);
                                if (parsed == null || parsed <= 0) {
                                  return 'Please enter valid amount';
                                }
                                return null;
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              formatter: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,10}(\.\d{0,2})?$'),
                                ),
                              ],
                              hintText: 'Enter amount',
                              controller: amountController,
                              onChanged: (value) {
                                validateAmounts();
                                final v = double.tryParse(
                                    value.trim().replaceAll(',', ''));
                                setState(() {
                                  _amountLimitError =
                                      (v != null && v > 999999.99)
                                          ? 'Amount cannot exceed \$999,999.99'
                                          : null;
                                });
                              },
                            ),
                            if (_amountLimitError != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  _amountLimitError!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text('Payment Method *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            const SizedBox(
                              height: 8,
                            ),
                            if (isFreePlan)
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Text(
                                    'Select method',
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xFFb0b6c3)),
                                  ),
                                  value: _paymentMethodsforfree
                                          .contains(_selectedPaymentMethod)
                                      ? _selectedPaymentMethod
                                      : null,
                                  items: _paymentMethodsforfree.map((method) {
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
                                    print(_selectedPaymentMethod == "Card");
                                    print(
                                        'Selected payment method: $_selectedPaymentMethod');
                                    surge_count();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height:
                                        MediaQuery.of(context).size.width < 500
                                            ? 46
                                            : 55,
                                    // width:
                                    //     MediaQuery.of(context).size.width < 500
                                    //         ? 200
                                    //         : 250,
                                    padding: const EdgeInsets.only(
                                        left: 2, right: 14),
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
                            if (!isFreePlan)
                              FormField<String>(
                                validator: (value) {
                                  if (_selectedPaymentMethod == null ||
                                      _selectedPaymentMethod!.isEmpty) {
                                    return 'Please select a payment method';
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
                                          hint: const Text(
                                            'Select method',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFb0b6c3)),
                                          ),
                                          value: _paymentMethods.contains(
                                                  _selectedPaymentMethod)
                                              ? _selectedPaymentMethod
                                              : null,
                                          items: _paymentMethods.map((method) {
                                            return DropdownMenuItem<String>(
                                              value: method,
                                              child: Text(method),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue == null) return;

                                            // Strip "(not available)" from the selection if present
                                            String cleanValue =
                                                newValue.replaceAll(
                                                    ' (not available)', '');

                                            // Check if the method is available
                                            bool isAvailable = true;
                                            if (cleanValue == 'ACH' &&
                                                !achaccepted) {
                                              isAvailable = false;
                                            }

                                            if (!isAvailable) {
                                              Fluttertoast.showToast(
                                                msg:
                                                    "$cleanValue payments are not accepted by the rental owner",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                              return;
                                            }

                                            state.didChange(
                                                cleanValue); // Update FormField state
                                            setState(() {
                                              _selectedPaymentMethod =
                                                  cleanValue;
                                              AddFields(); // Call your method to add fields
                                            });
                                            state.reset();
                                            print(_selectedPaymentMethod ==
                                                "Card");
                                            print(
                                                'Selected payment method: $_selectedPaymentMethod');
                                            surge_count(); // Your method call
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 46
                                                : 55,
                                            // width: MediaQuery.of(context)
                                            //             .size
                                            //             .width <
                                            //         500
                                            //     ? 200
                                            //     : 250,
                                            padding: const EdgeInsets.only(
                                                left: 2, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                        ),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Text(
                                            state.errorText ?? '',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            const SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text("Reference",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CustomTextField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter reference';
                                  }
                                  return null;
                                },
                                optional: true,
                                keyboardType: TextInputType.text,
                                hintText: 'Enter reference',
                                controller: reference,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (showCardNumberField) ...[
                              const SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FormField<String>(validator: (value) {
                                  if (selectedcardindex == null ||
                                      _selectedPaymentMethod!.isEmpty) {
                                    return 'Please select a card';
                                  }
                                  return null;
                                }, builder: (FormFieldState<String> state) {
                                  return Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Cards",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      cardDetails.isEmpty
                                          ? Container(
                                              child: const Center(
                                                  child: Text(
                                                      'No Cards Available')),
                                            )
                                          : SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                dataRowHeight: 75,
                                                horizontalMargin: 0.0,
                                                columnSpacing: 40.0,
                                                columns: [
                                                  DataColumn(
                                                    label: Text(
                                                      'Select',
                                                      style: TextStyle(
                                                          color: blueColor),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Card Number',
                                                      style: TextStyle(
                                                          color: blueColor),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Card Type',
                                                      style: TextStyle(
                                                          color: blueColor),
                                                    ),
                                                  ),
                                                ],
                                                rows: cardDetails
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  int index = entry.key;
                                                  BillingData item =
                                                      entry.value;
                                                  final exp = (item.ccExp ?? '')
                                                      .toString();
                                                  //  print(month);
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
                                                      currentMonth +
                                                          currentYear;
                                                  /* print(
                                                          'Current: $currentMonthYear');*/

                                                  bool isExpired = true;
                                                  if (exp.length >= 4) {
                                                    final expMonthYear = exp;
                                                    final expMonth =
                                                        expMonthYear.substring(
                                                            0, 2);
                                                    final expYear = expMonthYear
                                                        .substring(2, 4);
                                                    isExpired = int.parse(
                                                                expYear) <
                                                            int.parse(
                                                                currentYear) ||
                                                        (int.parse(expYear) ==
                                                                int.parse(
                                                                    currentYear) &&
                                                            int.parse(
                                                                    expMonth) <
                                                                int.parse(
                                                                    currentMonth));
                                                  }

                                                  /* print(
                                                          'Expiration date passed: $isExpired');
                                      */
                                                  return DataRow(cells: [
                                                    DataCell(
                                                      isExpired == true
                                                          ? const Text(
                                                              'Expired',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red))
                                                          : Checkbox(
                                                              fillColor: !isCardTypeAccepted(
                                                                      item.binResult ??
                                                                          '')
                                                                  ? MaterialStateProperty
                                                                      .all(Colors
                                                                              .grey[
                                                                          300])
                                                                  : null,
                                                              value:
                                                                  selectedcardindex ==
                                                                      index,
                                                              onChanged: (bool?
                                                                  value) async {
                                                                String
                                                                    cardType =
                                                                    item.binResult
                                                                            ?.toUpperCase() ??
                                                                        '';
                                                                bool
                                                                    isAccepted =
                                                                    isCardTypeAccepted(
                                                                        cardType);

                                                                if (!isAccepted) {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                    msg:
                                                                        "$cardType card payments are not accepted by the rental owner",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_LONG,
                                                                    gravity:
                                                                        ToastGravity
                                                                            .BOTTOM,
                                                                  );
                                                                  return;
                                                                }

                                                                setState(() {
                                                                  selectedcardindex =
                                                                      index;
                                                                });
                                                                await fetchSurcharge();
                                                              },
                                                            ),
                                                    ),
                                                    DataCell(Text(
                                                      item.ccNumber ?? '',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: blueColor),
                                                    )),
                                                    DataCell(Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                            height: 4),
                                                        // _buildLogosBlock(
                                                        //     item.ccType ?? ''),
                                                        // const SizedBox(
                                                        //     height: 4),
                                                        if (_resolveCardBrandLabel(
                                                                item.ccType,
                                                                item.ccNumber)
                                                            .isNotEmpty) ...[
                                                          Text(
                                                            _resolveCardBrandLabel(
                                                                item.ccType,
                                                                item.ccNumber),
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    blueColor),
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                        ],
                                                        Text(
                                                          '${item.binResult} CARD',
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              color: blueColor),
                                                        ),
                                                      ],
                                                    )),
                                                  ]);
                                                }).toList(),
                                              ),
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            if (surCharge != null &&
                                                selectedcardindex != null &&
                                                selectedcardindex! <
                                                    cardDetails.length)
                                              // ignore: unrelated_type_equality_checks
                                              Row(
                                                children: [
                                                  Text(
                                                    '${cardDetails[selectedcardindex!].binResult} card transactions will charge $surCharge%',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            if (state.hasError)
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
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
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddCard(
                                                            leaseId:
                                                                widget.leaseId,
                                                          )));
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .04,
                                                // width: MediaQuery.of(context).size.width * .36,
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 80
                                                    : 90,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  color: blueColor,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 6.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: isLoading
                                                      ? const SpinKitFadingCircle(
                                                          color: Colors.white,
                                                          size: 25.0,
                                                        )
                                                      : Text(
                                                          "Add Card",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 14
                                                                  : 17),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              const SizedBox(height: 15),
                            ],
                            if (showCheckNumberField) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  "Check Number",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter check number';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter check number',
                                  controller: checknumber,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (showACHFields) ...[
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ACH Account Details",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(height: 10),
                                  if (isLoadingAch)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SpinKitFadingCircle(
                                            color: blueColor, size: 45.0),
                                      ),
                                    )
                                  else if (achAccounts.isEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'No ACH accounts',
                                        style: TextStyle(
                                            fontSize: 15, color: grey),
                                      ),
                                    )
                                  else
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ...achAccounts
                                              .asMap()
                                              .entries
                                              .map((e) {
                                            final int idx = e.key;
                                            final acc = e.value;
                                            String accountName = acc[
                                                        'account_name']
                                                    ?.toString() ??
                                                acc['account_holder_name']
                                                    ?.toString() ??
                                                '—';
                                            String accountNumber = acc[
                                                        'account_number']
                                                    ?.toString() ??
                                                '';
                                            if (accountNumber.length > 4) {
                                              accountNumber = '****' +
                                                  accountNumber.substring(
                                                      accountNumber.length - 4);
                                            } else if (accountNumber
                                                .isNotEmpty) {
                                              accountNumber = accountNumber
                                                  .replaceAll(RegExp(r'\d'), '*');
                                            }
                                            final route = acc['routing_number']
                                                    ?.toString() ??
                                                '';
                                            return GestureDetector(
                                              onTap: () => setState(() =>
                                                  selectedAchIndex =
                                                      selectedAchIndex == idx
                                                          ? null
                                                          : idx),
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: selectedAchIndex ==
                                                          idx
                                                      ? blueColor
                                                          .withOpacity(0.05)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: selectedAchIndex ==
                                                            idx
                                                        ? blueColor
                                                        : Colors.grey.shade300,
                                                    width:
                                                        selectedAchIndex == idx
                                                            ? 1.5
                                                            : 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Checkbox(
                                                      value:
                                                          selectedAchIndex ==
                                                              idx,
                                                      onChanged: (v) =>
                                                          setState(() =>
                                                              selectedAchIndex =
                                                                  v == true
                                                                      ? idx
                                                                      : null),
                                                      activeColor: blueColor,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Account Holder Name',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          grey,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                const SizedBox(
                                                                    height: 3),
                                                                Text(
                                                                  accountName,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .black87),
                                                                ),
                                                                if (route
                                                                    .isNotEmpty) ...[
                                                                  const SizedBox(
                                                                      height:
                                                                          4),
                                                                  Text(
                                                                    'Routing $route',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color:
                                                                            grey,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Account Number',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          grey,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                const SizedBox(
                                                                    height: 3),
                                                                Text(
                                                                  accountNumber,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .black87),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if (selectedTenantId == null) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Please select Received From');
                                            return;
                                          }
                                          final added =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddAchAccount(
                                                tenantId: selectedTenantId!,
                                                customerVaultId:
                                                    customervaultid?.toString(),
                                                authAsStaff: true,
                                              ),
                                            ),
                                          );
                                          if (added == true &&
                                              mounted &&
                                              selectedTenantId != null) {
                                            await fetchcreditcard(
                                                selectedTenantId!);
                                          }
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 200,
                                          margin: const EdgeInsets.only(
                                              bottom: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: blueColor, width: 1.5),
                                            color: blueColor,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Add a New ACH Account",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (achAccounts.isNotEmpty &&
                                      selectedAchIndex == null &&
                                      !isLoadingAch)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'Select a saved account above.',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade800),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (showCashiersFields) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  "Check Number",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter check number';
                                    }
                                    return null;
                                  },
                                  optional: false,
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter check number',
                                  controller: checknumber,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (showMoneyorderFields) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  "Check Number",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter check number';
                                    }
                                    return null;
                                  },
                                  optional: false,
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter check number',
                                  controller: checknumber,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (showMenualFields) ...[
                              //checkfield is not required
                              const SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  "Check Number",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter check number';
                                    }
                                    return null;
                                  },
                                  optional: true,
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter check number',
                                  controller: checknumber,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text('Memo',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: CustomTextField(
                                optional: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter memo';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                hintText: 'Enter memo',
                                controller: Memo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text('Apply Payment to Accounts',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 11, right: 11),
                        child: Text(
                            'Current Balances : ${balance.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (MediaQuery.of(context).size.width < 500)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Charge ${index + 1}',
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold)),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                deleteRow(index);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12.0),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text("Account",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DropdownButtonHideUnderline(
                                          child: FormField<String>(
                                            validator: (value) {
                                              if (rows[index]['account'] ==
                                                  null) {
                                                return 'Please select an account';
                                              }
                                              return null;
                                            },
                                            builder:
                                                (FormFieldState<String> state) {
                                              String? selectedAccount =
                                                  row['account'];

                                              // List of all dropdown items, including missing ones
                                              Map<String, List<String>>
                                                  categorizedDataCopy =
                                                  Map.from(categorizedData);

                                              // Ensure the selected value is present in the list
                                              // if (selectedAccount != null && !categorizedData.values.expand((list) => list).contains(selectedAccount)) {
                                              //   if (categorizedDataCopy['Other'] == null) {
                                              //     categorizedDataCopy['Other'] = [];
                                              //   }
                                              //   categorizedDataCopy['Other']!.add(selectedAccount);
                                              // }
                                              print(
                                                  "categoriezed Data ${categorizedDataCopy}");
                                              print(row);
                                              if (row['charge_type'] ==
                                                  "Rent") {}
                                              List<String> liabilityAccounts = [
                                                "Late Fee Income",
                                                "Pre-payments",
                                                "Security Deposit",
                                                'Rent Income'
                                              ];
                                              print(
                                                  "${row['account']}_${row['charge_type']}");
                                              print(categorizedDataCopy.values
                                                  .expand((v) => v)
                                                  .contains(row['account']));
                                              print(categorizedDataCopy.values);
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  DropdownButton2<String>(
                                                    isExpanded: true,
                                                    //value: liabilityAccounts.contains(row['account']) ? "${row['account']}_Liability Account" : "${row['account']}_${row['charge_type']}",
                                                    // value: liabilityAccounts
                                                    //         .contains(
                                                    //             row['account'])
                                                    //     ? "${row['account']}_Liability Account"
                                                    //     : liabilityAccounts
                                                    //             .contains(row[
                                                    //                 'account'])
                                                    //         ? ""
                                                    //         : "${row['account']}_${row['charge_type']}",
                                                    value: (row['account'] == null ||
                                                            row['account']
                                                                .isEmpty ||
                                                            row['charge_type'] ==
                                                                null ||
                                                            row['charge_type']
                                                                .isEmpty)
                                                        ? null // Default value that is part of the items
                                                        : "${row['account']}_${row['charge_type']}",
                                                    items: [
                                                      ...categorizedDataCopy
                                                          .entries
                                                          .expand((entry) {
                                                        return [
                                                          // DropdownMenuItem<
                                                          //     String>(
                                                          //   enabled: false,
                                                          //   child: Text(
                                                          //     entry.key,
                                                          //     style:
                                                          //     const TextStyle(
                                                          //       fontWeight:
                                                          //       FontWeight
                                                          //           .bold,
                                                          //       color: Color
                                                          //           .fromRGBO(
                                                          //           21,
                                                          //           43,
                                                          //           81,
                                                          //           1),
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          ...entry.value
                                                              .map((item) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value:
                                                                  "${item}_${entry.key}",
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            16.0),
                                                                child: Text(
                                                                  item,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ];
                                                      }).toList(),
                                                    ],
                                                    onChanged: (value) {
                                                      dynamic? chargeType;
                                                      for (var entry
                                                          in categorizedData
                                                              .entries) {
                                                        if (entry.value
                                                            .contains(value)) {
                                                          chargeType =
                                                              entry.key;
                                                          break;
                                                        }
                                                      }
                                                      setState(() {
                                                        final parts =
                                                            value!.split('_');
                                                        final chargeType =
                                                            parts[0];
                                                        final selectedValue =
                                                            parts
                                                                .sublist(1)
                                                                .join('_');
                                                        print(
                                                            "account chargetype ${selectedValue}   $value");
                                                        bool isDuplicate =
                                                            rows.any((row) =>
                                                                row['account'] ==
                                                                    chargeType &&
                                                                rows.indexOf(
                                                                        row) !=
                                                                    index);
                                                        print(
                                                            "Duplicate Entry $isDuplicate");
                                                        if (isDuplicate) {
                                                          validationMessage =
                                                              "**Each account must be unique";
                                                        }
                                                        rows[index]['account'] =
                                                            chargeType;
                                                        rows[index][
                                                                'charge_type'] =
                                                            selectedValue;

                                                        state.didChange(
                                                            value); // Update the FormField state
                                                      });
                                                      state.reset();
                                                    },
                                                    buttonStyleData:
                                                        ButtonStyleData(
                                                      height: 45,
                                                      // width: 220,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 0,
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
                                                      width: 250,
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
                                                    hint: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                          'Select an account'),
                                                    ),
                                                  ),
                                                  if (state
                                                      .hasError) // Display the validation error
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16.0,
                                                              top: 5.0),
                                                      child: Text(
                                                        state.errorText ?? '',
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
                                      ),
                                      const SizedBox(height: 12.0),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text("Amount *",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: CustomTextField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter amount';
                                            }
                                            return null;
                                          },
                                          amount_check: !rows[index]["newfield"]
                                              ? true
                                              : null,
                                          max_amount: rows[index]
                                                  ["charge_amount"]
                                              .toString(),
                                          error_mess:
                                              "Amount must be less than or equal to balance",
                                          keyboardType: TextInputType.number,
                                          hintText: 'Enter amount',
                                          controller: controllers[index],
                                          onChanged: (value) =>
                                              updateAmount(index, value),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text("Balance",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Material(
                                          elevation: 3,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFb0b6c3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                const Text("Balance :",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(width: 12.0),
                                                Text(
                                                    charges_balances[index]
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      const SizedBox(height: 5),
                      if (MediaQuery.of(context).size.width > 500)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Table(
                            border: TableBorder.all(width: 1),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Account',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Amount',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Balance',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          color: blueColor,
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
                              ...rows.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, dynamic> row = entry.value;
                                return TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        value: row['account'],
                                        items: [
                                          ...categorizedData.entries
                                              .expand((entry) {
                                            return [
                                              DropdownMenuItem<String>(
                                                enabled: false,
                                                child: Text(
                                                  entry.key,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor,
                                                  ),
                                                ),
                                              ),
                                              ...entry.value.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0),
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ];
                                          }).toList(),
                                        ],
                                        onChanged: (value) {
                                          dynamic? chargeType;
                                          for (var entry
                                              in categorizedData.entries) {
                                            if (entry.value.contains(value)) {
                                              chargeType = entry.key;
                                              break;
                                            }
                                          }
                                          print(value);
                                          setState(() {
                                            rows[index]['account'] = value;
                                            rows[index]['charge_type'] =
                                                chargeType;
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 45,
                                          width: 220,
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
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          iconEnabledColor: Color(0xFFb0b6c3),
                                          iconDisabledColor: Colors.grey,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          width: 250,
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
                                        hint:
                                            const Text('   Select an account'),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 8),
                                    child: CustomTextField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter amount';
                                        }
                                        return null;
                                      },
                                      amount_check: !rows[index]["newfield"]
                                          ? true
                                          : null,
                                      max_amount: rows[index]["charge_amount"]
                                          .toString(),
                                      error_mess:
                                          "Amount must be less than or equal to balance",
                                      keyboardType: TextInputType.number,
                                      hintText: 'Enter amount',
                                      controller: controllers[index],
                                      onChanged2: (value) =>
                                          updateAmount(index, value),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 8),
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFb0b6c3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const SizedBox(width: 12.0),
                                            Text(
                                                charges_balances[index]
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.black),
                                      onPressed: () {
                                        deleteRow(index);
                                      },
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      '\$${NumberFormat('#,##0.00', 'en_US').format(totalAmount)}'),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(''),
                                ),

                                /* Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(
                                    '\$${NumberFormat('#,##0.00', 'en_US').format(totalAmount)}'),
                                                              ),*/
                              ]),
                            ],
                          ),
                        ),
                      if (MediaQuery.of(context).size.width < 500)
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Total',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Text('\$${NumberFormat('#,##0.00', 'en_US').format(totalAmount)}'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 5),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              addRow();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: MediaQuery.of(context).size.width < 500
                                    ? 40
                                    : 50,
                                // width: MediaQuery.of(context).size.width * .36,
                                width: MediaQuery.of(context).size.width < 500
                                    ? 90
                                    : 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: blueColor,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const SpinKitFadingCircle(
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
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 17),
                                        ),
                                ),
                              ),
                            ),
                          ),
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
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
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
                              Text('Upload Files',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: blueColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 50,
                                width: 95,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blueColor,
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
                              //   //fit: FlexFit.loose,
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
                              //                 _uploadedFileNames
                              //                     .removeAt(index);
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
                                              _uploadedFileNames
                                                  .removeAt(index);
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
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    // border: Border.all(
                                    //   color: blueColor,
                                    // ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Column(
                                  children: [
                                    if (_selectedPaymentMethod == "Card" ||
                                        _selectedPaymentMethod == "ACH")
                                      buildAmountContainer(
                                          'Amount', _safeParseAmountText()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if (_selectedPaymentMethod == "Card")
                                      buildAmountContainer(
                                          'Surcharge included',
                                          double.parse((_safeParseAmountText() *
                                                  (surCharge ?? 0.0) /
                                                  100)
                                              .toStringAsFixed(2))),
                                    if (_selectedPaymentMethod == "ACH")
                                      buildAmountContainer('Surcharge included',
                                          surchargecount!),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildAmountContainer(
                                        'Total Amount',
                                        (_selectedPaymentMethod == "Card")
                                            ? double.parse(
                                                ((_safeParseAmountText() *
                                                            (surCharge ?? 0.0) /
                                                            100) +
                                                        _safeParseAmountText())
                                                    .toStringAsFixed(2))
                                            : (_selectedPaymentMethod == "ACH")
                                                ? (finaltotal ?? 0.0)
                                                : _safeParseAmountText()),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width < 500 ? 18 : 35,
                  right: 16,
                  bottom: 10,
                  top: 20),
              child: Row(
                children: [
                  Container(
                      height: 45,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0))),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? id = prefs.getString('adminId');
                            if ((_formKey.currentState?.validate() ?? false) &&
                                validationMessage == null &&
                                _amountLimitError == null) {
                              if ((double.tryParse(amountController.text) ??
                                      0.0) <=
                                  0) {
                                Fluttertoast.showToast(
                                    msg: "Please enter a valid amount");
                                return;
                              }
                              rows = rows
                                  .asMap()
                                  .map((index, entry) {
                                    return MapEntry(
                                      index,
                                      {
                                        ...entry,
                                        'date': reverseFormatDate(_startDate
                                            .text
                                            .trim()),
                                        'balance': entry['amount'] ?? 0.0,
                                      },
                                    );
                                  })
                                  .values
                                  .toList();
                              setState(() {
                                _isLoading = true;
                              });
                              if (_selectedPaymentMethod == null) {
                                Fluttertoast.showToast(
                                    msg: "Please select the payment method");
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (_selectedPaymentMethod == "Card") {
                                print("adminId ${id}");
                                if (selectedcardindex == null ||
                                    selectedcardindex! < 0 ||
                                    selectedcardindex! >= cardDetails.length) {
                                  Fluttertoast.showToast(
                                      msg: "Please select a card");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }

                                final selectedBilling =
                                    cardDetails[selectedcardindex!];
                                print("adminId ${selectedBilling.company}");
                                if (processor_id == "zzz") {
                                  showFailedPaymentAlert(context);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } else {
                                  List<Map<String, String>> filteredTenants =
                                      tenants.where((tenant) {
                                    return tenant['tenant_id'] ==
                                        selectedTenantId;
                                  }).toList();
                                  Map<String, String> selectedTenant =
                                      filteredTenants.first;
                                  final DateFormat formatter =
                                      DateFormat('yyyy-MM-dd HH:mm:ss');
                                  String notificationTime =
                                      formatter.format(DateTime.now());
                                  await PaymentService()
                                      .makePaymentforcard(
                                    adminId: id ?? "",
                                    firstName: selectedTenant["first_name"]!,
                                    lastName: selectedTenant["last_name"]!,
                                    emailName: selectedTenant["email"]!,
                                    customerVaultId:
                                        selectedBilling.customerVaultId ?? "",
                                    billingId: selectedBilling.billingId ?? "",
                                    surcharge:
                                        "${(_safeParseAmountText() * (surCharge ?? 0.0) / 100).toStringAsFixed(2)}",
                                    amount:
                                        "${_safeParseAmountText()}",
                                    tenantId: selectedTenantId!,
                                    date: reverseFormatDate(_startDate.text.trim()),
                                    address1: selectedBilling.address_1 ?? "",
                                    processorId: processor_id,
                                    leaseid: widget.leaseId,
                                    company_name: companyName,
                                    entries: rows,
                                    tenantname: tenantname,
                                    future_Date: futuredate!,
                                    uploadedFile: _uploadedFileNames,
                                    notificationTime: notificationTime,
                                  )
                                      .then((value) {
                                    Fluttertoast.showToast(msg: "$value");
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (isChecked) {
                                      resetFields();
                                    } else {
                                      Navigator.pop(context, true);
                                    }
                                  }).catchError((e) {
                                    print(e
                                        .toString()
                                        .split("Exception")[1]
                                        .toString()
                                        .trimLeft());
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Alert(
                                      context: context,
                                      type: AlertType.warning,
                                      title: "Payment Failed!",
                                      desc:
                                          "${e.toString().split('Exception:')[1].toString().trimLeft()}",
                                      style: const AlertStyle(
                                        backgroundColor: Colors.white,
                                        //  overlayColor: Colors.black.withOpacity(.8)
                                      ),
                                      buttons: [
                                        DialogButton(
                                          child: const Text(
                                            "Ok",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          color: blueColor,
                                        ),
                                      ],
                                    ).show();
                                  });
                                }
                              } else if (_selectedPaymentMethod == "ACH") {
                                if (achAccounts.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Please add an ACH account first (Add a New ACH Account).");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }
                                if (selectedAchIndex == null) {
                                  Fluttertoast.showToast(
                                      msg: "Please select an ACH account");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }
                                List<Map<String, String>> filteredTenants =
                                    tenants.where((tenant) {
                                  return tenant['tenant_id'] ==
                                      selectedTenantId;
                                }).toList();
                                Map<String, String> selectedTenant =
                                    filteredTenants.first;
                                final DateFormat formatter =
                                    DateFormat('yyyy-MM-dd HH:mm:ss');
                                String notificationTime =
                                    formatter.format(DateTime.now());
                                final double achPrincipal = _achPrincipalForSale();
                                final Map<String, dynamic> vaultAch =
                                    achAccounts[selectedAchIndex!];
                                await PaymentService()
                                    .makePaymentforach(
                                  adminId: id ?? "",
                                  firstName: selectedTenant["first_name"]!,
                                  lastName: selectedTenant["last_name"]!,
                                  emailName: selectedTenant["email"]!,
                                  surcharge: "${surchargecount ?? 0}",
                                  amount: "${achPrincipal}",
                                  tenantId: selectedTenantId!,
                                  date: reverseFormatDate(_startDate.text.trim()),
                                  address1: "",
                                  processorId: processor_id,
                                  leaseid: widget.leaseId,
                                  company_name: companyName,
                                  entries: rows,
                                  future_Date: futuredate!,
                                  account_type: (vaultAch['account_type']
                                                  ?.toString() ??
                                              '')
                                          .trim()
                                          .isNotEmpty
                                      ? vaultAch['account_type'].toString()
                                      : "Checking",
                                  account_holder_type: (vaultAch[
                                                      'account_holder_type']
                                                  ?.toString() ??
                                              '')
                                          .trim()
                                          .isNotEmpty
                                      ? vaultAch['account_holder_type']
                                          .toString()
                                      : "Personal",
                                  checkaccount:
                                      vaultAch['account_number']?.toString() ??
                                          '',
                                  checkaba:
                                      vaultAch['routing_number']?.toString() ??
                                          '',
                                  tenantname: tenantname,
                                  checkname: vaultAch['account_name']
                                          ?.toString() ??
                                      vaultAch['account_holder_name']
                                          ?.toString() ??
                                      '',
                                  billingId:
                                      vaultAch['billing_id']?.toString(),
                                  customerVaultId: customervaultid?.toString(),
                                  uploadedFile: _uploadedFileNames,
                                  notificationTime: notificationTime,
                                )
                                    .then((value) {
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (isChecked) {
                                    resetFields();
                                  } else {
                                    Navigator.pop(context, true);
                                  }
                                }).catchError((e) {
                                  print(e
                                      .toString()
                                      .split("Exception")[1]
                                      .toString()
                                      .trimLeft());
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Alert(
                                    context: context,
                                    type: AlertType.warning,
                                    title: "Payment Failed!",
                                    desc:
                                        "${e.toString().split('Exception:')[1].toString().trimLeft()}",
                                    style: const AlertStyle(
                                      backgroundColor: Colors.white,
                                      //  overlayColor: Colors.black.withOpacity(.8)
                                    ),
                                    buttons: [
                                      DialogButton(
                                        child: const Text(
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
                                });
                              } else if (_selectedPaymentMethod == "Check" ||
                                  _selectedPaymentMethod == "Money Order" ||
                                  _selectedPaymentMethod ==
                                      "Cashier 's Check") {
                                List<Map<String, String>> filteredTenants =
                                    tenants.where((tenant) {
                                  return tenant['tenant_id'] ==
                                      selectedTenantId;
                                }).toList();
                                // Map<String, String> selectedTenant =
                                //     filteredTenants.first;
                                Map<String, String>? selectedTenant =
                                    filteredTenants.isNotEmpty
                                        ? filteredTenants.first
                                        : null;
                                final DateFormat formatter =
                                    DateFormat('yyyy-MM-dd HH:mm:ss');
                                String notificationTime =
                                    formatter.format(DateTime.now());
                                await PaymentService()
                                    .makePaymentfornormal(
                                  adminId: id ?? "",
                                  firstName:
                                      selectedTenant?["first_name"] ?? "",
                                  lastName: selectedTenant?["last_name"] ?? "",
                                  emailName: selectedTenant?["email"] ?? "",
                                  surcharge: "0",
                                  amount:
                                      "${_safeParseAmountText()}",
                                  tenantId: selectedTenant != null
                                      ? selectedTenantId!
                                      : "",
                                  date: reverseFormatDate(_startDate.text.trim()),
                                  address1: "",
                                  processorId: "",
                                  leaseid: widget.leaseId,
                                  company_name: companyName,
                                  entries: rows,
                                  future_Date: true,
                                  Check_number: checknumber.text.trim(),
                                  Check: true,
                                  uploadedFile: _uploadedFileNames,
                                  payment_method: _selectedPaymentMethod!,
                                  notificationTime: notificationTime,
                                )
                                    .then((value) {
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (isChecked) {
                                    resetFields();
                                  } else {
                                    Navigator.pop(context, true);
                                  }
                                }).catchError((e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Payment failed $e");
                                });
                              } else if (_selectedPaymentMethod == "Cash" ||
                                  _selectedPaymentMethod == "Manual") {
                                List<Map<String, String>> filteredTenants =
                                    tenants.where((tenant) {
                                  return tenant['tenant_id'] ==
                                      selectedTenantId;
                                }).toList();
                                // Map<String, String> selectedTenant =
                                //     filteredTenants.first;
                                Map<String, String>? selectedTenant =
                                    filteredTenants.isNotEmpty
                                        ? filteredTenants.first
                                        : null;
                                final DateFormat formatter =
                                    DateFormat('yyyy-MM-dd HH:mm:ss');
                                String notificationTime =
                                    formatter.format(DateTime.now());
                                await PaymentService()
                                    .makePaymentfornormal(
                                        adminId: id ?? "",
                                        firstName:
                                            selectedTenant?["first_name"] ?? "",
                                        lastName:
                                            selectedTenant?["last_name"] ?? "",
                                        emailName:
                                            selectedTenant?["email"] ?? "",
                                        surcharge: "0",
                                        amount:
                                            "${_safeParseAmountText()}",
                                        tenantId: selectedTenant != null
                                            ? selectedTenantId!
                                            : "",
                                        date: reverseFormatDate(_startDate.text.trim()),
                                        address1: "",
                                        processorId: "",
                                        leaseid: widget.leaseId,
                                        company_name: companyName,
                                        entries: rows,
                                        future_Date: true,
                                        Check_number: "",
                                        payment_method: _selectedPaymentMethod!,
                                        Check: false,
                                        uploadedFile: _uploadedFileNames,
                                        notificationTime: notificationTime)
                                    .then((value) {
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (isChecked) {
                                    resetFields();
                                  } else {
                                    Navigator.pop(context, true);
                                  }
                                }).catchError((e) {
                                  print(e);
                                  Fluttertoast.showToast(msg: e);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Payment failed $e");
                                });
                              }

                              //print(_selectedPaymentMethod);
                            }
                            /* print(cardDetails[selectedcardindex!].ccNumber);
                              print(cardDetails[selectedcardindex!].firstName);
                              print(cardDetails[selectedcardindex!].lastName);
                              // print(cardDetails[selectedcardindex!].b);
                              print(cardDetails[selectedcardindex!].company);
                              print(cardDetails[selectedcardindex!].address_1);
                              print(cardDetails[selectedcardindex!].email);*/
                          },
                          child: _isLoading
                              ? const Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 50.0,
                                  ),
                                )
                              : const Text(
                                  'Make Payment',
                                  style: TextStyle(
                                      color: Color(0xFFf7f8f9),
                                      fontWeight: FontWeight.bold),
                                ))),
                  const SizedBox(
                    width: 8,
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
                                  borderRadius: BorderRadius.circular(8.0))),
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
                            style: TextStyle(
                                color: Color(0xFF748097),
                                fontWeight: FontWeight.bold),
                          ))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 18),
                SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                    activeColor: isChecked ? blueColor : Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "Make Another Payment",
                  style:
                      TextStyle(color: blueColor, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAmountContainer(String label, double amount) {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
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
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(21, 43, 83, 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _safeParseAmountText() {
    final raw = amountController.text.trim().replaceAll(',', '');
    return double.tryParse(raw) ?? 0.0;
  }

  /// Principal subtotal for ACH_sale (matches web `paymentDetails.amount` and entry amounts).
  /// Do not pass [finaltotal] here: the gateway applies surcharge on top of `amount`.
  double _achPrincipalForSale() {
    double sum = 0.0;
    for (final r in rows) {
      final v = r['amount'];
      if (v is num) {
        sum += v.toDouble();
      } else {
        sum += double.tryParse(v?.toString() ?? '') ?? 0.0;
      }
    }
    if (sum > 0) return sum;
    return _safeParseAmountText();
  }

  surge_count() {
    final amount = _safeParseAmountText();
    if (_selectedPaymentMethod == "ACH") {
      final double achPercent =
          num.tryParse(surChargeAchper?.toString() ?? '')?.toDouble() ?? 0.0;
      final double achFlat =
          num.tryParse(surChargeAchflat?.toString() ?? '')?.toDouble() ?? 0.0;
      // Recompute from scratch each time so a prior fee can never linger when
      // the amount is cleared or the ACH config has no fee (matches web reset).
      double surcharge = 0.0;
      if (amount > 0) {
        if (achPercent > 0) surcharge += amount * achPercent / 100;
        if (achFlat > 0) surcharge += achFlat;
      }
      setState(() {
        surchargecount = double.parse(surcharge.toStringAsFixed(2));
        finaltotal = double.parse((amount + surcharge).toStringAsFixed(2));
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.only(left: 10),
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
    if (ccType.trim().isEmpty) {
      return const Icon(
        Icons.credit_card,
        color: Colors.white,
        size: 30,
      );
    }
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

  // Display-only: resolves the card network brand for the Card Type column.
  // Prefers the processor cc_type, then infers from the card number's first
  // digit. Does not read or change binResult, so surcharge and card-acceptance
  // logic remain unaffected.
  String _resolveCardBrandLabel(String? ccType, String? ccNumber) {
    final String raw = (ccType ?? '').trim().toLowerCase();
    if (raw.contains('american express') || raw.contains('amex')) return 'Amex';
    if (raw.contains('mastercard') || raw.contains('master card'))
      return 'Mastercard';
    if (raw.contains('visa')) return 'Visa';
    if (raw.contains('discover')) return 'Discover';
    if (raw.contains('jcb')) return 'JCB';
    if (raw.contains('diners')) return 'Diners';

    final String digits = (ccNumber ?? '').replaceAll(RegExp(r'\D'), '');
    final String first = digits.isNotEmpty ? digits[0] : '';
    if (first == '3') return 'Amex';
    if (first == '4') return 'Visa';
    if (first == '5') return 'Mastercard';
    if (first == '6') return 'Discover';
    return '';
  }
}
