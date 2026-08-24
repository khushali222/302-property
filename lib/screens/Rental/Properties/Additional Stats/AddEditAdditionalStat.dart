import 'package:three_zero_two_property/services/app_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';

class AddEditAdditionalStat extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic>? statData; // For editing existing stats
  final String? statId; // For editing existing stats

  const AddEditAdditionalStat({
    Key? key,
    required this.propertyId,
    this.statData,
    this.statId,
  }) : super(key: key);

  @override
  State<AddEditAdditionalStat> createState() => _AddEditAdditionalStatState();
}

class _AddEditAdditionalStatState extends State<AddEditAdditionalStat> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _yearController = TextEditingController();
  final _dateController = TextEditingController();
  final _valueController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _hasValidated = false; // Track if validation has been attempted

  // Store initial values for change detection
  String? _initialYear;
  String? _initialDate;
  double? _initialValue;

  @override
  void initState() {
    super.initState();
    if (widget.statData != null) {
      _populateFormWithData(widget.statData!);
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _dateController.dispose();
    _valueController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _populateFormWithData(Map<String, dynamic> statData) {
    setState(() {
      // Store initial values for change detection
      _initialYear = statData['year']?.toString();
      _initialDate = statData['date']?.toString();
      _initialValue = statData['stat_value'] != null
          ? (statData['stat_value'] is num
              ? statData['stat_value'].toDouble()
              : double.tryParse(statData['stat_value'].toString()))
          : null;

      // Populate year if available
      if (statData['year'] != null && statData['year'].toString().isNotEmpty) {
        _yearController.text = statData['year'].toString();
        // Clear date when year is populated
        _dateController.clear();
        _selectedDate = null;
      }

      // Populate date if available
      if (statData['date'] != null && statData['date'].toString().isNotEmpty) {
        try {
          // Parse the date - API returns format like "1/19/2026"
          String dateStr = statData['date'].toString();
          // Try to parse different date formats
          DateTime? parsedDate;
          try {
            // Try M/d/yyyy format first
            parsedDate = DateFormat('M/d/yyyy').parse(dateStr);
          } catch (e) {
            try {
              // Try yyyy-MM-dd format
              parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
            } catch (e2) {
              // Try other formats
              parsedDate = DateTime.tryParse(dateStr);
            }
          }

          if (parsedDate != null) {
            _selectedDate = parsedDate;
            // Clear year when date is populated
            _yearController.clear();
            final dateProvider =
                Provider.of<DateProvider>(context, listen: false);
            String apiFormatDate = DateFormat('yyyy-MM-dd').format(parsedDate);
            _dateController.text =
                dateProvider.formatCurrentDate(apiFormatDate);
          }
        } catch (e) {
          logError('Error parsing date: $e');
        }
      }

      // Populate value if available
      if (statData['stat_value'] != null) {
        // Remove $ sign and formatting if present
        String valueStr = statData['stat_value'].toString();
        _valueController.text =
            valueStr.replaceAll('\$', '').replaceAll(',', '');
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor, // header background color
              onPrimary: Colors.white, // header text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: blueColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Clear year field when date is selected
        _yearController.clear();
        // Get dateProvider to format the date according to user's preference
        final dateProvider = Provider.of<DateProvider>(context, listen: false);
        // Display format: Use provider's format for user display
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = dateProvider.formatCurrentDate(apiFormatDate);
      });
      // Trigger validation after date is selected
      _formKey.currentState?.validate();
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Please enter a valid year';
    }
    if (year < 2000 || year > 2100) {
      return 'Year must be between 2000 and 2100';
    }
    return null;
  }

  String? _validateValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Value is required';
    }
    // Remove $ sign and commas for validation
    String cleanValue = value.replaceAll('\$', '').replaceAll(',', '');
    final amount = double.tryParse(cleanValue);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  String? _validateYearOrDate() {
    // At least one of year or date must be filled
    if ((_yearController.text.trim().isEmpty) &&
        (_dateController.text.trim().isEmpty)) {
      return 'Either Year or Date must be provided';
    }
    return null;
  }

  bool _hasChanges() {
    if (widget.statId == null) {
      // For new entries, always return true
      return true;
    }

    // Compare current values with initial values
    String currentYear = _yearController.text.trim();
    String currentDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : '';
    double? currentValue = double.tryParse(
        _valueController.text.replaceAll('\$', '').replaceAll(',', ''));

    // Compare year
    bool yearChanged = currentYear != (_initialYear ?? '');

    // Compare date
    bool dateChanged = currentDate != (_initialDate ?? '');

    // Compare value
    bool valueChanged = (currentValue ?? 0) != (_initialValue ?? 0);

    return yearChanged || dateChanged || valueChanged;
  }

  Future<void> _saveForm() async {
    // Set validation flag to show error messages
    setState(() {
      _hasValidated = true;
    });

    // Manual validation
    bool isValid = true;

    // Validate year or date requirement
    String? yearOrDateError = _validateYearOrDate();
    if (yearOrDateError != null) {
      isValid = false;
    }

    // Validate value
    if (_valueController.text.trim().isEmpty) {
      isValid = false;
    } else {
      String cleanValue =
          _valueController.text.replaceAll('\$', '').replaceAll(',', '');
      final amount = double.tryParse(cleanValue);
      if (amount == null || amount <= 0) {
        isValid = false;
      }
    }

    // Validate year if date is empty
    if (_dateController.text.trim().isEmpty) {
      if (_yearController.text.trim().isEmpty) {
        isValid = false;
      } else {
        final year = int.tryParse(_yearController.text.trim());
        if (year == null || year < 2000 || year > 2100) {
          isValid = false;
        }
      }
    }

    // Validate date if year is empty
    if (_yearController.text.trim().isEmpty) {
      if (_dateController.text.trim().isEmpty) {
        isValid = false;
      }
    }

    // Check for changes if editing
    if (widget.statId != null && !_hasChanges()) {
      Fluttertoast.showToast(
        msg: "No changes detected",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      Navigator.pop(context, false);
      return;
    }

    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        String? id = prefs.getString("adminId");

        // Prepare the data according to API structure
        final statData = {
          'year': _yearController.text.trim().isNotEmpty
              ? _yearController.text.trim()
              : null,
          'date': _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : null,
          'stat_value': double.tryParse(
                  _valueController.text.replaceAll('\$', '').replaceAll(',', '')) ??
              0.0,
        };

        http.Response response;
        String apiUrl =
            '${Api_url}/api/rentals/additional-stats/${widget.propertyId}';

        if (widget.statId != null) {
          // Update existing stat (PUT)
          response = await http
              .put(
                Uri.parse('$apiUrl/${widget.statId}'),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'CRM $token',
                  'id': 'CRM $id',
                },
                body: json.encode(statData),
              )
              .timeout(const Duration(seconds: 30));
        } else {
          // Create new stat (POST)
          response = await http
              .post(
                Uri.parse(apiUrl),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'CRM $token',
                  'id': 'CRM $id',
                },
                body: json.encode(statData),
              )
              .timeout(const Duration(seconds: 30));
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: widget.statId != null
                  ? 'Additional stat updated successfully!'
                  : 'Additional stat added successfully!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else {
          if (mounted) {
            // Reset validation flag if form submission fails
            setState(() {
              _hasValidated = false;
            });
            final errorData = json.decode(response.body);
            final errorMessage =
                errorData['message'] ?? 'Failed to save additional stat';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          // Reset validation flag if form submission fails
          setState(() {
            _hasValidated = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving additional stat: ${friendlyErrorMessage(e)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  height: 45.0,
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
                    widget.statId != null
                        ? 'Edit Additional Stat'
                        : 'Add Additional Stat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                    _buildSectionHeader(widget.statId != null
                        ? 'Update additional stat details'
                        : 'Enter value for this property (e.g., Zillow estimate).'),
                    const SizedBox(height: 16),
                    // Year Field
                    _buildTextField(
                      controller: _yearController,
                      label: 'Year *',
                      hint: 'e.g., 2024',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        // Only validate if date is empty
                        if (_dateController.text.trim().isEmpty) {
                          return _validateYear(value);
                        }
                        return null;
                      },
                      enabled: _dateController.text.trim().isEmpty,
                      onChanged: (value) {
                        setState(() {
                          if (value.trim().isNotEmpty) {
                            // Year has value, clear date
                            _dateController.clear();
                            _selectedDate = null;
                          }
                          // If year is cleared, date field will be enabled automatically
                          // because enabled is bound to _dateController.text.trim().isEmpty
                        });
                        // Trigger validation to update UI
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _formKey.currentState?.validate();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date Field
                    _buildDateField(
                      controller: _dateController,
                      label: 'Date *',
                      hint: 'YYYY-MM-DD',
                      onTap: () {
                        if (_yearController.text.trim().isEmpty) {
                          // If date is already filled and user taps, clear it first to allow year entry
                          if (_dateController.text.trim().isNotEmpty) {
                            setState(() {
                              _dateController.clear();
                              _selectedDate = null;
                            });
                            // Force rebuild to update enabled states
                            Future.delayed(Duration(milliseconds: 50), () {
                              if (mounted) {
                                setState(() {
                                  _formKey.currentState?.validate();
                                });
                              }
                            });
                          } else {
                            _selectDate();
                          }
                        }
                      },
                      enabled: _yearController.text.trim().isEmpty,
                      validator: (value) {
                        // Only validate if year is empty
                        if (_yearController.text.trim().isEmpty) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Date is required';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Value Field
                    _buildTextField(
                      controller: _valueController,
                      label: 'Value *',
                      hint: 'e.g., 950000.00',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: _validateValue,
                      prefixText: '\$ ',
                    ),
                    const SizedBox(height: 32),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 45.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: blueColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _saveForm,
                            child: Container(
                              height: 45.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: SpinKitFadingCircle(
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                    : Text(
                                        widget.statId != null
                                            ? 'Update'
                                            : 'Save',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: blueColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? prefixText,
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[500]!, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: enabled ? Colors.transparent : Colors.grey[100],
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              validator: null, // Remove built-in validation
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[300]!),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[500]!, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_dateController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear,
                            size: 18, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _dateController.clear();
                            _selectedDate = null;
                          });
                          // Force rebuild to update enabled states
                          Future.delayed(Duration(milliseconds: 50), () {
                            if (mounted) {
                              setState(() {
                                // Trigger validation to update enabled state
                                _formKey.currentState?.validate();
                              });
                            }
                          });
                        },
                      ),
                    Icon(
                      Icons.calendar_today,
                      color: enabled ? blueColor : Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                filled: true,
                fillColor: enabled ? Colors.transparent : Colors.grey[100],
              ),
            ),
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
}
