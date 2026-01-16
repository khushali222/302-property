import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constant/constant.dart';
import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';

class AddEditInsurancePremium extends StatefulWidget {
  final String propertyId;
  final String? premiumId; // For editing existing premium
  final Map<String, dynamic>? premiumData; // For editing existing premium

  const AddEditInsurancePremium({
    Key? key,
    required this.propertyId,
    this.premiumId,
    this.premiumData,
  }) : super(key: key);

  @override
  State<AddEditInsurancePremium> createState() =>
      _AddEditInsurancePremiumState();
}

class _AddEditInsurancePremiumState extends State<AddEditInsurancePremium> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _yearController = TextEditingController();
  final _carrierController = TextEditingController();
  final _premiumAmountController = TextEditingController();

  bool _isLoading = false;
  bool _hasValidated = false;
  String? _generalError;
  List<Map<String, dynamic>> _existingPremiums = [];

  @override
  void initState() {
    super.initState();
    if (widget.premiumId != null && widget.premiumData != null) {
      _populateFormWithData(widget.premiumData!);
      _hasValidated = false;
    }
    _loadExistingPremiums();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _carrierController.dispose();
    _premiumAmountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFieldError(String field, String error) {
    setState(() {
      if (field == 'general') {
        _generalError = error;
      }
      _hasValidated = true;
    });
    // Scroll to top to show general error
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadExistingPremiums() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');

      final response = await http.get(
        Uri.parse(
            '${Api_url}/api/rentals/insurance-premiums/${widget.propertyId}'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $token',
          'id': 'CRM $id',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['insurance_premiums'] != null) {
          setState(() {
            _existingPremiums = List<Map<String, dynamic>>.from(
                data['data']['insurance_premiums']);
          });
        }
      }
    } catch (e) {
      print('Error loading existing premiums: $e');
    }
  }

  void _populateFormWithData(Map<String, dynamic> premiumData) {
    setState(() {
      _yearController.text = premiumData['year']?.toString() ?? '';
      _carrierController.text = premiumData['carrier']?.toString() ?? '';
      // Remove $ and format for editing
      String premium = premiumData['insurance_premium']?.toString() ?? '';
      if (premiumData['formatted_premium'] != null) {
        premium = premiumData['formatted_premium']
            .toString()
            .replaceAll('\$', '')
            .replaceAll(',', '');
      }
      _premiumAmountController.text = premium;
    });
  }

  Future<void> _saveForm() async {
    print('=== SAVE INSURANCE PREMIUM FORM STARTED ===');

    setState(() {
      _hasValidated = true;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error
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

      String amountStr = _premiumAmountController.text
          .replaceAll('\$', '')
          .replaceAll(',', '');
      double premiumAmount = double.parse(amountStr);

      if (widget.premiumId != null) {
        // Edit mode - PUT request
        print('=== EDITING INSURANCE PREMIUM ===');
        print('Premium ID: ${widget.premiumId}');
        print('Property ID: ${widget.propertyId}');

        final response = await http
            .put(
              Uri.parse(
                  '${Api_url}/api/rentals/insurance-premiums/${widget.propertyId}/${widget.premiumId}'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': 'CRM $token',
                'id': 'CRM $id',
              },
              body: json.encode({
                'year': _yearController.text.trim(),
                'carrier': _carrierController.text.trim(),
                'insurance_premium': premiumAmount,
              }),
            )
            .timeout(const Duration(seconds: 30));

        print('Edit Response Status: ${response.statusCode}');
        print('Edit Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            if (mounted) {
              Navigator.pop(context, true); // Return true to indicate success
            }
          } else {
            String errorMessage =
                data['message'] ?? 'Failed to update insurance premium';
            _showFieldError('general', errorMessage);
          }
        } else {
          final errorData = json.decode(response.body);
          String errorMessage =
              errorData['message'] ?? 'Failed to update insurance premium';
          _showFieldError('general', errorMessage);
        }
      } else {
        // Add mode - POST request to /api/rentals/insurance-premiums/{propertyId}
        print('=== CREATING INSURANCE PREMIUM ===');
        print('Property ID: ${widget.propertyId}');

        final response = await http
            .post(
              Uri.parse(
                  '${Api_url}/api/rentals/insurance-premiums/${widget.propertyId}'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': 'CRM $token',
                'id': 'CRM $id',
              },
              body: json.encode({
                'year': _yearController.text.trim(),
                'carrier': _carrierController.text.trim(),
                'insurance_premium': premiumAmount,
              }),
            )
            .timeout(const Duration(seconds: 30));

        print('Create Response Status: ${response.statusCode}');
        print('Create Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            if (mounted) {
              Navigator.pop(context, true); // Return true to indicate success
            }
          } else {
            String errorMessage =
                data['message'] ?? 'Failed to create insurance premium';
            _showFieldError('general', errorMessage);
          }
        } else {
          final errorData = json.decode(response.body);
          String errorMessage =
              errorData['message'] ?? 'Failed to create insurance premium';
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

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.premiumId != null;

    return Scaffold(
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
                    isEditMode
                        ? 'Edit Insurance Premium'
                        : 'Add Insurance Premium',
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
                          ? 'Update insurance premium details'
                          : 'Add new insurance premium for this property',
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

                    // Year Field
                    Text(
                      'Year *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormField<String>(
                      initialValue: _yearController.text,
                      validator: (value) {
                        if (_hasValidated &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Year is required';
                        }
                        // Check for duplicate year
                        if (_hasValidated &&
                            value != null &&
                            value.trim().isNotEmpty) {
                          String yearValue = value.trim();
                          // In edit mode, exclude current premium's year from duplicate check
                          bool isDuplicate = _existingPremiums.any((premium) {
                            String existingYear =
                                premium['year']?.toString().trim() ?? '';
                            // If editing, skip the current premium
                            if (widget.premiumId != null &&
                                premium['_id'] == widget.premiumId) {
                              return false;
                            }
                            return existingYear == yearValue;
                          });

                          if (isDuplicate) {
                            return 'A premium for this year already exists. Only one premium per year is allowed.';
                          }
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _yearController,
                              onChanged: (value) {
                                state.didChange(value);
                                if (_hasValidated) {
                                  state.validate();
                                }
                                if (_hasValidated && value.trim().isNotEmpty) {
                                  setState(() {
                                    _generalError = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'e.g., 2023, 2024, 2025',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                errorStyle: const TextStyle(
                                  fontSize: 0,
                                  height: 0,
                                ),
                                isDense: true,
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0, left: 16, right: 16),
                                child: Text(
                                  state.errorText ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    height: 1.0,
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Carrier Field
                    Text(
                      'Carrier *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormField<String>(
                      initialValue: _carrierController.text,
                      validator: (value) {
                        if (_hasValidated &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Carrier is required';
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _carrierController,
                              onChanged: (value) {
                                state.didChange(value);
                                if (_hasValidated) {
                                  state.validate();
                                }
                                if (_hasValidated && value.trim().isNotEmpty) {
                                  setState(() {
                                    _generalError = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'e.g., ABC Insurance',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                errorStyle: const TextStyle(
                                  fontSize: 0,
                                  height: 0,
                                ),
                                isDense: true,
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0, left: 16, right: 16),
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
                    const SizedBox(height: 20),

                    // Premium Amount Field
                    Text(
                      'Premium Amount *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormField<String>(
                      initialValue: _premiumAmountController.text,
                      validator: (value) {
                        if (_hasValidated &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Premium amount is required';
                        }
                        if (_hasValidated &&
                            value != null &&
                            value.isNotEmpty) {
                          String amountStr =
                              value.replaceAll('\$', '').replaceAll(',', '');
                          double? amount = double.tryParse(amountStr);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _premiumAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              onChanged: (value) {
                                state.didChange(value);
                                if (_hasValidated) {
                                  state.validate();
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'e.g., 1200.00',
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                errorStyle: const TextStyle(
                                  fontSize: 0,
                                  height: 0,
                                ),
                                isDense: true,
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0, left: 16, right: 16),
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
                              : Text(
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
    );
  }
}
