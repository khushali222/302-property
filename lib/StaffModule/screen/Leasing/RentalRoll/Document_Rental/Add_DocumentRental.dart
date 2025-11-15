import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/lease.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/applicants.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';

class AddDocument extends StatefulWidget {
  String leaseId;
  AddDocument({super.key, required this.leaseId});

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController firstName = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String renderId = '';
  String unitId = '';
  final List<String> items = [
    "Insurance policy Docs",
    "Lease agreements",
    "Lease renewal offers",
    "Lease renewal letters"
  ];
  String? selectedValue;
  bool isLoading = false;
  List<File> _pdfFiles = [];

  List<String> _uploadedFileNames = [];
  String? _fileUploadError;

  File? _image;
  List<File> _images = [];
  String? _uploadedFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              SizedBox(
                height: 25,
              ),
              titleBar(
                width: MediaQuery.of(context).size.width * .91,
                title: 'Add Document',
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: blueColor,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Text('Name *',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          hintText: 'Enter first name',
                          controller: firstName,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text('Document Type *',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(
                          height: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormField<String>(
                              validator: (value) {
                                if (selectedValue == null) {
                                  return 'Please select an option';
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: const Row(
                                          children: [
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Type',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        items: items
                                            .map((String item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                            .toList(),
                                        value: selectedValue,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedValue = value;
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 50,
                                          width: 230,
                                          padding: const EdgeInsets.only(
                                              left: 14, right: 14),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.black26,
                                            ),
                                            color: Colors.white,
                                          ),
                                          elevation: 3,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            //color: Colors.redAccent,
                                          ),
                                          offset: const Offset(-20, 0),
                                          scrollbarTheme: ScrollbarThemeData(
                                            radius: const Radius.circular(40),
                                            thickness:
                                                MaterialStateProperty.all(6),
                                            thumbVisibility:
                                                MaterialStateProperty.all(true),
                                          ),
                                        ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
                                          padding: EdgeInsets.only(
                                              left: 14, right: 14),
                                        ),
                                      ),
                                    ),
                                    if (state.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 14, top: 8),
                                        child: Text(
                                          state.errorText!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text('Upload file *',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 40,
                          width: 120,
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
                            onPressed: () async {
                              _pickPdfFiles().then((_) {
                                setState(() {
                                  _fileUploadError =
                                      null; // Clear error when file is selected
                                }); // Rebuild the widget after selecting the image
                              });
                            },
                            child: Text(
                              'Upload here',
                              style: TextStyle(
                                  color: Color(0xFFf7f8f9),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_fileUploadError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 14, top: 8),
                            child: Text(
                              _fileUploadError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        SingleChildScrollView(
                          child: Column(
                            children: _uploadedFileNames.map((fileName) {
                              int index = _uploadedFileNames.indexOf(fileName);
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
                                      _fileUploadError =
                                          null; // Clear error when file is removed
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
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    Container(
                        height: 45,
                        width: 170,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () async {
                              // Clear previous file upload error
                              setState(() {
                                _fileUploadError = null;
                              });

                              // Validate file upload
                              bool hasFileError = false;
                              if (_uploadedFileNames.isEmpty) {
                                setState(() {
                                  _fileUploadError =
                                      'Please upload at least one file';
                                });
                                hasFileError = true;
                              }

                              // Validate form fields
                              bool isFormValid =
                                  _formkey.currentState?.validate() ?? false;

                              // Only proceed if both validations pass
                              if (isFormValid && !hasFileError) {
                                print('valid');
                                addDocument();
                                //_submitApplicantAndLease();
                                //charges
                              } else {
                                print('invalid');
                              }
                            },
                            child: const Text(
                              'Create Document',
                              style: TextStyle(
                                  color: Color(
                                    0xFFf7f8f9,
                                  ),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ))),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                        height: 45,
                        width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFffffff),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () {
                              Navigator.pop(context);
                              firstName.clear();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold),
                            )))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    //  print(pdfFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', pdfFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData);
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

  addDocument() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      print('entry');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? id = prefs.getString("staff_id");
      String? token = prefs.getString('token');
      print('${adminId}  ${token}');

      // Convert selected tenants to a list of maps

      Map<String, dynamic> values = {
        "lease_id": widget.leaseId,
        "document_id": DateTime.now().millisecondsSinceEpoch,
        "file_name": firstName.text.trim(),
        "file_type": selectedValue,
        "document_name":
            _uploadedFileNames.isNotEmpty ? _uploadedFileNames.first : "",
        "document_type": "application/pdf",
        "created_date": DateFormat("yyyy-MM-dd h:mm:ss").format(DateTime.now()),
        "created_by": id, // Ensure it's properly formatted
      };

      print(jsonEncode(values)); // Debugging: Check final JSON format

      final http.Response response = await http.post(
        Uri.parse('$Api_url/api/lease-document/add-document'),
        headers: <String, String>{
          'authorization': 'CRM $token',
          'id': 'CRM $id',
          'Content-Type': 'application/json', // Ensure JSON format is specified
        },
        body: jsonEncode(values), // Encode JSON properly
      );

      var responseData = json.decode(response.body);
      print('response body ${response.body}');
      print('$Api_url/api/renter-insurance/add-policy');
      // if (response.statusCode == 200) {
      //   Fluttertoast.showToast(msg: responseData["Document added successfully"]);
      //   //Navigator.pop(context, true);
      //   return responseData;
      // } else {
      //   Fluttertoast.showToast(msg: responseData["message"]);
      //   throw Exception('Failed to Insurance');
      // }
      if (response.statusCode == 200) {
        // Use "message" instead of "Document added successfully"
        Fluttertoast.showToast(msg: "Document added successfully");
        Navigator.pop(context, true); // optional: close page after success
        return responseData;
      } else {
        Fluttertoast.showToast(msg: "Failed to add document");
        throw Exception('Failed to add document');
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
