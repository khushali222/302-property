import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';

/// Full-screen form to add a new ACH account for the tenant.
/// POST to add-tenant-ach; backend expects check_name (Account Holder Name).
class AddAchAccount extends StatefulWidget {
  final String tenantId;

  /// Optional: when set, existing ACH accounts from get-billing-customer-vault are shown in card style.
  final String? customerVaultId;

  const AddAchAccount({Key? key, required this.tenantId, this.customerVaultId})
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
  bool _loadingExisting = false;

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
    if (widget.customerVaultId != null && widget.customerVaultId!.isNotEmpty) {
      _loadExistingAchAccounts();
    }
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

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('tenant_id');
    String? token = prefs.getString('token');
    if (id == null) return;
    try {
      final response = await http.get(
        Uri.parse('$Api_url/api/tenant/tenant_profile/$id'),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $id',
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
    if (widget.customerVaultId == null) return;
    setState(() => _loadingExisting = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('tenant_id');
      String? adminId = prefs.getString('adminId');
      String? token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
        headers: {
          'Content-Type': 'application/json',
          'id': 'CRM $id',
          'authorization': 'CRM $token',
        },
        body: json.encode({
          'customer_vault_id': widget.customerVaultId,
          'admin_id': adminId ?? '',
        }),
      );
      if (response.statusCode == 200 && mounted) {
        final jsonResponse = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        var data = jsonResponse is Map ? jsonResponse['data'] : null;
        var customer = data is Map ? data['customer'] : null;
        var billing = customer is Map ? customer['billing'] : null;
        if (billing is List) {
          for (var item in billing) {
            if (item is! Map) continue;
            String? checkAccount = _extractString(item['check_account']);
            String? checkName = _extractString(item['check_name']);
            if ((checkAccount != null && checkAccount.isNotEmpty) ||
                (checkName != null && checkName.isNotEmpty)) {
              list.add({
                'account_name': checkName ?? '',
                'account_number': checkAccount ?? '',
                'account_type': _extractString(item['account_type']) ?? '',
                'account_holder_type':
                    _extractString(item['account_holder_type']) ?? '',
              });
            }
          }
        }
        setState(() {
          _existingAchAccounts = list;
          _loadingExisting = false;
        });
      } else {
        setState(() => _loadingExisting = false);
      }
    } catch (_) {
      setState(() => _loadingExisting = false);
    }
  }

  Future<bool> _submit() async {
    setState(() {
      _validationError = null;
      if (_accountType == null ||
          _accountHolderType == null ||
          _accountHolderName.text.trim().isEmpty ||
          _routingNumber.text.trim().isEmpty ||
          _accountNumber.text.trim().isEmpty) {
        _validationError = 'Please fill all the required fields*';
        return;
      }
      _isSubmitting = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString('adminId');
    String? id = prefs.getString('tenant_id');
    String? token = prefs.getString('token');

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
    print('body ${json.encode(body)}');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'id': 'CRM $id',
          'authorization': 'CRM $token',
        },
        body: json.encode(body),
      );
      print('response ${response.body}');
      print('response status ${response.statusCode}');
      print('response url ${url}');
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Fluttertoast.showToast(msg: 'ACH account added successfully');
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
      appBar: widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () => key.currentState?.openDrawer(),
      ),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(currentpage: 'Financial'),
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
                  hint: const Text('Account Type'),
                  value: _accountType,
                  items: _accountTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _accountType = v),
                  buttonStyleData: ButtonStyleData(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                  hint: const Text('Account Holder Type'),
                  value: _accountHolderType,
                  items: _holderTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _accountHolderType = v),
                  buttonStyleData: ButtonStyleData(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
              if (widget.customerVaultId != null &&
                  widget.customerVaultId!.isNotEmpty) ...[
                Text(
                  'ACH Accounts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                SizedBox(height: 8),
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
                                            Text(type,
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
