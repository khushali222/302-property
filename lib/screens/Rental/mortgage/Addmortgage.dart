import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';

// Custom Phone Number Formatter
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    // Format as (XXX) XXX-XXXX
    String formatted = '';
    if (digitsOnly.length >= 1) {
      formatted =
          '(${digitsOnly.substring(0, digitsOnly.length > 3 ? 3 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 4) {
      formatted +=
          ') ${digitsOnly.substring(3, digitsOnly.length > 6 ? 6 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 7) {
      formatted += '-${digitsOnly.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddMortgageScreen extends StatefulWidget {
  // pass the mortgage data to this screen from the previous screen
  final Map<String, dynamic>? mortgageData;
  final String? mortgageId; // For editing existing mortgages

  const AddMortgageScreen({Key? key, this.mortgageId, this.mortgageData})
      : super(key: key);

  @override
  State<AddMortgageScreen> createState() => _AddMortgageScreenState();
}

class _AddMortgageScreenState extends State<AddMortgageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _propertyController = TextEditingController();
  final List<Map<String, dynamic>> _selectedProperties = [];
  final _bankNameController = TextEditingController();
  final _bankAddressController = TextEditingController();
  final _bankContactController = TextEditingController();
  final _bankEmailController = TextEditingController();
  final _managerFirstNameController = TextEditingController();
  final _managerLastNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  final _managerEmailController = TextEditingController();
  final _mortgageNumberController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _statusController = TextEditingController();
  final _remainingBalanceController = TextEditingController();
  final _lastPaymentDateController = TextEditingController();
  final _nextPaymentDateController = TextEditingController();
  final _borrowerFirstNameController = TextEditingController();
  final _borrowerLastNameController = TextEditingController();
  final _borrowerSSNController = TextEditingController();
  final _borrowerAddressController = TextEditingController();
  final _borrowerPhoneController = TextEditingController();
  final _borrowerEmailController = TextEditingController();

  // Selected dates
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastPaymentDate;
  DateTime? _nextPaymentDate;

  // Status options
  final List<String> _statusOptions = [
    'Active',
    'Paid Off',
    'Defaulted',
    'Refinanced'
  ];
  List<Map<String, dynamic>> _propertyOptions = [];
  bool _isLoadingProperties = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();

    if (widget.mortgageId != null) {}
  }

  void dispose() {
    _propertyController.dispose();
    _bankNameController.dispose();
    _bankAddressController.dispose();
    _bankContactController.dispose();
    _bankEmailController.dispose();
    _managerFirstNameController.dispose();
    _managerLastNameController.dispose();
    _managerPhoneController.dispose();
    _managerEmailController.dispose();
    _mortgageNumberController.dispose();
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _statusController.dispose();
    _remainingBalanceController.dispose();
    _lastPaymentDateController.dispose();
    _nextPaymentDateController.dispose();
    _borrowerFirstNameController.dispose();
    _borrowerLastNameController.dispose();
    _borrowerSSNController.dispose();
    _borrowerAddressController.dispose();
    _borrowerPhoneController.dispose();
    _borrowerEmailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

// add the first date picker for the start date

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? initialDate,
      {DateTime? firstDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor, // header background color
              onPrimary: Colors.white, // header text color
              // onSurface: Colors.blue, // body text color
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
        // Get dateProvider to format the date according to user's preference
        final dateProvider = Provider.of<DateProvider>(context, listen: false);
        // Display format: Use provider's format for user display
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(picked);
        String displayFormat = dateProvider.formatCurrentDate(apiFormatDate);

        if (controller == _startDateController) {
          _startDate = picked;
          controller.text = displayFormat;
        } else if (controller == _endDateController) {
          _endDate = picked;
          controller.text = displayFormat;
        } else if (controller == _lastPaymentDateController) {
          _lastPaymentDate = picked;
          controller.text = displayFormat;
        } else if (controller == _nextPaymentDateController) {
          _nextPaymentDate = picked;
          controller.text = displayFormat;
        }
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      // Remove all non-digit characters to check length
      String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.length != 10) {
        return 'Phone number must be exactly 10 digits';
      }

      // Optional: Check if it's a valid US phone number format
      final phoneRegex = RegExp(r'^\(\d{3}\) \d{3}-\d{4}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Please enter a valid phone number format';
      }
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value != null && value.isNotEmpty) {
      final amountRegex = RegExp(r'^\$?\d+(\.\d{1,2})?$');
      if (!amountRegex.hasMatch(value)) {
        return 'Please enter a valid amount';
      }
      final amount = double.tryParse(value.replaceAll('\$', ''));
      if (amount == null || amount <= 0) {
        return 'Amount must be greater than 0';
      }
    }
    return null;
  }

  String? _validateInterestRate(String? value) {
    if (value != null && value.isNotEmpty) {
      final rate = double.tryParse(value.replaceAll('%', ''));
      if (rate == null || rate < 0 || rate > 100) {
        return 'Interest rate must be between 0% and 100%';
      }
    }
    return null;
  }

  String? _validateSSN(String? value) {
    if (value != null && value.isNotEmpty) {
      final ssnRegex = RegExp(r'^\d{3}-?\d{2}-?\d{4}$');
      if (!ssnRegex.hasMatch(value)) {
        return 'Please enter a valid SSN (XXX-XX-XXXX)';
      }
    }
    return null;
  }

  String? _validateMortgageNumber(String? value) {
    if (value != null && value.isNotEmpty) {
      // Remove all non-digit characters to check length
      String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.length < 3) {
        return 'Mortgage number must be at least 3 digits';
      }
    }
    return null;
  }

  String? _validateProperties() {
    if (_selectedProperties.isEmpty) {
      return 'At least one property must be selected';
    }
    return null;
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      final response = await http.get(
        Uri.parse(
            'https://staging.cloudrentalmanager.com/api/mortgage/properties/list'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
          // Add your authentication headers here if needed
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            _propertyOptions = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          // Handle empty data response
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No properties found in the response.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else if (response.statusCode == 401) {
        // Handle authentication error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required. Please login again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        // Load fallback properties for development/testing
        _loadFallbackProperties();
      } else {
        // Handle other errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to load properties: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Load fallback properties for development/testing
        _loadFallbackProperties();
      }
      if (widget.mortgageId != null) {
        _loadMortgageData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading properties: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Load fallback properties for development/testing
      _loadFallbackProperties();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProperties = false;
        });
      }
    }
  }

  void _loadFallbackProperties() {
    // Fallback properties for development/testing when API is not accessible
    setState(() {
      _propertyOptions = [
        {
          'rental_id': '1755846103111',
          'address': '024 Evergreen Lane',
          'city': 'Portland',
          'state': 'Oregon',
          'zipcode': '97205',
          'subdivision': 'Riverbend Estates',
          'full_address': '024 Evergreen Lane Portland Oregon 97205'
        },
        {
          'rental_id': '1748925551064',
          'address': '1200 Commerce Blvd',
          'city': 'Denverr',
          'state': 'CO',
          'zipcode': '80202',
          'subdivision': 'N/A',
          'full_address': '1200 Commerce Blvd Denverr CO 80202'
        },
        {
          'rental_id': '1748925551065',
          'address': '123 Elm Street',
          'city': 'Austin',
          'state': 'Texas',
          'zipcode': '73301',
          'subdivision': 'Downtown District',
          'full_address': '123 Elm Street Austin Texas 73301'
        },
      ];
    });
  }

  Future<void> _loadMortgageData() async {
    if (widget.mortgageId == null) return;

    // assign the data from widget.mortgageData to the form
    _populateFormWithData(widget.mortgageData!);
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? token = prefs.getString('token');
      // String? id = prefs.getString('adminId');
      //
      // final response = await http.get(
      //   Uri.parse('$Api_url/api/mortgage/${widget.mortgageId}'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'authorization': 'CRM $token',
      //     'id': 'CRM $id',
      //   },
      // ).timeout(const Duration(seconds: 30));

      // if (response.statusCode == 200) {
      //   print(response.body);
      //   final data = json.decode(response.body);

      //   if (data['data'] != null) {
      //     _populateFormWithData(data['data']);
      //   }
      // } else {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('Failed to load mortgage: ${response.statusCode}'),
      //         backgroundColor: Colors.red,
      //       ),
      //     );
      //   }
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading mortgage: ${e.toString()}'),
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
  // populate the form with the data from the widget.mortgageData

  void _populateFormWithData(Map<String, dynamic> mortgageData) {
    try {
      setState(() {
        // Bank Information
        _bankNameController.text = mortgageData['bank_name'] ?? '';
        _bankAddressController.text = mortgageData['bank_address'] ?? '';
        _bankContactController.text = mortgageData['bank_contact_no'] ?? '';
        _bankEmailController.text = mortgageData['bank_email'] ?? '';

        // Relationship Manager Information
        _managerFirstNameController.text =
            mortgageData['relationship_manager_first_name'] ?? '';
        _managerLastNameController.text =
            mortgageData['relationship_manager_last_name'] ?? '';
        _managerPhoneController.text =
            mortgageData['relationship_manager_phone'] ?? '';
        _managerEmailController.text =
            mortgageData['relationship_manager_email'] ?? '';

        // Mortgage Details
        _mortgageNumberController.text = mortgageData['mortgage_no'] ?? '';
        _loanAmountController.text = mortgageData['loan_amount'].toString();
        print(mortgageData['interest_rate']);
        _interestRateController.text = mortgageData['interest_rate'].toString();

        // Format dates properly for display using DateProvider
        if (mortgageData['start_date'] != null &&
            mortgageData['start_date'].toString().isNotEmpty) {
          try {
            _startDate = DateTime.parse(mortgageData['start_date']);
            // Use DateProvider to format according to user's preference
            final dateProvider =
            Provider.of<DateProvider>(context, listen: false);
            String apiFormatDate = DateFormat('yyyy-MM-dd').format(_startDate!);
            _startDateController.text =
                dateProvider.formatCurrentDate(apiFormatDate);
          } catch (e) {
            _startDateController.text = '';
          }
        } else {
          _startDateController.text = '';
        }

        if (mortgageData['end_date'] != null &&
            mortgageData['end_date'].toString().isNotEmpty) {
          try {
            _endDate = DateTime.parse(mortgageData['end_date']);
            // Use DateProvider to format according to user's preference
            final dateProvider =
            Provider.of<DateProvider>(context, listen: false);
            String apiFormatDate = DateFormat('yyyy-MM-dd').format(_endDate!);
            _endDateController.text =
                dateProvider.formatCurrentDate(apiFormatDate);
          } catch (e) {
            _endDateController.text = '';
          }
        } else {
          _endDateController.text = '';
        }

        // mortgageData['status'] first letter make a so that.. because active is not match with Active
        print("mortgageData['status'] ${mortgageData['status']}");
        // if mortgageData['status'] is I/flutter ( 4495): mortgageData['status'] paid_off then make it Paid Off detecct the "_" and make the first letter uppercase
        final status = mortgageData['status'].toString();
        final formattedStatus = status
            .split('_') // split into ['paid', 'off']
            .map((word) =>
        word[0].toUpperCase() + word.substring(1)) // capitalize each
            .join(' '); // join back with space

        _statusController.text = formattedStatus;

        //_statusController.text = mortgageData['status'] ?? '';
        _remainingBalanceController.text =
            mortgageData['remaining_balance'].toString();

        // Format payment dates properly for display using DateProvider
        if (mortgageData['last_payment_date'] != null &&
            mortgageData['last_payment_date'].toString().isNotEmpty) {
          try {
            _lastPaymentDate =
                DateTime.parse(mortgageData['last_payment_date']);
            // Use DateProvider to format according to user's preference
            final dateProvider =
            Provider.of<DateProvider>(context, listen: false);
            String apiFormatDate =
            DateFormat('yyyy-MM-dd').format(_lastPaymentDate!);
            _lastPaymentDateController.text =
                dateProvider.formatCurrentDate(apiFormatDate);
          } catch (e) {
            _lastPaymentDateController.text = '';
          }
        } else {
          _lastPaymentDateController.text = '';
        }

        if (mortgageData['next_payment_date'] != null &&
            mortgageData['next_payment_date'].toString().isNotEmpty) {
          try {
            _nextPaymentDate =
                DateTime.parse(mortgageData['next_payment_date']);
            // Use DateProvider to format according to user's preference
            final dateProvider =
            Provider.of<DateProvider>(context, listen: false);
            String apiFormatDate =
            DateFormat('yyyy-MM-dd').format(_nextPaymentDate!);
            _nextPaymentDateController.text =
                dateProvider.formatCurrentDate(apiFormatDate);
          } catch (e) {
            _nextPaymentDateController.text = '';
          }
        } else {
          _nextPaymentDateController.text = '';
        }

        // Borrower Information
        _borrowerFirstNameController.text =
            mortgageData['borrower_first_name'] ?? '';
        _borrowerLastNameController.text =
            mortgageData['borrower_last_name'] ?? '';
        _borrowerSSNController.text = mortgageData['borrower_ssn'] ?? '';
        _borrowerAddressController.text =
            mortgageData['borrower_address'] ?? '';
        _borrowerPhoneController.text = mortgageData['borrower_phone'] ?? '';
        _borrowerEmailController.text = mortgageData['borrower_email'] ?? '';

        print(mortgageData['properties']);

        // Handle properties selection
        if (mortgageData['properties'] != null &&
            mortgageData['properties'] is List) {
          _selectedProperties.clear();
          for (var propertyId in mortgageData['properties']) {
            print(propertyId);
            print(_propertyOptions);
            // Find the property in _propertyOptions by rental_id
            final property = _propertyOptions.firstWhere(
                  (p) => p['rental_id'] == propertyId,
              orElse: () => <String, dynamic>{},
            );
            if (property.isNotEmpty) {
              _selectedProperties.add(property);
            }
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        String? id = prefs.getString('adminId');

        // Prepare the data according to your API structure
        final mortgageData = {
          'properties': _selectedProperties.map((p) => p['rental_id']).toList(),
          'bank_name': _bankNameController.text.trim(),
          'bank_address': _bankAddressController.text.trim(),
          'bank_contact_no': _bankContactController.text.trim(),
          'bank_email': _bankEmailController.text.trim(),
          'relationship_manager_first_name':
              _managerFirstNameController.text.trim(),
          'relationship_manager_last_name':
              _managerLastNameController.text.trim(),
          'relationship_manager_phone': _managerPhoneController.text.trim(),
          'relationship_manager_email': _managerEmailController.text.trim(),
          'mortgage_no': _mortgageNumberController.text.trim(),
          'loan_amount': _loanAmountController.text.trim(),
          'interest_rate': _interestRateController.text.trim(),
          'start_date': _startDate != null ? _startDate!.toIso8601String() : '',
          'end_date': _endDate != null ? _endDate!.toIso8601String() : '',
          'status':  _statusController.text.trim().toLowerCase().replaceAll(' ', '_'),
          'remaining_balance': _remainingBalanceController.text.trim(),
          'last_payment_date': _lastPaymentDate != null
              ? _lastPaymentDate!.toIso8601String()
              : '',
          'next_payment_date': _nextPaymentDate != null
              ? _nextPaymentDate!.toIso8601String()
              : '',
          'borrower_first_name': _borrowerFirstNameController.text.trim(),
          'borrower_last_name': _borrowerLastNameController.text.trim(),
          'borrower_ssn': _borrowerSSNController.text.trim(),
          'borrower_address': _borrowerAddressController.text.trim(),
          'borrower_phone': _borrowerPhoneController.text.trim(),
          'borrower_email': _borrowerEmailController.text.trim(),
        };

        http.Response response;
        String apiUrl = '$Api_url/api/mortgage';

        if (widget.mortgageId != null) {
          // Update existing mortgage (PUT)
          response = await http
              .put(
                Uri.parse('$apiUrl/${widget.mortgageId}'),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'CRM $token',
                  'id': 'CRM $id',
                },
                body: json.encode(mortgageData),
              )
              .timeout(const Duration(seconds: 30));
        } else {
          // Create new mortgage (POST)
          response = await http
              .post(
                Uri.parse(apiUrl),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'CRM $token',
                  'id': 'CRM $id',
                },
                body: json.encode(mortgageData),
              )
              .timeout(const Duration(seconds: 30));
        }
        print("responce mortgage ${response.body}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.mortgageId != null
                    ? 'Mortgage updated successfully!'
                    : 'Mortgage created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            final errorData = json.decode(response.body);
            final errorMessage =
                errorData['message'] ?? 'Failed to save mortgage';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving mortgage: ${e.toString()}'),
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
                  //if appliance is not null then show edit else show add
                  child: Text(
                    widget.mortgageId != null
                        ? 'Edit Mortgage Information'
                        : 'Add Mortgage Information',
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
                    // Property Selection Section
                    if (_isLoadingProperties)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              SpinKitFadingCircle(
                                color: Colors.black,
                                size: 50.0,
                              ),
                              SizedBox(height: 8),
                              Text('Loading properties...'),
                            ],
                          ),
                        ),
                      )
                    else if (_propertyOptions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.home_outlined,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'No properties available',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadProperties,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildMultiSelectField(
                        label: 'Select Properties *',
                        hint: 'Select properties...',
                        validator: _validateProperties,
                        items: _propertyOptions,
                        selectedItems: _selectedProperties,
                        onSelectionChanged:
                            (List<Map<String, dynamic>> selectedItems) {
                          setState(() {
                            _selectedProperties.clear();
                            _selectedProperties.addAll(selectedItems);
                          });
                        },
                      ),
                    const SizedBox(height: 24),

                    // Bank Information Section
                    _buildSectionHeader('Bank Information'),
                    _buildTextField(
                      controller: _bankNameController,
                      label: 'Name *',
                      hint: 'Enter bank name',
                      validator: (value) =>
                          _validateRequired(value, 'Bank name'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bankAddressController,
                      label: 'Address',
                      hint: 'Enter bank address',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bankContactController,
                      label: 'Contact Number *',
                      hint: 'Enter bank contact number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneNumberFormatter()],
                      validator: (value) {
                        String? requiredError =
                            _validateRequired(value, 'Bank contact number');
                        if (requiredError != null) return requiredError;
                        return _validatePhone(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bankEmailController,
                      label: 'Email',
                      hint: 'Enter bank email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 24),

                    // Relationship Manager Information Section
                    _buildSectionHeader('Relationship Manager Information'),
                    _buildTextField(
                      controller: _managerFirstNameController,
                      label: 'First Name',
                      hint: 'Enter first name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _managerLastNameController,
                      label: 'Last Name',
                      hint: 'Enter last name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _managerPhoneController,
                      label: 'Phone *',
                      hint: 'Enter relationship manager phone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneNumberFormatter()],
                      validator: (value) {
                        String? requiredError =
                            _validateRequired(value, 'Manager phone');
                        if (requiredError != null) return requiredError;
                        return _validatePhone(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _managerEmailController,
                      label: 'Email',
                      hint: 'Enter email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 24),

                    // Mortgage Details Section
                    _buildSectionHeader('Mortgage Details'),
                    _buildTextField(
                      controller: _mortgageNumberController,
                      label: 'Mortgage Number *',
                      hint: 'Enter mortgage number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        String? requiredError =
                            _validateRequired(value, 'Mortgage number');
                        if (requiredError != null) return requiredError;
                        return _validateMortgageNumber(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _loanAmountController,
                      label: 'Loan Amount *',
                      hint: '\$Enter loan amount',
                      keyboardType: TextInputType.number,
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _interestRateController,
                      label: 'Interest Rate *',
                      hint: 'Enter interest rate',
                      keyboardType: TextInputType.number,
                      validator: _validateInterestRate,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _startDateController,
                      label: 'Start Date *',
                      hint: 'DD/MMM/YYYY',
                      onTap: () => _selectDate(
                          context, _startDateController, _startDate),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _endDateController,
                      label: 'End Date *',
                      hint: 'DD/MMM/YYYY',
                      onTap: () =>
                          _selectDate(context, _endDateController, _endDate),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      controller: _statusController,
                      label: 'Status *',
                      hint: 'Select status',
                      validator: (value) => _validateRequired(value, 'Status'),
                      items: _statusOptions,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _remainingBalanceController,
                      label: 'Remaining Balance',
                      hint: '\$Enter remaining balance',
                      keyboardType: TextInputType.number,
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _lastPaymentDateController,
                      label: 'Last Payment Date',
                      hint: 'DD/MMM/YYYY',
                      onTap: () => _selectDate(context,
                          _lastPaymentDateController, _lastPaymentDate),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _nextPaymentDateController,
                      label: 'Next Payment Date',
                      hint: 'DD/MMM/YYYY',
                      onTap: () => _selectDate(
                          context, _nextPaymentDateController, _nextPaymentDate,
                          firstDate: _lastPaymentDate),
                    ),
                    const SizedBox(height: 24),

                    // Borrower Information Section
                    _buildSectionHeader('Borrower Information'),
                    _buildTextField(
                      controller: _borrowerFirstNameController,
                      label: 'First Name *',
                      hint: 'Enter first name',
                      validator: (value) =>
                          _validateRequired(value, 'Borrower first name'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _borrowerLastNameController,
                      label: 'Last Name *',
                      hint: 'Enter last name',
                      validator: (value) =>
                          _validateRequired(value, 'Borrower last name'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _borrowerSSNController,
                      label: 'SSN',
                      hint: 'Enter SSN',
                      validator: _validateSSN,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _borrowerAddressController,
                      label: 'Address',
                      hint: 'Enter address',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _borrowerPhoneController,
                      label: 'Phone *',
                      hint: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneNumberFormatter()],
                      validator: (value) {
                        String? requiredError =
                            _validateRequired(value, 'Borrower phone');
                        if (requiredError != null) return requiredError;
                        return _validatePhone(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _borrowerEmailController,
                      label: 'Email',
                      hint: 'Enter email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: blueColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      widget.mortgageId != null
                                          ? 'Update'
                                          : 'Save',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
          fontSize: 18,
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
    int maxLines = 1,
    Widget? suffix,
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
          maxLines: maxLines,
          validator: validator,
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
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
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
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
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
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: blueColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required List<String> items,
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
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
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
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              controller.text = newValue ?? '';
            });
          },
          validator: validator,
          icon: Icon(Icons.arrow_drop_down, color: blueColor),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required String hint,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> selectedItems,
    required Function(List<Map<String, dynamic>>) onSelectionChanged,
    String? Function()? validator,
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Selected Properties Tags
              if (selectedItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedItems.map((property) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: blueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: blueColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              property['address'] ?? 'Unknown Property',
                              style: TextStyle(
                                color: blueColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                final newSelection =
                                    List<Map<String, dynamic>>.from(
                                        selectedItems);
                                newSelection.remove(property);
                                onSelectionChanged(newSelection);
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: blueColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Dropdown Button
              InkWell(
                onTap: () {
                  _showPropertySelectionDialog(
                      context, items, selectedItems, onSelectionChanged);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedItems.isEmpty
                              ? hint
                              : '${selectedItems.length} properties selected',
                          style: TextStyle(
                            color: selectedItems.isEmpty
                                ? Colors.grey[400]
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: blueColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (validator != null)
          Builder(
            builder: (context) {
              final error = validator();
              if (error != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    error,
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

  void _showPropertySelectionDialog(
    BuildContext context,
    List<Map<String, dynamic>> items,
    List<Map<String, dynamic>> selectedItems,
    Function(List<Map<String, dynamic>>) onSelectionChanged,
  ) {
    List<Map<String, dynamic>> tempSelection = List.from(selectedItems);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Properties'),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxHeight: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Select All Checkbox
                    CheckboxListTile(
                      title: const Text(
                        'Select All',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: tempSelection.length == items.length,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelection = List.from(items);
                          } else {
                            tempSelection.clear();
                          }
                        });
                      },
                      activeColor: blueColor,
                    ),
                    const Divider(),
                    // Property List
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final property = items[index];
                          final isSelected = tempSelection.contains(property);
                          return CheckboxListTile(
                            title: Text(
                              property['address'] ?? 'Unknown Property',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${property['city'] ?? ''} ${property['state'] ?? ''} ${property['zipcode'] ?? ''}'
                                  .trim(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (!tempSelection.contains(property)) {
                                    tempSelection.add(property);
                                  }
                                } else {
                                  tempSelection.remove(property);
                                }
                              });
                            },
                            activeColor: blueColor,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSelectionChanged(tempSelection);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
