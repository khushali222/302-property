import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:three_zero_two_property/widgets/custom_textfield.dart';
import '../../../../widgets/custom_drawer.dart';

class EditDocument extends StatefulWidget {
  String leaseId;
  Map<String, dynamic> documentData;
  EditDocument({super.key, required this.leaseId, required this.documentData});

  @override
  State<EditDocument> createState() => _EditDocumentState();
}

class _EditDocumentState extends State<EditDocument> {
  @override
  void initState() {
    super.initState();
    _initializeFields();
    fetchTenants();
  }

  void _initializeFields() {
    // Pre-populate fields with existing document data
    firstName.text = widget.documentData['file_name'] ??
        widget.documentData['document_name'] ??
        '';

    // Normalize document type to match items list (case-insensitive)
    String? docType = widget.documentData['file_type'] ??
        widget.documentData['document_type'];
    if (docType != null) {
      // Find matching item in the items list (case-insensitive)
      try {
        selectedValue = items.firstWhere(
          (item) => item.toLowerCase() == docType.toString().toLowerCase(),
          orElse: () => docType.toString(), // If not found, use original value
        );
        // If the value doesn't match any item exactly, set to null to avoid dropdown error
        if (!items.contains(selectedValue)) {
          selectedValue = null;
        }
      } catch (e) {
        // If no match found, set to null
        selectedValue = null;
      }
    }

    selectedTenantId = widget.documentData['tenant_id']?.toString();
    documentId = widget.documentData['document_id']?.toString() ?? '';

    // If there's an existing file, mark it as existing
    if (widget.documentData['document_name'] != null) {
      _hasExistingFile = true;
    }
  }

  final TextEditingController firstName = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String renderId = '';
  String unitId = '';
  String documentId = '';
  bool _hasExistingFile = false;

  final List<String> items = [
    "Insurance policy Docs",
    "Lease agreements",
    "Lease renewal offers",
    "Lease renewal letters",
    "Other"
  ];
  String? selectedValue;
  bool isLoading = false;
  String? _fileUploadError;
  File? _selectedFile; // Store the selected file for upload

  // Tenant dropdown variables
  List<Map<String, dynamic>> tenants = [];
  String? selectedTenantId;
  bool isLoadingTenants = false;

  // Get unique tenants by tenant_id
  List<Map<String, dynamic>> get uniqueTenants {
    final Map<String, Map<String, dynamic>> uniqueMap = {};
    for (var tenant in tenants) {
      final tenantId = tenant['tenant_id']?.toString();
      if (tenantId != null && !uniqueMap.containsKey(tenantId)) {
        uniqueMap[tenantId] = tenant;
      }
    }
    return uniqueMap.values.toList();
  }

