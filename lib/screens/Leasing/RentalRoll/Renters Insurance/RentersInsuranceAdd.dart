import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../../model/LeaseSummary.dart';
import '../../../../repository/lease.dart';
import '../../../../widgets/custom_drawer.dart';

class LeaseAddRentersInsurance extends StatefulWidget {
  final String tenantid;
  final String leaseId;
  const LeaseAddRentersInsurance(
      {required this.tenantid, required this.leaseId});

  @override
  State<LeaseAddRentersInsurance> createState() =>
      _LeaseAddRentersInsuranceState();
}

class _LeaseAddRentersInsuranceState extends State<LeaseAddRentersInsurance> {
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

    var response = await request.send();
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
        effective.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Future<void> _selectDateexpiration(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: expirationDate ?? DateTime.now(),
      firstDate: effectiveDate!,
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
        expiration.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  List<Map<String, String>> tenants = [];
  List<String> selectedTenants = [];
  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print("token $token");
    print("Admin $id");
    final response = await http.get(
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
                    title: 'New Insurance',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      // height: !form_valid ? 860 : 830,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
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
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Insurance Company',
                              controller: company,
                              //   label: "",
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
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Phone Number',
                              controller: number,
                              //   label: "",
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
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Policy Id',
                              controller: policy,
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
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              onTap: () {
                                _selectDate(context);
                              },
                              keyboardType: TextInputType.text,
                              hintText: 'dd-mm-yyyy',
                              controller: effective,
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
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              onTap: () {
                                _selectDateexpiration(context);
                              },
                              keyboardType: TextInputType.text,
                              hintText: 'dd-mm-yyyy',
                              controller: expiration,
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
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: '\$0.0',
                              controller: liablity,
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
                            Text('Covered Tenants: *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
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
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 40,
                              width: 125,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: blueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: _pickPdfFiles,
                                child: Text('Choose Files'),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: _uploadedFileNames.map((fileName) {
                                  int index =
                                      _uploadedFileNames.indexOf(fileName);
                                  return ListTile(
                                    title: Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF748097),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _uploadedFileNames.removeAt(index);
                                        });
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.remove,
                                        color: Color(0xFF748097),
                                      ),
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
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              //print("calling 111");
                              if (_formkey.currentState!.validate()) {
                                //  print("calling 22");
                                print('hhhhhh');
                                addinsurance();
                                print('end');
                              }
                            },
                            child: isLoading
                                ? Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 55.0,
                                    ),
                                  )
                                : Text(
                                    'Add Insurance',
                                    style: TextStyle(color: Color(0xFFf7f8f9)),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                            height: 50,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFffffff),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF748097)),
                                )))
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
  //   final http.Response response = await http.post(
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
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print('${adminId}  ${token}');

    // Convert selected tenants to a list of maps
    List<String> selectedTenantsList =
        selectedTenants.map((tenantId) => tenantId.toString()).toList();

    Map<String, dynamic> values = {
      "lease_id": widget.leaseId,
      "insurance_company": company.text.trim(),
      "insurance_company_phone_number": number.text.trim(),
      "policy_id": policy.text.trim(),
      "effective_date": reverseFormatDate(effective.text.trim()),
      "expiration_date": reverseFormatDate(expiration.text.trim()),
      "liability_coverage": liablity.text.trim(),
      "tenants": selectedTenantsList, // Ensure it's properly formatted
      "insurance_policy_document":
          _uploadedFileNames.isNotEmpty ? _uploadedFileNames.first : "",
    };

    print(jsonEncode(values)); // Debugging: Check final JSON format

    final http.Response response = await http.post(
      Uri.parse('$Api_url/api/renter-insurance/add-policy'),
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
    if (responseData["savedPolicy"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      Navigator.pop(context, true);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to Insurance');
    }
  }
}
