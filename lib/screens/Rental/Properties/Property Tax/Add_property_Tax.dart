import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:provider/provider.dart';
import '../../../../provider/dateProvider.dart';

class Add_property_Tax extends StatefulWidget {
  // pass the mortgage data to this screen from the previous screen
  final Map<String, dynamic>? taxData;
  final String? taxId; // For editing existing mortgages

  const Add_property_Tax({Key? key, this.taxId, this.taxData})
      : super(key: key);

  @override
  State<Add_property_Tax> createState() => _Add_property_TaxState();
}

class _Add_property_TaxState extends State<Add_property_Tax> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _taxAuthorityController = TextEditingController();
  final _taxAmountController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _paidDateController = TextEditingController();
  final _statusController = TextEditingController();
  final _taxYearController = TextEditingController();

  // Selected dates
  DateTime? _dueDate;
  DateTime? _paidDate;

  // Status options
  final List<String> _statusOptions = [
    'Pending',
    'Paid',
    'Overdue',
    'Cancelled'
  ];

  // Year options (2000 to current year)
  List<String> _yearOptions = [];

  bool _isLoading = false;

  String _convertToApiFormat(String displayDate) {
    if (displayDate.isEmpty) return "";
    try {
      DateTime? parsedDate;

      // Try to parse the date using common formats
      List<String> dateFormats = [
        'MM/dd/yyyy',
        'MM-dd-yyyy',
        'yyyy-MM-dd',
        'yyyy-MMM-dd', // Added for API format like "2025-Aug-22"
        'dd/MM/yyyy',
        'dd-MM-yyyy',
        'dd/MMM/yyyy' // Added for current format
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
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        return displayDate; // Return original if parsing fails
      }
    } catch (e) {
      return displayDate; // Return original if parsing fails
    }
  }

  @override
  void initState() {
    super.initState();
    _generateYearOptions();

    if (widget.taxId != null && widget.taxData != null) {
      _populateFormWithData(widget.taxData!);
    }
  }

  void dispose() {
    _taxAuthorityController.dispose();
    _taxAmountController.dispose();
    _assessmentController.dispose();
    _dueDateController.dispose();
    _paidDateController.dispose();
    _statusController.dispose();
    _taxYearController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _generateYearOptions() {
    int currentYear = DateTime.now().year;
    _yearOptions = List.generate(
      currentYear - 1999, // 2000 to current year
      (index) => (2000 + index).toString(),
    );
    _yearOptions = _yearOptions.reversed.toList(); // Most recent first
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? initialDate) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(picked);
        if (controller == _dueDateController) {
          _dueDate = picked;
          controller.text = dateProvider.formatCurrentDate(apiFormatDate);
        } else if (controller == _paidDateController) {
          _paidDate = picked;
          controller.text = dateProvider.formatCurrentDate(apiFormatDate);
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

  void _populateFormWithData(Map<String, dynamic> taxData) {
    try {
      setState(() {
        // Tax Information
        _taxAuthorityController.text = taxData['tax_authority'] ?? '';
        _taxAmountController.text = taxData['tax_amount']?.toString() ?? '';
        _assessmentController.text =
            taxData['assessment_value']?.toString() ?? '';
        _taxYearController.text = taxData['tax_year']?.toString() ?? '';
        _statusController.text = taxData['status'] ?? '';

        // Handle dates using DateProvider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final dateProvider =
              Provider.of<DateProvider>(context, listen: false);
          if (taxData['due_date'] != null) {
            try {
              _dueDate = DateTime.parse(taxData['due_date']);
              _dueDateController.text =
                  dateProvider.formatCurrentDate(taxData['due_date']);
            } catch (e) {
              // Handle invalid date format
            }
          }
          if (taxData['paid_date'] != null) {
            try {
              _paidDate = DateTime.parse(taxData['paid_date']);
              _paidDateController.text =
                  dateProvider.formatCurrentDate(taxData['paid_date']);
            } catch (e) {
              // Handle invalid date format
            }
          }
        });
      });
    } catch (e) {
      print('Error populating form: $e');
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

        // Prepare the tax data according to your API structure
        final taxData = {
          'tax_authority': _taxAuthorityController.text.trim(),
          'tax_amount':
              double.tryParse(_taxAmountController.text.replaceAll('\$', '')) ??
                  0.0,
          'assessment_value': double.tryParse(
                  _assessmentController.text.replaceAll('\$', '')) ??
              0.0,
          'tax_year': _taxYearController.text.trim(),
          'due_date': _dueDateController.text.isNotEmpty
              ? _convertToApiFormat(_dueDateController.text.trim())
              : null,
          'paid_date': _paidDateController.text.isNotEmpty
              ? _convertToApiFormat(_paidDateController.text.trim())
              : null,
          'status': _statusController.text.trim().toLowerCase(),
        };

        http.Response response;
        String apiUrl = '$Api_url/api/taxes';

        if (widget.taxId != null) {
          // Update existing tax (PUT)
          response = await http
              .put(
                Uri.parse('$apiUrl/${widget.taxId}'),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'CRM $token',
                  'id': 'CRM $id',
                },
                body: json.encode(taxData),
              )
              .timeout(const Duration(seconds: 30));
        } else {
          // Create new tax (POST)
          response = await http
              .post(
                Uri.parse(apiUrl),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'CRM $token',
                  'id': 'CRM $id',
                },
                body: json.encode(taxData),
              )
              .timeout(const Duration(seconds: 30));
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.taxId != null
                    ? 'Tax record updated successfully!'
                    : 'Tax record created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            final errorData = json.decode(response.body);
            final errorMessage =
                errorData['message'] ?? 'Failed to save tax record';
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
              content: Text('Error saving tax record: ${e.toString()}'),
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

  //for image
  File? _image;
  bool isLoading = false;
  List<File> _images = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  List<String> _imageUrls = [];
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _images.add(File(image.path));
      });
      _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? fileName = await uploadImage(imageFile);
      setState(() {
        _uploadedFileNames.add(fileName!);
        _uploadedFileName = fileName;
        _imageUrls.add(fileName!);
      });
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.taxId != null ? 'Edit Tax Record' : 'Add Tax Record'),
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Add new tax record for this property'),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      controller: _taxYearController,
                      label: 'Tax Year *',
                      hint: 'Select tax year',
                      validator: (value) =>
                          _validateRequired(value, 'Tax year'),
                      items: _yearOptions,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _taxAuthorityController,
                      label: 'Tax Authority *',
                      hint: 'Enter tax authority',
                      validator: (value) =>
                          _validateRequired(value, 'Tax authority'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _taxAmountController,
                      label: 'Tax Amount *',
                      hint: '\$Enter Tax amount',
                      keyboardType: TextInputType.number,
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _assessmentController,
                      label: 'Assessment Value *',
                      hint: '\$Enter assessment value',
                      keyboardType: TextInputType.number,
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _dueDateController,
                      label: 'Due Date *',
                      hint: Provider.of<DateProvider>(context, listen: false)
                          .dateFormat
                          .toUpperCase(),
                      onTap: () =>
                          _selectDate(context, _dueDateController, _dueDate),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _paidDateController,
                      label: 'Paid Date',
                      hint: Provider.of<DateProvider>(context, listen: false)
                          .dateFormat
                          .toUpperCase(),
                      onTap: () =>
                          _selectDate(context, _paidDateController, _paidDate),
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
                    Text("Receipt (Optional)"),
                    const SizedBox(height: 8),
                    if (_images.isEmpty)
                      GestureDetector(
                        onTap: () {
                          _pickImage().then((_) {
                            setState(() {});
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // Icon(Icons.upload,
                              //     size: 40, color: Colors.grey[600]),
                              Image.asset(
                                'assets/icons/Upload.png',
                                height: 50,
                                width: 50,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Upload your Photo here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Maximum File Size is 20MB',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Supported File Types are .png, .jpeg, .pdf, .csv',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_images.isEmpty) SizedBox(height: 16),
                    if (_images.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      _pickImage().then((_) {
                                        setState(() {});
                                      });
                                    },
                                    child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: blueColor,
                                          borderRadius:
                                          BorderRadius.circular(7),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 15,
                                        ))),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, right: 10),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment:
                                  WrapCrossAlignment.start,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                  List.generate(_images.length, (index) {
                                    return Stack(
                                      clipBehavior: Clip.none, //
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                  Colors.grey.shade300),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                              child: Image.file(
                                                _images[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0, //
                                          right: 0, //
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _images.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.taxId != null ? 'Update' : 'Save',
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
}
