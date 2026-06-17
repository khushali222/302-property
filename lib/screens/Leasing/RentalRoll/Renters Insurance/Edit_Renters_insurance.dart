import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:three_zero_two_property/Model/Renters_Insurnce/Edit_insurnce.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:provider/provider.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../../model/LeaseSummary.dart';
import '../../../../repository/lease.dart';
import '../../../../repository/lease_rental_insurance_repo.dart';
import '../../../../widgets/custom_drawer.dart';

class EditRentersInsurance extends StatefulWidget {
  final String tenantid;
  final String leaseId;
  final String renters_insurance_id;
  const EditRentersInsurance(
      {required this.tenantid,
      required this.leaseId,
      required this.renters_insurance_id});

  @override
  State<EditRentersInsurance> createState() => _EditRentersInsuranceState();
}

class _EditRentersInsuranceState extends State<EditRentersInsurance> {
  TextEditingController company = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController policy = TextEditingController();
  TextEditingController effective = TextEditingController();
  TextEditingController expiration = TextEditingController();
  TextEditingController liablity = TextEditingController();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    fetchTenants();
    fetchRentersDetails(widget.renters_insurance_id);
  }

  Future<void> fetchRentersDetails(String renters_insurance_id) async {
    //try {
    // await _loadProperties();
    RentersEdit fetchedDetails = await RentersInsuranceService()
        .fetchRentersDetails(renters_insurance_id);
    print(renters_insurance_id);

    print('Address ${fetchedDetails.insurancePolicyDocument}');

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // print(fetchedDetails.rental.rentalAddress);

      //_imageUrls = fetchedDetails.workOrderImages ?? [];
      company.text = fetchedDetails.insuranceCompany!;
      number.text = fetchedDetails.insuranceCompanyPhoneNumber!;

      policy.text = fetchedDetails.policyId ?? "";
      // effective.text = fetchedDetails.expirationDate ?? "" ;
      // expiration.text = fetchedDetails.expirationDate ?? "";

      // Convert API date format to user's preferred display format
      final dateProvider = Provider.of<DateProvider>(context, listen: false);

      // Set effective date
      if (fetchedDetails.effectiveDate != null) {
        effectiveDate =
            DateTime.parse(fetchedDetails.effectiveDate!.substring(0, 10));
        effective.text = dateProvider.formatCurrentDate(fetchedDetails
            .effectiveDate!
            .substring(0, 10)); // Extract YYYY-MM-DD
      } else {
        effective.text = "";
      }

      // Set expiration date
      if (fetchedDetails.expirationDate != null) {
        DateTime parsedExpirationDate =
            DateTime.parse(fetchedDetails.expirationDate!.substring(0, 10));

        // Validate that expiration date is after effective date
        if (effectiveDate != null &&
            parsedExpirationDate.isAfter(effectiveDate!)) {
          expirationDate = parsedExpirationDate;
          expiration.text = dateProvider.formatCurrentDate(fetchedDetails
              .expirationDate!
              .substring(0, 10)); // Extract YYYY-MM-DD
        } else {
          // Clear invalid expiration date
          expirationDate = null;
          expiration.text = "";
        }
      } else {
        expiration.text = "";
      }
      liablity.text = fetchedDetails.liabilityCoverage != null
          ? fetchedDetails.liabilityCoverage.toString()
          : "0";

      selectedTenants = fetchedDetails.tenants!;

      if (fetchedDetails.insurancePolicyDocument!.isNotEmpty)
        _uploadedFileNames.add(fetchedDetails.insurancePolicyDocument!);
    });
  }

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
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', pdfFile.path));

    var response = await apiSend(request);
    var responseData = await http.Response.fromStream(response);

    var responseBody = json.decode(responseData.body);
    print(responseBody);
    if (responseBody['status'] == 'ok') {
      Fluttertoast.showToast(msg: 'PDF added successfully');
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  DateTime? effectiveDate;
  DateTime? expirationDate;

  Future<void> _selectDate(BuildContext context) async {
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
        // Get dateProvider to format the date according to user's preference
        final dateProvider = Provider.of<DateProvider>(context, listen: false);
        // Display format: Use provider's format for user display
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        effective.text = dateProvider.formatCurrentDate(apiFormatDate);

        // Clear expiration date if it's now invalid (before or equal to effective date)
        if (expirationDate != null && !expirationDate!.isAfter(selectedDate)) {
          expirationDate = null;
          expiration.clear();
        }
      });
    }
  }

  Future<void> _selectDateexpiration(BuildContext context) async {
    // Calculate the minimum allowed date (effective date + 1 day)
    DateTime minDate = effectiveDate != null
        ? effectiveDate!.add(Duration(days: 1))
        : DateTime.now().add(Duration(days: 1));

    // Set initial date to the minimum allowed date if no expiration date is set or if current expiration date is invalid
    DateTime initialDate = (expirationDate != null &&
            expirationDate!.isAfter(effectiveDate ?? DateTime.now()))
        ? expirationDate!
        : minDate;

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
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
      // Validate that the selected date is after the effective date
      DateTime effectiveDateForValidation = effectiveDate ?? DateTime.now();
      if (selectedDate.isAfter(effectiveDateForValidation)) {
        setState(() {
          expirationDate = selectedDate;
          // Get dateProvider to format the date according to user's preference
          final dateProvider =
              Provider.of<DateProvider>(context, listen: false);
          // Display format: Use provider's format for user display
          String apiFormatDate = DateFormat('yyyy-MM-dd').format(selectedDate);
          expiration.text = dateProvider.formatCurrentDate(apiFormatDate);
        });
      } else {
        // Show error message if invalid date is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expiration date must be after the effective date'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  List<Map<String, String>> tenants = [];
  List<String> selectedTenants = [];

  // Helper function to convert display format back to API format (yyyy-MM-dd)
  String _convertToApiFormat(String displayDate) {
    if (displayDate.isEmpty) return "";
    try {
      DateTime? parsedDate;

      // Try to parse the date using common formats
      List<String> dateFormats = [
        'yyyy-MM-dd',
        'yyyy-MMM-dd',
        'MM/dd/yyyy',
        'MM-dd-yyyy',
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
      }
      return displayDate;
    } catch (e) {
      return displayDate;
    }
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print("token $token");
    print("Admin $id");
    final response = await apiGet(
      Uri.parse('$Api_url/api/leases/lease_tenant/${widget.leaseId}'),
      headers: {"id": "CRM $id", "authorization": "CRM $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final List<Map<String, String>> fetchedTenants = [];
      //print(firstName.text = data['tenant_firstName'] ?? "");
      for (var tenant in data['data']['tenants']) {
        fetchedTenants.add({
          'tenant_id': tenant['tenant_id'],
          'tenant_name':
              '${tenant['tenant_firstName']} ${tenant['tenant_lastName']}',
          'tenant_firstname': '${tenant['tenant_firstName']}',
          'tenant_lastName': '${tenant['tenant_lastName']}',
          'tenant_email': '${tenant['tenant_email']}',
          'tenant_phoneNumber': '${tenant['tenant_phoneNumber']}',
          'rental_adress': "${data['data']['rental_adress']}",
          'rental_city': "${data['data']['rental_city']}",
          'rental_state': "${data['data']['rental_state']}",
          'rental_country': "${data['data']['rental_country']}",
          'rental_zip': "${data['data']['rental_zip']}",
          'tenant_firstName': '${tenant['tenant_firstName']}',
          'tenant_lastName': '${tenant['tenant_lastName']}',
          'tenant_email': '${tenant['tenant_email']}',
          'tenant_phoneNumber':
              formatPhoneNumberedit('${tenant['tenant_phoneNumber']}'),
          'rental_adress': "${data['data']['rental_adress']}",
          'rental_city': "${data['data']['rental_city']}",
          'rental_state': "${data['data']['rental_state']}",
          'rental_country': "${data['data']['rental_country']}",
          'rental_zip': "${data['data']['rental_zip']}",
        });
      }
      final rentalAddress = {
        'rental_adress': data['data']['rental_adress'] ?? "",
      };
      setState(() {
        tenants = fetchedTenants;
      });
    } else {
      throw Exception('Failed to load tenants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawer(
          currentpage: "Rent Roll",
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
                    title: 'Update Policy',
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
                            Text('Insurance Company *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Insurance Company',
                              controller: company,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter insurance company';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Insurance Company Phone Number *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Phone Number',
                              controller: number,
                              phone: true,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                PhoneNumberFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter phone number';
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
                                  return 'please enter the effective date';
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
                                  return 'please enter the expiration date';
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
                              keyboardType: TextInputType.text,
                              hintText: '\$0.0',
                              controller: liablity,
                              showElevation: false,
                              borderColor: const Color(0xFFCED4DA),
                              borderWidth: 1.5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the liability coverage';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Covered Tenants: *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: tenants.map((tenant) {
                                return Row(
                                  children: [
                                    Checkbox(
                                      value: selectedTenants
                                          .contains(tenant['tenant_id']),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedTenants
                                                .add(tenant['tenant_id']!);
                                          } else {
                                            selectedTenants
                                                .remove(tenant['tenant_id']);
                                          }
                                        });
                                      },
                                    ),
                                    Text(tenant['tenant_name'] ?? ""),
                                  ],
                                );
                              }).toList(),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Upload Insurance Document',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickPdfFiles,
                              child: Container(
                                width: double.infinity,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCED4DA),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload,
                                      size: 36,
                                      color: const Color(0xFF6B7A99),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Click to upload document',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4A5568),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_uploadedFileNames.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Column(
                                children: _uploadedFileNames.map((fileName) {
                                  int index =
                                      _uploadedFileNames.indexOf(fileName);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: blueColor.withOpacity(0.05),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFFCED4DA)),
                                    ),
                                    child: Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.filePdf,
                                            size: 16,
                                            color: Colors.red.shade400),
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
                                              _uploadedFileNames
                                                  .removeAt(index);
                                            });
                                          },
                                          child: const FaIcon(
                                            FontAwesomeIcons.xmark,
                                            size: 14,
                                            color: Color(0xFF748097),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                                  addinsurance();
                                }
                              },
                              child: isLoading
                                  ? const Center(
                                      child: SpinKitFadingCircle(
                                        color: Colors.white,
                                        size: 28.0,
                                      ),
                                    )
                                  : const Text(
                                      'Update Insurance',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
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
                                side: BorderSide(
                                    color: const Color(0xFFCED4DA), width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Color(0xFF748097),
                                    fontWeight: FontWeight.w600),
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

  // addinsurance() async {
  //   print('entry');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? adminId = prefs.getString("adminId");
  //   String? token = prefs.getString('token');
  //   print('${adminId}  ${token}');
  //
  //   List<Map<String, String>> selectedTenantsList = selectedTenants.map((tenantId) {
  //     return {"tenant_id": tenantId};
  //   }).toList();
  //
  //   Map<String, dynamic> values = {
  //     "lease_id": widget.leaseId,
  //     "admin_id": adminId!,
  //     "insurance_company": company.text.trim(),
  //     "insurance_company_phone_number": number.text.trim(),
  //     "policy_id": policy.text.trim(),
  //     "effective_date": reverseFormatDate(effective.text.trim()),
  //     "expiration_date": reverseFormatDate(expiration.text.trim()),
  //     "liability_coverage": liablity.text.trim(),
  //     "tenants": selectedTenantsList,
  //     "insurance_policy_document": _uploadedFileNames.length > 0 ? _uploadedFileNames.first : "",
  //   };
  //   print(values);
  //   print('entry');
  //
  //   final http.Response response = await apiPost(
  //     Uri.parse(
  //         '$Api_url/api/renter-insurance/add-policy'),
  //     headers: <String, String>{
  //       'authorization': 'CRM $token',
  //       'id': 'CRM $adminId',
  //
  //       //'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: values,
  //   );
  //
  //   var responseData = json.decode(response.body);
  //   print('response body ${response.body}');
  //   if (responseData["statusCode"] == 200) {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     Navigator.pop(context, true);
  //     return responseData;
  //   } else {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to Insurance');
  //   }
  // }
  addinsurance() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      print('entry');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? token = prefs.getString('token');
      print('${adminId}  ${token}');

      // Convert selected tenants to a list of maps
      List<String> selectedTenantsList =
          selectedTenants.map((tenantId) => tenantId.toString()).toList();

      Map<String, dynamic> values = {
        "admin_id": adminId!,
        "lease_id": widget.leaseId,
        "insurance_company": company.text.trim(),
        "insurance_company_phone_number": number.text.trim(),
        "policy_id": policy.text.trim(),
        "effective_date": _convertToApiFormat(effective.text.trim()),
        "expiration_date": _convertToApiFormat(expiration.text.trim()),
        "liability_coverage": liablity.text.trim(),
        "tenants": selectedTenantsList, // Ensure it's properly formatted
        "insurance_policy_document":
            _uploadedFileNames.isNotEmpty ? _uploadedFileNames.first : "",
        "renters_insurance_id": widget.renters_insurance_id,
      };

      print(jsonEncode(values)); // Debugging: Check final JSON format

      final http.Response response = await apiPut(
        Uri.parse(
            '$Api_url/api/renter-insurance/edit-policy/${widget.renters_insurance_id}'),
        headers: <String, String>{
          'authorization': 'CRM $token',
          'id': 'CRM $adminId',
          'Content-Type': 'application/json', // Ensure JSON format is specified
        },
        body: jsonEncode(values), // Encode JSON properly
      );

      var responseData = json.decode(response.body);
      print('response body ${response.body}');
      print('$Api_url/api/renter-insurance/add-policy');
      if (responseData["statusCode"] == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        Navigator.pop(context, true);
        return responseData;
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to Insurance');
      }
    } catch (error) {
      print('Error: $error');
      Fluttertoast.showToast(msg: 'Something went wrong');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }
}
