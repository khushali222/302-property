import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../constant/constant.dart';
import '../../../../../StaffModule/widgets/appbar.dart';
import '../../../../../StaffModule/widgets/custom_drawer.dart';

class Add_Edit_Utility extends StatefulWidget {
  final String rentalId;
  final String? unitId;
  final String? unitName; // Unit name for display
  final Map<String, dynamic>? utilityData; // For edit mode
  final String? utilityId; // For edit mode

  const Add_Edit_Utility({
    Key? key,
    required this.rentalId,
    this.unitId,
    this.unitName,
    this.utilityData,
    this.utilityId,
  }) : super(key: key);

  @override
  State<Add_Edit_Utility> createState() => _Add_Edit_UtilityState();
}

class _Add_Edit_UtilityState extends State<Add_Edit_Utility> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _utilityNameController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _customerServicePhoneController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _hasValidated = false;

  // Store original values for comparison
  String? _originalUtilityName;
  String? _originalProviderName;
  String? _originalAccountNumber;
  String? _originalCustomerServicePhone;

  @override
  void initState() {
    super.initState();
    if (widget.utilityData != null) {
      // Edit mode - populate form
      _originalUtilityName =
          widget.utilityData!['utility_name']?.toString() ?? '';
      _originalProviderName =
          widget.utilityData!['provider_name']?.toString() ?? '';
      _originalAccountNumber =
          widget.utilityData!['account_number']?.toString() ?? '';
      _originalCustomerServicePhone =
          widget.utilityData!['customer_service_phone']?.toString() ?? '';

      _utilityNameController.text = _originalUtilityName!;
      _providerNameController.text = _originalProviderName!;
      _accountNumberController.text = _originalAccountNumber!;
      // Format phone number for display (handles both formatted and unformatted)
      String phoneToDisplay = _originalCustomerServicePhone!;
      if (phoneToDisplay.isNotEmpty) {
        // Remove any existing formatting first, then format it
        String digitsOnly = phoneToDisplay.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length == 10) {
          String formatted = formatPhoneNumberedit(digitsOnly);
          _customerServicePhoneController.text = formatted;
        } else {
          _customerServicePhoneController.text = phoneToDisplay;
        }
      } else {
        _customerServicePhoneController.text = '';
      }

      // Add listeners to detect changes
      _utilityNameController.addListener(_checkForChanges);
      _providerNameController.addListener(_checkForChanges);
      _accountNumberController.addListener(_checkForChanges);
      _customerServicePhoneController.addListener(_checkForChanges);
    }
  }

  @override
  void dispose() {
    _utilityNameController.dispose();
    _providerNameController.dispose();
    _accountNumberController.dispose();
    _customerServicePhoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    if (widget.utilityData == null) return; // Not in edit mode

    String currentPhone =
        _customerServicePhoneController.text.replaceAll(RegExp(r'\D'), '');
    String originalPhone =
        _originalCustomerServicePhone?.replaceAll(RegExp(r'\D'), '') ?? '';

    bool hasChanges =
        _utilityNameController.text.trim() != _originalUtilityName ||
            _providerNameController.text.trim() != _originalProviderName ||
            _accountNumberController.text.trim() != _originalAccountNumber ||
            currentPhone != originalPhone;

    setState(() {
      _hasChanges = hasChanges;
    });
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account Number is required';
    }
    // Check if it's numeric and minimum 3 digits
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Account Number must contain only numbers';
    }
    if (value.trim().length < 3) {
      return 'Account Number must be at least 3 digits';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Customer Service Phone is required';
    }
    // Remove all non-digit characters to check length
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }

    // Check format (xxx) xxx-xxxx
    final phoneRegex = RegExp(r'^\(\d{3}\) \d{3}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number format (xxx) xxx-xxxx';
    }
    return null;
  }

  Future<void> _saveUtility() async {
    setState(() {
      _hasValidated = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // In edit mode, check if anything changed
    if (widget.utilityData != null && !_hasChanges) {
      Fluttertoast.showToast(
        msg: "No changes detected",
        backgroundColor: Colors.orange,
      );
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? staffId = prefs.getString("staff_id");
      String? token = prefs.getString('token');

      if (adminId == null || token == null || staffId == null) {
        throw Exception('Admin ID, Staff ID or token not found');
      }

      // Prepare phone number (send formatted phone number to API)
      String formattedPhone = _customerServicePhoneController.text.trim();


      Map<String, dynamic> requestData = {
        'admin_id': adminId,
        'rental_id': widget.rentalId,
        'utility_name': _utilityNameController.text.trim(),
        'provider_name': _providerNameController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
        'customer_service_phone': formattedPhone,
      };

      // Add unit_id if provided (for multi-unit properties)
      if (widget.unitId != null && widget.unitId!.isNotEmpty) {
        requestData['unit_id'] = widget.unitId;
      }

      final response = widget.utilityData != null
          ? await apiPut(
              Uri.parse('$Api_url/api/utilities/${widget.utilityId}'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': 'CRM $token',
                'id': 'CRM $staffId',
              },
              body: jsonEncode(requestData),
            )
          : await apiPost(
              Uri.parse('$Api_url/api/utilities/utilities'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': 'CRM $token',
                'id': 'CRM $staffId',
              },
              body: jsonEncode(requestData),
            );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Utility saved successfully',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Failed to save utility',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving utility: ${friendlyErrorMessage(e)}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: null, // Remove built-in validation
          inputFormatters: inputFormatters ?? [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: blueColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (validator != null && _hasValidated)
          Builder(
            builder: (context) {
              final errorText = validator(controller.text);
              if (errorText != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: blueColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.utilityData != null;

    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Properties",
        dropdown: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                height: 50.0,
                width: double.infinity,
                padding: EdgeInsets.only(top: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: blueColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Text(
                  isEditMode ? 'Edit Utility' : 'Add Utility',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(isEditMode
                        ? 'Update utility details'
                        : 'Add new utility for this property'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _utilityNameController,
                      label: 'Utility Name *',
                      hint:
                          'Enter utility name (e.g., Electricity, Water, Gas)',
                      validator: (value) =>
                          _validateRequired(value, 'Utility Name'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _providerNameController,
                      label: 'Provider Name *',
                      hint: 'Enter provider name',
                      validator: (value) =>
                          _validateRequired(value, 'Provider Name'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _accountNumberController,
                      label: 'Account Number *',
                      hint: 'Enter account number (minimum 3 digits)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: _validateAccountNumber,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _customerServicePhoneController,
                      label: 'Customer Service Phone *',
                      hint: '(xxx) xxx-xxxx',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        PhoneNumberFormatter(),
                      ],
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading || (isEditMode && !_hasChanges)
                              ? null
                              : _saveUtility,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 20.0,
                                )
                              : Text(
                                  isEditMode ? 'Update' : 'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        SizedBox(width: 16),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: blueColor, width: 1.5),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: blueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
