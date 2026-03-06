import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart' as widget_302;
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart'
    as staff_drawer;
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart'
    as widget_302_staff;
import '../../widgets/custom_drawer.dart';
import '../../repository/fetch_allcategories.dart';
import '../../Model/All_categories_model.dart';

class CreateBidRoom extends StatefulWidget {
  /// When true, uses staff drawer and staff app bar (for Staff module).
  final bool useStaffLayout;

  const CreateBidRoom({super.key, this.useStaffLayout = false});

  @override
  State<CreateBidRoom> createState() => _CreateBidRoomState();
}

class _CreateBidRoomState extends State<CreateBidRoom> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  // Dropdown values
  Map<String, String> properties = {};
  Map<String, String> units = {};
  Map<String, String> vendors = {};
  List<allcategories_model> tradeTypes = [];

  // Selected values
  String? _selectedPropertyId;
  String? _selectedUnitId;
  String? _selectedTradeType;
  String? _selectedStatus = 'Open';
  List<String> _selectedVendorIds = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingProperties = false;
  bool _isLoadingCategories = false;

  // File upload
  List<File> _selectedImages = [];
  List<String> _uploadedImageNames = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadVendors();
    _loadCategories();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${Api_url}/api/rentals/rentals/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> addresses = {};
        jsonResponse.forEach((data) {
          addresses[data['rental_id'].toString()] =
              data['rental_adress'].toString();
        });

        // Sort properties alphabetically
        final sortedEntries = addresses.entries.toList()
          ..sort(
              (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
        final sortedAddresses = Map<String, String>.fromEntries(sortedEntries);

        setState(() {
          properties = sortedAddresses;
          _isLoadingProperties = false;
        });
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      setState(() {
        _isLoadingProperties = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load properties: $e');
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      units = {};
      _selectedUnitId = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${Api_url}/api/unit/rental_unit/$rentalId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitMap = {};
        jsonResponse.forEach((data) {
          String unitId = data['unit_id']?.toString() ?? '';
          String unitName = data['rental_unit']?.toString() ?? '';
          if (unitId.isNotEmpty && unitName.trim().isNotEmpty) {
            unitMap[unitId] = unitName.trim();
          }
        });

        setState(() {
          units = unitMap;
        });
      } else {
        throw Exception('Failed to load units');
      }
    } catch (e) {
      // Handle error silently - property might not have units
      setState(() {
        units = {};
      });
    }
  }

  Future<void> _loadVendors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${Api_url}/api/vendor/vendors/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> names = {};
        jsonResponse.forEach((data) {
          names[data['vendor_id'].toString()] = data['vendor_name'].toString();
        });

        // Sort vendors alphabetically
        final sortedEntries = names.entries.toList()
          ..sort(
              (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
        final sortedNames = Map<String, String>.fromEntries(sortedEntries);

        setState(() {
          vendors = sortedNames;
        });
      } else {
        throw Exception('Failed to load vendors');
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories = await FetchAllcategories().fetchAllCategories();

      // Sort categories alphabetically by name
      categories.sort((a, b) {
        final nameA = (a.name ?? '').toLowerCase();
        final nameB = (b.name ?? '').toLowerCase();
        return nameA.compareTo(nameB);
      });

      setState(() {
        tradeTypes = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load categories: $e');
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        List<File> newImages = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        // Check if adding these images would exceed the limit
        if (_selectedImages.length + newImages.length > 10) {
          Fluttertoast.showToast(
            msg: 'Maximum of 10 images allowed',
            toastLength: Toast.LENGTH_SHORT,
          );
          // Only add up to the limit
          newImages = newImages.take(10 - _selectedImages.length).toList();
        }

        setState(() {
          _selectedImages.addAll(newImages);
        });

        // Upload images immediately
        await _uploadImages(newImages);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to pick images: $e');
    }
  }

  Future<void> _uploadImages(List<File> images) async {
    setState(() {
      _isUploading = true;
    });

    try {
      for (File image in images) {
        String? fileName = await _uploadImage(image);
        if (fileName != null) {
          _uploadedImageNames.add(fileName);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to upload some images: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(
      await http.MultipartFile.fromPath('files', imageFile.path),
    );

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    var responseBody = json.decode(responseData.body);

    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (index < _uploadedImageNames.length) {
        _uploadedImageNames.removeAt(index);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPropertyId == null) {
      Fluttertoast.showToast(msg: 'Please select a property');
      return;
    }

    if (_selectedTradeType == null) {
      Fluttertoast.showToast(msg: 'Please select a trade type');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      // Upload any remaining images
      if (_selectedImages.length > _uploadedImageNames.length) {
        List<File> remainingImages =
            _selectedImages.sublist(_uploadedImageNames.length);
        await _uploadImages(remainingImages);
      }

      final response = await http.post(
        Uri.parse('${Api_url}/api/bid-request/bid-request'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "bidRequest": {
            "admin_id": id,
            "rental_id": _selectedPropertyId,
            "unit_id": _selectedUnitId ?? "",
            "work_category": _selectedTradeType,
            "description": _descriptionController.text,
            "bid_request_images": _uploadedImageNames,
            "due_date":
                _dueDateController.text.isEmpty ? "" : _dueDateController.text,
            "status": _selectedStatus,
            "selected_vendor_ids": _selectedVendorIds,
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: 'Bid Room created successfully',
          toastLength: Toast.LENGTH_SHORT,
        );
        Navigator.pop(context, true);
      } else {
        final errorBody = json.decode(response.body);
        Fluttertoast.showToast(
          msg: errorBody['message'] ?? 'Failed to create bid room',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error creating bid room: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.useStaffLayout
          ? widget_302_staff.widget_302_Staff.App_Bar(context: context)
          : widget_302.widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: widget.useStaffLayout
          ? staff_drawer.CustomDrawerStaff(
              currentpage: "Bid Room",
              dropdown: false,
            )
          : CustomDrawer(
              currentpage: "Bid Room",
              dropdown: false,
            ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 500 ? 20.0 : 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 500 ? 0 : 0,
                  ),
                  child: titleBar(
                    width: double.infinity,
                    title: 'Create Bid Room',
                  ),
                ),
                const SizedBox(height: 24),
                // Property Dropdown
                _buildDropdownField(
                  label: 'Property',
                  isRequired: true,
                  value: _selectedPropertyId,
                  items: properties.keys.map((id) {
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(properties[id] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPropertyId = value;
                      _selectedUnitId = null;
                      if (value != null) {
                        _loadUnits(value);
                      }
                    });
                  },
                  hint: 'Select Property',
                  isLoading: _isLoadingProperties,
                ),
                // Unit Dropdown (Optional) - Only show if property has units
                if (_selectedPropertyId != null && units.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Unit',
                    isRequired: false,
                    value: _selectedUnitId,
                    items: units.keys.map((id) {
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(units[id] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnitId = value;
                      });
                    },
                    hint: 'Select Unit',
                  ),
                ],
                const SizedBox(height: 16),

                // Trade Type Dropdown
                _buildDropdownField(
                  label: 'Trade type',
                  isRequired: true,
                  value: _selectedTradeType,
                  items: tradeTypes.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.name,
                      child: Text(category.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTradeType = value;
                    });
                  },
                  hint: 'Select Trade Type',
                  isLoading: _isLoadingCategories,
                ),
                const SizedBox(height: 16),

                // Select Vendors (Optional)
                _buildVendorSelectionField(),
                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  label: 'Description',
                  isRequired: true,
                  controller: _descriptionController,
                  hint: 'Enter job description...',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Due Date
                _buildDateField(),
                const SizedBox(height: 16),

                // Status Dropdown
                _buildDropdownField(
                  label: 'Status',
                  isRequired: true,
                  value: _selectedStatus,
                  items: ['Open', 'Closed'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  hint: 'Select Status',
                ),
                const SizedBox(height: 16),

                // Upload Pictures
                _buildImageUploadField(),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: blueColor,
                          side: BorderSide(color: blueColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          foregroundColor: Colors.white,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Bid Room',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required bool isRequired,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required String hint,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          //   color: Colors.red,
          child: isLoading
              ? Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                    border: Border.all(
                      color: const Color(0xFFDBE0E5),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : DropdownButtonFormField2<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            hint: Text(
              hint,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              border: InputBorder.none,
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select $label';
                    }
                    return null;
                  }
                : null,
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.only(left: 16, right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFDBE0E5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              elevation: 0,
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              maxHeight: 300,
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(6),
                thickness: MaterialStateProperty.all(6),
                thumbVisibility: MaterialStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildTextField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: maxLines > 1 ? null : 50,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDBE0E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDBE0E5)),
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
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: blueColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: _dueDateController,
            readOnly: true,
            onTap: _selectDueDate,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Select Due Date (YYYY-MM-DD)',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDBE0E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDBE0E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: blueColor, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
                ),
                onPressed: _selectDueDate,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Vendors',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            Text(
              ' (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            String displayText = _selectedVendorIds.isEmpty
                ? 'Select Vendors (Optional)'
                : _selectedVendorIds.length == 1
                    ? vendors[_selectedVendorIds.first] ?? '1 vendor selected'
                    : '${_selectedVendorIds.length} vendors selected';

            return Container(
              child: DropdownButtonFormField2<String>(
                value: null, // Always null for multi-select
                isExpanded: true,
                hint: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedVendorIds.isEmpty
                        ? Colors.grey[600]
                        : Colors.black87,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  border: InputBorder.none,
                ),
                items: vendors.entries.map((entry) {
                  String vendorId = entry.key;
                  String vendorName = entry.value;
                  bool isSelected = _selectedVendorIds.contains(vendorId);

                  return DropdownMenuItem<String>(
                    value: vendorId,
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (!_selectedVendorIds.contains(vendorId)) {
                                  _selectedVendorIds.add(vendorId);
                                }
                              } else {
                                _selectedVendorIds.remove(vendorId);
                              }
                            });
                          },
                          activeColor: blueColor,
                        ),
                        Expanded(
                          child: Text(
                            vendorName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  // Handle selection is done in checkbox onChanged
                },
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFDBE0E5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  elevation: 0,
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                  ),
                  iconSize: 24,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  maxHeight: 300,
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(6),
                    thickness: MaterialStateProperty.all(6),
                    thumbVisibility: MaterialStateProperty.all(true),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            );
          },
        ),
        if (_selectedVendorIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedVendorIds.map((vendorId) {
              return Chip(
                label: Text(vendors[vendorId] ?? ''),
                onDeleted: () {
                  setState(() {
                    _selectedVendorIds.remove(vendorId);
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImageUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Pictures',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: blueColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectedImages.length < 10 ? _pickImages : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload Pictures',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(Maximum of 10)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supported File Types: image/*',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              File image = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeImage(index),
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
