import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:email_validator/email_validator.dart';
import '../../../../constant/constant.dart';
import '../../../../provider/dateProvider.dart';
import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';
import '../../../../Model/PropertyInsuranceModel.dart';

class AddEditInsurancePolicy extends StatefulWidget {
  final String propertyId;
  final String? policyId; // For editing existing policy
  final PropertyInsuranceData? policyData; // For editing existing policy

  const AddEditInsurancePolicy({
    Key? key,
    required this.propertyId,
    this.policyId,
    this.policyData,
  }) : super(key: key);

  @override
  State<AddEditInsurancePolicy> createState() =>
      _AddEditInsurancePolicyState();
}

class _AddEditInsurancePolicyState extends State<AddEditInsurancePolicy> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Section 1: Policy Identification Information
  final _insuranceCompanyNameController = TextEditingController();
  final _policyNumberController = TextEditingController();
  String? _selectedPolicyType;
  String? _selectedFormNumber;

  // Section 2: Insured Party Details
  final _namedInsuredController = TextEditingController();
  final _mailingAddressController = TextEditingController();
  final _additionalInsuredController = TextEditingController();
  final _premiumAmountController = TextEditingController();

  // Section 3: Coverage Dates
  final _effectiveDateController = TextEditingController();
  final _expirationDateController = TextEditingController();
  final _cancellationNoticeDateController = TextEditingController();
  DateTime? _effectiveDate;
  DateTime? _expirationDate;
  DateTime? _cancellationNoticeDate;

  // Section 4: Financial Information
  final _deductibleController = TextEditingController();
  String? _selectedPaymentTerms;

  // Section 5: Claims and Customer Service Information
  final _agentNameController = TextEditingController();
  final _agentPhoneController = TextEditingController();
  final _agentEmailController = TextEditingController();
  final _brokerNameController = TextEditingController();
  final _claimsContactInfoController = TextEditingController();
  final _underwritingOfficeController = TextEditingController();
  String? _selectedStatus;
  final _notesController = TextEditingController();

  // Policy Type options (common insurance types)
  final List<String> _policyTypeOptions = [
    'Homeowners Insurance (HO Policies)',
    'Landlord or Dwelling Policies (DP Policies)',
    'Specialty Property Insurance',
    'Commercial Property Insurance',
  ];

  // Form Number options (will be populated based on policy type)
  List<String> _formNumberOptions = [];

  // Method to populate form number options based on policy type
  void _updateFormNumberOptions(String? policyType) {
    setState(() {
      _formNumberOptions = [];
      if (policyType == null) {
        return;
      }
      
      if (policyType == 'Homeowners Insurance (HO Policies)') {
        _formNumberOptions = [
          'HO-1 (Basic Form)',
          'HO-2 (Broad Form)',
          'HO-3 (Special Form)',
          'HO-4 (Contents Broad Form)',
          'HO-5 (Comprehensive Form)',
          'HO-6 (Unit-Owners Form)',
          'HO-8 (Modified Coverage Form)',
        ];
      } else if (policyType == 'Landlord or Dwelling Policies (DP Policies)') {
        _formNumberOptions = [
          'DP-1 (Basic Form)',
          'DP-2 (Broad Form)',
          'DP-3 (Special Form)',
          'DP-4 (Contents Broad Form)',
          'DP-5 (Comprehensive Form)',
        ];
      } else if (policyType == 'Specialty Property Insurance') {
        _formNumberOptions = [
          'SP-1 (Basic Specialty)',
          'SP-2 (Broad Specialty)',
          'SP-3 (Special Specialty)',
          'SP-4 (Comprehensive Specialty)',
        ];
      } else if (policyType == 'Commercial Property Insurance') {
        _formNumberOptions = [
          'CP-1 (Basic Commercial)',
          'CP-2 (Broad Commercial)',
          'CP-3 (Special Commercial)',
          'CP-4 (Comprehensive Commercial)',
          'CP-5 (Commercial Package)',
        ];
      }
    });
  }

  // Payment Terms options
  final List<String> _paymentTermsOptions = [
    'Monthly',
    'Quarterly',
    'Semi-Annual',
    'Annual',
  ];

  // Status options
  final List<String> _statusOptions = [
    'Active',
    'Expired',
    'Cancelled',
    'Pending',
  ];

  bool _isLoading = false;
  bool _hasValidated = false;
  String? _generalError;

  String _convertToApiFormat(String displayDate) {
    if (displayDate.isEmpty) return "";
    try {
      DateTime? parsedDate;

      // Try to parse the date using common formats
      List<String> dateFormats = [
        'MM/dd/yyyy',
        'MM-dd-yyyy',
        'yyyy-MM-dd',
        'yyyy-MMM-dd',
        'dd/MM/yyyy',
        'dd-MM-yyyy',
        'dd/MMM/yyyy'
      ];

      for (String format in dateFormats) {
        try {
          parsedDate = DateFormat(format).parse(displayDate);
          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate != null) {
        // Convert to ISO format with time: "2026-01-15T00:00:00.000Z"
        String dateStr = DateFormat('yyyy-MM-dd').format(parsedDate);
        return '${dateStr}T00:00:00.000Z';
      } else {
        return displayDate;
      }
    } catch (e) {
      return displayDate;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.policyId != null && widget.policyData != null) {
      _populateFormWithData(widget.policyData!);
      _hasValidated = false;
    }
    // Initialize form number options if policy type is already set
    if (_selectedPolicyType != null) {
      _updateFormNumberOptions(_selectedPolicyType);
    }
  }

  @override
  void dispose() {
    _insuranceCompanyNameController.dispose();
    _policyNumberController.dispose();
    _namedInsuredController.dispose();
    _mailingAddressController.dispose();
    _additionalInsuredController.dispose();
    _premiumAmountController.dispose();
    _effectiveDateController.dispose();
    _expirationDateController.dispose();
    _cancellationNoticeDateController.dispose();
    _deductibleController.dispose();
    _agentNameController.dispose();
    _agentPhoneController.dispose();
    _agentEmailController.dispose();
    _brokerNameController.dispose();
    _claimsContactInfoController.dispose();
    _underwritingOfficeController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _populateFormWithData(PropertyInsuranceData policy) {
    setState(() {
      _insuranceCompanyNameController.text =
          policy.insuranceCompanyName ?? '';
      _policyNumberController.text = policy.policyNumber ?? '';
      _selectedPolicyType = policy.policyType;
      _selectedFormNumber = policy.formNumber;
      // Update form number options based on policy type
      if (_selectedPolicyType != null) {
        _updateFormNumberOptions(_selectedPolicyType);
      }
      _namedInsuredController.text = policy.namedInsured ?? '';
      _mailingAddressController.text = policy.mailingAddress ?? '';
      _additionalInsuredController.text = policy.additionalInsured ?? '';
      _premiumAmountController.text =
          policy.premiumAmount?.toString() ?? '';
      _deductibleController.text = policy.deductible?.toString() ?? '';
      _selectedPaymentTerms = policy.paymentTerms;
      _agentNameController.text = policy.agentName ?? '';
      _agentPhoneController.text = policy.agentPhone ?? '';
      _agentEmailController.text = policy.agentEmail ?? '';
      _brokerNameController.text = policy.brokerName ?? '';
      _claimsContactInfoController.text = policy.claimsContactInfo ?? '';
      _underwritingOfficeController.text = policy.underwritingOffice ?? '';
      _selectedStatus = policy.status ?? 'Active';
      _notesController.text = policy.notes ?? '';

      // Parse dates
      if (policy.effectiveDate != null && policy.effectiveDate!.isNotEmpty) {
        try {
          _effectiveDate = DateTime.parse(policy.effectiveDate!);
          final dateProvider =
              Provider.of<DateProvider>(context, listen: false);
          _effectiveDateController.text =
              dateProvider.formatCurrentDate(policy.effectiveDate!);
        } catch (e) {
          print('Error parsing effective date: $e');
        }
      }
      if (policy.expirationDate != null &&
          policy.expirationDate!.isNotEmpty) {
        try {
          _expirationDate = DateTime.parse(policy.expirationDate!);
          final dateProvider =
              Provider.of<DateProvider>(context, listen: false);
          _expirationDateController.text =
              dateProvider.formatCurrentDate(policy.expirationDate!);
        } catch (e) {
          print('Error parsing expiration date: $e');
        }
      }
      if (policy.cancellationNoticeDate != null &&
          policy.cancellationNoticeDate!.isNotEmpty) {
        try {
          _cancellationNoticeDate =
              DateTime.parse(policy.cancellationNoticeDate!);
          final dateProvider =
              Provider.of<DateProvider>(context, listen: false);
          _cancellationNoticeDateController.text =
              dateProvider.formatCurrentDate(policy.cancellationNoticeDate!);
        } catch (e) {
          print('Error parsing cancellation date: $e');
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? initialDate,
      {Function(DateTime)? onDateSelected, bool isExpiration = false}) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: isExpiration ? (_effectiveDate ?? DateTime.now()) : DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.day,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor,
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: blueColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(picked);
        controller.text = dateProvider.formatCurrentDate(apiFormatDate);
        
        // Update the DateTime objects
        if (controller == _effectiveDateController) {
          _effectiveDate = picked;
          // If effective date is after expiration date, clear expiration date
          if (_expirationDate != null && _effectiveDate!.isAfter(_expirationDate!)) {
            _expirationDate = null;
            _expirationDateController.text = '';
          }
        } else if (controller == _expirationDateController) {
          _expirationDate = picked;
          // Validate expiration date is after effective date
          if (_effectiveDate != null &&
              (_expirationDate!.isBefore(_effectiveDate!) ||
                  _expirationDate!.isAtSameMomentAs(_effectiveDate!))) {
            // Show warning but don't clear
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Expiration date must be after effective date.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else if (controller == _cancellationNoticeDateController) {
          _cancellationNoticeDate = picked;
        }
        
        if (onDateSelected != null) {
          onDateSelected(picked);
        }
      });
    }
  }

  void _showFieldError(String field, String error) {
    setState(() {
      if (field == 'general') {
        _generalError = error;
      }
      _hasValidated = true;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _saveForm() async {
    print('=== SAVE INSURANCE POLICY FORM STARTED ===');

    setState(() {
      _hasValidated = true;
    });

    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');

      // Prepare data
      Map<String, dynamic> requestData = {
        'propertyId': widget.propertyId,
        'insurance_company_name': _insuranceCompanyNameController.text.trim(),
        'policy_number': _policyNumberController.text.trim(),
        'policy_type': _selectedPolicyType ?? '',
        'form_number': _selectedFormNumber ?? '',
        'named_insured': _namedInsuredController.text.trim(),
        'mailing_address': _mailingAddressController.text.trim(),
        'additional_insured': _additionalInsuredController.text.trim(),
        'effective_date': _effectiveDate != null
            ? '${DateFormat('yyyy-MM-dd').format(_effectiveDate!)}T00:00:00.000Z'
            : (_effectiveDateController.text.isNotEmpty
                ? _convertToApiFormat(_effectiveDateController.text)
                : ''),
        'expiration_date': _expirationDate != null
            ? '${DateFormat('yyyy-MM-dd').format(_expirationDate!)}T00:00:00.000Z'
            : (_expirationDateController.text.isNotEmpty
                ? _convertToApiFormat(_expirationDateController.text)
                : ''),
        'cancellation_notice_date':
            _cancellationNoticeDate != null
                ? '${DateFormat('yyyy-MM-dd').format(_cancellationNoticeDate!)}T00:00:00.000Z'
                : (_cancellationNoticeDateController.text.isNotEmpty
                    ? _convertToApiFormat(_cancellationNoticeDateController.text)
                    : null),
        'premium_amount': _premiumAmountController.text.isNotEmpty
            ? double.tryParse(_premiumAmountController.text
                .replaceAll('\$', '')
                .replaceAll(',', ''))
            : null,
        'deductible': _deductibleController.text.isNotEmpty
            ? double.tryParse(_deductibleController.text
                .replaceAll('\$', '')
                .replaceAll(',', ''))
            : null,
        'payment_terms': _selectedPaymentTerms ?? '',
        'claims_contact_info': _claimsContactInfoController.text.trim(),
        'agent_name': _agentNameController.text.trim(),
        'agent_phone': _agentPhoneController.text.trim(),
        'agent_email': _agentEmailController.text.trim(),
        'broker_name': _brokerNameController.text.trim(),
        'underwriting_office': _underwritingOfficeController.text.trim(),
        'status': _selectedStatus ?? 'Active',
        'notes': _notesController.text.trim(),
      };

      if (widget.policyId != null) {
        // Edit mode - PUT request
        print('=== EDITING INSURANCE POLICY ===');
        print('Policy ID: ${widget.policyId}');

        final response = await http
            .put(
              Uri.parse('${Api_url}/api/property-insurance/${widget.policyId}'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': 'CRM $token',
                'id': 'CRM $id',
              },
              body: json.encode(requestData),
            )
            .timeout(const Duration(seconds: 30));

        print('Edit Response Status: ${response.statusCode}');
        print('Edit Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            if (mounted) {
              Navigator.pop(context, true);
            }
          } else {
            String errorMessage =
                data['message'] ?? 'Failed to update insurance policy';
            _showFieldError('general', errorMessage);
          }
        } else {
          final errorData = json.decode(response.body);
          String errorMessage =
              errorData['message'] ?? 'Failed to update insurance policy';
          _showFieldError('general', errorMessage);
        }
      } else {
        // Add mode - POST request
        print('=== CREATING INSURANCE POLICY ===');

        final response = await http
            .post(
              Uri.parse('${Api_url}/api/property-insurance'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': 'CRM $token',
                'id': 'CRM $id',
              },
              body: json.encode(requestData),
            )
            .timeout(const Duration(seconds: 30));

        print('Create Response Status: ${response.statusCode}');
        print('Create Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            if (mounted) {
              Navigator.pop(context, true);
            }
          } else {
            String errorMessage =
                data['message'] ?? 'Failed to create insurance policy';
            _showFieldError('general', errorMessage);
          }
        } else {
          final errorData = json.decode(response.body);
          String errorMessage =
              errorData['message'] ?? 'Failed to create insurance policy';
          _showFieldError('general', errorMessage);
        }
      }
    } catch (e) {
      print('=== EXCEPTION ===');
      print('Exception occurred: $e');
      if (mounted) {
        _showFieldError('general', 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSectionHeader(int number, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                children: required
                    ? [
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        )
                      ]
                    : [],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 8),
        prefixText != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 16),
                    child: Text(
                      prefixText,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: controller,
                      hintText: hint ?? '',
                      keyboardType: keyboardType ?? TextInputType.text,
                      inputFormatters: inputFormatters,
                      optional: !required,
                      maxLines: maxLines,
                      validator: validator ?? (value) {
                        if (required && _hasValidated &&
                            (value == null || value.trim().isEmpty)) {
                          return '$label is required';
                        }
                        return null;
                      },
                      showElevation: false,
                      borderColor: Colors.grey[300],
                      borderWidth: 1.0,
                      isInRow: false,
                    ),
                  ),
                ],
              )
            : CustomTextField(
                controller: controller,
                hintText: hint ?? '',
                keyboardType: keyboardType ?? TextInputType.text,
                inputFormatters: inputFormatters,
                optional: !required,
                maxLines: maxLines,
                validator: validator ?? (value) {
                  if (required && _hasValidated &&
                      (value == null || value.trim().isEmpty)) {
                    return '$label is required';
                  }
                  return null;
                },
                showElevation: false,
                borderColor: Colors.grey[300],
                borderWidth: 1.0,
                isInRow: false,
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required DateTime? selectedDate,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                children: required
                    ? [
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        )
                      ]
                    : [],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _selectDate(
              context, 
              controller, 
              selectedDate, 
              isExpiration: label.contains('Expiration'),
              onDateSelected: (date) {
                setState(() {
                  if (label.contains('Effective')) {
                    _effectiveDate = date;
                  } else if (label.contains('Expiration')) {
                    _expirationDate = date;
                  } else if (label.contains('Cancellation')) {
                    _cancellationNoticeDate = date;
                  }
                });
              },
            );
          },
          child: AbsorbPointer(
            child: Builder(
              builder: (context) {
                final dateProvider = Provider.of<DateProvider>(context, listen: false);
                // Convert date format to hint format (e.g., MM/dd/yyyy -> MM/DD/YYYY, dd/MMM/yyyy -> DD/MMM/YYYY)
                String dateFormatHint = dateProvider.dateFormat
                    .replaceAll('dd', 'DD')
                    .replaceAll('d', 'DD')
                    .replaceAll('MMM', 'MMM')
                    .replaceAll('MM', 'MM')
                    .replaceAll('M', 'MM')
                    .replaceAll('yyyy', 'YYYY')
                    .replaceAll('yy', 'YY');
                
                return TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: dateFormatHint,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: blueColor,
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
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    errorStyle: const TextStyle(
                      fontSize: 12,
                      height: 1.0,
                    ),
                    errorMaxLines: 2,
                    isDense: true,
                  ),
                  validator: (value) {
                    if (required &&
                        _hasValidated &&
                        (value == null || value.trim().isEmpty)) {
                      return '$label is required';
                    }
                    return null;
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
    bool required = false,
    String? hint,
    bool disabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                children: required
                    ? [
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        )
                      ]
                    : [],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: disabled ? null : value,
          validator: required
              ? (val) {
                  if (_hasValidated && (val == null || val.isEmpty)) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Row(
                      children: [
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hint ?? 'Select ${label.replaceAll(' (Optional)', '')}',
                            style: TextStyle(
                              fontSize: 14,
                              color: disabled ? Colors.grey[300] : Colors.grey[400],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    value: disabled ? null : value,
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: disabled ? null : (newValue) {
                      state.didChange(newValue);
                      if (onChanged != null) {
                        onChanged(newValue);
                      }
                      // Trigger validation after change
                      if (_hasValidated) {
                        _formKey.currentState?.validate();
                      }
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                        color: disabled ? Colors.grey[100] : Colors.white,
                      ),
                      elevation: 0,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      offset: const Offset(0, -5),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
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
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 0),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        height: 1.0,
                      ),
                      maxLines: 2,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.policyId != null;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.blue.withOpacity(0.3),
          selectionHandleColor: Colors.blue,
        ),
      ),
      child: Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawer(
          currentpage: "Properties",
          dropdown: true,
        ),
        body: Form(
          key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 45,
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
                    isEditMode
                        ? 'Edit Insurance Policy'
                        : 'Add Insurance Policy',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditMode
                          ? 'Update insurance policy details'
                          : 'Add new insurance policy for this property',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // General Error Message
                    if (_generalError != null && _hasValidated)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _generalError!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: Colors.red.shade700, size: 18),
                              onPressed: () {
                                setState(() {
                                  _generalError = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                    // Section 1: Policy Identification Information
                    _buildSectionHeader(
                      1,
                      'Policy Identification Information',
                      'Basic policy details and identification',
                    ),
                    _buildTextField(
                      label: 'Insurance Company Name',
                      controller: _insuranceCompanyNameController,
                      hint: 'Enter insurance company name',
                      required: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Policy Number',
                            controller: _policyNumberController,
                            hint: 'Enter policy number',
                            required: true,
                            validator: (value) {
                              if (_hasValidated && (value == null || value.trim().isEmpty)) {
                                return 'Policy Number is required';
                              }
                              if (_hasValidated && value != null && value.trim().length < 2) {
                                return 'Policy Number must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    _buildDropdown(
                      label: 'Policy Type',
                      value: _selectedPolicyType,
                      items: _policyTypeOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedPolicyType = value;
                          _selectedFormNumber = null; // Reset form number
                          _updateFormNumberOptions(value); // Update form number options
                        });
                      },
                      hint: 'Select Policy Type',
                    ),
                    _buildDropdown(
                      label: 'Form Number',
                      value: _selectedPolicyType == null ? null : _selectedFormNumber,
                      items: _formNumberOptions,
                      onChanged: _selectedPolicyType == null 
                          ? null 
                          : (value) {
                              setState(() {
                                _selectedFormNumber = value;
                              });
                            },
                      hint: _selectedPolicyType == null
                          ? 'Select Policy Type First'
                          : 'Select Form Number',
                      disabled: _selectedPolicyType == null,
                    ),

                    // Section 2: Insured Party Details
                    _buildSectionHeader(
                      2,
                      'Insured Party Details',
                      'Information about the policyholder and property',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Named Insured',
                            controller: _namedInsuredController,
                            hint: 'Enter named insured',
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Premium Amount',
                            controller: _premiumAmountController,
                            hint: 'Enter premium amount',
                            required: true,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            prefixText: '\$ ',
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      label: 'Mailing Address',
                      controller: _mailingAddressController,
                      hint: 'Enter mailing address',
                      required: true,
                      maxLines: 2,
                    ),
                    _buildTextField(
                      label: 'Additional Insured or Interest',
                      controller: _additionalInsuredController,
                      hint: 'Enter additional insured or interest',
                      maxLines: 2,
                    ),

                    // Section 3: Coverage Dates
                    _buildSectionHeader(
                      3,
                      'Coverage Dates',
                      'Policy effective and expiration dates',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Policy Effective Date',
                            controller: _effectiveDateController,
                            selectedDate: _effectiveDate,
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            label: 'Policy Expiration Date',
                            controller: _expirationDateController,
                            selectedDate: _expirationDate,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    _buildDateField(
                      label: 'Cancellation/Non-Renewal Notice Date',
                      controller: _cancellationNoticeDateController,
                      selectedDate: _cancellationNoticeDate,
                    ),

                    // Section 4: Financial Information
                    _buildSectionHeader(
                      4,
                      'Financial Information',
                      'Premium amounts, deductibles, and payment terms',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Deductible',
                            controller: _deductibleController,
                            hint: 'Enter deductible amount',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            prefixText: '\$ ',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Payment Terms',
                            value: _selectedPaymentTerms,
                            items: _paymentTermsOptions,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentTerms = value;
                              });
                            },
                            required: true,
                            hint: 'Select Payment Terms',
                          ),
                        ),
                      ],
                    ),

                    // Section 5: Claims and Customer Service Information
                    _buildSectionHeader(
                      5,
                      'Claims and Customer Service Information',
                      'Contact information for claims and policy management',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Agent or Broker Name',
                            controller: _agentNameController,
                            hint: 'Enter agent or broker name',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Agent Phone',
                            controller: _agentPhoneController,
                            hint: '(xxx) xxx-xxxx',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [PhoneNumberFormatter()],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                // Remove formatting to check digit count
                                String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                                if (digitsOnly.length != 10) {
                                  return 'Phone number must be exactly 10 digits';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Agent Email',
                            controller: _agentEmailController,
                            hint: 'Enter agent email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Broker Name',
                            controller: _brokerNameController,
                            hint: 'Enter broker name',
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      label: 'Claims Contact Information',
                      controller: _claimsContactInfoController,
                      hint: 'Phone numbers or websites for filing claims',
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Underwriting Office',
                            controller: _underwritingOfficeController,
                            hint: 'Enter underwriting office',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Status',
                            value: _selectedStatus,
                            items: _statusOptions,
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                            required: true,
                            hint: 'Select Status',
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      label: 'Notes',
                      controller: _notesController,
                      hint: 'Enter any additional notes or comments',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 40),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel Button
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Save Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// CustomTextField widget for responsive text fields
class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final Function(String)? onChanged2;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final String? label;
  final bool readOnnly;
  final bool? amount_check;
  final String? max_amount;
  final String? error_mess;
  final bool? optional;
  final bool? email;
  final bool? pass;
  final bool? phone;
  final bool? worknum;
  final bool? phonenum;
  final bool? businessnum;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? otherController;
  final TextEditingController? businessController;
  final TextEditingController? telephoneController;
  final TextEditingController? alterController;
  final TextEditingController? emrgencyController;
  final bool? samephonenumber;
  final bool? isInRow;
  final Border? customBorder;
  final Color? borderColor;
  final double? borderWidth;
  final bool showElevation;
  final int? errorMaxLines;
  final TextInputAction? textInputAction;
  final int? maxLines;

  CustomTextField({
    Key? key,
    this.onChanged,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.readOnnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSuffixIconPressed,
    this.label,
    this.onTap,
    this.onChanged2,
    this.amount_check,
    this.max_amount,
    this.error_mess,
    this.optional = false,
    this.email,
    this.pass,
    this.phone,
    this.inputFormatters,
    this.worknum,
    this.phonenum,
    this.businessnum,
    this.otherController,
    this.businessController,
    this.telephoneController,
    this.alterController,
    this.emrgencyController,
    this.samephonenumber = false,
    this.isInRow = false,
    this.customBorder,
    this.borderColor,
    this.borderWidth,
    this.showElevation = false,
    this.errorMaxLines,
    this.textInputAction,
    this.maxLines,
  }) : super(key: key);

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  TextEditingController _textController = TextEditingController();
  late FocusNode _focusNode;

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  if (widget.onChanged2 != null) {
                    widget.onChanged2!(_textController.text);
                  }
                  node.unfocus();
                },
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    "Done",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  void _validatePhoneNumber(String value) {
    String formattedPhoneNumber = value.replaceAll(RegExp(r'\D'), '');
    if (formattedPhoneNumber.length != 10) {
      setState(() {
        _errorMessage = "Phone number must be 10 digits";
      });
    } else {
      if (widget.telephoneController != null &&
          widget.telephoneController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else if (widget.otherController != null &&
          widget.otherController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else if (widget.businessController != null &&
          widget.businessController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
      }
    }
  }

  void _validateEmail(String value) {
    if (!EmailValidator.validate(value)) {
      setState(() {
        _errorMessage = "Email is not valid";
      });
    } else {
      if (widget.alterController != null &&
          widget.alterController?.text == value) {
        setState(() {
          _errorMessage = 'Email cannot be the same';
        });
      } else if (widget.emrgencyController != null &&
          widget.emrgencyController?.text == value) {
        setState(() {
          _errorMessage = 'Email cannot be the same';
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldUseKeyboardActions =
        widget.keyboardType == TextInputType.number;

    bool hasError = _errorMessage != null && _errorMessage!.isNotEmpty;

    Widget textfield = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FormField<String>(
          validator: widget.optional!
              ? (value) {
                  if (widget.controller!.text.trim().isEmpty) {
                    return null;
                  } else if (widget.phone != null) {
                    _validatePhoneNumber(widget.controller!.text.trim());
                    if (_errorMessage == null) {
                      return null;
                    }
                    return '';
                  } else if (widget.email != null) {
                    _validateEmail(widget.controller!.text.trim());
                    if (_errorMessage == null) {
                      return null;
                    }
                    return '';
                  } else if (widget.amount_check != null &&
                      double.parse(widget.controller!.text.trim()) >
                          double.parse(widget.max_amount!)) {
                    setState(() {
                      _errorMessage = '${widget.error_mess}';
                    });
                  }
                  return null;
                }
              : (value) {
                  if (widget.validator != null) {
                    String? result = widget.validator!(value);
                    if (result != null) {
                      setState(() {
                        _errorMessage = result;
                      });
                      return result;
                    }
                  }
                  if (widget.controller!.text.trim().isEmpty) {
                    setState(() {
                      if (widget.label == null)
                        _errorMessage = 'Please ${widget.hintText}';
                      else
                        _errorMessage = 'Please ${widget.label}';
                    });
                    return '';
                  } else if (widget.phone != null) {
                    String formattedPhoneNumber =
                        widget.controller!.text.replaceAll(RegExp(r'\D'), '');
                    if (formattedPhoneNumber.length != 10) {
                      setState(() {
                        _errorMessage = "Phone number must be 10 digits";
                      });
                      return '';
                    }
                    if (widget.samephonenumber != null &&
                        widget.samephonenumber!) {
                      setState(() {
                        _errorMessage =
                            'Phone number and work number cannot be the same';
                      });
                      return '';
                    } else {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  } else if (widget.email != null) {
                    if (!EmailValidator.validate(
                        widget.controller!.text.trim())) {
                      setState(() {
                        _errorMessage = "Email is not valid";
                      });
                      return '';
                    }
                  } else if (widget.pass != null) {
                    String? validationMessage =
                        ValidatePassword(widget.controller!.text.trim());
                    if (validationMessage != null) {
                      setState(() {
                        _errorMessage = validationMessage;
                      });
                      return '';
                    }
                  } else if (widget.amount_check != null &&
                      double.parse(widget.controller!.text.trim()) >
                          double.parse(widget.max_amount!)) {
                    setState(() {
                      _errorMessage = '${widget.error_mess}';
                    });
                  }
                  return null;
                },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  elevation: widget.showElevation ? 2 : 0,
                  borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      height: widget.maxLines != null && widget.maxLines! > 1
                          ? null
                          : 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 0),
                      decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: widget.customBorder ??
                          (widget.borderColor != null
                              ? Border.all(
                                  color: widget.borderColor!,
                                  width: widget.borderWidth ?? 1.0)
                              : null),
                      boxShadow: widget.showElevation
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(4, 4),
                                blurRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: TextFormField(
                      onFieldSubmitted: widget.onChanged2,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                        if (widget.onChanged != null) widget.onChanged!(value);
                      },
                      inputFormatters: widget.inputFormatters ?? [],
                      focusNode: _focusNode,
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      obscureText: widget.obscureText,
                      readOnly: widget.readOnnly,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      maxLines: widget.maxLines ?? 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          state.validate();
                        }
                        return null;
                      },
                      controller: widget.controller,
                      cursorColor: blueColor,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        suffixIcon: widget.suffixIcon,
                        hintStyle: const TextStyle(
                            fontSize: 14, color: Color(0xFFb0b6c3)),
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 14),
                      ),
                    ),
                  ),
                ),
                hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.pass == true) const SizedBox(width: 4),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.0,
                                      height: 1.0,
                                    ),
                                    maxLines: widget.pass == true ? 6 : 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ],
    );
    return shouldUseKeyboardActions
        ? SizedBox(
            height: widget.isInRow == true
                ? 70
                : (hasError
                    ? (widget.pass == true ? 150 : 74)
                    : 54),
            child: KeyboardActions(
              config: _buildConfig(context),
              child: textfield,
            ),
          )
        : widget.isInRow == true
            ? SizedBox(
                height: 82,
                child: textfield,
              )
            : textfield;
  }
}
