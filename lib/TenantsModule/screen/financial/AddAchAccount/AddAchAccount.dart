import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart' as admin_appbar;
import 'package:three_zero_two_property/widgets/custom_drawer.dart' as admin_drawer;
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart' as staff_appbar;
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart';

/// Full-screen form to add a new ACH account for the tenant.
/// POST to add-tenant-ach; backend expects check_name (Account Holder Name).
class AddAchAccount extends StatefulWidget {
  final String tenantId;

  /// Optional: when set, existing ACH accounts from get-billing-customer-vault are shown in card style.
  final String? customerVaultId;

  /// Optional: when set, used as fallback to fetch vault_id from payment history if getCreditCards returns 404.
  final String? leaseId;

  /// When true (e.g. staff Make Payment flow), HTTP `id` header uses `staff_id` instead of `tenant_id`.
  final bool authAsStaff;

  /// When true (admin Make Payment), HTTP `id` header uses `adminId` instead of `tenant_id`.
  final bool authAsAdmin;

  const AddAchAccount(
      {Key? key,
      required this.tenantId,
      this.customerVaultId,
      this.leaseId,
      this.authAsStaff = false,
      this.authAsAdmin = false})
      : super(key: key);

  @override
  State<AddAchAccount> createState() => _AddAchAccountState();
}

