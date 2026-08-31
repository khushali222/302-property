import 'package:three_zero_two_property/services/api_client.dart';
import 'package:three_zero_two_property/services/payment_reconciliation.dart';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:three_zero_two_property/TenantsModule/screen/financial/payment/payment_service.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

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
import '../AddAchAccount/AddAchAccount.dart';
import '../../Payment/checkout_screen.dart';

class MakePayment extends StatefulWidget {
  final String leaseId;
  final String tenantId;

  const MakePayment({required this.leaseId, required this.tenantId});

  @override
  State<MakePayment> createState() => _MakePaymentState();
}

/// Make Payment flow (Tenant):
/// - APIs: get_tenant (allow_card, allow_ach), get_leases (lease list + per-lease creditCardAccepted, debitCardAccepted, achAccepted),
///   tenant_due_amount (charges + surcharge ACH), payment_settings (creditCardAccepted, debitCardAccepted for card section),
///   get-billing-customer-vault (saved cards + ACH), ACH_sale, tenant-payment.
/// - Payment method dropdown: Card always shown when get_tenant allow_card==true. ACH shown when allow_ach==true AND (no lease OR lease achAccepted).
/// - Card section visibility/disable: from payment_settings API (tenant); rental owner messages from same. Card list from get-billing-customer-vault.
/// - ACH surcharge from tenant_due_amount (surcharge_percent_ACH, surcharge_flat_ACH). Card surcharge from fetchSurcharge (getadmin).
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
  bool IsLoading = false;
  bool isloading = false;

  // One idempotency key per payment attempt: kept while the outcome is
  // unknown (network drop / still processing) so a retry replays the first
  // result instead of charging twice; cleared on a definitive answer.
  String? _saleIdempotencyKey;
  String? _saleKeyScope;
  bool _saleInFlight = false;

  // Identifies the payment being attempted. A key may only be replayed for the
  // same payment — a changed amount/account must start a new key, or the server
  // would replay the earlier result and record nothing.
  String _saleScope() => [
        totalamount,
        selected_account,
        widget.tenantId,
        _startDate.text.trim(),
      ].join('|');

  void _beginSale() {
    final scope = _saleScope();
    if (_saleKeyScope != scope) {
      _saleIdempotencyKey = null;
      _saleKeyScope = scope;
    }
    _saleIdempotencyKey ??= newIdempotencyKey();
    _saleInFlight = true;
  }

  void _settleSaleKey([Object? error]) {
    _saleInFlight = false;
    if (error == null || !isOutcomeUnknown(error)) {
      _saleIdempotencyKey = null;
      _saleKeyScope = null;
    }
  }

  // ---- Reconciliation (CRM-4660) -------------------------------------------
  // When the connection drops mid-request the server may still have taken the
  // payment. Read the ledger and answer the question instead of asking the user
  // to check by hand.
  final PaymentReconciliationService _reconciliation =
      PaymentReconciliationService();

  /// Payment ids present before we submit, so a payment appearing afterwards
  /// can be told apart from an identical earlier one.
  Set<String>? _preSaleLedgerIds;

  Future<void> _snapshotLedgerBeforeSale(String tenantId) async {
    _preSaleLedgerIds = await _reconciliation.snapshot(
      leaseId: widget.leaseId,
      tenantId: tenantId,
    );
  }

  Future<void> _handleSaleFailure(
    Object e, {
    required String tenantId,
    required double amount,
  }) async {
    if (!isOutcomeUnknown(e)) {
      _showSaleAlert(
        paymentAlertTitle(e),
        friendlyErrorMessage(e, networkMessage: paymentNetworkErrorMessage),
      );
      return;
    }

    final result = await _reconciliation.verify(
      leaseId: widget.leaseId,
      tenantId: tenantId,
      amount: amount,
      before: _preSaleLedgerIds,
      backoff: const [
        Duration(seconds: 2),
        Duration(seconds: 4),
        Duration(seconds: 6),
      ],
    );
    // NOTE: deliberately NOT guarded by `mounted` — the whole point is that the
    // screen may be gone by now. _showSaleAlert uses the root navigator.

    switch (result.verdict) {
      case PaymentVerdict.completed:
        _saleIdempotencyKey = null;
        _saleKeyScope = null;
        _showSaleAlert(
          'Payment Completed',
          'The connection dropped, but the payment of ${formatMoney(amount)} '
              'was processed successfully. Do not pay again.',
        );
        break;
      case PaymentVerdict.notFound:
        _showSaleAlert(
          'Payment Not Processed',
          'The connection dropped and no payment was recorded on the ledger. '
              'You can safely try again.',
        );
        break;
      case PaymentVerdict.unknown:
        _showSaleAlert(
          paymentAlertTitle(e),
          friendlyErrorMessage(e, networkMessage: paymentNetworkErrorMessage),
        );
        break;
    }
  }

  void _showSaleAlert(String title, String desc) {
    // The host screen can be destroyed mid-request — several screens swap their
    // entire body to a "No Internet" widget the moment connectivity drops, which
    // disposes this one. The verdict must still reach the user, so the dialog is
    // shown on the app's ROOT navigator rather than this widget's context.
    final ctx = ApiClient.navigatorKey.currentContext ?? (mounted ? context : null);
    if (ctx == null) return;
    Alert(
      context: ctx,
      type: AlertType.warning,
      title: title,
      desc: desc,
      style: const AlertStyle(backgroundColor: Colors.white),
      buttons: [
        DialogButton(
          child: const Text('Ok',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () => Navigator.pop(ctx),
          color: blueColor,
        ),
      ],
    ).show();
  }

  bool isLoadingamount = false;
  bool hasError = false;
  double chargeAmount = 0.0;
  double surchargeIncluded = 0.0;
  double totalAmount = 0.0;
  int? selectedcardindex;
  bool? futuredate = false;
  Setting1? surcharges;
  double? surchargecount = 0.0;
  double? finaltotal;
  String override_fee = "";
  // Sibling of override_fee on the same tenant JSON object (token_check / tenant_due_amount).
  bool enableOverrideFee = false;
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
      Fluttertoast.showToast(msg: 'Could not load surcharge settings. Amounts may be incomplete.');
    }
  }

  Future<void> checkTokenTenant() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await apiPost(
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
        // enable_override_fee is a sibling of override_fee on the same object.
        enableOverrideFee = jsonData['enable_override_fee'] == true;
      });
      //prefs.setString('checkedToken',jsonData["token"]);
      // String? adminId = jsonData['data']['admin_id'];
      // print('Admin ID: $adminId');
    } else {
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
        // Handle error state, e.g., show error message to user
      }
    }
  }

  String? leaseid;

  /// From get_tenant API: tenant-level allow_ach / allow_card. Merged with lease flags for dropdown.
  /// WEB parity: default true (opt-out) like AddPaymentByTenant.jsx useState(true).
  bool? tenantAllowAch = true;
  bool? tenantAllowCard = true;

  @override
  void initState() {
    super.initState();
    checkTokenTenant();
    fetchTenants();
    fetchTenantPaymentOptions(widget.tenantId);
    // fetchCompany();
    fetchDropdownData();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await fetchPaymentSettings(widget.tenantId, widget.leaseId);
    // });
    DateTime today = DateTime.now();

    _startDate.text = DateFormat('yyyy-MM-dd').format(today);
    //  fetchSurcharge();
    //totalAmount = chargeAmount + surchargeIncluded;
    // amountController.addListener(_updateTotalAmount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dateProvider = Provider.of<DateProvider>(context);
    _startDate.text = dateProvider.formatCurrentDate(
      _startDate.text.isNotEmpty
          ? _startDate.text
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  void _updateTotalAmount() {
    setState(() {
      totalAmount = chargeAmount + surchargeIncluded;
    });
  }

  List<Map<String, dynamic>> tenants = [];
  String? selectedTenantId;
  double selectedTenantRent = 0.0;

  List<TextEditingController> controllers = [];
  List<BillingData> cardDetails = [];

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    final response = await apiGet(
      Uri.parse('$Api_url/api/leases/get_leases/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    // print('$Api_url/api/leases/get_leases/${widget.tenantId}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Map<String, dynamic>> fetchedTenants = [];

      for (var tenant in data['data']['leases']) {
        fetchedTenants.add({
          'tenant_id': tenant['lease_id'],
          'tenant_name': '${tenant['rental_adress']}',
          'status': '${tenant['status']}',
          'rent': '${tenant['rent']}',
          'creditCardAccepted': tenant['creditCardAccepted'] == true,
          'debitCardAccepted': tenant['debitCardAccepted'] == true,
          'achAccepted': tenant['achAccepted'] == true,
        });
      }
      setState(() {
        tenants = fetchedTenants;
        // leaseid = tenants[0]['tenant_id'];
        // print('leaseid $leaseid');
        // selectedTenantRent =
        //     double.tryParse(tenants[0]['rent'] ?? '0.0') ?? 0.0;
        isLoading = false;
        if (fetchedTenants.isNotEmpty) {
          leaseid = fetchedTenants[0]['tenant_id'];
          selectedTenantRent =
              double.tryParse(fetchedTenants[0]['rent'] ?? '0.0') ?? 0.0;

          if (fetchedTenants.length == 1) {
            selectedTenantId = leaseid;
            fetchTotal_due_amountTenant(selectedTenantId!);
            fetchPaymentSettings(id!, selectedTenantId!);
            // ACH list loaded in fetchcreditcard via fetchAchFromBillingVault
            //fetchChargesForSelectedTenant(selectedTenantId!);
            // if (id != null) {
            //   //fetchPaymentSettings(id, leaseid ?? "");
            // }
          }
        }
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
      final response = await apiGet(
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
    double roundedEntered = double.parse(enteredAmount.toStringAsFixed(2));
    double roundedTotal = double.parse(totalAmount.toStringAsFixed(2));

    /* setState(() {
      totalAmount = enteredAmount;
    });*/
    if (roundedEntered != roundedTotal) {
      setState(() {
        validationMessage =
            "The charge's amount must match the total applied to balance. The difference is ${NumberFormat('#,##0.00', 'en_US').format((roundedEntered - roundedTotal).abs())}";
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
      Fluttertoast.showToast(msg: 'Failed to attach the file. Please try again.');
    }
  }

  Future<String?> uploadPdf(File pdfFile) async {
    //print(pdfFile.path);
    final String uploadUrl = '${Api_url}/api/images/upload';

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
    'Cashier\'s Check',
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

  // ACH: list of saved ACH accounts and selected index
  List<Map<String, dynamic>> achAccounts = [];
  int? selectedAchIndex;
  bool isLoadingAch = false;

  /// Card-only list: excludes ACH entries (getCreditCards returns card_detail with ACH billing_id;
  /// postBillingCustomerVault then includes that entry, which has null ccExp and crashes). Use this for Card UI and payment.
  List<BillingData> get _cardOnlyList => cardDetails
      .where((b) => b.ccExp != null && b.ccExp!.trim().isNotEmpty)
      .toList();

  void AddFields() {
    setState(() {
      showCardNumberField = _selectedPaymentMethod == 'Card';
      showCheckNumberField = _selectedPaymentMethod == 'Check';
      showACHFields = _selectedPaymentMethod == 'ACH';
      showCashiersFields = _selectedPaymentMethod == 'Cashier\'s Check';
      showMoneyorderFields = _selectedPaymentMethod == 'Money Order';
      showMenualFields = _selectedPaymentMethod == 'Manual';
    });
  }

  /// Fetches get_tenant to get allow_ach and allow_card (merged with lease flags for dropdown).
  Future<void> fetchTenantPaymentOptions(String tenantId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('tenant_id');
      String? token = prefs.getString('token');
      final response = await apiGet(
        Uri.parse('$Api_url/api/tenant/get_tenant/$tenantId'),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $id',
        },
      );
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        final d = data is Map ? data['data'] : null;
        if (d is Map<String, dynamic>) {
          setState(() {
            // WEB parity: opt-out semantics (allow unless explicitly false)
            tenantAllowAch = d['allow_ach'] != false;
            tenantAllowCard = d['allow_card'] != false;
          });
        }
      }
    } catch (_) {}
  }

  /// Payment method dropdown: Card is always shown when tenant allows (get_tenant allow_card).
  /// ACH is shown only when tenant allows (get_tenant allow_ach) AND (no lease selected OR selected lease has achAccepted from get_leases).
  List<String> get _availablePaymentMethods {
    List<String> methods = [];
    final tenantCard = tenantAllowCard == true;
    final tenantAch = tenantAllowAch == true;
    // Card: always visible in dropdown when tenant allows (no lease condition)
    if (tenantCard) methods.add('Card');
    // ACH: only when tenant allows AND (no lease selected OR selected lease accepts ACH)
    if (tenantAch) {
      if (selectedTenantId == null || tenants.isEmpty) {
        methods.add('ACH');
      } else {
        final list = tenants
            .cast<Map<String, dynamic>>()
            .where((t) => t['tenant_id'] == selectedTenantId)
            .toList();
        if (list.isNotEmpty && list.first['achAccepted'] == true)
          methods.add('ACH');
      }
    }
    // WEB parity: when the tenant is allowed neither method, return an empty
    // list (block) instead of falling back to both. Allow-flags default true,
    // so this is empty only when the tenant is explicitly disallowed both.
    return methods;
  }

  /// Fetches ACH accounts from get-billing-customer-vault (POST).
  /// Uses customervaultid and admin_id; parses data.customer.billing and
  /// keeps only entries that have check_account / check_name (ACH).
  Future<void> fetchAchFromBillingVault() async {
    if (customervaultid == null) {
      setState(() {
        achAccounts = [];
        isLoadingAch = false;
      });
      return;
    }
    setState(() => isLoadingAch = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('tenant_id');
      String? adminId = prefs.getString('adminId');
      String? token = prefs.getString('token');
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
        headers: {
          'Content-Type': 'application/json',
          'id': 'CRM $id',
          'authorization': 'CRM $token',
        },
        body: json.encode({
          'customer_vault_id': customervaultid.toString(),
          'admin_id': adminId ?? '',
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        var data = jsonResponse is Map ? jsonResponse['data'] : null;
        var customer = data is Map ? data['customer'] : null;
        var billing = customer is Map ? customer['billing'] : null;
        if (billing is List) {
          for (var item in billing) {
            if (item is! Map) continue;
            // ACH entries have check_account or check_name (non-empty)
            String? checkAccount = _extractString(item['check_account']);
            String? checkName = _extractString(item['check_name']);
            if ((checkAccount != null && checkAccount.isNotEmpty) ||
                (checkName != null && checkName.isNotEmpty)) {
              var attrs = item['@attributes'];
              String? billingId =
                  attrs is Map ? _extractString(attrs['id']) : null;
              list.add({
                'account_name': checkName ?? '',
                'account_holder_name': checkName ?? '',
                'account_number': checkAccount ?? '',
                'routing_number': _extractString(item['check_aba']) ?? '',
                'account_type': _extractString(item['account_type']) ?? '',
                'account_holder_type':
                    _extractString(item['account_holder_type']) ?? '',
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
      } else {
        setState(() {
          achAccounts = [];
          selectedAchIndex = null;
          isLoadingAch = false;
        });
      }
    } catch (e) {
      setState(() {
        achAccounts = [];
        selectedAchIndex = null;
        isLoadingAch = false;
      });
    }
  }

  /// Extract string from API value (may be string, number, or empty object {}).
  static String? _extractString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    if (v is num) return v.toString();
    if (v is Map && v.isEmpty) return null;
    if (v is Map) return null;
    return v.toString();
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
  double totalrent = 0.0;
  double surchargeamount = 0.0;
  double totalpayamount = 0.0;
//for payment
//   Future<void> fetchChargesForSelectedTenant(String tenantId) async {
//     setState(() {
//       isLoading = true;
//       hasError = false;
//     });
//     try {
//       List<Entrycharge>? charges = await ChargeRepositorys()
//           .fetchChargesTable(tenantId);
//       List<Entrycharge> filteredCharges =
//           charges?.where((entry) => entry.chargeAmount! > 0).toList() ?? [];
//
//       // print('leaseid ${widget.leaseId}');
//       // print('tenantid $tenantId');
//       // print(charges!.length);
//       // print("aaaa ${filteredCharges.length}");
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
//         //     print(rows.length);
//         //       print(filteredCharges.length);
//         for (var i = 0; i < filteredCharges.length; i++) {
//           print("calling");
//           if (i == 0) {
//             charges_balances[0] = filteredCharges[i].chargeAmount!;
//           } else {
//             charges_balances.add(filteredCharges[i].chargeAmount!);
//           }
//         }
//         //   print("charges ${charges_balances}");
//         // print(rows.length);
//         /*  print(rows.first['account']);
//         print(rows.first['charge_amount']);
//         print(rows.first['charge_amount']);*/
//         controllers = rows.map((row) {
//           return TextEditingController(text: "".toString());
//         }).toList();
//         //    print(rows);
//         totalAmount = rows.fold(
//             0.0, (sum, row) => sum + (row[amountController.text] ?? 0));
//         isLoading = false;
//         //   print(controllers.length);
//       });
//     } catch (e) {
//       print(e);
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//     }
//   }
  Future<void> fetchChargesForSelectedTenant(String tenantId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      List<Entrycharge>? charges =
          await ChargeRepositorys().fetchChargesTable(widget.leaseId);
      List<Entrycharge> filteredCharges =
          charges?.where((entry) => entry.chargeAmount! > 0).toList() ?? [];


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
        /*  print(rows.first['account']);
        print(rows.first['charge_amount']);
        print(rows.first['charge_amount']);*/
        controllers = rows.map((row) {
          return TextEditingController(text: "".toString());
        }).toList();
        // 'amount' is the row's applied-amount key (web sums the same field).
        // This previously indexed the map with the TEXT typed in the amount
        // box — row[""] at load — which only worked because rows start at 0.0.
        totalAmount =
            rows.fold(0.0, (sum, row) => sum + (row['amount'] ?? 0));
        isLoading = false;
      });
    } catch (e) {
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
        override_fee = charges!["override_fee"].toString();
        // enable_override_fee is a sibling of override_fee on the same charges object.
        enableOverrideFee = charges["enable_override_fee"] == true;
        // ACH surcharge from tenant_due_amount API (surcharge.surcharge_percent_ACH, surcharge_flat_ACH)
        if (charges["surcharge"] != null && charges["surcharge"] is Map) {
          final sur = charges["surcharge"] as Map<String, dynamic>;
          surChargeAchper = sur["surcharge_percent_ACH"];
          surChargeAchflat = sur["surcharge_flat_ACH"];
        }

        if (selected_account == "full") {
          totalamount = double.parse(
              (double.tryParse(lease_data!["total_due_amount"].toString()) ??
                      0.0)
                  .toStringAsFixed(2));
          totalpayamount = double.parse(
              (double.tryParse(lease_data!["total_due_amount"].toString()) ??
                      0.0)
                  .toStringAsFixed(2));
          totalrent = double.parse(
              (double.tryParse(lease_data!["total_due_amount"].toString()) ??
                      0.0)
                  .toStringAsFixed(2));
          if (totalamount <= 0) {
            // Web parity: no fee on a zero base — the flat ACH fee is
            // amount-independent and must not create a fee-only total.
            surchargeamount = 0.0;
            totalpayamount = 0.0;
          } else if (_selectedPaymentMethod == 'ACH') {
            final achPct = surChargeAchper != null
                ? (double.tryParse(surChargeAchper.toString()) ?? 0.0)
                : 0.0;
            final achFlat = surChargeAchflat != null
                ? (double.tryParse(surChargeAchflat.toString()) ?? 0.0)
                : 0.0;
            // Web parity: round the surcharge ONCE, then build the total
            // from that rounded value so the displayed total matches the
            // amount actually charged (the payload sends the rounded fee).
            surchargeamount = roundCurrency(totalamount * achPct / 100 + achFlat);
            totalpayamount = roundCurrency(totalamount + surchargeamount);
          } else if (surCharge != null) {
            // Web parity: round the surcharge ONCE, then build the total
            // from that rounded value so the displayed total matches the
            // amount actually charged (the payload sends the rounded fee).
            surchargeamount = roundCurrency(totalamount * surCharge! / 100);
            totalpayamount = roundCurrency(totalamount + surchargeamount);
          }
        } else if (selected_account == "rent") {
          totalamount = selectedTenantRent;
          totalpayamount = selectedTenantRent;
          totalrent = selectedTenantRent;
          if (totalamount <= 0) {
            // Web parity: no fee on a zero base — the flat ACH fee is
            // amount-independent and must not create a fee-only total.
            surchargeamount = 0.0;
            totalpayamount = 0.0;
          } else if (_selectedPaymentMethod == 'ACH') {
            final achPct = surChargeAchper != null
                ? (double.tryParse(surChargeAchper.toString()) ?? 0.0)
                : 0.0;
            final achFlat = surChargeAchflat != null
                ? (double.tryParse(surChargeAchflat.toString()) ?? 0.0)
                : 0.0;
            // Web parity: round the surcharge ONCE, then build the total
            // from that rounded value so the displayed total matches the
            // amount actually charged (the payload sends the rounded fee).
            surchargeamount = roundCurrency(totalamount * achPct / 100 + achFlat);
            totalpayamount = roundCurrency(totalamount + surchargeamount);
          } else if (surCharge != null) {
            // Web parity: round the surcharge ONCE, then build the total
            // from that rounded value so the displayed total matches the
            // amount actually charged (the payload sends the rounded fee).
            surchargeamount = roundCurrency(totalamount * surCharge! / 100);
            totalpayamount = roundCurrency(totalamount + surchargeamount);
          } else {
            totalpayamount = totalamount;
          }
        } else {
          totalamount = 0.0;
          totalpayamount = 0.0;
          surchargeamount = 0.0;
        }

        isLoadingamount = false;
      });

      // Load-order guard for the override race: fetchSurcharge() can run during
      // initState (fetchPaymentSettings -> fetchcreditcard auto-select) BEFORE
      // this method sets enable_override_fee / override_fee, which would leave a
      // stale default debit fee (the reported $2). Now that the override data is
      // loaded, recompute the card surcharge if a card is already selected.
      if (selectedcardindex != null) {
        await fetchSurcharge();
      }
    } catch (e) {
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
        'date': _normalizeToIsoDate(_startDate.text),
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
        // Field cleared: this charge now applies 0, so restore its balance to the
        // full charge amount and recompute the total from all rows (empty == 0),
        // matching the web. Without this the total keeps the previous keystroke.
        rows[index]['amount'] = 0.0;
        charges_balances[index] = rows[index]["charge_amount"];
        totalAmount = 0.0;
        for (var i = 0; i < rows.length; i++) {
          if (rows[i]["amount"] != 0.0)
            totalAmount = totalAmount + rows[i]["amount"];
        }
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

    try {
      final url = '$Api_url/api/creditcard/getCreditCards/$tenantId';

      final response = await apiGet(
        Uri.parse(url),
        headers: {"id": "CRM $id", "authorization": "CRM $token"},
      );


      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(response.body);

          if (jsonResponse is Map<String, dynamic>) {

            // Check customer_vault_id
            if (jsonResponse.containsKey('customer_vault_id')) {
              var vaultId = jsonResponse['customer_vault_id'];
              if (vaultId != null) {
                if (vaultId is int) {
                  customervaultid = vaultId;
                } else if (vaultId is String) {
                  customervaultid = int.tryParse(vaultId);
                } else {
                  customervaultid = int.tryParse(vaultId.toString());
                }
              } else {
                customervaultid = null;
              }
            } else {
            }

            // Load ACH accounts from billing vault when we have vault id (even if no cards)
            if (customervaultid != null) {
              await fetchAchFromBillingVault();
            }

            // Check card_detail
            if (jsonResponse.containsKey('card_detail')) {
              var cardDetail = jsonResponse['card_detail'];

              if (cardDetail is List) {
                List<dynamic> cardDetailsList = cardDetail;

                for (int i = 0; i < cardDetailsList.length; i++) {
                }

                if (customervaultid != null) {
                  CustomerData? customerData = await postBillingCustomerVault(
                      customervaultid.toString(), cardDetailsList);

                  if (customerData != null) {

                    setState(() {
                      cardDetails = customerData.billing;
                      // Only consider real cards (exclude ACH entries that have null ccExp)
                      final cardOnly = customerData.billing
                          .where((b) =>
                              b.ccExp != null && b.ccExp!.trim().isNotEmpty)
                          .toList();
                      if (cardOnly.length == 1) {
                        // WEB parity: auto-select the lone card based on ITS OWN
                        // type being accepted (web filteredData[0].allowPayment),
                        // not on both flags being true.
                        final String loneType =
                            (cardOnly.first.binResult ?? '').toUpperCase();
                        final bool loneAccepted =
                            (loneType == 'CREDIT' && creditCardAccepted) ||
                                (loneType == 'DEBIT' && debitCardAccepted);
                        if (loneAccepted) {
                          selectedcardindex = 0;
                          fetchSurcharge();
                        } else {
                        }
                      } else {
                        selectedcardindex = null;
                      }
                    });

                  } else {
                  }
                } else {
                }
              } else {
              }
            } else {
            }
          } else {
          }
        } catch (e, stackTrace) {
          Fluttertoast.showToast(msg: 'Could not load saved cards.');
        }
      } else if (response.statusCode == 404) {
      } else {
      }
    } catch (e, stackTrace) {
      Fluttertoast.showToast(msg: 'Could not load saved cards.');
    } finally {
      setState(() {
        isLoading = false;
        isloading = false;
      });
    }
  }

  Future<CustomerData?> postBillingCustomerVault(
      String customerVaultId, List<dynamic> cardDetailsList) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": adminId.toString(),
    };


    try {
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
        try {
          var jsonResponse = json.decode(response.body);

          if (jsonResponse is Map<String, dynamic>) {
            if (jsonResponse.containsKey('data')) {
              var data = jsonResponse['data'];

              if (data is Map<String, dynamic>) {
                if (data.containsKey('customer')) {
                  var customerJson = data['customer'];

                  if (customerJson == null) {
                    return null;
                  }

                  CustomerData customerData =
                      CustomerData.fromJson(customerJson);

                  customerData.billing.forEach((billing) {
                  });

                  Set<String> cardBillingIds = cardDetailsList
                      .map((card) {
                        if (card is Map) {
                          if (card.containsKey('billing_id')) {
                            var billingId = card['billing_id'];
                            return billingId.toString();
                          } else {
                            return '';
                          }
                        } else {
                          return '';
                        }
                      })
                      .where((id) => id.isNotEmpty)
                      .toSet();


                  // Filter customerData.billing to only include matching billing IDs
                  List<BillingData> filteredCards =
                      customerData.billing.where((billing) {
                    bool matches = cardBillingIds.contains(billing.billingId);
                    return matches;
                  }).toList();

                  customerData.billing = filteredCards;

                  // Assign card types by billing_id (web: cardTypeMap keyed on
                  // billing_id, read off "@attributes".id). Index pairing is
                  // wrong here because `billing` was just filtered above while
                  // cardDetailsList was not.
                  final Map<String, String> cardTypeByBillingId = {};
                  for (final dynamic item in cardDetailsList) {
                    if (item is Map) {
                      final bid = item['billing_id']?.toString();
                      final ct = item['card_type']?.toString();
                      if (bid != null && bid.isNotEmpty && ct != null) {
                        cardTypeByBillingId[bid] = ct;
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
                  return null;
                }
              } else {
                return null;
              }
            } else {
              return null;
            }
          } else {
            return null;
          }
        } catch (e, stackTrace) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      return null;
    } finally {
    }
  }

  static const int numItems = 20;
  List<bool> selected = List<bool>.generate(numItems, (int index) => false);

  String? selected_account = "full";
  Map<int, bool> selectedRows = {};
  num? surCharge;
  bool? scheduledPayment = false;

  dynamic? surChargeAchper;
  dynamic? surChargeAchflat;
  bool partialamount = false;
  Future<void> fetchSurcharge() async {
    //  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId') ?? '';
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    //  print(adminId);

    final response = await apiGet(
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
      // Card type is chosen by explicit binResult, never inferred.
      // WEB parity: normalize case so a stored "Credit"/"credit" still matches.
      final String? cardType = (selectedcardindex != null &&
              selectedcardindex! < _cardOnlyList.length)
          ? _cardOnlyList[selectedcardindex!].binResult?.toUpperCase()
          : null;
      // WEB PARITY (AddPaymentByTenant.jsx / AddPayment.jsx): web takes the
      // override whenever the flag is on and the value isn't null/undefined. A
      // BLANK value is accepted there and coerces to 0 — no debit fee. Only a
      // missing value ("null") falls through to the company debit %. Treating
      // blank as "no override" charged the tenant a fee web wouldn't.
      final bool hasOverrideFee = override_fee != "null" &&
          (override_fee.isEmpty || num.tryParse(override_fee) != null);
      if (cardType == "CREDIT") {
        // CREDIT ALWAYS uses surcharge_percent and NEVER consults override_fee.
        setState(() {
          surCharge = num.tryParse(
                  (surchargeData['surcharge_percent'] ?? 0).toString()) ??
              0;
          if (totalamount > 0.0) {
            // Web parity: round the surcharge ONCE, then build the total
            // from that rounded value so the displayed total matches the
            // amount actually charged (the payload sends the rounded fee).
            surchargeamount = roundCurrency(totalamount * surCharge! / 100);
            totalpayamount = roundCurrency(totalamount + surchargeamount);
          }
        });
      } else if (cardType == "DEBIT") {
        // DEBIT: override_fee (as a PERCENTAGE) only when enabled AND present;
        // otherwise surcharge_percent_debit.
        setState(() {
          final num effectivePercent = (enableOverrideFee == true &&
                  hasOverrideFee)
              ? (num.tryParse(override_fee) ?? 0)
              : (num.tryParse((surchargeData['surcharge_percent_debit'] ?? 0)
                      .toString()) ??
                  0);
          surCharge = effectivePercent;
          if (totalamount > 0.0) {
            // Web parity: round the surcharge ONCE, then build the total
            // from that rounded value so the displayed total matches the
            // amount actually charged (the payload sends the rounded fee).
            surchargeamount = roundCurrency(totalamount * surCharge! / 100);
            totalpayamount = roundCurrency(totalamount + surchargeamount);
          }
        });
      } else {
        // Any card type that is neither exactly "CREDIT" nor "DEBIT" => 0% surcharge.
        setState(() {
          surCharge = 0.0;
          surchargeamount = 0.0;
          totalpayamount = totalamount;
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
      var jsonResponse = jsonDecode(response.body);
      String message = jsonResponse['message'];
      throw Exception('Failed to fetch the surcharge $message');
    }
    /* } catch (e) {
      print('Error: $e');
    }*/
  }

  bool creditCardAccepted = false;
  bool debitCardAccepted = false;
  bool isCardOneEnabled = false;
  bool isCardTwoEnabled = false;

  Future<void> fetchPaymentSettings(String tenantId, String leaseid) async {
    setState(() {
      isloading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("tenant_id");

    final url = '${Api_url}/api/tenant/payment_settings/${tenantId}/${leaseid}';

    try {
      final response = await apiGet(
        Uri.parse(url),
        headers: {
          "id": "CRM $id",
          "authorization": "CRM $token",
        },
      );


      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(response.body);

          // Check if data exists and is a Map
          if (jsonResponse is Map<String, dynamic>) {

            if (jsonResponse.containsKey('data')) {
              var data = jsonResponse['data'];

              if (data is Map<String, dynamic>) {

                setState(() {
                  // WEB parity: fail-open — missing flag means accepted
                  creditCardAccepted = data['creditCardAccepted'] ?? true;
                  debitCardAccepted = data['debitCardAccepted'] ?? true;

                  // Print values to ensure state is being updated correctly
                });

                // Fetch the credit card details
                await fetchcreditcard(tenantId);
              } else {
              }
            } else {
            }
          } else {
          }
        } catch (e, stackTrace) {
          Fluttertoast.showToast(msg: 'Could not load payment settings.');
        } finally {
          setState(() {
            isloading = false;
          });
        }
      } else {
        setState(() {
          isloading = false;
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        isloading = false;
      });
    }
  }

  String? _errorText;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  bool iserror = false;
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
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
      body: SingleChildScrollView(
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
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      EdgeInsets.only(left: 18, top: 8, right: 18, bottom: 8),
                  child: FormField<String>(validator: (value) {
                    if (_selectedPaymentMethod == null &&
                        _availablePaymentMethods.isNotEmpty) {
                      return 'Please select a payment method';
                    }
                    if (_selectedPaymentMethod == 'Card' &&
                        _cardOnlyList.isEmpty) {
                      return 'Please add a card first';
                    }
                    if (_selectedPaymentMethod == 'Card' &&
                        selectedcardindex == null) {
                      return 'Please select a card';
                    }
                    if (_selectedPaymentMethod == 'ACH' &&
                        selectedAchIndex == null &&
                        achAccounts.isNotEmpty) {
                      return 'Please select an ACH account';
                    }
                    if (_selectedPaymentMethod == 'ACH' &&
                        achAccounts.isEmpty) {
                      return 'Please add an ACH account first';
                    }
                    return null;
                  }, builder: (FormFieldState<String> state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Lease *",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blueColor),
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: const Text('Select Lease'),
                                      value: selectedTenantId,
                                      items: tenants.map((tenant) {
                                        String status = tenant['status']
                                                ?.toString()
                                                .trim() ??
                                            '';
                                        String displayText =
                                            tenant['tenant_name']!;
                                        if (status.isNotEmpty) {
                                          displayText =
                                              "$displayText ($status)";
                                        }
                                        return DropdownMenuItem<String>(
                                          value: tenant['tenant_id'],
                                          child: Text(displayText),
                                        );
                                      }).toList(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: blueColor.withOpacity(.8)),
                                      onChanged: (value) async {
                                        setState(() {
                                          selectedTenantId = value;
                                          leaseid = value;
                                          fetchTotal_due_amountTenant(value!);
                                          fetchChargesForSelectedTenant(value!);
                                          // Find the selected tenant from the list
                                          final selectedTenant =
                                              tenants.firstWhere(
                                            (tenant) =>
                                                tenant['tenant_id'] == value,
                                            orElse: () => <String, dynamic>{},
                                          );

                                          // Update rent amount if the tenant is found
                                          selectedTenantRent = double.tryParse(
                                                  selectedTenant['rent']
                                                          ?.toString() ??
                                                      '0.0') ??
                                              0.0;

                                          _selectedPaymentMethod = null;
                                          selectedAchIndex = null;
                                          state.didChange(
                                              value); // Notify FormField of change
                                        });
                                        await fetchPaymentSettings(
                                            widget.tenantId, value ?? "");
                                        // ACH list is loaded in fetchcreditcard via fetchAchFromBillingVault
                                        state.reset();
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 50,
                                        // width: 250,
                                        // padding: EdgeInsets.only(left: 14, right: 14),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          color: Colors.white,
                                        ),
                                        elevation: 0,
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
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Date *',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        SizedBox(
                          height: 8,
                        ),
                        CustomTextField(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              // Web parity (CRM-4270): manual methods back-date only,
                              // card/ACH forward-date only.
                              firstDate:
                                  paymentFirstSelectableDate(_selectedPaymentMethod),
                              lastDate: paymentLastSelectableDate(_selectedPaymentMethod),
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
                                            21, 43, 83, 1), // button text color
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
                              // use dateProvider to format the date
                              String formattedDate = dateProvider
                                  .formatCurrentDate(pickedDate.toString());
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
                          borderColor: Colors.grey.shade300,
                          borderWidth: 1,
                          showElevation: false,
                          // label: "Select the date",
                          // borderColor: Colors.grey.shade300,
                          keyboardType: TextInputType.text,

                          hintText: 'dd-mm-yyyy',
                          controller: _startDate,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Payment Method *",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blueColor),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const Text('Select Payment Method'),
                            value: _availablePaymentMethods
                                    .contains(_selectedPaymentMethod)
                                ? _selectedPaymentMethod
                                : null,
                            items: _availablePaymentMethods
                                .map(
                                    (String method) => DropdownMenuItem<String>(
                                          value: method,
                                          child: Text(method),
                                        ))
                                .toList(),
                            style: TextStyle(
                                fontSize: 16, color: blueColor.withOpacity(.8)),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                                AddFields();
                                if (value == 'ACH') {
                                  selectedcardindex = null;
                                  // Recalc ACH surcharge for current amount.
                                  // Web recomputes on every method change, so a
                                  // zero amount must RESET the fee, not skip.
                                  if (totalamount > 0) {
                                    final achPct = surChargeAchper != null
                                        ? (double.tryParse(
                                                surChargeAchper.toString()) ??
                                            0.0)
                                        : 0.0;
                                    final achFlat = surChargeAchflat != null
                                        ? (double.tryParse(
                                                surChargeAchflat.toString()) ??
                                            0.0)
                                        : 0.0;
                                    surchargeamount =
                                        totalamount * achPct / 100 + achFlat;
                                    totalpayamount =
                                        totalamount + surchargeamount;
                                  } else {
                                    surchargeamount = 0.0;
                                    totalpayamount = 0.0;
                                  }
                                } else if (value == 'Card') {
                                  selectedAchIndex = null;
                                  // Recalc card surcharge for current amount.
                                  // The else is what stops an ACH flat fee
                                  // surviving a switch back to Card.
                                  if (totalamount > 0 && surCharge != null) {
                                    surchargeamount =
                                        totalamount * surCharge! / 100;
                                    totalpayamount =
                                        totalamount + surchargeamount;
                                  } else {
                                    surchargeamount = 0.0;
                                    totalpayamount = 0.0;
                                  }
                                }
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 50,
                              // width: 250,
                              // padding:
                              //     const EdgeInsets.only(left: 10, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                color: Colors.white,
                              ),
                              elevation: 0,
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
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 45,
                              padding: EdgeInsets.only(left: 14, right: 14),
                            ),
                          ),
                        ),

                        if (_selectedPaymentMethod == 'Card') ...[
                          SizedBox(height: 10),
                          Text(
                            "Payment Card Details",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: blueColor),
                          ),
                          SizedBox(height: 10),
                        ],
                        if (_selectedPaymentMethod == 'Card')
                          cardDetails == null
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.zero,
                                  child: isloading
                                      ? Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              color: blueColor,
                                              size: 45.0,
                                            ),
                                          ),
                                        )
                                      : _cardOnlyList.isEmpty &&
                                              selectedTenantId == null
                                          ? Container(
                                              height: 50,
                                              child: Center(
                                                  child: Text(
                                                'No Card Found. If you have not selected any lease, please select it first.',
                                                style: TextStyle(
                                                    fontSize: 15, color: grey),
                                              )),
                                            )
                                          : _cardOnlyList.isEmpty
                                              ? Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .2,
                                                  child: Center(
                                                      child: Text(
                                                    'No Cards Available',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  )),
                                                )
                                              : Column(
                                                  children: [
                                                    Column(
                                                      children: _cardOnlyList
                                                          .asMap()
                                                          .entries
                                                          .map((entry) {
                                                        int index = entry.key;
                                                        BillingData item =
                                                            entry.value;
                                                        String currentMonth =
                                                            DateTime.now()
                                                                .month
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0');
                                                        String currentYear =
                                                            DateTime.now()
                                                                .year
                                                                .toString()
                                                                .substring(2);
                                                        String expMonth = item
                                                            .ccExp!
                                                            .substring(0, 2);
                                                        String expYear = item
                                                            .ccExp!
                                                            .substring(2, 4);
                                                        bool isExpired = int
                                                                    .parse(
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
                                                        // A CREDIT card is accepted only when creditCardAccepted; a DEBIT card only when debitCardAccepted (matches web handleSetCardDetails)
                                                        // WEB parity: normalize case before comparing (web lowercases; Admin/Staff uppercase) so a stored "Credit"/"credit" is still recognized.
                                                        final String cardTypeU =
                                                            (item.binResult ?? '')
                                                                .toUpperCase();
                                                        bool isCardAccepted =
                                                            cardTypeU == "DEBIT"
                                                                ? debitCardAccepted
                                                                : (cardTypeU ==
                                                                        "CREDIT" &&
                                                                    creditCardAccepted);
                                                        bool isDisabled = isExpired ||
                                                            (cardTypeU == "CREDIT" &&
                                                                !creditCardAccepted) ||
                                                            (cardTypeU == "DEBIT" &&
                                                                !debitCardAccepted);
                                                        bool isSelected =
                                                            selectedcardindex ==
                                                                index;
                                                        final String brand =
                                                            _resolveCardBrandLabel(
                                                                item.ccType,
                                                                item.ccNumber);
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 12),
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            onTap: (isDisabled ||
                                                                    !isCardAccepted)
                                                                ? null
                                                                : () async {
                                                                    setState(
                                                                        () {
                                                                      selectedcardindex =
                                                                          index;
                                                                    });
                                                                    await fetchSurcharge();
                                                                  },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          14,
                                                                      vertical:
                                                                          14),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isDisabled
                                                                    ? Colors.redAccent.shade100
                                                                    : isSelected
                                                                        ? const Color.fromRGBO(240, 243, 248, 1)
                                                                        : Colors.white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border:
                                                                    Border.all(
                                                                  color: isSelected
                                                                      ? blueColor
                                                                      : Colors
                                                                          .grey
                                                                          .shade300,
                                                                  width:
                                                                      isSelected
                                                                          ? 1.5
                                                                          : 1,
                                                                ),
                                                              ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  isDisabled
                                                                      ? const Icon(
                                                                          Icons
                                                                              .close,
                                                                          color: Colors
                                                                              .red,
                                                                          size:
                                                                              22)
                                                                      : SizedBox(
                                                                          width:
                                                                              24,
                                                                          height:
                                                                              24,
                                                                          child:
                                                                              Checkbox(
                                                                            activeColor:
                                                                                blueColor,
                                                                            checkColor:
                                                                                Colors.white,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(4),
                                                                            ),
                                                                            side:
                                                                                BorderSide(
                                                                              color: isCardAccepted ? blueColor : Colors.grey,
                                                                              width: 1.5,
                                                                            ),
                                                                            value:
                                                                                isSelected,
                                                                            onChanged: isCardAccepted
                                                                                ? (bool? value) async {
                                                                                    setState(() {
                                                                                      selectedcardindex = index;
                                                                                    });
                                                                                    await fetchSurcharge();
                                                                                  }
                                                                                : null,
                                                                          ),
                                                                        ),
                                                                  const SizedBox(
                                                                      width:
                                                                          14),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Text(
                                                                          "CARD NUMBER",
                                                                          style: TextStyle(
                                                                              fontSize: 11,
                                                                              letterSpacing: .5,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Colors.grey),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                2),
                                                                        Text(
                                                                          item.ccNumber!,
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          10),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      if (brand
                                                                          .isNotEmpty)
                                                                        Text(
                                                                          brand,
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor),
                                                                        ),
                                                                      const SizedBox(
                                                                          height:
                                                                              2),
                                                                      Text(
                                                                        '${item.binResult}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    if (!debitCardAccepted &&
                                                        _cardOnlyList.any(
                                                            (item) =>
                                                                (item.binResult ?? '')
                                                                        .toUpperCase() ==
                                                                "DEBIT"))
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            '*DEBIT card is not accepted by Rental Owner',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                    if (!creditCardAccepted &&
                                                        _cardOnlyList.any(
                                                            (item) =>
                                                                (item.binResult ?? '')
                                                                        .toUpperCase() ==
                                                                "CREDIT"))
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'CREDIT card types not accepted by rental owner',
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                ),

                        /* const SizedBox(
                            height: 10,
                          ),*/
                        // if(!creditCardAccepted )
                        //   Text(
                        //     'Credit cards are not accepted.',
                        //     style: TextStyle(
                        //       color: Colors.red,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        //   if(!debitCardAccepted)
                        //     Text(
                        //       'Debit cards are not accepted.',
                        //       style: TextStyle(
                        //         color: Colors.red,
                        //         fontSize: 14,
                        //       ),
                        //     ),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5, left: 16, right: 16, bottom: 10),
                          child: Row(
                            children: [
                              if (state.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    state.errorText ?? '',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        //Text("Note* if Getting Card is Red Background then it is Expired",style: TextStyle(color: blueColor,fontSize: 14,fontWeight: FontWeight.bold),),
                        if (_selectedPaymentMethod == 'Card') ...[
                          GestureDetector(
                            onTap: () async {
                              final newCard = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCard()),
                              );

                              if (newCard != null) {
                                setState(() {
                                  fetchPaymentSettings(
                                      widget.tenantId, leaseid ?? "");
                                });
                              }
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
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              )),
                            ),
                          )
                        ],
                        if (_selectedPaymentMethod == 'ACH') ...[
                          Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Color.fromRGBO(115, 119, 145, 1),
                            //     width: 1,
                            //   ),
                            //   borderRadius: BorderRadius.circular(6),
                            // ),
                            // padding: const EdgeInsets.only(
                            //     left: 8, right: 8, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ACH Account Details",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor),
                                ),
                                SizedBox(height: 10),
                                isLoadingAch
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: SpinKitFadingCircle(
                                              color: blueColor, size: 45.0),
                                        ),
                                      )
                                    : achAccounts.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Text(
                                              'No ACH accounts',
                                              style: TextStyle(
                                                  fontSize: 15, color: grey),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                ...achAccounts
                                                    .asMap()
                                                    .entries
                                                    .map((e) {
                                                  int idx = e.key;
                                                  var acc = e.value;
                                                  String accountName = acc[
                                                              'account_name']
                                                          ?.toString() ??
                                                      acc['account_holder_name']
                                                          ?.toString() ??
                                                      '—';
                                                  String accountNumber =
                                                      acc['account_number']
                                                              ?.toString() ??
                                                          '';
                                                  if (accountNumber.length >
                                                      4) {
                                                    accountNumber = '****' +
                                                        accountNumber.substring(
                                                            accountNumber
                                                                    .length -
                                                                4);
                                                  } else if (accountNumber
                                                      .isNotEmpty) {
                                                    accountNumber =
                                                        accountNumber
                                                            .replaceAll(
                                                                RegExp(r'\d'),
                                                                '*');
                                                  }
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(height: 10),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Checkbox(
                                                            value:
                                                                selectedAchIndex ==
                                                                    idx,
                                                            onChanged: (v) {
                                                              setState(() =>
                                                                  selectedAchIndex =
                                                                      v == true
                                                                          ? idx
                                                                          : null);
                                                            },
                                                            activeColor:
                                                                blueColor,
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                        'Account Holder Name',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                grey,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              2),
                                                                      Text(
                                                                        accountName,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.black87),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 2),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                        'Account Number',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                grey,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              2),
                                                                      Text(
                                                                        accountNumber,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.black87),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      if (idx <
                                                          achAccounts.length -
                                                              1)
                                                        Divider(
                                                          height: 1,
                                                          thickness: 1,
                                                          color: Colors
                                                              .grey.shade300,
                                                        ),
                                                    ],
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final added = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddAchAccount(
                                                    tenantId: widget.tenantId,
                                                    customerVaultId:
                                                        customervaultid
                                                            ?.toString(),
                                                  )),
                                        );
                                        if (added == true && mounted) {
                                          setState(() {
                                            fetchAchFromBillingVault();
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 45,
                                        width: 200,
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
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
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
                SizedBox(
                  height: 15,
                ),
                // if (_selectedPaymentMethod != null && isLoadingamount == false)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Balance : ',
                            style: TextStyle(
                                color: Color.fromRGBO(73, 81, 96, 1),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            formatMoney(lease_data != null ? lease_data!["total_due_amount"] : 0),
                            style: TextStyle(
                                color: Color.fromRGBO(73, 81, 96, 1),
                                fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rent Amount : ",
                            style: TextStyle(
                                color: Color.fromRGBO(73, 81, 96, 1),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          if (lease_data != null && tenants.isNotEmpty)
                            Text(
                              formatMoney(selectedTenantRent),
                              style: TextStyle(
                                  color: Color.fromRGBO(73, 81, 96, 1),
                                  fontSize: 15),
                            ),
                          if (lease_data == null)
                            Text(
                              "\$0.0",
                              style: TextStyle(
                                  color: Color.fromRGBO(73, 81, 96, 1),
                                  fontSize: 15),
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(
                          height: 1, thickness: 1, color: Colors.grey.shade300),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Choose Payment Amount : ',
                            style: TextStyle(
                                color: blueColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildPaymentAmountRadio(
                        value: "full",
                        label: 'Pay Full Amount',
                        selected: selected_account == "full",
                        onChanged: () {
                          setState(() {
                            selected_account = "full";
                            partialamount = false;
                            if (lease_data != null) {
                              totalamount = double.parse((double.tryParse(
                                          lease_data!["total_due_amount"]
                                              .toString()) ??
                                      0.0)
                                  .toStringAsFixed(2));
                              if (totalamount <= 0) {
                                // Web parity: no fee on a zero base.
                                surchargeamount = 0.0;
                              } else if (_selectedPaymentMethod == 'ACH') {
                                final achPct = surChargeAchper != null
                                    ? (double.tryParse(
                                            surChargeAchper.toString()) ??
                                        0.0)
                                    : 0.0;
                                final achFlat = surChargeAchflat != null
                                    ? (double.tryParse(
                                            surChargeAchflat.toString()) ??
                                        0.0)
                                    : 0.0;
                                surchargeamount =
                                    totalamount * achPct / 100 + achFlat;
                              } else if (surCharge != null) {
                                surchargeamount =
                                    totalamount * surCharge! / 100;
                              }
                              totalpayamount = totalamount + surchargeamount;
                              iserror = false;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      _buildPaymentAmountRadio(
                        value: "partial",
                        label: 'Pay Partial Amount ',
                        selected: selected_account == "partial",
                        onChanged: () {
                          setState(() {
                            selected_account = "partial";
                            if (amountController.text.isNotEmpty) {
                              totalamount =
                                  double.tryParse(amountController.text) ?? 0.0;
                              if (totalamount <= 0) {
                                // Web parity: no fee on a zero base.
                                surchargeamount = 0.0;
                              } else if (_selectedPaymentMethod == 'ACH') {
                                final achPct = surChargeAchper != null
                                    ? (double.tryParse(
                                            surChargeAchper.toString()) ??
                                        0.0)
                                    : 0.0;
                                final achFlat = surChargeAchflat != null
                                    ? (double.tryParse(
                                            surChargeAchflat.toString()) ??
                                        0.0)
                                    : 0.0;
                                surchargeamount =
                                    totalamount * achPct / 100 + achFlat;
                              } else if (surCharge != null) {
                                surchargeamount =
                                    totalamount * surCharge! / 100;
                              } else {
                                surchargeamount = 0.0;
                              }
                              totalpayamount = totalamount + surchargeamount;
                              partialamount = true;
                              iserror = false;
                            } else {
                              totalamount = 0.0;
                              totalpayamount = 0.0;
                              surchargeamount = 0.0;
                              partialamount = true;
                              iserror = true;
                            }
                          });
                        },
                      ),
                      if (partialamount) ...[
                        SizedBox(height: 12),
                        Container(
                          // decoration: BoxDecoration(
                          //   color: Colors.grey.shade50,
                          //   borderRadius: BorderRadius.circular(6),
                          //   border: Border.all(color: Colors.grey.shade300),
                          // ),
                          child: CustomTextField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter amount';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            borderColor: Colors.grey.shade300,
                            borderWidth: 1,
                            showElevation: false,
                            hintText: 'Enter Amount',
                            controller: amountController
                              ..text = lease_data != null &&
                                      (double.tryParse(lease_data![
                                                      "total_due_amount"]
                                                  .toString()) ??
                                              0.0) >
                                          0
                                  ? amountController.text
                                  : '0',
                            onChanged: (value) {
                              setState(() {
                                final limitVal = double.tryParse(
                                    value.trim().replaceAll(',', ''));
                                _amountLimitError = (limitVal != null &&
                                        limitVal > 999999.99)
                                    ? 'Amount cannot exceed \$999,999.99'
                                    : null;
                                if (value.isNotEmpty && lease_data != null) {
                                  double inputAmount =
                                      double.tryParse(value) ?? 0.0;
                                  // WEB parity: web's handlePartialAmountChange only sanitizes
                                  // the input and does NOT cap it at total_due_amount, so a
                                  // tenant may overpay (prepay). Mobile no longer caps it.
                                  totalamount = inputAmount;
                                  totalpayamount = inputAmount;
                                  if (inputAmount <= 0) {
                                    // A zero amount attracts no fee. The ACH
                                    // flat fee is amount-independent, so
                                    // without this it turned $0 into a
                                    // fee-only payment.
                                    surchargeamount = 0.0;
                                    totalpayamount = 0.0;
                                  } else if (_selectedPaymentMethod == 'ACH') {
                                    final achPct = surChargeAchper != null
                                        ? (double.tryParse(
                                                surChargeAchper.toString()) ??
                                            0.0)
                                        : 0.0;
                                    final achFlat = surChargeAchflat != null
                                        ? (double.tryParse(
                                                surChargeAchflat.toString()) ??
                                            0.0)
                                        : 0.0;
                                    surchargeamount =
                                        totalamount * achPct / 100 + achFlat;
                                    totalpayamount += surchargeamount;
                                  } else if (surCharge != null) {
                                    surchargeamount =
                                        totalamount * surCharge! / 100;
                                    totalpayamount += surchargeamount;
                                  }
                                  iserror = false;
                                } else {
                                  if (lease_data == null)
                                    amountController.text = "0";
                                  totalamount = 0.0;
                                  totalpayamount = 0.0;
                                  surchargeamount = 0.0;
                                  iserror = true;
                                }
                              });
                            },
                          ),
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
                      ],
                      SizedBox(height: 8),
                      _buildPaymentAmountRadio(
                        value: "rent",
                        label:
                            'Pay Rent Amount${lease_data != null && tenants.isNotEmpty ? " ${formatMoney(selectedTenantRent)}" : ""}',
                        selected: selected_account == "rent",
                        onChanged: () {
                          setState(() {
                            selected_account = "rent";
                            partialamount = false;
                            if (lease_data != null) {
                              totalamount = selectedTenantRent;
                              if (totalamount <= 0) {
                                // Web parity: no fee on a zero base.
                                surchargeamount = 0.0;
                              } else if (_selectedPaymentMethod == 'ACH') {
                                final achPct = surChargeAchper != null
                                    ? (double.tryParse(
                                            surChargeAchper.toString()) ??
                                        0.0)
                                    : 0.0;
                                final achFlat = surChargeAchflat != null
                                    ? (double.tryParse(
                                            surChargeAchflat.toString()) ??
                                        0.0)
                                    : 0.0;
                                surchargeamount =
                                    totalamount * achPct / 100 + achFlat;
                              } else if (surCharge != null) {
                                surchargeamount =
                                    totalamount * surCharge! / 100;
                              }
                              totalpayamount = totalamount + surchargeamount;
                            }
                            iserror = false;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Divider(
                          height: 1, thickness: 1, color: Colors.grey.shade300),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment : ',
                            style: TextStyle(
                                color: Color.fromRGBO(73, 81, 96, 1),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            formatMoney(totalamount < 0 ? 0 : totalamount),
                            style: TextStyle(
                                color: Color.fromRGBO(73, 81, 96, 1),
                                fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Surcharge : ',
                            style: TextStyle(
                                color: Color.fromRGBO(73, 81, 96, 1),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            formatMoney(surchargeamount < 0 ? 0 : surchargeamount),
                            style: TextStyle(
                                color: Color.fromRGBO(73, 81, 96, 1),
                                fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(
                          height: 1, thickness: 1, color: Colors.grey.shade300),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount to Pay : ',
                            style: TextStyle(
                                color: blueColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatMoney(totalpayamount < 0 ? 0 : totalpayamount),
                            style: TextStyle(
                                color: blueColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                //Google Pay / Apple Pay Button
                if (totalpayamount > 0.0 && selectedTenantId != null)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Prepare payment entries
                            List<Map<String, dynamic>> manualEntries = [
                              {
                                "account": selected_account == "rent"
                                    ? "Rent Income"
                                    : "Payment",
                                "amount": totalamount,
                                "memo": selected_account == "rent"
                                    ? "Rent Income"
                                    : "Payment",
                                "date": _normalizeToIsoDate(_startDate.text),
                                "charge_type": selected_account == "rent"
                                    ? "Rent"
                                    : "Payment",
                              }
                            ];

                            // Navigate to CheckoutScreen for Google/Apple Pay
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(
                                  amount: totalpayamount,
                                  tenantId: widget.tenantId,
                                  leaseId: selectedTenantId ?? "",
                                  paymentAmountType: selected_account ?? "full",
                                  entries: manualEntries,
                                  surchargeamount: surchargeamount,
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                // Payment successful, refresh or navigate back
                                Navigator.pop(context, true);
                              }
                            });
                          },
                          child: Container(
                            height: 50,
                            // width: 250,
                            margin: EdgeInsets.only(left: 0, bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Pay with Google/Apple Pay",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                      child: GestureDetector(
                        onTap: () async {
                          if (_saleInFlight) return;
                          if ((_formKey.currentState?.validate() ?? false) &&
                              (!partialamount || _amountLimitError == null)) {
                            // Web parity (AddPaymentByTenant.jsx handleSubmit):
                            // the gate is the ENTERED amount, never base + fee.
                            // Gating on totalpayamount let a stale surcharge
                            // stand in for the amount and submit a $0 payment
                            // that still charged the convenience fee.
                            if (totalamount <= 0.0) {
                              // Same message as web and as Admin/Staff
                              // make_payment; the field's own validator is
                              // ignored by this CustomTextField, so the
                              // refusal has to be stated here.
                              Fluttertoast.showToast(
                                  msg: "Please enter a valid amount");
                              return;
                            }
                            if (totalamount > 0.0) {
                              setState(() {
                                iserror = false;
                                IsLoading = true;
                              });

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? id = prefs.getString('adminId');
                              String? first_name =
                                  prefs.getString("first_name");
                              String? last_name = prefs.getString("last_name");
                              String? email = prefs.getString("email");
                              List<Map<String, dynamic>> filteredTenants =
                                  tenants.where((tenant) {
                                return tenant['tenant_id'] == selectedTenantId;
                              }).toList();
                              if (filteredTenants.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "Please select a tenant");
                                setState(() => IsLoading = false);
                                return;
                              }
                              Map<String, dynamic> selectedTenant =
                                  filteredTenants.first;
                              final DateFormat formatter =
                                  DateFormat('yyyy-MM-dd HH:mm:ss');
                              String notificationTime =
                                  formatter.format(DateTime.now());
                              List<Map<String, dynamic>> manualEntries = [
                                {
                                  "account": selected_account == "rent"
                                      ? "Rent Income"
                                      : "Payment",
                                  "amount": totalamount,
                                  "memo": selected_account == "rent"
                                      ? "Rent Income"
                                      : "Payment",
                                  "date": _normalizeToIsoDate(_startDate.text),
                                  "charge_type": selected_account == "rent"
                                      ? "Rent"
                                      : "Payment",
                                }
                              ];
                              if (_selectedPaymentMethod == 'ACH' &&
                                  selectedAchIndex != null &&
                                  selectedAchIndex! < achAccounts.length) {
                                final ach = achAccounts[selectedAchIndex!];
                                final String checkname = ach['account_name']
                                        ?.toString() ??
                                    ach['account_holder_name']?.toString() ??
                                    '';
                                final String accountType =
                                    ach['account_type']?.toString() ??
                                        'Checking';
                                final String holderType =
                                    ach['account_holder_type']?.toString() ??
                                        'Personal';
                                final String checkaccount =
                                    ach['account_number']?.toString() ?? '';
                                final String checkaba =
                                    ach['routing_number']?.toString() ?? '';
                                final String? billingId =
                                    ach['billing_id']?.toString();
                                final String? customerVaultId =
                                    customervaultid?.toString();
                                final String processorId =
                                    lease_data?['processorId']?.toString() ??
                                        '';
                                await _snapshotLedgerBeforeSale(widget.tenantId);
                                _beginSale();
                                await PaymentService()
                                    .makePaymentforach(
                                  idempotencyKey: _saleIdempotencyKey,
                                  adminId: id ?? "",
                                  firstName: first_name ?? "",
                                  lastName: last_name ?? "",
                                  emailName: email ?? "",
                                  surcharge: surchargeamount.toStringAsFixed(2),
                                  amount: totalamount.toStringAsFixed(2),
                                  tenantId: widget.tenantId,
                                  date: _normalizeToIsoDate(_startDate.text),
                                  address1: checkname,
                                  processorId: processorId,
                                  leaseid: selectedTenantId!,
                                  company_name: companyName,
                                  account_type: accountType,
                                  account_holder_type: holderType,
                                  checkaccount: checkaccount,
                                  checkaba: checkaba,
                                  checkname: checkname,
                                  future_Date: futuredate!,
                                  entries: manualEntries,
                                  billingId: billingId,
                                  customerVaultId: customerVaultId,
                                  paymentAmountType: selected_account ?? 'full',
                                )
                                    .then((value) {
                                  _settleSaleKey();
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() => IsLoading = false);
                                  Navigator.pop(context, true);
                                }).catchError((e) async {
                                  _settleSaleKey(e);
                                  await _handleSaleFailure(
                                    e,
                                    tenantId: widget.tenantId,
                                    amount: totalamount,
                                  );
                                  if (mounted) {
                                    setState(() => IsLoading = false);
                                  }
                                });
                                return;
                              }
                              if (selectedcardindex == null ||
                                  selectedcardindex! < 0 ||
                                  selectedcardindex! >= _cardOnlyList.length) {
                                Fluttertoast.showToast(
                                    msg: "Please select a card");
                                setState(() => IsLoading = false);
                                return;
                              }
                              final BillingData selectedBilling =
                                  _cardOnlyList[selectedcardindex!];
                              try {
                                await _snapshotLedgerBeforeSale(widget.tenantId);
                                _beginSale();
                                await PaymentService()
                                    .makePaymentforcard(
                                  idempotencyKey: _saleIdempotencyKey,
                                  scheduledPayment: scheduledPayment ?? false,
                                  entries: manualEntries,
                                  paymentAmountType: selected_account ?? '',
                                  adminId: id ?? "",
                                  firstName: first_name ?? "",
                                  lastName: last_name ?? "",
                                  emailName: email ?? "",
                                  customerVaultId:
                                      selectedBilling.customerVaultId ?? "",
                                  billingId: selectedBilling.billingId ?? "",
                                  surcharge: surchargeamount.toStringAsFixed(2),
                                  amount: totalamount.toStringAsFixed(2),
                                  tenantId: widget.tenantId,
                                  date: _normalizeToIsoDate(_startDate.text),
                                  address1: selectedBilling.address_1 ?? "",
                                  processorId:
                                      lease_data?['processorId']?.toString() ??
                                          "",
                                  leaseid: selectedTenantId!,
                                  company_name: companyName,
                                  future_Date: futuredate!,
                                  notificationTime: notificationTime,
                                )
                                    .then((value) {
                                  _settleSaleKey();
                                  Fluttertoast.showToast(msg: "$value");
                                  setState(() {
                                    IsLoading = false;
                                  });
                                  Navigator.pop(context, true);
                                }).catchError((e) async {
                                  _settleSaleKey(e);
                                  await _handleSaleFailure(
                                    e,
                                    tenantId: widget.tenantId,
                                    amount: totalamount,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      IsLoading = false;
                                    });
                                  }
                                });
                              } catch (e) {
                                _settleSaleKey(e);
                                setState(() => IsLoading = false);
                                Fluttertoast.showToast(
                                    msg: friendlyErrorMessage(e,
                                        networkMessage:
                                            paymentNetworkErrorMessage));
                              }
                            } else {
                              setState(() {
                                //iserror = totalpayamount < 0.0;
                                iserror = true;
                                isLoading = false;
                              });
                            }
                          } else {
                            setState(() {
                              //iserror = totalpayamount < 0.0;
                              // iserror = true;
                              //print("iserror $iserror");
                              isLoading = false;
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          // width: 130,
                          margin: EdgeInsets.only(left: 0, bottom: 0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: blueColor),
                          child: IsLoading
                              ? Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 42.0,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                  "Make Payment ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoadingamount)
                  Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 45.0,
                    ),
                  ),
                if (selectedTenantId != null &&
                    iserror) // Conditionally show error message
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Payment cannot be processed due to a negative balance.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: scheduledPayment,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      activeColor: blueColor,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      onChanged: (value) {
                        setState(() {
                          scheduledPayment = value!;
                        });
                      },
                    ),
                    Text(
                      "Schedule Payment",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: blueColor),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],

              // add a checkbox to schedule the payment
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentAmountRadio({
    required String value,
    required String label,
    required bool selected,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onChanged,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? blueColor : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
            color: selected ? blueColor.withOpacity(0.08) : Colors.white,
          ),
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Radio<String>(
                  value: value,
                  groupValue: selected_account,
                  activeColor: blueColor,
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected))
                      return blueColor;
                    return Colors.grey.shade400;
                  }),
                  onChanged: (_) => onChanged(),
                ),
              ),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: blueColor,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              formatMoney(amount),
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
          surchargecount = ((double.tryParse(amountController.text) ?? 0.0) *
                  surChargeAchper /
                  100) +
              surChargeAchflat;
          finaltotal =
              (double.tryParse(amountController.text) ?? 0.0) + surchargecount!;
        });
      } else if (_selectedPaymentMethod == "ACH" &&
          (surChargeAchflat != null || surChargeAchflat != 0.0)) {
        setState(() {
          surchargecount = double.tryParse(surChargeAchflat.toString()) ?? 0.0;
          finaltotal =
              (double.tryParse(amountController.text) ?? 0.0) + surchargecount!;
          // surchargecount = (double.tryParse(amountController.text) ?? 0.0) * surChargeAchper /100;
        });
      } else if (_selectedPaymentMethod == "ACH" &&
          (surChargeAchper != null || surChargeAchper != 0.0)) {
        setState(() {
          surchargecount = ((double.tryParse(amountController.text) ?? 0.0) *
              surChargeAchper /
              100);
          finaltotal =
              (double.tryParse(amountController.text) ?? 0.0) + surchargecount!;
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

  // Display-only: resolves the card network brand for the card list.
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

  String _normalizeToIsoDate(String inputDate) {
    inputDate = inputDate.trim();
    final List<String> formats = [
      'yyyy-MM-dd',
      'yyyy-M-d',
      'MM/dd/yyyy',
      'M/d/yyyy',
      'dd-MM-yyyy',
      'd-M-yyyy',
    ];
    for (final fmt in formats) {
      try {
        final parsed = DateFormat(fmt).parseStrict(inputDate);
        return DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {}
    }
    return inputDate;
  }
}