  // Get unique tenant IDs
  Set<String> get uniqueTenantIds {
    return uniqueTenants
        .map((t) => t['tenant_id']?.toString())
        .where((id) => id != null)
        .cast<String>()
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
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
                title: 'Edit Document',
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
                          showElevation: false,
                          borderColor: Color( 0xFFCED4DA),
                          keyboardType: TextInputType.text,
                          hintText: 'Enter document name',
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
                                                'Select Document Type',
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
                                        items: items.map((String item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        value: selectedValue,
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedValue = value;
                                            state.didChange(value);
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
                                              color:Color( 0xFFCED4DA),
                                            ),
                                            color: Colors.white,
                                          ),
                                         // elevation: 3,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
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
                        Text('Associate with Tenant (Optional)',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(
                          height: 5,
                        ),
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
                                    'Select Tenant (optional)',
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
                            items: [
                              // Add "No tenant association" option
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'No tenant association',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Add unique tenant options
                              ...uniqueTenants.map((tenant) {
                                String displayName =
                                    '${tenant['tenant_firstName'] ?? ''} ${tenant['tenant_lastName'] ?? ''}'
                                        .trim();
                                final tenantId =
                                    tenant['tenant_id']?.toString();
                                return DropdownMenuItem<String>(
                                  value: tenantId,
                                  child: Text(
                                    displayName.isEmpty
                                        ? 'Unknown Tenant'
                                        : displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ],
                            value: (selectedTenantId != null &&
                                    uniqueTenantIds.contains(selectedTenantId))
                                ? selectedTenantId
                                : null,
                            onChanged: (value) {
                              setState(() {
                                selectedTenantId = value;
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 50,
                              width: 230,
                              padding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color( 0xFFCED4DA),
                                ),
                                color: Colors.white,
                              ),
                             // elevation: 3,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              offset: const Offset(-20, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: MaterialStateProperty.all(6),
                                thumbVisibility:
                                    MaterialStateProperty.all(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.only(left: 14, right: 14),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                            'Upload file (Optional - leave empty to keep existing)',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(
                          height: 5,
                        ),
                        if (_selectedFile == null)
                          GestureDetector(
                            onTap: () {
                              _pickFile().then((_) {
                                setState(() {
                                  _fileUploadError = null;
                                  _hasExistingFile = false;
                                });
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
                                  Image.asset(
                                    'assets/icons/Upload.png',
                                    height: 50,
                                    width: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Click to upload new document',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Supported File Types: PDF, JPG, PNG, GIF, BMP, TIFF, WEBP',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
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
                        if (_hasExistingFile && _selectedFile == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                //color: Color(0xFFE3F2FD), // Light blue background
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300, // Blue border
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    color: blueColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Current file:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          widget.documentData[
                                                  'document_name'] ??
                                              'N/A',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_selectedFile != null) ...[
                          SizedBox(height: 8),
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
                                SizedBox(height: 15),
                                Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedFile!.path.split('/').last,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedFile = null;
                                            _fileUploadError = null;
                                          });
                                        },
                                        child: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                            onPressed: isLoading
                                ? null
                                : () async {
                                    // Validate form fields
                                    bool isFormValid =
                                        _formkey.currentState?.validate() ??
                                            false;

                                    // Only proceed if validation passes
                                    if (isFormValid) {
                                      print('valid');
                                      updateDocument();
                                    } else {
                                      print('invalid');
                                    }
                                  },
                            child: isLoading
                                ? SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : const Text(
                                    'Update',
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
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'tiff',
          'webp'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      Fluttertoast.showToast(
        msg: 'Error selecting file: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  bool _isValidFileType(String fileName) {
    final supportedExtensions = [
      '.pdf',
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.tiff',
      '.webp'
    ];
    final extension =
        fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return supportedExtensions.contains(extension);
  }

  Future<void> fetchTenants() async {
    setState(() {
      isLoadingTenants = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$Api_url/api/leases/tenants/${widget.leaseId}'),
        headers: <String, String>{
          'authorization': 'CRM $token',
          'id': 'CRM $adminId',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true &&
            responseData['tenants'] != null) {
          setState(() {
            tenants = List<Map<String, dynamic>>.from(responseData['tenants']);
          });
        }
      } else {
        print('Failed to fetch tenants: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching tenants: $error');
    } finally {
      setState(() {
        isLoadingTenants = false;
      });
    }
  }

  updateDocument() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      print('Updating document');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? token = prefs.getString('token');
      print('${adminId}  ${token}');

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        "document_id": documentId,
        "file_name": firstName.text.trim(),
        "file_type": selectedValue,
      };

      // Add tenant_id if a tenant is selected
      if (selectedTenantId != null && selectedTenantId!.isNotEmpty) {
        requestBody["tenant_id"] = selectedTenantId;
      }

      print('Request body: ${jsonEncode(requestBody)}');

      // Create multipart request for file upload
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$Api_url/api/lease-document/update-document'),
      );

      // Add headers
      request.headers['authorization'] = 'CRM $token';
      request.headers['id'] = 'CRM $adminId';

      // Add text fields
      request.fields['document_id'] = documentId;
      request.fields['file_name'] = firstName.text.trim();
      request.fields['file_type'] = selectedValue ?? '';
      if (selectedTenantId != null && selectedTenantId!.isNotEmpty) {
        request.fields['tenant_id'] = selectedTenantId!;
      }

      // Add file if a new file was uploaded
      if (_selectedFile != null) {
        // Validate file type
        if (!_isValidFileType(_selectedFile!.path)) {
          setState(() {
            _fileUploadError =
                'Unsupported file type. Please select PDF, JPG, PNG, GIF, BMP, TIFF, or WEBP files.';
            isLoading = false;
          });
          return;
        }

        // Get mime type from file extension
        final mimeType = _getMimeType(_selectedFile!.path);
        final originalFilename = _selectedFile!.path.split('/').last;

        // Add file with explicit content-type
        request.files.add(
          await http.MultipartFile.fromPath(
            'document',
            _selectedFile!.path,
            filename: originalFilename,
            contentType: MediaType.parse(mimeType),
          ),
        );

        // Add mime_type field
        request.fields['mime_type'] = mimeType;
        request.fields['document_type'] = mimeType;
        request.fields['original_filename'] = originalFilename;
      }

      print(
          'Sending PUT request to: $Api_url/api/lease-document/update-document');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Document updated successfully");
        setState(() {
          isLoading = false; // Stop loading before popping
        });
        Navigator.pop(context, true); // Return true to trigger table refresh
        return responseData;
      } else {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? "Failed to update document");
        setState(() {
          isLoading = false;
        });
        return null; // Return null on failure
      }
    } catch (e) {
      print('Error updating document: $e');
      Fluttertoast.showToast(msg: "Error updating document: ${e.toString()}");
      setState(() {
        isLoading = false;
      });
    }
  }
}