class _AddAchAccountState extends State<AddAchAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _accountHolderName = TextEditingController();
  final TextEditingController _routingNumber = TextEditingController();
  final TextEditingController _accountNumber = TextEditingController();

  String? _accountType; // Checking, Savings
  String? _accountHolderType; // Personal, Business
  bool _isSubmitting = false;
  String? _validationError;
  Map<String, dynamic>? _profileData;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _existingAchAccounts = [];
  bool _loadingExisting = true;
  String? _resolvedVaultId;

  static const List<String> _accountTypes = ['Checking', 'Savings'];
  static const List<String> _holderTypes = ['Personal', 'Business'];

  static String? _extractString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    if (v is num) return v.toString();
    if (v is Map && v.isEmpty) return null;
    return v.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _resolvedVaultId = widget.customerVaultId;
    if (_resolvedVaultId != null && _resolvedVaultId!.isNotEmpty) {
      _loadExistingAchAccounts();
    } else {
      _fetchVaultIdThenLoadAccounts();
    }
  }

  Future<void> _fetchVaultIdThenLoadAccounts() async {
    if (kDebugMode) debugPrint('[ACH] _fetchVaultIdThenLoadAccounts START tenantId=${widget.tenantId} authAsAdmin=${widget.authAsAdmin} authAsStaff=${widget.authAsStaff}');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? headerId = _headerIdForRequest(prefs);
      String? token = prefs.getString('token');
      if (kDebugMode) debugPrint('[ACH] headerId=$headerId token=${token != null ? 'set' : 'NULL'}');
      if (headerId == null || token == null) {
        if (kDebugMode) debugPrint('[ACH] EARLY RETURN — headerId or token is null');
        if (mounted) setState(() => _loadingExisting = false);
        return;
      }
      final url = '$Api_url/api/creditcard/getCreditCards/${widget.tenantId}';
      if (kDebugMode) debugPrint('[ACH] GET $url');
      final response = await apiGet(
        Uri.parse(url),
        headers: {
          'id': 'CRM $headerId',
          'authorization': 'CRM $token',
        },
      );
      if (kDebugMode) debugPrint('[ACH] getCreditCards status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final vaultId = jsonResponse['customer_vault_id']?.toString();
        if (kDebugMode) debugPrint('[ACH] vaultId=$vaultId');
        if (vaultId != null && vaultId.isNotEmpty && mounted) {
          setState(() => _resolvedVaultId = vaultId);
          await _loadExistingAchAccounts();
          return;
        } else {
          if (kDebugMode) debugPrint('[ACH] vaultId null/empty — trying payment history fallback');
        }
      } else if (response.statusCode == 404 && widget.leaseId != null) {
        // No credit cards — try to find vault_id from ACH payment history
        if (kDebugMode) debugPrint('[ACH] getCreditCards 404 — trying payment history fallback for leaseId=${widget.leaseId}');
        final vaultId = await _fetchVaultIdFromPaymentHistory(headerId!, token!);
        if (vaultId != null && mounted) {
          setState(() => _resolvedVaultId = vaultId);
          await _loadExistingAchAccounts();
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ACH] ERROR in _fetchVaultIdThenLoadAccounts: $e');
    }
    if (mounted) setState(() => _loadingExisting = false);
  }

  Future<String?> _fetchVaultIdFromPaymentHistory(String headerId, String token) async {
    try {
      final historyUrl = '$Api_url/api/payment/charges_payments/${widget.leaseId}';
      if (kDebugMode) debugPrint('[ACH] GET $historyUrl (vault_id fallback)');
      final res = await apiGet(
        Uri.parse(historyUrl),
        headers: {'id': 'CRM $headerId', 'authorization': 'CRM $token'},
      );
      if (kDebugMode) debugPrint('[ACH] payment history status=${res.statusCode}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        final j = json.decode(res.body);
        final data = j is Map ? j['data'] : null;
        if (data is List) {
          for (final item in data) {
            if (item is! Map) continue;
            final vaultId = item['customer_vault_id']?.toString();
            if (vaultId != null && vaultId.isNotEmpty && vaultId != 'null') {
              if (kDebugMode) debugPrint('[ACH] Found vault_id=$vaultId from payment history');
              return vaultId;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ACH] ERROR in _fetchVaultIdFromPaymentHistory: $e');
    }
    if (kDebugMode) debugPrint('[ACH] No vault_id found in payment history');
    return null;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _accountHolderName.dispose();
    _routingNumber.dispose();
    _accountNumber.dispose();
    super.dispose();
  }

  String? _headerIdForRequest(SharedPreferences prefs) {
    if (widget.authAsStaff) return prefs.getString('staff_id');
    if (widget.authAsAdmin) return prefs.getString('adminId');
    return prefs.getString('tenant_id');
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? headerId = _headerIdForRequest(prefs);
    String? token = prefs.getString('token');
    if (headerId == null || token == null) return;
    try {
      final response = await apiGet(
        Uri.parse('$Api_url/api/tenant/tenant_profile/${widget.tenantId}'),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $headerId',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['statusCode'] == 200 && data['data'] != null) {
          setState(() {
            _profileData = data['data'] as Map<String, dynamic>;
            _firstName.text =
                _profileData!['tenant_firstName']?.toString() ?? '';
            _lastName.text = _profileData!['tenant_lastName']?.toString() ?? '';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadExistingAchAccounts() async {
    final vaultId = _resolvedVaultId ?? widget.customerVaultId;
    if (kDebugMode) debugPrint('[ACH] _loadExistingAchAccounts START vaultId=$vaultId');
    if (vaultId == null || vaultId.isEmpty) {
      if (kDebugMode) debugPrint('[ACH] _loadExistingAchAccounts EARLY RETURN — vaultId null/empty');
      if (mounted) setState(() => _loadingExisting = false);
      return;
    }
    if (mounted) setState(() => _loadingExisting = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // id header: staff_id for staff, adminId for admin — matches make_payment.dart
      String? headerId = _headerIdForRequest(prefs);
      String? adminId = prefs.getString('adminId');
      String? token = prefs.getString('token');
      if (kDebugMode) debugPrint('[ACH] _loadExistingAchAccounts headerId=$headerId adminId=$adminId token=${token != null ? 'set' : 'NULL'}');
      if (headerId == null || adminId == null || token == null) {
        if (kDebugMode) debugPrint('[ACH] _loadExistingAchAccounts EARLY RETURN — headerId/adminId/token null');
        if (mounted) setState(() => _loadingExisting = false);
        return;
      }
      final postUrl = '$Api_url/api/nmipayment/get-billing-customer-vault';
      if (kDebugMode) debugPrint('[ACH] POST $postUrl body={"customer_vault_id":"$vaultId","admin_id":"$adminId"}');
      final response = await apiPost(
        Uri.parse(postUrl),
        headers: {
          'Content-Type': 'application/json',
          'id': 'CRM $headerId',
          'authorization': 'CRM $token',
        },
        body: json.encode({
          'customer_vault_id': vaultId,
          'admin_id': adminId,
        }),
      );
      if (kDebugMode) debugPrint('[ACH] get-billing-customer-vault status=${response.statusCode} body=${response.body}');
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        final jsonResponse = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        var data = jsonResponse is Map ? jsonResponse['data'] : null;
        var customer = data is Map ? data['customer'] : null;
        var rawBilling = customer is Map ? customer['billing'] : null;
        if (kDebugMode) debugPrint('[ACH] rawBilling type=${rawBilling?.runtimeType} value=$rawBilling');

        // billing can be a List (multiple entries) or a Map (single entry from XML conversion)
        List billingList = [];
        if (rawBilling is List) {
          billingList = rawBilling;
        } else if (rawBilling is Map) {
          billingList = [rawBilling];
        }
        if (kDebugMode) debugPrint('[ACH] billingList.length=${billingList.length}');

        for (var item in billingList) {
          if (item is! Map) continue;
          String? checkAccount = _extractString(item['check_account']);
          String? checkName = _extractString(item['check_name']);
          if (kDebugMode) debugPrint('[ACH] billing item: check_name=$checkName check_account=$checkAccount');
          if ((checkAccount != null && checkAccount.isNotEmpty) ||
              (checkName != null && checkName.isNotEmpty)) {
            // Capture billing_id so a specific ACH entry can be deleted
            // (NMI returns it under @attributes.id, or a flat billing_id).
            String? billingId;
            final attrs = item['@attributes'];
            if (attrs is Map && attrs['id'] != null) {
              billingId = attrs['id'].toString();
            } else if (item['billing_id'] != null) {
              billingId = item['billing_id'].toString();
            }
            list.add({
              'account_name': checkName ?? '',
              'account_number': checkAccount ?? '',
              'account_type': _extractString(item['account_type']) ?? '',
              'account_holder_type':
                  _extractString(item['account_holder_type']) ?? '',
              'billing_id': billingId,
            });
          }
        }
        if (kDebugMode) debugPrint('[ACH] ACH accounts extracted: ${list.length}');
        if (mounted) {
          setState(() {
            _existingAchAccounts = list;
            _loadingExisting = false;
          });
        }
      } else {
        if (kDebugMode) debugPrint('[ACH] get-billing-customer-vault failed or not mounted');
        if (mounted) setState(() => _loadingExisting = false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ACH] ERROR in _loadExistingAchAccounts: $e');
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  // Swipe-to-delete confirmation popup (mirrors the web "Are you sure?" card dialog).
  Future<void> _confirmDeleteAch(Map<String, dynamic> acc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 3),
              ),
              child: const Icon(Icons.priority_high,
                  color: Colors.orange, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Are you sure?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Once deleted, you will not be able to recover this ACH account!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFDECEC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await _deleteAchAccount(acc);
    }
  }

  // Deletes one ACH account. Uses the exact same two calls as the card delete
  // (billing-level only — never delete-customer-vault — so saved cards stay).
  Future<void> _deleteAchAccount(Map<String, dynamic> acc) async {
    final billingId = acc['billing_id']?.toString();
    final vaultId = _resolvedVaultId;
    if (billingId == null ||
        billingId.isEmpty ||
        vaultId == null ||
        vaultId.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Unable to delete this ACH account (missing reference).');
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? headerId = _headerIdForRequest(prefs);
      String? adminId = prefs.getString('adminId');
      String? token = prefs.getString('token');
      if (headerId == null || token == null) {
        Fluttertoast.showToast(msg: 'Session expired. Please log in again.');
        return;
      }
      final headers = {
        'Content-Type': 'application/json',
        'authorization': 'CRM $token',
        'id': 'CRM $headerId',
      };
      // 1) Remove from the NMI customer vault (billing-level).
      final nmiRes = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/delete-customer-billing'),
        headers: headers,
        body: json.encode({
          'admin_id': adminId ?? '',
          'customer_vault_id': vaultId,
          'billing_id': billingId,
        }),
      );
      // 2) Remove the DB record.
      final dbRes = await apiDelete(
        Uri.parse('$Api_url/api/creditcard/deleteCreditCard/$billingId'),
        headers: headers,
        body: json.encode({'tenant_id': widget.tenantId}),
      );
      if (nmiRes.statusCode == 200 && dbRes.statusCode == 200) {
        Fluttertoast.showToast(msg: 'ACH account deleted successfully');
        if (_resolvedVaultId != null && _resolvedVaultId!.isNotEmpty) {
          await _loadExistingAchAccounts();
        } else {
          await _fetchVaultIdThenLoadAccounts();
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to delete ACH account');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ACH] delete error: $e');
      Fluttertoast.showToast(msg: 'Failed to delete ACH account');
    }
  }

  Future<bool> _submit() async {
    if (_accountType == null ||
        _accountHolderType == null ||
        _accountHolderName.text.trim().isEmpty ||
        _routingNumber.text.trim().isEmpty ||
        _accountNumber.text.trim().isEmpty) {
      setState(() => _validationError = 'Please fill all the required fields*');
      return false;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    setState(() {
      _validationError = null;
      _isSubmitting = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString('adminId');
    String? headerId = _headerIdForRequest(prefs);
    String? token = prefs.getString('token');
    if (headerId == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return false;
    }

    final String url = '$Api_url/api/nmipayment/tenant/add-tenant-ach-mobile';
    final String accountHolderName = _accountHolderName.text.trim();
    final Map<String, dynamic> body = {
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'account_type': _accountType!,
      'account_holder_type': _accountHolderType!,
      'account_name': accountHolderName,
      // 'check_name':
      //     accountHolderName, // Backend requires check_name (NMI field)
      'routing_number': _routingNumber.text.trim(),
      'account_number': _accountNumber.text.trim(),
      'tenant_id': widget.tenantId,
      'admin_id': adminId ?? '',
      'user_active_recently': true,
      'is_web': false,
    };
    if (kDebugMode) {
      final masked = Map<String, dynamic>.from(body)
        ..['account_number'] = '****'
        ..['routing_number'] = '****';
      debugPrint('add-tenant-ach body $masked');
    }
    try {
      final response = await apiPost(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'id': 'CRM $headerId',
          'authorization': 'CRM $token',
        },
        body: json.encode(body),
      );
      if (kDebugMode) {
        debugPrint('add-tenant-ach status ${response.statusCode}');
      }
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Fluttertoast.showToast(msg: 'ACH account added successfully');
          await _fetchVaultIdThenLoadAccounts();
          Navigator.pop(context, true);
          return true;
        } else {
          final err = json.decode(response.body);
          setState(() {
            final data = err is Map ? err['data'] : null;
            final dataError = data is Map ? data['error']?.toString() : null;
            _validationError = dataError ??
                err['message']?.toString() ??
                'Failed to add ACH account';
          });
          return false;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _validationError = 'Network error. Please try again.';
        });
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: widget.authAsAdmin
          ? admin_appbar.widget_302.App_Bar(context: context)
          : widget.authAsStaff
              ? staff_appbar.widget_302_Staff.App_Bar(context: context)
              : widget_302.App_Bar(
                  context: context,
                  onDrawerIconPressed: () => key.currentState?.openDrawer(),
                ),
      backgroundColor: Colors.white,
      drawer: widget.authAsAdmin
          ? admin_drawer.CustomDrawer(currentpage: 'Leases', dropdown: true)
          : widget.authAsStaff
              ? CustomDrawerStaff(currentpage: 'Leases', dropdown: true)
              : CustomDrawer(currentpage: 'Financial'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBar(
                  width: MediaQuery.of(context).size.width * .91,
                  title: 'Add a new ACH account'),
              const SizedBox(height: 20),
              _buildLabel('First Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _firstName,
                decoration: _inputDecoration('First Name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Last Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _lastName,
                decoration: _inputDecoration('Last Name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Account Type *'),
              const SizedBox(height: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Text('Account Type',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ),
                  value: _accountType,
                  selectedItemBuilder: (context) => _accountTypes
                      .map((e) => Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(e,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  items: _accountTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _accountType = v),
                  buttonStyleData: ButtonStyleData(
                    height: 48,
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: blueColor.withOpacity(0.6)),
                      color: Colors.white,
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Account Holder Type *'),
              const SizedBox(height: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Text('Account Holder Type',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ),
                  value: _accountHolderType,
                  selectedItemBuilder: (context) => _holderTypes
                      .map((e) => Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(e,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  items: _holderTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _accountHolderType = v),
                  buttonStyleData: ButtonStyleData(
                    height: 48,
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: blueColor.withOpacity(0.6)),
                      color: Colors.white,
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Account Holder Name *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountHolderName,
                decoration: _inputDecoration('Account Holder Name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Bank Routing Number *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _routingNumber,
                decoration: _inputDecoration('Routing Number'),
                keyboardType: TextInputType.number,
                maxLength: 9,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(r'^\d+$').hasMatch(v.trim()))
                    return 'Only numbers allowed';
                  if (v.trim().length != 9)
                    return 'Routing number must be 9 digits';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildLabel('Bank Account Number *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountNumber,
                decoration: _inputDecoration('Account Number'),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(r'^\d+$').hasMatch(v.trim()))
                    return 'Only numbers allowed';
                  return null;
                },
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _validationError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
              const SizedBox(height: 12),
              ...[
                Text(
                  'ACH Accounts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                SizedBox(height: 8),
                // Hint shown only when there is at least one saved ACH account.
                if (!_loadingExisting && _existingAchAccounts.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: blueColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: blueColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swipe_left, size: 16, color: blueColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Note: Swipe left on an account to delete',
                            style: TextStyle(
                                fontSize: 12,
                                color: blueColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                _loadingExisting
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child:
                              SpinKitFadingCircle(color: blueColor, size: 40),
                        ),
                      )
                    : _existingAchAccounts.isEmpty
                        ? Text(
                            'No ACH accounts yet.',
                            style: TextStyle(fontSize: 14, color: grey),
                          )
                        : Column(
                            children: _existingAchAccounts.map((acc) {
                              String name = acc['account_name']?.toString() ??
                                  acc['account_holder_name']?.toString() ??
                                  '—';
                              String num =
                                  acc['account_number']?.toString() ?? '';
                              if (num.length > 4)
                                num = '****${num.substring(num.length - 4)}';
                              else if (num.isNotEmpty)
                                num = num.replaceAll(RegExp(r'\d'), '*');
                              String type =
                                  acc['account_type']?.toString() ?? '—';
                              String holderType =
                                  acc['account_holder_type']?.toString() ?? '—';
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, top: 8),
                                child: Slidable(
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) => _confirmDeleteAch(acc),
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: blueColor.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Account Holder Name',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: grey,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(height: 4),
                                            Text(name,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87)),
                                            const SizedBox(height: 12),
                                            Text('Account Type',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: grey,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(height: 4),
                                            Text(type,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Account Number',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: grey,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(height: 4),
                                            Text(num,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87)),
                                            const SizedBox(height: 12),
                                            Text('Account Holder Type',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: grey,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(height: 4),
                                            Text(holderType,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            }).toList(),
                          ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                        onTap: () => _submit(),
                        child: Container(
                          height: 45,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: SpinKitFadingCircle(
                                      color: Colors.white, size: 24))
                              : Center(
                                  child: Text('Add ACH Account',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold))),
                        )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 45,
                        child: Center(
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold))),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: blueColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
