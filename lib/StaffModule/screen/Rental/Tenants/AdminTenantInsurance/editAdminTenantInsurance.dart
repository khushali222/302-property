import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AdminTenantInsuranceModel/adminTenantInsuranceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import 'package:http/http.dart' as http;
import '../../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../../widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import '../../../../../provider/dateProvider.dart';

class editAdminInsurance extends StatefulWidget {
  AdminTenantInsuranceModel data;
  editAdminInsurance({super.key, required this.data});

  @override
  State<editAdminInsurance> createState() => _editAdminInsuranceState();
}

class _editAdminInsuranceState extends State<editAdminInsurance> {
  TextEditingController provider = TextEditingController();
  TextEditingController policy = TextEditingController();
  TextEditingController effective = TextEditingController();
  TextEditingController expiration = TextEditingController();
  TextEditingController liablity = TextEditingController();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  bool isLoading = false;
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
          if (_uploadedFileNames.isNotEmpty) {
            _uploadedFileNames.clear();
          }
          _uploadedFileNames.add(fileName);
        }
      });
    } catch (e) {
      print('PDF upload failed: $e');
    }
  }

  Future<String?> uploadPdf(File pdfFile) async {
    print(pdfFile.path);
  }

  DateTime? effectiveDate;
  DateTime? expirationDate;

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
        'dd-MM-yyyy'
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

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: effectiveDate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      //  firstDate: DateTime(1900),
      lastDate: DateTime(2101),
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

    if (selectedDate != null) {
      setState(() {
        effectiveDate = selectedDate;
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        effective.text = dateProvider.formatCurrentDate(apiFormatDate);

        // If effective date is after expiration date, clear expiration date and show warning
        if (expirationDate != null && effectiveDate!.isAfter(expirationDate!)) {
          expirationDate = null;
          expiration.text = '';
          Fluttertoast.showToast(
              msg:
                  "Effective date cannot be after expiration date. Please select a new expiration date.");
        }
      });
    }
  }

  Future<void> _selectDateexpiration(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: expirationDate ?? DateTime.now(),
      firstDate: effectiveDate ?? DateTime.now(),
      // firstDate: DateTime(1900),
      lastDate: DateTime(2101),
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

    if (selectedDate != null) {
      setState(() {
        expirationDate = selectedDate;
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        expiration.text = dateProvider.formatCurrentDate(apiFormatDate);

        // If expiration date is before or same as effective date, show warning
        if (effectiveDate != null &&
            (expirationDate!.isBefore(effectiveDate!) ||
                expirationDate!.isAtSameMomentAs(effectiveDate!))) {
          Fluttertoast.showToast(
              msg: "Expiration date must be after effective date.");
        }
      });
    }
  }

  @override
  initState() {
    provider.text = widget.data.provider!;
    policy.text = widget.data.policyId!;

    // Parse and set DateTime variables from existing data
    try {
      effectiveDate = DateTime.parse(widget.data.effectiveDate!);
      expirationDate = DateTime.parse(widget.data.expirationDate!);
    } catch (e) {
      print('Error parsing dates: $e');
    }

    // Use DateProvider to format dates for display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      effective.text =
          dateProvider.formatCurrentDate(widget.data.effectiveDate!);
      expiration.text =
          dateProvider.formatCurrentDate(widget.data.expirationDate!);
    });

    liablity.text = widget.data.liabilityCoverage.toString()!;
    if (widget.data.policy!.isNotEmpty)
      _uploadedFileNames.add(widget.data.policy!);
    super.initState();
  }

  bool _validateDates() {
    // Check if both dates are selected
    if (effectiveDate == null || expirationDate == null) {
      Fluttertoast.showToast(
          msg: "Please select both Effective Date and Expiration Date");
      return false;
    }

    // Check if expiration date is after effective date
    if (expirationDate!.isBefore(effectiveDate!) ||
        expirationDate!.isAtSameMomentAs(effectiveDate!)) {
      Fluttertoast.showToast(
          msg: "Expiration Date must be after Effective Date");
      return false;
    }

    return true;
  }

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: widget_302_Staff.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawerStaff(
          currentpage: "Tenants",
          dropdown: true,
        ),
        body: Form(
          key: _formkey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  titleBar(
                    width: MediaQuery.of(context).size.width * .91,
                    title: 'Edit Insurance Policy',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      // height: !form_valid ? 860 : 830,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: const Color(0xFFCED4DA),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Provider *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Provider Name',
                              controller: provider,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the subject';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Policy Id *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Policy Id',
                              controller: policy,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the subject';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Effective Date *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              onTap: () {
                                _selectDate(context);
                              },
                              keyboardType: TextInputType.text,
                              hintText: Provider.of<DateProvider>(context,
                                      listen: false)
                                  .dateFormat
                                  .toUpperCase(),
                              controller: effective,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the subject';
                                }
                                return null;
                              },
                              suffixIcon: Icon(
                                Icons.date_range,
                                color: blueColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Expiration Date *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              onTap: () {
                                _selectDateexpiration(context);
                              },
                              keyboardType: TextInputType.text,
                              hintText: Provider.of<DateProvider>(context,
                                      listen: false)
                                  .dateFormat
                                  .toUpperCase(),
                              controller: expiration,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the subject';
                                }
                                return null;
                              },
                              suffixIcon: Icon(
                                Icons.date_range,
                                color: blueColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Liability Coverage *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              hintText: '\$0.0',
                              controller: liablity,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    r'^\d*\.?\d{0,2}')), // allows decimals
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter the liability coverage.';
                                }
                                final parsed = double.tryParse(value.trim());
                                if (parsed == null) {
                                  return 'Liability Coverage must be a number. Please enter a valid numeric value.';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Upload Insurance Document',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: _pickPdfFiles,
                              child: Container(
                                width: double.infinity,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCED4DA), width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.upload, size: 36, color: Color(0xFF6B7A99)),
                                    const SizedBox(height: 8),
                                    const Text('Click to upload document',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                            color: Color(0xFF4A5568))),
                                  ],
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: _uploadedFileNames.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String fileName = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFCED4DA), width: 1.2),
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xFFF8F9FA),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file_outlined, size: 16, color: Color(0xFF6B7A99)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF748097),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _uploadedFileNames.removeAt(index);
                                            });
                                          },
                                          child: const Icon(Icons.close, size: 16, color: Color(0xFF748097)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  if (_validateDates()) {
                                    editinsurance(widget.data.tenantInsuranceId!);
                                  }
                                }
                              },
                              child: isLoading
                                  ? const Center(
                                      child: SpinKitFadingCircle(
                                        color: Colors.white,
                                        size: 55.0,
                                      ),
                                    )
                                  : const Text(
                                      'Save',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCED4DA), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Color(0xFF748097), fontWeight: FontWeight.w600),
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
          ),
        ));
  }

  editinsurance(String TenantInsurance_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    Map<String, dynamic> values = {
      "admin_id": adminId!,
      "Provider": provider.text.trim(),
      "policy_id": policy.text.trim(),
      "EffectiveDate": _convertToApiFormat(effective.text.trim()),
      "ExpirationDate": _convertToApiFormat(expiration.text.trim()),
      "LiabilityCoverage": liablity.text.trim(),
      "Policy": _uploadedFileNames.length > 0 ? _uploadedFileNames.first : "",
    };

    final http.Response response = await http.put(
      Uri.parse(
          '$Api_url/api/tenantinsurance/tenantinsurance/$TenantInsurance_id'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminId",
        //'Content-Type': 'application/json; charset=UTF-8',
      },
      body: values,
    );

    print(response.body);
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      Navigator.of(context).pop(true);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to Insurance');
    }
  }
}
