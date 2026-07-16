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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

import 'package:three_zero_two_property/repository/lease.dart';

import '../../../../model/LeaseLedgerModel.dart';
import '../../../repository/payment/Edit_payment.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

import '../../../model/EnterChargeModel.dart';
import '../../../../model/payments/fetch_payment_table.dart';
import '../../../../model/setting.dart';
import '../../../../provider/Plan Purchase/plancheckProvider.dart';
import '../../../repository/payment/charge_responce.dart';

import '../../../repository/setting.dart';
import '../../../repository/tenants.dart';
import 'addcard/AddCard.dart';
import 'addcard/CardModel.dart';
import '../../../widgets/custom_drawer.dart';

class EditMakePayment extends StatefulWidget {
  final String leaseId;
  final String tenantId;
  bool? isEdit;
  Data? data;

  EditMakePayment(
      {required this.leaseId, required this.tenantId, this.isEdit, this.data});

  @override
  State<EditMakePayment> createState() => _EditMakePaymentState();
}

class _EditMakePaymentState extends State<EditMakePayment> {
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
  bool hasError = false;
  double chargeAmount = 0.0;
  double surchargeIncluded = 0.0;
  double totalAmount = 0.0;
  int? selectedcardindex;
  bool? futuredate;
  Setting1? surcharges;
  double? surchargecount = 0.0;
  double? finaltotal;
  String tenantname = "";
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
    super.initState();
    fetchDropdownData();

    fetchTenants();
    fetchCompany();

