import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:three_zero_two_property/widgets/custom_textfield.dart';
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart';

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
    "Insurance Policy Docs",
    "Lease Agreements",
    "Lease Renewal Offers",
    "Lease Renewal Letters",
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
              const SizedBox(height: 25),
              titleBar(
                width: MediaQuery.of(context).size.width * .91,
                title: 'Edit Document',
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFCED4DA), width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Name *',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(height: 8),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                          showElevation: false,
                          borderColor: const Color(0xFFCED4DA),
                          keyboardType: TextInputType.text,
                          hintText: 'Enter document name',
                          controller: firstName,
                        ),
                        const SizedBox(height: 16),
                        Text('Document Type *',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(height: 8),
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
                                    hint: const Text(
                                      'Select Document Type',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFADB5BD),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    items: items.map((String item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
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
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFCED4DA),
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 14, top: 6),
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
                        const SizedBox(height: 16),
                        Text('Associate with Tenant (Optional)',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const Text(
                              'Select Tenant (optional)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFADB5BD),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'No tenant association',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ...uniqueTenants.map((tenant) {
                                String displayName =
                                    '${tenant['tenant_firstName'] ?? ''} ${tenant['tenant_lastName'] ?? ''}'
                                        .trim();
                                final tenantId = tenant['tenant_id']?.toString();
                                return DropdownMenuItem<String>(
                                  value: tenantId,
                                  child: Text(
                                    displayName.isEmpty
                                        ? 'Unknown Tenant'
                                        : displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
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
                              padding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFCED4DA),
                                ),
                                color: Colors.white,
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
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
                        const SizedBox(height: 16),
                        Text('Upload File (Optional - leave empty to keep existing)',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: blueColor)),
                        const SizedBox(height: 8),
                        if (_selectedFile == null && !_hasExistingFile)
                          GestureDetector(
                            onTap: () => _showUploadOptions(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 28, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFFCED4DA), width: 1.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icons/Upload.png',
                                    height: 50,
                                    width: 50,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Click to upload new document',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Supported formats: PDF, DOC, DOCX, TXT, JPG, PNG',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9AA0A6)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_fileUploadError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 6),
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
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFCED4DA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8EEF7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: blueColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.documentData['document_name'] ??
                                              'N/A',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Current file',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hasExistingFile = false;
                                      });
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[200],
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_selectedFile != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: const Color(0xFFCED4DA)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.insert_drive_file,
                                    color: blueColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedFile!.path.split('/').last,
                                    style: const TextStyle(
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
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: blueColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  bool isFormValid =
                                      _formkey.currentState?.validate() ??
                                          false;
                                  if (isFormValid) {
                                    updateDocument();
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Update Document',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
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
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        Widget sourceTile({
          required IconData icon,
          required String title,
          required String subtitle,
          required VoidCallback onPick,
        }) {
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pop(sheetContext);
              onPick();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDBE0E5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: blueColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(21, 43, 81, 1))),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBE0E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Upload Document',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(21, 43, 81, 1))),
                const SizedBox(height: 4),
                Text('Choose where to pick your document from',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
                const SizedBox(height: 18),
                sourceTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Photo Gallery',
                  subtitle: '.jpg, .png',
                  onPick: () => _pickFiles(FileType.image, null),
                ),
                const SizedBox(height: 12),
                sourceTile(
                  icon: Icons.insert_drive_file_rounded,
                  title: 'Browse Files',
                  subtitle: '.pdf, .doc, .docx, .txt',
                  onPick: () => _pickFiles(
                      FileType.custom, ['pdf', 'doc', 'docx', 'txt']),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFiles(FileType type, List<String>? allowedExtensions) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        // Auto-fill the Name from the newly selected file (web parity): strip
        // the extension. On Edit, always sync to the new file's name.
        final pickedName = result.files.single.name;
        final dotIndex = pickedName.lastIndexOf('.');
        final nameWithoutExt =
            dotIndex > 0 ? pickedName.substring(0, dotIndex) : pickedName;
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileUploadError = null;
          firstName.text = nameWithoutExt;
        });
      }
    } catch (e) {
      logError('Error picking file: $e');
      Fluttertoast.showToast(
        msg: 'Error selecting file: ${friendlyErrorMessage(e)}',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  bool _isValidFileType(String fileName) {
    final supportedExtensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.jpg',
      '.jpeg',
      '.png',
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
      String? staffId = prefs.getString("staff_id");
      String? id = (staffId != null && staffId.isNotEmpty) ? staffId : adminId;
      String? token = prefs.getString('token');

      final response = await apiGet(
        Uri.parse('$Api_url/api/leases/tenants/${widget.leaseId}'),
        headers: <String, String>{
          'authorization': 'CRM $token',
          'id': 'CRM $id',
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
      }
    } catch (error) {
      logError('Error fetching tenants: $error');
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? staffId = prefs.getString("staff_id");
      String? id = (staffId != null && staffId.isNotEmpty) ? staffId : adminId;
      String? token = prefs.getString('token');

      // Create multipart request for file upload
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$Api_url/api/lease-document/update-document'),
      );

      // Add headers
      request.headers['authorization'] = 'CRM $token';
      request.headers['id'] = 'CRM $id';

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
                'Unsupported file type. Please select PDF, DOC, DOCX, TXT, JPG, or PNG files.';
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

      var streamedResponse = await apiSend(request);
      var response = await http.Response.fromStream(streamedResponse);


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
      logError('Error updating document: $e');
      Fluttertoast.showToast(msg: "Error updating document: ${friendlyErrorMessage(e)}");
      setState(() {
        isLoading = false;
      });
    }
  }
}
