import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:three_zero_two_property/Model/bid_request.dart';

class CreateBidRoom extends StatefulWidget {
  /// When true, uses staff drawer and staff app bar (for Staff module).
  final bool useStaffLayout;

  /// When provided, screen opens in edit mode and pre-fills form; submit calls PUT to update.
  final BidRequest? existingBidRequest;

  const CreateBidRoom({
    super.key,
    this.useStaffLayout = false,
    this.existingBidRequest,
  });

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

  /// In edit mode, number of images that came from API (so we don't show same image twice when adding new).
  int _initialExistingImageCount = 0;

  /// Snapshot of payload when form was loaded in edit mode; used to skip API if unchanged.
  Map<String, dynamic>? _initialPayload;

  bool get _isEditMode => widget.existingBidRequest != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final b = widget.existingBidRequest!;
      _descriptionController.text = b.description ?? '';
      _dueDateController.text = b.dueDate ?? '';
      _selectedStatus = b.status ?? 'Open';
      _selectedTradeType = b.workCategory;
      _selectedVendorIds = List<String>.from(b.selectedVendorIds ?? []);
      _uploadedImageNames = List<String>.from(b.bidRequestImages ?? []);
      _initialExistingImageCount = _uploadedImageNames.length;
    }
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
        if (_isEditMode && widget.existingBidRequest?.rentalId != null) {
          final rentalId = widget.existingBidRequest!.rentalId!;
          setState(() => _selectedPropertyId = rentalId);
          await _loadUnits(rentalId);
          if (_isEditMode) _setInitialPayloadForEdit();
        }
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

  void _setInitialPayloadForEdit() {
    final b = widget.existingBidRequest!;
    setState(() {
      _selectedUnitId =
          (b.unitId == null || b.unitId!.isEmpty) ? null : b.unitId;
      _initialPayload = _buildPayload(
        rentalId: b.rentalId,
        unitId: b.unitId ?? '',
        workCategory: b.workCategory,
        description: b.description ?? '',
        bidRequestImages: List<String>.from(b.bidRequestImages ?? []),
        dueDate: b.dueDate ?? '',
        status: b.status ?? 'Open',
        selectedVendorIds: List<String>.from(b.selectedVendorIds ?? []),
      );
    });
  }

  Map<String, dynamic> _buildPayload({
    required String? rentalId,
    required String unitId,
    required String? workCategory,
    required String description,
    required List<String> bidRequestImages,
    required String dueDate,
    required String status,
    required List<String> selectedVendorIds,
  }) {
    return {
      'rental_id': rentalId ?? '',
      'unit_id': unitId,
      'work_category': workCategory ?? '',
      'description': description,
      'bid_request_images': List<String>.from(bidRequestImages),
      'due_date': dueDate,
      'status': status,
      'selected_vendor_ids': List<String>.from(selectedVendorIds),
    };
  }

  Map<String, dynamic> _getCurrentPayload() {
    return _buildPayload(
      rentalId: _selectedPropertyId,
      unitId: _selectedUnitId ?? '',
      workCategory: _selectedTradeType,
      description: _descriptionController.text,
      bidRequestImages: _uploadedImageNames,
      dueDate: _dueDateController.text,
      status: _selectedStatus ?? 'Open',
      selectedVendorIds: _selectedVendorIds,
    );
  }

  bool _payloadEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k)) return false;
      final va = a[k];
      final vb = b[k];
      if (va is List && vb is List) {
        if (va.length != vb.length) return false;
        for (int i = 0; i < va.length; i++) {
          if (va[i] != vb[i]) return false;
        }
      } else if (va != vb) {
        return false;
      }
    }
    return true;
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: blueColor, // body text color
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
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      // Use image_picker (not file_picker) to avoid Android crash in FileUtils.compressImage
      final ImagePicker picker = ImagePicker();
      final List<XFile>? picked = await picker.pickMultiImage(
        limit: 10 - _uploadedImageNames.length,
      );

      if (picked == null || picked.isEmpty) return;

      List<File> newImages = [];
      for (final x in picked) {
        File? file;
        final path = x.path;
        if (path.isNotEmpty) {
          final f = File(path);
          if (f.existsSync()) {
            file = f;
          }
        }
        if (file == null) {
          try {
            final bytes = await x.readAsBytes();
            if (bytes.isNotEmpty) {
              final dir = Directory.systemTemp;
              final temp = File('${dir.path}/bid_room_${DateTime.now().millisecondsSinceEpoch}_${newImages.length}.jpg');
              await temp.writeAsBytes(bytes);
              file = temp;
            }
          } catch (_) {}
        }
        if (file != null) {
          newImages.add(file);
        }
      }

      if (newImages.isEmpty) {
        Fluttertoast.showToast(msg: 'Could not read selected images');
        return;
      }

      setState(() {
        _selectedImages.addAll(newImages);
      });

      await _uploadImages(newImages);
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
      if (index < _initialExistingImageCount) {
        _uploadedImageNames.removeAt(index);
        _initialExistingImageCount--;
      } else {
        _uploadedImageNames.removeAt(index);
        _selectedImages.removeAt(index - _initialExistingImageCount);
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

    if (_isEditMode && _initialPayload != null) {
      final current = _getCurrentPayload();
      if (_payloadEquals(current, _initialPayload!)) {
        Fluttertoast.showToast(
          msg: 'No changes to save',
          toastLength: Toast.LENGTH_SHORT,
        );
        Navigator.pop(context, false);
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      // Upload any remaining images (e.g. if an upload failed on pick)
      final newUploadedCount = _uploadedImageNames.length - _initialExistingImageCount;
      if (_selectedImages.length > newUploadedCount) {
        final remainingImages = _selectedImages.sublist(newUploadedCount);
        await _uploadImages(remainingImages);
      }

      final body = {
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
      };

      if (_isEditMode) {
        final bidRequestId = widget.existingBidRequest!.bidRequestId;
        if (bidRequestId == null || bidRequestId.isEmpty) {
          Fluttertoast.showToast(msg: 'Invalid bid request');
          setState(() => _isLoading = false);
          return;
        }
        final response = await http.put(
          Uri.parse('${Api_url}/api/bid-request/bid-request/$bidRequestId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
            "Content-Type": "application/json",
          },
          body: json.encode(body),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Fluttertoast.showToast(
            msg: 'Bid Room updated successfully',
            toastLength: Toast.LENGTH_SHORT,
          );
          Navigator.pop(context, true);
        } else {
          final errorBody = json.decode(response.body);
          Fluttertoast.showToast(
            msg: errorBody['message'] ?? 'Failed to update bid room',
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        final response = await http.post(
          Uri.parse('${Api_url}/api/bid-request/bid-request'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
            "Content-Type": "application/json",
          },
          body: json.encode(body),
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
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: _isEditMode
            ? 'Error updating bid room: $e'
            : 'Error creating bid room: $e',
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
                    title: _isEditMode ? 'Update Bid Room' : 'Create Bid Room',
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
                            ?  SpinKitFadingCircle(
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                _isEditMode
                                    ? 'Update Bid Room'
                                    : 'Create Bid Room',
                                style: const TextStyle(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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

  static const int _maxFilenameDisplayLength = 20;

  String _truncateFilename(String name) {
    if (name.length <= _maxFilenameDisplayLength) return name;
    return '${name.substring(0, _maxFilenameDisplayLength - 3)}...';
  }

  Widget _buildImageUploadField() {
    final totalImages = _uploadedImageNames.length;
    final canAdd = totalImages < 10;

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Empty state hint or pill-shaped tags for uploaded images
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: totalImages == 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 28, color: Colors.grey[500]),
                              const SizedBox(width: 10),
                              Text(
                                'Tap + to add pictures (max 10)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _uploadedImageNames.asMap().entries.map((entry) {
                  final index = entry.key;
                  final fileName = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _truncateFilename(fileName),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: blueColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                      ),
              ),
              // Add button - top right, dark blue with white +
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: canAdd ? _pickImages : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: canAdd ? blueColor : Colors.grey[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
