import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:three_zero_two_property/widgets/collectjs_card_field.dart';
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
  // Distinguishes "no accounts on file" from "the list could not be loaded".
  bool _existingLoadFailed = false;
  // Set when the secure-field key could not be fetched.
  bool _keyLoadFailed = false;

  // PCI: Collect.js ACH tokenization — replaces the raw routing/account inputs.
  // Sends a payment_token (+ the masked account/routing Collect.js returns) to
  // add-tenant-ach (the token-aware web route); raw account/routing never leave
  // the app.
  final CollectJsController _achCtrl = CollectJsController();
  String? _publicKey;
  bool _achReady = false;

  static const List<String> _accountTypes = ['Checking', 'Savings'];
  static const List<String> _holderTypes = ['Personal', 'Business'];

  // Web parity (AddACHForm.jsx): the submit button stays disabled until the
  // required NATIVE fields are filled. The Collect.js bank fields validate
  // themselves on submit, so they're excluded here — same as the web.
  bool get _requiredFieldsFilled =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _accountType != null &&
      _accountHolderType != null;

  void _onRequiredChanged() {
    if (mounted) setState(() {});
  }

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
    // Re-evaluate the submit button as the name fields change (web parity).
    _firstName.addListener(_onRequiredChanged);
    _lastName.addListener(_onRequiredChanged);
    _loadProfile();
    _loadLeaseResidents();
    _fetchTokenizationKey();
    _resolvedVaultId = widget.customerVaultId;
    if (_resolvedVaultId != null && _resolvedVaultId!.isNotEmpty) {
      _loadExistingAchAccounts();
    } else {
      _fetchVaultIdThenLoadAccounts();
    }
  }

  // ── Resident picker (web parity: AddACHDetailsForm staffResidentPicker) ────
  // Web shows a "Select A Resident" dropdown when an Admin/Staff user adds an
  // ACH account, so on a multi-tenant lease they choose WHICH resident the
  // account belongs to. Without it every account was filed against whichever
  // tenant the screen was opened from. Tenants adding their own account never
  // see the picker — it is theirs by definition.
  List<_AchResident> _leaseResidents = const [];
  String? _selectedResidentId;

  /// Only Admin/Staff, and only when a lease is known to read residents from.
  bool get _showResidentPicker =>
      (widget.authAsStaff || widget.authAsAdmin) &&
      (widget.leaseId ?? '').isNotEmpty;

  /// The resident the ACH account is saved against — the picked one when the
  /// picker is in use, otherwise the tenant the screen was opened for.
  String get _effectiveTenantId =>
      (_showResidentPicker && (_selectedResidentId ?? '').isNotEmpty)
          ? _selectedResidentId!
          : widget.tenantId;

  Future<void> _loadLeaseResidents() async {
    if (!_showResidentPicker) return;
    try {
      // Fetched here rather than via LeaseRepository.fetchLeaseTenants, which
      // always sends the adminId header — Staff must send staff_id, so that
      // call returned nothing for Staff and the picker never appeared.
      final prefs = await SharedPreferences.getInstance();
      final headerId = _headerIdForRequest(prefs);
      final token = prefs.getString('token');
      if (headerId == null || token == null) return;
      final response = await apiGet(
        Uri.parse('$Api_url/api/tenant/leases/${widget.leaseId}'),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $headerId',
        },
      );
      if (response.statusCode != 200) return;
      final decoded = json.decode(response.body);
      final rows = (decoded is Map ? decoded['data'] : null);
      if (rows is! List) return;
      // Only three fields are needed, read defensively — LeaseTenant.fromJson
      // assigns non-nullable fields straight from JSON and throws on a single
      // missing key, which would silently hide the picker.
      final residents = rows
          .whereType<Map>()
          .map((e) => _AchResident(
                tenantId: e['tenant_id']?.toString() ?? '',
                firstName: e['tenant_firstName']?.toString() ?? '',
                lastName: e['tenant_lastName']?.toString() ?? '',
              ))
          .where((r) => r.tenantId.isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _leaseResidents = residents;
        // Default to the tenant the screen was opened for, as web does.
        final match = residents
            .where((r) => r.tenantId == widget.tenantId)
            .toList();
        _selectedResidentId =
            match.isNotEmpty ? match.first.tenantId : widget.tenantId;
      });
    } catch (_) {
      // Picker simply stays hidden if residents cannot be read — the form must
      // still work for the tenant it was opened for.
    }
  }

  /// Swap the prefilled names when a different resident is chosen.
  void _onResidentSelected(String? tenantId) {
    if (tenantId == null || tenantId == _selectedResidentId) return;
    final match = _leaseResidents.where((r) => r.tenantId == tenantId).toList();
    setState(() {
      _selectedResidentId = tenantId;
      if (match.isNotEmpty) {
        _firstName.text = match.first.firstName;
        _lastName.text = match.first.lastName;
      }
    });
    _onRequiredChanged();
  }

  Future<void> _fetchVaultIdThenLoadAccounts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? headerId = _headerIdForRequest(prefs);
      String? token = prefs.getString('token');
      if (headerId == null || token == null) {
        if (mounted) setState(() => _loadingExisting = false);
        return;
      }
      final url = '$Api_url/api/creditcard/getCreditCards/${widget.tenantId}';
      final response = await apiGet(
        Uri.parse(url),
        headers: {
          'id': 'CRM $headerId',
          'authorization': 'CRM $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final vaultId = jsonResponse['customer_vault_id']?.toString();
        if (vaultId != null && vaultId.isNotEmpty && mounted) {
          setState(() => _resolvedVaultId = vaultId);
          await _loadExistingAchAccounts();
          return;
        } else {
        }
      } else if (response.statusCode == 404 && widget.leaseId != null) {
        // No credit cards — try to find vault_id from ACH payment history
        final vaultId = await _fetchVaultIdFromPaymentHistory(headerId!, token!);
        if (vaultId != null && mounted) {
          setState(() => _resolvedVaultId = vaultId);
          await _loadExistingAchAccounts();
          return;
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not load saved bank accounts.');
    }
    if (mounted) setState(() => _loadingExisting = false);
  }

  Future<String?> _fetchVaultIdFromPaymentHistory(String headerId, String token) async {
    try {
      final historyUrl = '$Api_url/api/payment/charges_payments/${widget.leaseId}';
      final res = await apiGet(
        Uri.parse(historyUrl),
        headers: {'id': 'CRM $headerId', 'authorization': 'CRM $token'},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final j = json.decode(res.body);
        final data = j is Map ? j['data'] : null;
        if (data is List) {
          for (final item in data) {
            if (item is! Map) continue;
            final vaultId = item['customer_vault_id']?.toString();
            if (vaultId != null && vaultId.isNotEmpty && vaultId != 'null') {
              return vaultId;
            }
          }
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not load saved bank accounts.');
    }
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

  // PCI: fetch the Collect.js public key (unauth by-admin route, same as cards).
  /// Without the key the secure bank fields never initialise, so every exit
  /// here used to leave a form that silently could not be completed. Each
  /// failure now reports itself and can be retried.
  Future<void> _fetchTokenizationKey() async {
    if (mounted) setState(() => _keyLoadFailed = false);
    final prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString('adminId');
    if (adminId == null || adminId.isEmpty) {
      if (mounted) setState(() => _keyLoadFailed = true);
      return;
    }
    try {
      final res = await apiGet(
        Uri.parse('$Api_url/api/tenant/nmi_public_key_by_admin/$adminId'),
      );
      final decoded = res.statusCode == 200 ? json.decode(res.body) : null;
      final key = decoded is Map ? decoded['publicKey'] : null;
      if (key is String && key.isNotEmpty) {
        if (mounted) setState(() => _publicKey = key);
      } else {
        if (mounted) setState(() => _keyLoadFailed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _keyLoadFailed = true);
    }
  }

  Future<void> _loadExistingAchAccounts() async {
    final vaultId = _resolvedVaultId ?? widget.customerVaultId;
    if (vaultId == null || vaultId.isEmpty) {
      if (mounted) setState(() => _loadingExisting = false);
      return;
    }
    if (mounted) {
      setState(() {
        _loadingExisting = true;
        _existingLoadFailed = false;
      });
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // id header: staff_id for staff, adminId for admin — matches make_payment.dart
      String? headerId = _headerIdForRequest(prefs);
      String? adminId = prefs.getString('adminId');
      String? token = prefs.getString('token');
      if (headerId == null || adminId == null || token == null) {
        if (mounted) setState(() => _loadingExisting = false);
        return;
      }
      final postUrl = '$Api_url/api/nmipayment/get-billing-customer-vault';
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
      // PCI: the vault body carries bank/card details — log the status only.
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        final jsonResponse = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        var data = jsonResponse is Map ? jsonResponse['data'] : null;
        var customer = data is Map ? data['customer'] : null;
        var rawBilling = customer is Map ? customer['billing'] : null;

        // billing can be a List (multiple entries) or a Map (single entry from XML conversion)
        List billingList = [];
        if (rawBilling is List) {
          billingList = rawBilling;
        } else if (rawBilling is Map) {
          billingList = [rawBilling];
        }

        for (var item in billingList) {
          if (item is! Map) continue;
          String? checkAccount = _extractString(item['check_account']);
          String? checkName = _extractString(item['check_name']);
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
        if (mounted) {
          setState(() {
            _existingAchAccounts = list;
            _loadingExisting = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingExisting = false;
            _existingLoadFailed = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingExisting = false;
          _existingLoadFailed = true;
        });
      }
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
      Fluttertoast.showToast(msg: 'Failed to delete ACH account');
    }
  }

  // PCI: called by the Collect.js widget once the bank fields are tokenized.
  // We post the payment_token (+ the masked account/routing Collect.js returns)
  // to add-tenant-ach (the web endpoint, which USES the token; the -mobile route
  // ignored it and choked on the masked account number). No raw data leaves the
  // app. Same server as before — just the token-aware route the website uses.
  Future<void> _saveWithToken(CardToken token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString('adminId');
    String? headerId = _headerIdForRequest(prefs);
    String? authToken = prefs.getString('token');
    if (headerId == null) {
      // Aborting silently left the user looking at a form that simply did
      // nothing on submit.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _validationError =
              'Your session details are missing. Please sign in again to add a bank account.';
        });
      }
      return;
    }

    final String url = '$Api_url/api/nmipayment/tenant/add-tenant-ach';
    final Map<String, dynamic> body = {
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'account_type': _accountType!,
      'account_holder_type': _accountHolderType!,
      'account_name': token.accountName ?? '',
      'payment_token': token.token,
      'routing_number': token.routingNumber ?? '',
      'account_number': token.accountNumber ?? '', // already masked by Collect.js
      // The resident chosen in the picker (web parity), falling back to the
      // tenant this screen was opened for.
      'tenant_id': _effectiveTenantId,
      'admin_id': adminId ?? '',
      'user_active_recently': true,
      'is_web': false,
    };
    if (kDebugMode) {
    }
    try {
      final response = await apiPost(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'id': 'CRM $headerId',
          'authorization': 'CRM $authToken',
        },
        body: json.encode(body),
      );
      if (kDebugMode) {
      }
      if (!mounted) return;
      final decoded = json.decode(response.body);
      // The API signals auth failures as HTTP 200 with statusCode 401 in the
      // BODY (Server/routes/api/Authorization/VerifyToken.js), so the HTTP
      // status alone would report a save that never happened.
      final bodyStatus = decoded is Map ? decoded['statusCode'] : null;
      final bool httpOk =
          response.statusCode == 200 || response.statusCode == 201;
      final bool bodyOk =
          bodyStatus == null || bodyStatus == 200 || bodyStatus == 201;
      if (httpOk && bodyOk) {
        Fluttertoast.showToast(msg: 'ACH account added successfully');
        await _fetchVaultIdThenLoadAccounts();
        // _isSubmitting stays true until the screen actually leaves, so the
        // button cannot be tapped again during the reload above and post a
        // second bank account.
        if (mounted) {
          setState(() => _isSubmitting = false);
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _isSubmitting = false;
          final data = decoded is Map ? decoded['data'] : null;
          final dataError = data is Map ? data['error']?.toString() : null;
          _validationError = bodyStatus == 401
              ? 'Your session has expired. Please sign in again — the bank account was not added.'
              : (dataError ??
                  (decoded is Map ? decoded['message']?.toString() : null) ??
                  'Failed to add ACH account');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _validationError = 'Network error. Please try again.';
        });
      }
    }
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
              // Web parity (AddACHDetailsForm): Admin/Staff pick which resident
              // on the lease the ACH account belongs to. Sits above the name
              // fields and defaults to the tenant the screen was opened for.
              if (_showResidentPicker && _leaseResidents.isNotEmpty) ...[
                _buildLabel('Select A Resident'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBE0E5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedResidentId,
                      hint: const Text('Select A Resident'),
                      items: _leaseResidents
                          .map((r) => DropdownMenuItem<String>(
                                value: r.tenantId,
                                child: Text(
                                  '${r.firstName} ${r.lastName}'.trim(),
                                  style: TextStyle(
                                      color: blueColor, fontSize: 14),
                                ),
                              ))
                          .toList(),
                      onChanged: _onResidentSelected,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildLabel('First Name'),
              const SizedBox(height: 6),
              _cardField(
                controller: _firstName,
                hint: 'First Name',
                textCap: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Last Name'),
              const SizedBox(height: 6),
              _cardField(
                controller: _lastName,
                hint: 'Last Name',
                textCap: TextCapitalization.words,
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
                        style: TextStyle(fontSize: 14, color: Color(0xFFb0b6c3))),
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
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
                        style: TextStyle(fontSize: 14, color: Color(0xFFb0b6c3))),
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
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
              _buildLabel('Bank Details *'),
              const SizedBox(height: 6),
              // PCI: account holder name / routing / account number are typed
              // inside Collect.js secure fields (WebView); only a token leaves
              // the app. Raw account/routing never touch Dart or our server.
              // Without the key the secure fields below stay blank forever, so
              // say so and offer a retry instead of leaving a dead form.
              if (_keyLoadFailed) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Secure bank fields could not be loaded.',
                        style: TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchTokenizationKey,
                      child:
                          Text('Retry', style: TextStyle(color: blueColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              CollectJsCardField(
                mode: CollectJsMode.ach,
                height: 236,
                publicKey: _publicKey,
                controller: _achCtrl,
                onReady: () => setState(() => _achReady = true),
                onToken: (t) => _saveWithToken(t),
                onError: (msg) {
                  if (mounted) setState(() => _isSubmitting = false);
                  Fluttertoast.showToast(msg: msg);
                },
                onValidation: (field, valid, message) {
                  // Collect.js fires this (instead of a token) when a bank field
                  // is invalid after the user taps Add — release the button.
                  if (!valid && _isSubmitting) {
                    setState(() => _isSubmitting = false);
                    Fluttertoast.showToast(
                        msg: message.isNotEmpty
                            ? message
                            : 'Please enter valid bank details.');
                  }
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
                    : _existingLoadFailed
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Could not load saved bank accounts.',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: _fetchVaultIdThenLoadAccounts,
                                child: Text('Retry',
                                    style: TextStyle(color: blueColor)),
                              ),
                            ],
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
                        onTap: (!_requiredFieldsFilled || _isSubmitting)
                            ? null
                            : () {
                                // Required native fields are filled (button
                                // enabled) → tokenize; save runs in onToken.
                                if (!(_formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                if (!_achReady) {
                                  Fluttertoast.showToast(
                                      msg: 'Bank fields are still loading…');
                                  return;
                                }
                                setState(() {
                                  _validationError = null;
                                  _isSubmitting = true;
                                });
                                _achCtrl.tokenize();
                              },
                        child: Container(
                          height: 45,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            // Web parity: greyed until required fields are
                            // filled. Also greyed while the secure bank fields
                            // are not ready — the tap handler already refuses
                            // in that state, so this only stops the button
                            // from looking usable when it isn't.
                            color: (_requiredFieldsFilled && _achReady)
                                ? blueColor
                                : blueColor.withOpacity(0.4),
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
      // Match the card screens' field labels exactly (grey, bold, 13).
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  // Structurally identical to the card screens' CustomTextField: Material(elev 0)
  // + white Container(grey.shade300 border, radius 8, h50) + a borderless field
  // with hint #b0b6c3 @13, and any validation error shown below the box.
  Widget _cardField({
    required TextEditingController controller,
    required String hint,
    TextCapitalization textCap = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: (_) => validator?.call(controller.text),
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Center(
                child: TextFormField(
                  controller: controller,
                  textCapitalization: textCap,
                  onChanged: (v) => state.didChange(v),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                        fontSize: 13, color: Color(0xFFb0b6c3)),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ),
          if (state.hasError && (state.errorText ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

/// Minimal resident row for the ACH "Select A Resident" picker. Deliberately
/// not LeaseTenant: that model assigns non-nullable fields directly from JSON
/// and throws if any key is absent.
class _AchResident {
  final String tenantId;
  final String firstName;
  final String lastName;
  const _AchResident({
    required this.tenantId,
    required this.firstName,
    required this.lastName,
  });
}