    fetchSurcharge();
    //totalAmount = chargeAmount + surchargeIncluded;
    // amountController.addListener(_updateTotalAmount);
  }

  void _updateTotalAmount() {
    setState(() {
      totalAmount = chargeAmount + surchargeIncluded;
    });
  }

  editpayment() {
    if (widget.data == null) return;
    try {
    Data c_data = widget.data!;
    setState(() {
      selectedTenantId = widget.tenantId;
      tenantname =
          "${(c_data.tenantData ?? {})["tenant_firstName"]} ${(c_data.tenantData ?? {})["tenant_lastName"]}";
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      if ((c_data.entry?.isNotEmpty ?? false) &&
          c_data.entry!.first.date != null) {
        _startDate.text = dateProvider
            .formatCurrentDate(formatDate(c_data.entry!.first.date!));
      }
      amountController.text = c_data.totalAmount.toString();
      _selectedPaymentMethod = c_data.paymenttype;
      customerVaultId = c_data.customer_vault_id ?? "";
      billingId = c_data.billing_id ?? "";
      if ((c_data.entry?.isNotEmpty ?? false) &&
          (c_data.entry!.first.memo?.isNotEmpty ?? false)) {
        Memo.text = c_data.entry!.first.memo!;
      }
      if (_selectedPaymentMethod != "Cash")
        checknumber.text = c_data!.check_number ?? "";
      reference.text = c_data!.reference ?? "";

      print('charge details ${charges!.length}');
      rows = c_data.entry?.map((entry) {
            String? chargeType = (entry.account == "Late Fee Income" ||
                    entry.account == "Pre-payments" ||
                    entry.account == "Security Deposit")
                ? entry.account
                : entry.account == "Rent Income"
                    ? "Rent"
                    : categorizedData.entries
                        .firstWhere(
                          (entryData) =>
                              entryData.value.contains(entry.account),
                          orElse: () {
                            String fallbackType =
                                entry.chargeType ?? "One Time Charge";
                            if (entry.account != null) {
                              categorizedData[fallbackType] ??= [];
                              if (!categorizedData[fallbackType]!
                                  .contains(entry.account)) {
                                categorizedData[fallbackType]!
                                    .add(entry.account!);
                              }
                            }
                            return MapEntry(fallbackType, []);
                          },
                        )
                        .key;
            print(chargeType);
            return {
              'entry_id': entry.entryId,
              'account': entry.account,
              'amount': entry.amount,
              'charge_amount': entry.amount,
              'memo': entry.memo,
              'date': entry.date,
              'charge_type': chargeType,
              'sub_charge_type': entry.chargeType,
              'newfield': false,
            };
          }).toList() ??
          [];
      for (var i = 0; i < (c_data.entry ?? []).length; i++) {
        if (i == 0) {
          charges_balances[0] = (c_data.entry![i].amount ?? 0).toDouble();
        } else {
          charges_balances.add((c_data.entry![i].amount ?? 0).toDouble());
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
    } catch (e) {
      print('editpayment prefill failed: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String processor_id = "";
  List<Map<String, String>> tenants = [];
  String? selectedTenantId;
  List<TextEditingController> controllers = [];
  List<BillingData> cardDetails = [];

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? staffId = prefs.getString("staff_id");
    final response = await apiGet(
      Uri.parse('$Api_url/api/leases/lease_tenant/${widget.leaseId}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffId",
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
        processor_id = data["processor_id"] ?? "";
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
        final value = tenant['enableoverridefee'];
        return value == 'true' || value == '1';
      }
    }
    return false;
  }

  Future<void> fetchDropdownData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String adminId = prefs.getString('adminId') ?? '';
      String? token = prefs.getString('token');
      String? staffId = prefs.getString("staff_id");
      // print(token); // removed: do not log auth token
      print('lease ${widget.leaseId}');
      final response = await apiGet(
        Uri.parse('$Api_url/api/accounts/accounts/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $staffId",
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
          String chargeType = item['charge_type'] ?? 'One Time Charge';
          String account = item['account'] ?? '';
          if (account.isEmpty) continue;

          if (!fetchedData.containsKey(chargeType)) {
            fetchedData[chargeType] = [];
          }
          if (!fetchedData[chargeType]!.contains(account)) {
            fetchedData[chargeType]!.add(account);
          }
        }
        setState(() {
          categorizedData = fetchedData;
          isLoading = false;
        });
        if (widget.isEdit == true && widget.data != null) editpayment();
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        if (widget.isEdit == true && widget.data != null) editpayment();
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      if (widget.isEdit == true && widget.data != null) editpayment();
    }
  }

  List<Map<String, dynamic>> rows = [];

  List<double> charges_balances = [0.0];

  void validateAmounts() {
    double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
    double roundedEntered =
        double.parse(enteredAmount.toStringAsFixed(2));
    double roundedTotal = double.parse(totalAmount.toStringAsFixed(2));

    if (roundedEntered != roundedTotal) {
      setState(() {
        validationMessage =
            "The charge's amount must match the total applied to balance. The difference is ${(roundedEntered - roundedTotal).abs().toStringAsFixed(2)}";
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
  final List<String> _paymentMethods = [
    'Card',
    'Check',
    'Cash',
    'ACH',
    'Cashier \'s Check',
    'Money Order',
    'Manual'
  ];
  final List<String> _paymentMethodsforfree = ['Check', 'Cash'];
  final List<String> _selecttype = ['Checking', 'Savings'];
  final List<String> _selectholder = ['Business', 'Personal'];
  bool showCardNumberField = false;
  bool showCheckNumberField = false;
  bool showACHFields = false;
  bool showCashiersFields = false;
  bool showMoneyorderFields = false;
  bool showMenualFields = false;
  int? customervaultid;
  String customerVaultId = "";
  String billingId = "";

  void AddFields() {
    print("selected method $_selectedPaymentMethod");
    setState(() {
      showCardNumberField = _selectedPaymentMethod == 'Card';
      showCheckNumberField = _selectedPaymentMethod == 'Check';
      showACHFields = _selectedPaymentMethod == 'ACH';
      showCashiersFields = _selectedPaymentMethod == 'Cashier \'s Check';
      showMoneyorderFields = _selectedPaymentMethod == 'Money Order';
      showMenualFields = _selectedPaymentMethod == 'Manual';
    });
  }

  TextEditingController checknumber = TextEditingController();
  TextEditingController reference = TextEditingController();
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

//for payment
//   Future<void> fetchChargesForSelectedTenant(String tenantId) async {
//     setState(() {
//       isLoading = true;
//       hasError = false;
//     });
//     try {
//       List<Entrycharge>? charges =
//           await ChargeRepositorys().fetchChargesTable(widget.leaseId);
//       print('charge details ${charges!.length}');
//       List<Entrycharge> filteredCharges =
//           charges?.where((entry) => entry.chargeAmount! > 0).toList() ?? [];
//       print("charges length:- ${charges!.length}");
//       print('leaseid ${widget.leaseId}');
//
//       print('tenantid '
//           '$tenantId');
//
//       setState(() {
//         rows = charges?.where((entry) => entry.chargeAmount! > 0).map((entry) {
//               return {
//                 'entry_id': entry.entryId,
//                 'account': entry.account,
//                 'amount': 0.0,
//                 'charge_amount': entry.chargeAmount,
//                 'memo': entry.memo,
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
//         print("rows length:- ${rows!.length}");
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
                      : categorizedData.entries
                          .firstWhere(
                            (entryData) =>
                                entryData.value.contains(entry.account),
                            orElse: () => const MapEntry(
                                "Unknown", []), // Default if not found
                          )
                          .key;
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
        'memo': Memo.text,
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
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    setState(() {
      isLoading = true;
      cardDetails = []; // Clear previous card details
    });

    final response = await apiGet(
      Uri.parse('$Api_url/api/creditcard/getCreditCards/$tenantId'),
      headers: {"id": "CRM $staffId", "authorization": "CRM $token"},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      customervaultid = jsonResponse['customer_vault_id'];
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
    });
  }

  Future<CustomerData?> postBillingCustomerVault(
      String customerVaultId, List<dynamic> cardDetailsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": adminId.toString(),
    };

    final response = await apiPost(
      Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
      headers: {
        'Content-Type': 'application/json',
        "id": "CRM $staffId",
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
      for (int i = 0; i < customerData.billing.length; i++) {
        if (i < cardDetailsList.length) {
          customerData.billing[i].binResult = cardDetailsList[i]["card_type"];
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
    String? staffId = prefs.getString('staff_id');
    String? token = prefs.getString('token');
    print(adminId);

    final response = await apiGet(
      Uri.parse('$Api_url/api/surcharge/surcharge/getadmin/$adminId'),
      headers: {
        "id": "CRM $staffId",
        "authorization": "CRM $token",
      },
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      var jsonResponse = jsonDecode(response.body);

      // Accessing the first element in the 'data' list
      final dataList = jsonResponse['data'];
      if (dataList is! List || dataList.isEmpty) {
        setState(() {
          surCharge = 0.0;
        });
        return;
      }
      var surchargeData = dataList[0];
      if (_selectedPaymentMethod == "Card") {
        if (selectedcardindex == null ||
            selectedcardindex! < 0 ||
            selectedcardindex! >= cardDetails.length) {
          setState(() {
            surCharge = 0.0;
          });
          return;
        }
        final String binResult = cardDetails[selectedcardindex!].binResult ?? '';
        if (binResult == "CREDIT") {
          // CREDIT always uses surcharge_percent and never consults override_fee.
          setState(() {
            surCharge =
                num.tryParse('${surchargeData['surcharge_percent']}')?.toDouble() ??
                    0.0;
          });
        } else if (binResult == "DEBIT") {
          setState(() {
            String? overrideFee = getOverrideFee(selectedTenantId!);
            bool enableOverrideFee = getEnableOverrideFee(selectedTenantId!);
            print("overrideFee   ${overrideFee}");
            double debitPercent =
                num.tryParse('${surchargeData['surcharge_percent_debit']}')
                        ?.toDouble() ??
                    0.0;
            if (enableOverrideFee &&
                overrideFee != null &&
                overrideFee != "null" &&
                overrideFee.trim().isNotEmpty) {
              // override_fee is treated as a PERCENTAGE on debit.
              surCharge = double.tryParse(overrideFee) ?? debitPercent;
            } else {
              surCharge = debitPercent;
            }
          });
        } else {
          // Any card type that is neither CREDIT nor DEBIT => 0% surcharge.
          setState(() {
            surCharge = 0.0;
          });
        }
      }

      setState(() {
        surChargeAchper = surchargeData['surcharge_percent_ACH'];
        surChargeAchflat = surchargeData['surcharge_flat_ACH'];
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
                  padding: const EdgeInsets.only(top: 10, left: 10),
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
                  child: const Text(
                    "Make Payment",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
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
                    left: MediaQuery.of(context).size.width < 500 ? 16 : 35,
                    right: MediaQuery.of(context).size.width < 500 ? 16 : 35),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFCED4DA),
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
                                          hint: const Text('Select Tenant',
                                              style: TextStyle(fontSize: 13, color: Color(0xFFb0b6c3))),
                                          value: selectedTenantId,
                                          items: tenants.map((tenant) {
                                            return DropdownMenuItem<String>(
                                              value: tenant['tenant_id'],
                                              child:
                                                  Text(tenant['tenant_name']!),
                                            );
                                          }).toList(),
                                          // onChanged: (value) async {
                                          //   state.didChange(value);
                                          //   setState(() {
                                          //     selectedTenantId = value;
                                          //     tenantname = tenants.firstWhere(
                                          //         (tenant) =>
                                          //             tenant['tenant_id'] ==
                                          //             value)['tenant_name']!;
                                          //     fetchChargesForSelectedTenant(
                                          //         value!);
                                          //   });
                                          //   state.reset();
                                          //   await fetchcreditcard(value!);
                                          //   print(
                                          //       'Selected tenant_id: $selectedTenantId');
                                          // },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
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
                                            iconDisabledColor: Color(0xFFb0b6c3),
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
                                                        'Select Tenant',
                                                        style: TextStyle(fontSize: 13, color: Color(0xFFb0b6c3))),
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
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 2,
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
                                                          Color(0xFFb0b6c3),
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
                                          Text('Date *',
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
                                                  _startDate.text =
                                                      formattedDate;
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
                                            hintText: 'YYYY-MM-DD',
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
                                final parsed = double.tryParse(value.trim());
                                if (parsed == null || parsed <= 0) {
                                  return 'Please enter a valid amount';
                                }
                                return null;
                              },
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              hintText: 'Enter amount',
                              controller: amountController,
                              onChanged: (value) => validateAmounts(),
                              readOnnly: true,
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
                                  hint: const Text('Select Method',
                                    style: TextStyle(fontSize: 13, color: Color(0xFFb0b6c3))),
                                  value: _selectedPaymentMethod,
                                  items: _paymentMethodsforfree.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                  // onChanged: (String? newValue) {
                                  //   // setState(() {
                                  //   //   _selectedPaymentMethod = newValue;
                                  //   //   //_selectedPaymentMethod = addRow();
                                  //   //   if(_selectedPaymentMethod == 'Card')
                                  //   //   addRow();
                                  //   //   if(_selectedPaymentMethod == 'Check')
                                  //   //    Text("hello");
                                  //   //
                                  //   // });
                                  //   setState(() {
                                  //     _selectedPaymentMethod = newValue;
                                  //     AddFields();
                                  //   });
                                  //   print(_selectedPaymentMethod == "Card");
                                  //   print(
                                  //       'Selected payment method: $_selectedPaymentMethod');
                                  //   surge_count();
                                  // },
                                  buttonStyleData: ButtonStyleData(
                                    height:
                                        MediaQuery.of(context).size.width < 500
                                            ? 46
                                            : 55,
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
                                    iconDisabledColor: Color(0xFFb0b6c3),
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
                                  if (!_paymentMethods
                                      .contains(_selectedPaymentMethod)) {
                                    _selectedPaymentMethod = null;
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: const Text('Select Method',
                                              style: TextStyle(fontSize: 13, color: Color(0xFFb0b6c3))),
                                          value: _selectedPaymentMethod,
                                          items: _paymentMethods.map((method) {
                                            return DropdownMenuItem<String>(
                                              value: method,
                                              child: Text(method),
                                            );
                                          }).toList(),
                                          // onChanged: (String? newValue) {
                                          //    // Update FormField state
                                          //   setState(() {
                                          //     _selectedPaymentMethod = newValue;
                                          //     state.didChange(
                                          //         newValue);
                                          //     AddFields(); // Call your method to add fields
                                          //   });
                                          //   state.reset();
                                          //   print(_selectedPaymentMethod ==
                                          //       "Card");
                                          //   print(
                                          //       'Selected payment method: $_selectedPaymentMethod');
                                          //   surge_count(); // Your method call
                                          // },
                                          buttonStyleData: ButtonStyleData(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 46
                                                : 55,
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
                                            iconDisabledColor: Color(0xFFb0b6c3),
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
                            const SizedBox(
                              height: 12,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text("Reference",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: blueColor)),
                            ),
                            const SizedBox(
                              height: 5,
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
                            if (showCardNumberField && widget.isEdit == null) ...[
                              const SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FormField<String>(validator: (value) {
                                  if (widget.isEdit == null &&
                                      (selectedcardindex == null ||
                                          _selectedPaymentMethod!.isEmpty)) {
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
                                                      'No Cards Avaiable')),
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
                                                  String month = item.ccExp!
                                                      .substring(0, 2);
                                                  String year = item.ccExp!
                                                      .substring(2, 4);
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
                                                              value:
                                                                  selectedcardindex ==
                                                                          index
                                                                      ? true
                                                                      : false,
                                                              onChanged: (bool?
                                                                  value) async {
                                                                setState(() {
                                                                  state.didChange(
                                                                      index
                                                                          .toString());
                                                                  selectedcardindex =
                                                                      index;
                                                                });
                                                                state.reset();
                                                                await fetchSurcharge();
                                                              },
                                                            ),
                                                    ),
                                                    DataCell(Text(
                                                      item.ccNumber!,
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
                                                        _buildLogosBlock(
                                                            item.ccType!),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          '${item.binResult} CARD',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
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
                                        child: Row(
                                          children: [
                                            if (surCharge != null)
                                              // ignore: unrelated_type_equality_checks
                                              Text(
                                                '${cardDetails[selectedcardindex!].binResult} card transactions will charge $surCharge%',
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
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
                                                  boxShadow: [
                                                    const BoxShadow(
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
                                padding: const EdgeInsets.all(4.0),
                                child: Text("Check Number",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: blueColor)),
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
                              const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text("Bank Routing Number"),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter routing number';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter routing number',
                                  controller: bankrountingnum,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text("Bank Account Number"),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter account number';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter account number',
                                  controller: accountnum,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (MediaQuery.of(context).size.width < 500)
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: DropdownButtonHideUnderline(
                                    child: FormField<String>(
                                      validator: (value) {
                                        if (selectedAccount == null ||
                                            selectedAccount!.isEmpty) {
                                          return 'Please select an account';
                                        }
                                        return null;
                                      },
                                      builder: (FormFieldState<String> state) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            DropdownButton2<String>(
                                              isExpanded: true,
                                              hint:
                                                  const Text('Select Account'),
                                              value: selectedAccount,
                                              items: _selecttype.map((method) {
                                                return DropdownMenuItem<String>(
                                                  value: method,
                                                  child: Text(method),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedAccount = newValue;
                                                });
                                                state.reset();
                                                print(
                                                    'Selected account: $selectedAccount ${selectedAccount == "Card"}');
                                              },
                                              buttonStyleData: ButtonStyleData(
                                                height: 45,
                                                padding: const EdgeInsets.only(
                                                    left: 2, right: 14),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                                                iconDisabledColor: Color(0xFFb0b6c3),
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
                                                height: 40,
                                                padding: EdgeInsets.only(
                                                    left: 14, right: 14),
                                              ),
                                            ),
                                            if (state.hasError)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 14, top: 5),
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
                                  ),
                                ),
                              if (MediaQuery.of(context).size.width > 500)
                                Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // First Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                hint: const Text(
                                                    'Select Account'),
                                                value: selectedAccount,
                                                items:
                                                    _selecttype.map((method) {
                                                  return DropdownMenuItem<
                                                      String>(
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
                                                    selectedAccount = newValue;
                                                  });
                                                  // print();
                                                  print(
                                                      'Selected payment method: $selectedAccount ${selectedAccount == "Card"}');
                                                },
                                                buttonStyleData:
                                                    ButtonStyleData(
                                                  height: 55,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 2, right: 14),
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
                                                      Color(0xFFb0b6c3),
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    // Second Column
                                    Expanded(
                                      child: Column(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              hint: const Text(
                                                  'Select Account Holder Type'),
                                              value: _selectedHoldertype,
                                              items:
                                                  _selectholder.map((method) {
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
                                                  _selectedHoldertype =
                                                      newValue;
                                                });
                                                print(
                                                    'Selected payment method: $_selectedHoldertype');
                                              },
                                              buttonStyleData: ButtonStyleData(
                                                height: 55,
                                                // width: 300,
                                                padding: const EdgeInsets.only(
                                                    left: 14, right: 14),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                                                iconDisabledColor: Color(0xFFb0b6c3),
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
                                                height: 40,
                                                padding: EdgeInsets.only(
                                                    left: 14, right: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text("Name of the ACH account"),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter account name';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter account name',
                                  controller: achname,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (MediaQuery.of(context).size.width < 500)
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: FormField<String>(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select an account holder type';
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
                                                  'Select Account Holder Type'),
                                              value: _selectedHoldertype,
                                              items: _selectholder
                                                  .map((holderType) {
                                                return DropdownMenuItem<String>(
                                                  value: holderType,
                                                  child: Text(holderType),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedHoldertype =
                                                      newValue;
                                                  state.didChange(
                                                      newValue); // Notify FormField of change
                                                });
                                                state.reset();
                                              },
                                              buttonStyleData: ButtonStyleData(
                                                height: 45,
                                                padding: const EdgeInsets.only(
                                                    left: 0, right: 14),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                elevation: 3,
                                              ),
                                              iconStyleData:
                                                  const IconStyleData(
                                                icon:
                                                    Icon(Icons.arrow_drop_down),
                                                iconSize: 24,
                                                iconEnabledColor:
                                                    Color(0xFFb0b6c3),
                                                iconDisabledColor: Color(0xFFb0b6c3),
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
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 10),
                            ],
                            if (showCashiersFields) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text("Check Number",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: blueColor)),
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
                                padding: const EdgeInsets.all(4.0),
                                child: Text("Check Number",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: blueColor)),
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
                                padding: const EdgeInsets.all(4.0),
                                child: Text("Check Number",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: blueColor)),
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
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text('Apply Payment to Balances',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
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
                                              if (selectedAccount != null &&
                                                  !categorizedData.values
                                                      .expand((list) => list)
                                                      .contains(
                                                          selectedAccount)) {
                                                if (categorizedDataCopy[
                                                        'Other'] ==
                                                    null) {
                                                  categorizedDataCopy['Other'] =
                                                      [];
                                                }
                                                categorizedDataCopy['Other']!
                                                    .add(selectedAccount);
                                              }
                                              for (final k in categorizedDataCopy
                                                  .keys
                                                  .toList()) {
                                                categorizedDataCopy[k] =
                                                    categorizedDataCopy[k]!
                                                        .toSet()
                                                        .toList();
                                              }
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
                                                    value: liabilityAccounts
                                                            .contains(
                                                                row['account'])
                                                        ? "${row['account']}_Liability Account"
                                                        : (row['account'] ==
                                                                    null ||
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
                                                        return entry.value
                                                            .map((item) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      "${item}_${entry.key}",
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            16.0),
                                                                    child: Text(
                                                                      item,
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight: FontWeight
                                                                              .w400),
                                                                    ),
                                                                  ),
                                                                ));
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
                                                          Color(0xFFb0b6c3),
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
                                        child: Text("Amount",
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
                                          hintText: 'Enter Amount',
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
                                              ...entry.value.map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .only(left: 16.0),
                                                      child: Text(
                                                        item,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
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
                                          iconDisabledColor: Color(0xFFb0b6c3),
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
                                        hint: const Text('Select an account'),
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
                                      hintText: 'Enter Amount',
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
                                  boxShadow: [
                                    const BoxShadow(
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
                                          'Amount',
                                          amountController.text.isNotEmpty
                                              ? (double.tryParse(
                                                  amountController.text) ?? 0.0)
                                              : 0.0),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if (_selectedPaymentMethod == "Card")
                                      buildAmountContainer(
                                          'Surcharge included',
                                          amountController.text.isNotEmpty
                                              ? double.parse((((double.tryParse(
                                                              amountController
                                                                  .text) ??
                                                          0.0) *
                                                      (surCharge ?? 0.0) /
                                                      100))
                                                  .toStringAsFixed(2))
                                              : 0.0),
                                    if (_selectedPaymentMethod == "ACH")
                                      buildAmountContainer('Surcharge included',
                                          surchargecount ?? 0.0),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildAmountContainer(
                                        'Total Amount',
                                        amountController.text.isNotEmpty &&
                                                (_selectedPaymentMethod ==
                                                    "Card")
                                            ? double.parse((((double.tryParse(
                                                                amountController
                                                                    .text) ??
                                                            0.0) *
                                                        (surCharge ?? 0.0) /
                                                        100) +
                                                    (double.tryParse(
                                                            amountController
                                                                .text) ??
                                                        0.0))
                                                .toStringAsFixed(2))
                                            : amountController
                                                        .text.isNotEmpty &&
                                                    (_selectedPaymentMethod ==
                                                        "ACH")
                                                ? (finaltotal ?? 0.0)
                                                : amountController
                                                        .text.isNotEmpty
                                                    ? (double.tryParse(
                                                            amountController
                                                                .text) ??
                                                        0.0)
                                                    : 0.0),
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
                  left: MediaQuery.of(context).size.width < 500 ? 16 : 35,
                  right: 16,
                  bottom: 10,
                  top: 10),
              child: Row(
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
                                  borderRadius: BorderRadius.circular(8.0))),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? id = prefs.getString('adminId');
                            if ((_formKey.currentState?.validate() ?? false) &&
                                validationMessage == null) {
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
                                            .trim()), // Set the date to the desired date
                                        'balance': double.parse(((entry['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)), // WEB: entry balance equals its own amount on edit
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
                              } else if (_selectedPaymentMethod == "Card" ||
                                  _selectedPaymentMethod == "ACH") {
                                await PaymentService()
                                    .storePaymentForEdit(
                                      companyName: companyName,
                                      adminId: id ?? "",
                                      tenantId: selectedTenantId!,
                                      tenantName: tenantname,
                                      leaseId: widget.leaseId,
                                      paymentId: widget.data!.paymentId ?? "",
                                      customerVaultId: customerVaultId,
                                      billingId: billingId,
                                      entries: rows!,
                                      totalAmount: (double.tryParse(amountController.text.trim()) ?? 0.0),
                                      uploadedFile: _uploadedFileNames,
                                      checkNumber: checknumber.text.trim(),
                                    )
                                    .then((value) {
                                  Fluttertoast.showToast(
                                      msg: "Payment Updated Successfully");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pop(context, true);
                                }).catchError((e) {
                                  print(e.toString());
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Alert(
                                    context: context,
                                    type: AlertType.warning,
                                    title: "Payment Failed!",
                                    desc: "${e.toString().split('Exception:').last.trimLeft()}",
                                    style: AlertStyle(
                                      backgroundColor: Colors.white,
                                    ),
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "Ok",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 18),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        color: blueColor,
                                      ),
                                    ],
                                  ).show();
                                });
                              }
                              /*  else if (_selectedPaymentMethod == "Card") {
                                print("adminId ${id}");
                                print("adminId ${cardDetails[selectedcardindex!].company}");
                                if (processor_id == "zzz") {
                                  showFailedPaymentAlert(context);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } else {
                                  List<Map<String, String>> filteredTenants = tenants.where((tenant) {
                                    return tenant['tenant_id'] == selectedTenantId;
                                  }).toList();
                                  Map<String, String> selectedTenant = filteredTenants.first;
                                  await PaymentService()
                                      .makePaymentforcard(
                                          adminId: id ?? "",
                                          firstName: selectedTenant["first_name"]!,
                                          lastName: selectedTenant["last_name"]!,
                                          emailName: selectedTenant["email"]!,
                                          customerVaultId: cardDetails[selectedcardindex!].customerVaultId!,
                                          billingId: cardDetails[selectedcardindex!].billingId!,
                                          surcharge: "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100)}",
                                          amount: "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100) + (double.tryParse(amountController.text.trim()) ?? 0.0)}",
                                          tenantId: selectedTenantId!,
                                          date: reverseFormatDate(_startDate.text.trim()),
                                          address1: cardDetails[selectedcardindex!].address_1!,
                                          processorId: "",
                                          leaseid: widget.leaseId,
                                          company_name: companyName,
                                          entries: rows,
                                          tenantname: tenantname,
                                          future_Date: futuredate!,
                                          uploadedFile: _uploadedFileNames)
                                      .then((value) {
                                    Fluttertoast.showToast(msg: "$value");
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.pop(context, true);
                                  }).catchError((e) {
                                    print(e.toString().split("Exception")[1].toString().trimLeft());
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Alert(
                                      context: context,
                                      type: AlertType.warning,
                                      title: "Payment Failed!",
                                      desc: "${e.toString().split('Exception:')[1].toString().trimLeft()}",
                                      style: AlertStyle(
                                        backgroundColor: Colors.white,
                                        //  overlayColor: Colors.black.withOpacity(.8)
                                      ),
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "Ok",
                                            style: TextStyle(color: Colors.white, fontSize: 18),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          color: blueColor,
                                        ),
                                      ],
                                    ).show();
                                  });
                                }
                              }
                              else if (_selectedPaymentMethod == "ACH") {
                                List<Map<String, String>> filteredTenants = tenants.where((tenant) {
                                  return tenant['tenant_id'] == selectedTenantId;
                                }).toList();
                                Map<String, String> selectedTenant = filteredTenants.first;
                                await PaymentService()
                                    .makePaymentforach(
                                        adminId: id ?? "",
                                        firstName: selectedTenant["first_name"]!,
                                        lastName: selectedTenant["last_name"]!,
                                        emailName: selectedTenant["email"]!,
                                        surcharge: "$surchargecount",
                                        amount: "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100) + (double.tryParse(amountController.text.trim()) ?? 0.0)}",
                                        tenantId: selectedTenantId!,
                                        date: reverseFormatDate(_startDate.text.trim()),
                                        address1: "",
                                        processorId: "",
                                        leaseid: widget.leaseId,
                                        company_name: companyName,
                                        entries: rows,
                                        future_Date: futuredate!,
                                        account_type: selectedAccount!,
                                        account_holder_type: _selectedHoldertype!,
                                        checkaccount: accountnum.text.trim(),
                                        checkaba: bankrountingnum.text.trim(),
                                        tenantname: tenantname,
                                        checkname: achname.text.trim(),
                                        uploadedFile: _uploadedFileNames)
                                    .then((value) {
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pop(context, true);
                                }).catchError((e) {
                                  print(e.toString().split("Exception")[1].toString().trimLeft());
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Alert(
                                    context: context,
                                    type: AlertType.warning,
                                    title: "Payment Failed!",
                                    desc: "${e.toString().split('Exception:')[1].toString().trimLeft()}",
                                    style: AlertStyle(
                                      backgroundColor: Colors.white,
                                      //  overlayColor: Colors.black.withOpacity(.8)
                                    ),
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "Ok",
                                          style: TextStyle(color: Colors.white, fontSize: 18),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        color: blueColor,
                                      ),
                                    ],
                                  ).show();
                                });
                              }*/
                              else if (_selectedPaymentMethod == "Check" ||
                                  _selectedPaymentMethod == "Money Order" ||
                                  _selectedPaymentMethod ==
                                      "Cashier 's Check") {
                                List<Map<String, String>> filteredTenants =
                                    tenants.where((tenant) {
                                  return tenant['tenant_id'] ==
                                      selectedTenantId;
                                }).toList();
                                if (filteredTenants.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "Tenant details not found");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }
                                Map<String, String> selectedTenant =
                                    filteredTenants.first;
                                await PaymentService()
                                    .makePaymentfornormal(
                                  adminId: id ?? "",
                                  firstName: selectedTenant["first_name"]!,
                                  lastName: selectedTenant["last_name"]!,
                                  emailName: selectedTenant["email"]!,
                                  surcharge:
                                      "${(0.0).toStringAsFixed(2)}", // WEB: no surcharge on edit for manual methods
                                  amount:
                                      "${(double.tryParse(amountController.text.trim()) ?? 0.0).toStringAsFixed(2)}", // WEB: base amount only, no surcharge fold
                                  tenantId: selectedTenantId!,
                                  date: reverseFormatDate(_startDate.text.trim()),
                                  address1: "",
                                  processorId: "",
                                  leaseid: widget.leaseId,
                                  company_name: companyName,
                                  entries: rows,
                                  future_Date: true,
                                  paymentId: widget.data?.paymentId ?? "",
                                  Check_number: checknumber.text.trim(),
                                  Check: true,
                                  uploadedFile: _uploadedFileNames,
                                  payment_method: _selectedPaymentMethod!,
                                )
                                    .then((value) {
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pop(context, true);
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
                                if (filteredTenants.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "Tenant details not found");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }
                                Map<String, String> selectedTenant =
                                    filteredTenants.first;
                                await PaymentService()
                                    .makePaymentfornormal(
                                  adminId: id ?? "",
                                  paymentId: widget.data?.paymentId ?? "",
                                  firstName: selectedTenant["first_name"]!,
                                  lastName: selectedTenant["last_name"]!,
                                  emailName: selectedTenant["email"]!,
                                  surcharge:
                                      "${(0.0).toStringAsFixed(2)}", // WEB: no surcharge on edit for manual methods
                                  amount:
                                      "${(double.tryParse(amountController.text.trim()) ?? 0.0).toStringAsFixed(2)}", // WEB: base amount only, no surcharge fold
                                  tenantId: selectedTenantId!,
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
                                )
                                    .then((value) {
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pop(context, true);
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
                            // SharedPreferences prefs =
                            //     await SharedPreferences.getInstance();
                            // String? id = prefs.getString('adminId');
                            // if ((_formKey.currentState?.validate() ?? false) &&
                            //     validationMessage == null) {
                            //   rows = rows
                            //       .asMap()
                            //       .map((index, entry) {
                            //         return MapEntry(
                            //           index,
                            //           {
                            //             ...entry,
                            //             'date': reverseFormatDate(_startDate
                            //                 .text.trim()), // Set the date to the desired date
                            //             'balance': charges_balances[
                            //                 index], // Add balance from charges_balances list
                            //           },
                            //         );
                            //       })
                            //       .values
                            //       .toList();
                            //   setState(() {
                            //     _isLoading = true;
                            //   });
                            //   if (_selectedPaymentMethod == null) {
                            //     Fluttertoast.showToast(
                            //         msg: "Please select the payment method");
                            //     setState(() {
                            //       _isLoading = false;
                            //     });
                            //   } else if (_selectedPaymentMethod == "Card") {
                            //     print("adminId ${id}");
                            //     print(
                            //         "adminId ${cardDetails[selectedcardindex!].company}");
                            //     if (processor_id == "zzz") {
                            //       showFailedPaymentAlert(context);
                            //       setState(() {
                            //         _isLoading = false;
                            //       });
                            //     } else {
                            //       List<Map<String, String>> filteredTenants =
                            //           tenants.where((tenant) {
                            //         return tenant['tenant_id'] ==
                            //             selectedTenantId;
                            //       }).toList();
                            //       Map<String, String> selectedTenant =
                            //           filteredTenants.first;
                            //       await PaymentService()
                            //           .makePaymentforcard(
                            //               adminId: id ?? "",
                            //               firstName:
                            //                   selectedTenant["first_name"]!,
                            //               lastName:
                            //                   selectedTenant["last_name"]!,
                            //               emailName: selectedTenant["email"]!,
                            //               customerVaultId:
                            //                   cardDetails[selectedcardindex!]
                            //                       .customerVaultId!,
                            //               billingId:
                            //                   cardDetails[selectedcardindex!]
                            //                       .billingId!,
                            //               surcharge:
                            //                   "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100)}",
                            //               amount:
                            //                   "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100) + (double.tryParse(amountController.text.trim()) ?? 0.0)}",
                            //               tenantId: selectedTenantId!,
                            //               date: _startDate.text.trim(),
                            //               address1:
                            //                   cardDetails[selectedcardindex!]
                            //                       .address_1!,
                            //               processorId: "",
                            //               leaseid: widget.leaseId,
                            //               company_name: companyName,
                            //               entries: rows,
                            //               tenantname: tenantname,
                            //               future_Date: futuredate!,
                            //               uploadedFile: _uploadedFileNames)
                            //           .then((value) {
                            //         Fluttertoast.showToast(msg: "$value");
                            //         setState(() {
                            //           _isLoading = false;
                            //         });
                            //         Navigator.pop(context, true);
                            //       }).catchError((e) {
                            //         print(e
                            //             .toString()
                            //             .split("Exception")[1]
                            //             .toString()
                            //             .trimLeft());
                            //         setState(() {
                            //           _isLoading = false;
                            //         });
                            //         Alert(
                            //           context: context,
                            //           type: AlertType.warning,
                            //           title: "Payment Failed!",
                            //           desc:
                            //               "${e.toString().split('Exception:')[1].toString().trimLeft()}",
                            //           style: AlertStyle(
                            //             backgroundColor: Colors.white,
                            //             //  overlayColor: Colors.black.withOpacity(.8)
                            //           ),
                            //           buttons: [
                            //             DialogButton(
                            //               child: Text(
                            //                 "Ok",
                            //                 style: TextStyle(
                            //                     color: Colors.white,
                            //                     fontSize: 18),
                            //               ),
                            //               onPressed: () =>
                            //                   Navigator.pop(context),
                            //               color: blueColor,
                            //             ),
                            //           ],
                            //         ).show();
                            //       });
                            //     }
                            //   } else if (_selectedPaymentMethod == "ACH") {
                            //     List<Map<String, String>> filteredTenants =
                            //         tenants.where((tenant) {
                            //       return tenant['tenant_id'] ==
                            //           selectedTenantId;
                            //     }).toList();
                            //     Map<String, String> selectedTenant =
                            //         filteredTenants.first;
                            //     await PaymentService()
                            //         .makePaymentforach(
                            //             adminId: id ?? "",
                            //             firstName:
                            //                 selectedTenant["first_name"]!,
                            //             lastName: selectedTenant["last_name"]!,
                            //             emailName: selectedTenant["email"]!,
                            //             surcharge: "$surchargecount",
                            //             amount:
                            //                 "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100) + (double.tryParse(amountController.text.trim()) ?? 0.0)}",
                            //             tenantId: selectedTenantId!,
                            //             date: _startDate.text.trim(),
                            //             address1: "",
                            //             processorId: "",
                            //             leaseid: widget.leaseId,
                            //             company_name: companyName,
                            //             entries: rows,
                            //             future_Date: futuredate!,
                            //             account_type: selectedAccount!,
                            //             account_holder_type:
                            //                 _selectedHoldertype!,
                            //             checkaccount: accountnum.text.trim(),
                            //             checkaba: bankrountingnum.text.trim(),
                            //             tenantname: tenantname,
                            //             checkname: achname.text.trim(),
                            //             uploadedFile: _uploadedFileNames)
                            //         .then((value) {
                            //       Fluttertoast.showToast(msg: "$value");
                            //       setState(() {
                            //         _isLoading = false;
                            //       });
                            //       Navigator.pop(context, true);
                            //     }).catchError((e) {
                            //       print(e
                            //           .toString()
                            //           .split("Exception")[1]
                            //           .toString()
                            //           .trimLeft());
                            //       setState(() {
                            //         _isLoading = false;
                            //       });
                            //       Alert(
                            //         context: context,
                            //         type: AlertType.warning,
                            //         title: "Payment Failed!",
                            //         desc:
                            //             "${e.toString().split('Exception:')[1].toString().trimLeft()}",
                            //         style: AlertStyle(
                            //           backgroundColor: Colors.white,
                            //           //  overlayColor: Colors.black.withOpacity(.8)
                            //         ),
                            //         buttons: [
                            //           DialogButton(
                            //             child: Text(
                            //               "Ok",
                            //               style: TextStyle(
                            //                   color: Colors.white,
                            //                   fontSize: 18),
                            //             ),
                            //             onPressed: () => Navigator.pop(context),
                            //             color: blueColor,
                            //           ),
                            //         ],
                            //       ).show();
                            //     });
                            //   } else if (_selectedPaymentMethod == "Check" ||
                            //       _selectedPaymentMethod == "Money Order" ||
                            //       _selectedPaymentMethod ==
                            //           "Cashier 's Check") {
                            //     List<Map<String, String>> filteredTenants =
                            //         tenants.where((tenant) {
                            //       return tenant['tenant_id'] ==
                            //           selectedTenantId;
                            //     }).toList();
                            //     Map<String, String> selectedTenant =
                            //         filteredTenants.first;
                            //     await PaymentService()
                            //         .makePaymentfornormal(
                            //       adminId: id ?? "",
                            //       firstName: selectedTenant["first_name"]!,
                            //       lastName: selectedTenant["last_name"]!,
                            //       emailName: selectedTenant["email"]!,
                            //       surcharge:
                            //           "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100)}",
                            //       amount:
                            //           "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100) + (double.tryParse(amountController.text.trim()) ?? 0.0)}",
                            //       tenantId: selectedTenantId!,
                            //       date: _startDate.text.trim(),
                            //       address1: "",
                            //       processorId: "",
                            //       leaseid: widget.leaseId,
                            //       company_name: companyName,
                            //       entries: rows,
                            //       future_Date: true,
                            //       Check_number: checknumber.text.trim(),
                            //       Check: true,
                            //       uploadedFile: _uploadedFileNames,
                            //       payment_method: _selectedPaymentMethod!,
                            //     )
                            //         .then((value) {
                            //       Fluttertoast.showToast(msg: "$value");
                            //       setState(() {
                            //         _isLoading = false;
                            //       });
                            //       Navigator.pop(context, true);
                            //     }).catchError((e) {
                            //       setState(() {
                            //         _isLoading = false;
                            //       });
                            //       Fluttertoast.showToast(
                            //           msg: "Payment failed $e");
                            //     });
                            //   } else if (_selectedPaymentMethod == "Cash" ||
                            //       _selectedPaymentMethod == "Manual") {
                            //     List<Map<String, String>> filteredTenants =
                            //         tenants.where((tenant) {
                            //       return tenant['tenant_id'] ==
                            //           selectedTenantId;
                            //     }).toList();
                            //     Map<String, String> selectedTenant =
                            //         filteredTenants.first;
                            //     await PaymentService()
                            //         .makePaymentfornormal(
                            //       adminId: id ?? "",
                            //       firstName: selectedTenant["first_name"]!,
                            //       lastName: selectedTenant["last_name"]!,
                            //       emailName: selectedTenant["email"]!,
                            //       surcharge:
                            //           "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100)}",
                            //       amount:
                            //           "${((double.tryParse(amountController.text.trim()) ?? 0.0) * (surCharge ?? 0.0) / 100) + (double.tryParse(amountController.text.trim()) ?? 0.0)}",
                            //       tenantId: selectedTenantId!,
                            //       date: _startDate.text.trim(),
                            //       address1: "",
                            //       processorId: "",
                            //       leaseid: widget.leaseId,
                            //       company_name: companyName,
                            //       entries: rows,
                            //       future_Date: true,
                            //       Check_number: "",
                            //       payment_method: _selectedPaymentMethod!,
                            //       Check: false,
                            //       uploadedFile: _uploadedFileNames,
                            //     )
                            //         .then((value) {
                            //       Fluttertoast.showToast(msg: "$value");
                            //       setState(() {
                            //         _isLoading = false;
                            //       });
                            //       Navigator.pop(context, true);
                            //     }).catchError((e) {
                            //       print(e);
                            //       Fluttertoast.showToast(msg: e);
                            //       setState(() {
                            //         _isLoading = false;
                            //       });
                            //       Fluttertoast.showToast(
                            //           msg: "Payment failed $e");
                            //     });
                            //   }
                            //
                            //   //print(_selectedPaymentMethod);
                            // }
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
                                  style: TextStyle(color: Color(0xFFf7f8f9)),
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
                            style: TextStyle(color: Color(0xFF748097)),
                          ))),
                ],
              ),
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
              '\$$amount',
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

  surge_count() {
    if (amountController.text.isNotEmpty) {
      if (_selectedPaymentMethod == "ACH") {
        final double base = double.tryParse(amountController.text) ?? 0.0;
        final double achPercent =
            num.tryParse('$surChargeAchper')?.toDouble() ?? 0.0;
        final double achFlat =
            num.tryParse('$surChargeAchflat')?.toDouble() ?? 0.0;
        // ACH: add percent term and flat term only when their value is > 0.
        // override_fee is never used for ACH. Flat is a dollar amount.
        double surcharge = 0.0;
        if (achPercent > 0) {
          surcharge += base * achPercent / 100;
        }
        if (achFlat > 0) {
          surcharge += achFlat;
        }
        setState(() {
          surchargecount =
              double.parse(surcharge.toStringAsFixed(2));
          finaltotal = double.parse((base + surchargecount!).toStringAsFixed(2));
        });
      }
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
}
