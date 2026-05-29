import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/constant.dart';
import '../../../Model/All_categories_model.dart';
import '../../../repository/fetch_allcategories.dart';
import '../../../repository/workorder.dart';

/// Mobile-friendly 4-step wizard for adding a work order.
/// Uses the same [WorkOrderRepository.addWorkOrder] and API as the web form —
/// see [docs/DESIGN_WORK_ORDER_MOBILE.md] for design and how it matches web.
class AddWorkOrderMobileWizard extends StatefulWidget {
  final String? rentalid;

  const AddWorkOrderMobileWizard({super.key, this.rentalid});

  @override
  State<AddWorkOrderMobileWizard> createState() =>
      _AddWorkOrderMobileWizardState();
}

class _AddWorkOrderMobileWizardState extends State<AddWorkOrderMobileWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Where & What
  final TextEditingController _subjectController = TextEditingController();
  Map<String, String> _properties = {};
  Map<String, String> _units = {};
  String? _selectedPropertyId;
  String? _selectedUnitId;
  List<allcategories_model> _categories = [];
  allcategories_model? _selectedCategory;
  bool _loadingProperties = true;
  bool _loadingUnits = false;
  bool _loadingCategories = true;

  // Step 2: Details
  Map<String, String> _staffs = {};
  Map<String, String> _vendors = {};
  Map<String, String> _tenants = {};
  String? _selectedStaffId;
  String? _selectedVendorId;
  String? _selectedTenantId;
  bool _entryAllowed = false;
  final TextEditingController _workPerformedController = TextEditingController();
  bool _loadingStaff = true;
  bool _loadingVendors = true;
  bool _loadingTenants = false;

  // Step 3: Photos
  final List<File> _imageFiles = [];
  final List<String> _uploadedFileNames = [];
  static const int _maxPhotos = 10;
  bool _uploading = false;

  // Step 4: Cost & Finish
  final List<Map<String, dynamic>> _partsRows = [];
  final TextEditingController _vendorNotesController = TextEditingController();
  bool _billableToTenant = false;
  String _priority = 'Normal';
  String _status = 'New';
  final TextEditingController _dueDateController = TextEditingController();
  bool _submitting = false;

  static const List<String> _statusOptions = [
    'New', 'In Progress', 'On Hold', 'Completed', 'Closed'
  ];

  @override
  void initState() {
    super.initState();
    _selectedPropertyId = widget.rentalid;
    _loadProperties();
    _loadCategories();
    _loadStaff();
    _loadVendors();
    if (widget.rentalid != null) _loadUnits(widget.rentalid!);
    _dueDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _addPartsRow();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _subjectController.dispose();
    _workPerformedController.dispose();
    _vendorNotesController.dispose();
    _dueDateController.dispose();
    for (var row in _partsRows) {
      (row['qtyController'] as TextEditingController?)?.dispose();
      (row['priceController'] as TextEditingController?)?.dispose();
      (row['descController'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() => _loadingProperties = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('adminId');
      final token = prefs.getString('token');
      final response = await apiGet(
        Uri.parse('${Api_url}/api/rentals/rentals/$id'),
        headers: {'authorization': 'CRM $token', 'id': 'CRM $id'},
      );
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as Map)['data'] as List;
        final map = <String, String>{};
        for (var d in list) {
          map[d['rental_id'].toString()] = d['rental_adress'].toString();
        }
        final sorted = Map.fromEntries(
            map.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
        setState(() {
          _properties = sorted;
          _loadingProperties = false;
          if (_selectedPropertyId != null && !_properties.containsKey(_selectedPropertyId)) {
            _selectedPropertyId = null;
          }
        });
        if (_selectedPropertyId != null) _loadUnits(_selectedPropertyId!);
      } else {
        setState(() => _loadingProperties = false);
      }
    } catch (_) {
      setState(() => _loadingProperties = false);
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _loadingUnits = true;
      _units = {};
      _selectedUnitId = null;
      _selectedTenantId = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('adminId');
      final token = prefs.getString('token');
      final response = await apiGet(
        Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'),
        headers: {'authorization': 'CRM $token', 'id': 'CRM $id'},
      );
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as Map)['data'] as List;
        final map = <String, String>{};
        for (var d in list) {
          final uid = d['unit_id']?.toString() ?? '';
          final name = d['rental_unit']?.toString() ?? '';
          if (uid.isNotEmpty && name.trim().isNotEmpty) map[uid] = name.trim();
        }
        setState(() {
          _units = map;
          _loadingUnits = false;
        });
        _loadTenants(rentalId, null);
      } else {
        setState(() => _loadingUnits = false);
      }
    } catch (_) {
      setState(() => _loadingUnits = false);
    }
  }

  Future<void> _loadTenants(String rentalId, String? unitId) async {
    if (unitId == null) {
      setState(() => _tenants = {});
      return;
    }
    setState(() => _loadingTenants = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('adminId');
      final token = prefs.getString('token');
      final response = await apiGet(
        Uri.parse('$Api_url/api/leases/get_tenants/$rentalId/$unitId'),
        headers: {'authorization': 'CRM $token', 'id': 'CRM $id'},
      );
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as Map)['data'] as List;
        final map = <String, String>{};
        for (var d in list) {
          final tid = d['tenant_id']?.toString() ?? '';
          final name =
              '${d['tenant_firstName'] ?? ''} ${d['tenant_lastName'] ?? ''}'
                  .trim();
          if (tid.isNotEmpty) map[tid] = name;
        }
        setState(() {
          _tenants = map;
          _loadingTenants = false;
        });
      } else {
        setState(() => _loadingTenants = false);
      }
    } catch (_) {
      setState(() => _loadingTenants = false);
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final cats = await FetchAllcategories().fetchAllCategories();
      cats.sort((a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
      setState(() {
        _categories = cats;
        _loadingCategories = false;
      });
    } catch (_) {
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _loadStaff() async {
    setState(() => _loadingStaff = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('adminId');
      final token = prefs.getString('token');
      final response = await apiGet(
        Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
        headers: {'authorization': 'CRM $token', 'id': 'CRM $id'},
      );
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as Map)['data'] as List;
        final map = <String, String>{};
        for (var d in list) {
          map[d['staffmember_id'].toString()] =
              d['staffmember_name'].toString();
        }
        setState(() {
          _staffs = map;
          _loadingStaff = false;
        });
      } else {
        setState(() => _loadingStaff = false);
      }
    } catch (_) {
      setState(() => _loadingStaff = false);
    }
  }

  Future<void> _loadVendors() async {
    setState(() => _loadingVendors = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('adminId');
      final token = prefs.getString('token');
      final response = await apiGet(
        Uri.parse('${Api_url}/api/vendor/vendors/$id'),
        headers: {'authorization': 'CRM $token', 'id': 'CRM $id'},
      );
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as Map)['data'] as List;
        final map = <String, String>{};
        for (var d in list) {
          map[d['vendor_id'].toString()] = d['vendor_name'].toString();
        }
        setState(() {
          _vendors = map;
          _loadingVendors = false;
        });
      } else {
        setState(() => _loadingVendors = false);
      }
    } catch (_) {
      setState(() => _loadingVendors = false);
    }
  }

  Future<String?> _uploadImage(File file) async {
    final uri = Uri.parse('${image_upload_url}/api/images/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('files', file.path));
    final stream = await apiSend(request);
    final response = await http.Response.fromStream(stream);
    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['status'] == 'ok') {
      final files = body['files'] as List;
      if (files.isNotEmpty && files.first is Map) {
        return (files.first as Map)['filename'] as String?;
      }
    }
    return null;
  }

  static const List<String> _accountOptions = [
    'Advertising', 'Association Fees', 'Bank Fees', 'Auto and Travel',
    'Cleaning and Maintenance', 'Commissions', 'Depreciation Expense',
    'Insurance', 'Legal and Professional Fees', 'Licenses and Permits',
    'Management Fees', 'Mortgage Interest', 'Other Expenses',
    'Other Interest Expenses', 'Postage and Delivery', 'Repairs',
  ];

  void _addPartsRow() {
    final qty = TextEditingController(text: '1');
    final price = TextEditingController(text: '0');
    final desc = TextEditingController();
    setState(() {
      _partsRows.add({
        'qtyController': qty,
        'priceController': price,
        'descController': desc,
        'selectedAccount': 'Cleaning and Maintenance',
      });
    });
  }

  void _removePartsRow(int index) {
    if (_partsRows.length <= 1) return;
    (_partsRows[index]['qtyController'] as TextEditingController).dispose();
    (_partsRows[index]['priceController'] as TextEditingController).dispose();
    (_partsRows[index]['descController'] as TextEditingController).dispose();
    setState(() => _partsRows.removeAt(index));
  }

  bool _validateStep1() {
    if (_selectedPropertyId == null || _selectedPropertyId!.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select Property');
      return false;
    }
    if (_selectedUnitId == null || _selectedUnitId!.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select Unit');
      return false;
    }
    if (_subjectController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter Subject');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_selectedStaffId == null || _selectedStaffId!.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select Assigned To');
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    if (_status.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select Status');
      return false;
    }
    if (_dueDateController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please set Due Date');
      return false;
    }
    return true;
  }

  void _next() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;
    if (_currentStep == 3) {
      _submit();
      return;
    }
    if (_currentStep == 2) {
      if (_selectedPropertyId != null && _selectedUnitId != null) {
        _loadTenants(_selectedPropertyId!, _selectedUnitId);
      }
    }
    setState(() => _currentStep++);
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentStep--);
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _submit() async {
    if (!_validateStep4()) return;
    setState(() => _submitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('adminId');
      final parts = _partsRows.map((row) {
        final qty = int.tryParse((row['qtyController'] as TextEditingController).text) ?? 0;
        final price = double.tryParse((row['priceController'] as TextEditingController).text) ?? 0;
        final total = qty * price;
        return {
          'parts_quantity': qty,
          'account': row['selectedAccount'] as String? ?? 'Cleaning and Maintenance',
          'description': (row['descController'] as TextEditingController).text,
          'charge_type': 'Workorder Charge',
          'parts_price': price,
          'amount': total,
        };
      }).toList();

      await WorkOrderRepository().addWorkOrder(
        adminId: adminId,
        workSubject: _subjectController.text.trim(),
        staffMemberName: _selectedStaffId,
        workCategory: _selectedCategory?.name,
        categoryId: _selectedCategory?.categoryId,
        workPerformed: _workPerformedController.text.trim(),
        status: _status,
        rentalAddress: _properties[_selectedPropertyId],
        rentalUnit: _units[_selectedUnitId],
        tenant: _selectedTenantId,
        rentalid: _selectedPropertyId,
        unitid: _selectedUnitId,
        workOrderImages: _uploadedFileNames.isEmpty ? null : _uploadedFileNames,
        entry: _entryAllowed,
        vendorId: _selectedVendorId,
        vendorNotes: _vendorNotesController.text.trim(),
        priority: _priority,
        workChargeTo: _billableToTenant,
        date: reverseFormatDate(_dueDateController.text),
        isBillable: _billableToTenant,
        parts: parts,
        notificationTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to add work order: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_imageFiles.length >= _maxPhotos) {
      Fluttertoast.showToast(msg: 'Maximum $_maxPhotos photos allowed');
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() => _imageFiles.add(File(picked.path)));
    setState(() => _uploading = true);
    try {
      final name = await _uploadImage(File(picked.path));
      if (name != null && mounted) {
        setState(() => _uploadedFileNames.add(name));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _imageFiles.removeLast());
        Fluttertoast.showToast(msg: 'Upload failed');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      if (index < _imageFiles.length) _imageFiles.removeAt(index);
      if (index < _uploadedFileNames.length) _uploadedFileNames.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Work Order'),
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalSteps, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= _currentStep ? Colors.white : Colors.white24,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2))
      ]),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _submitting ? null : _back,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: blueColor),
              ),
              child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitting ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_currentStep == 3 ? 'Add Work Order' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Where & What', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Property *',
            value: _selectedPropertyId,
            map: _properties,
            loading: _loadingProperties,
            onChanged: (id) {
              setState(() {
                _selectedPropertyId = id;
                _selectedUnitId = null;
              });
              if (id != null) _loadUnits(id);
            },
          ),
          const SizedBox(height: 12),
          _dropdown(
            label: 'Unit *',
            value: _selectedUnitId,
            map: _units,
            loading: _loadingUnits,
            onChanged: (id) {
              setState(() => _selectedUnitId = id);
              if (_selectedPropertyId != null && id != null) {
                _loadTenants(_selectedPropertyId!, id);
              }
            },
          ),
          const SizedBox(height: 12),
          _textField('Subject *', _subjectController, hint: 'e.g. Maintenance - plumbing'),
          const SizedBox(height: 12),
          _categoryDropdown(),
        ],
      ),
    );
  }

  Widget _categoryDropdown() {
    if (_loadingCategories) {
      return const ListTile(title: Text('Loading categories...'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._categories.map((c) => ListTile(
                          title: Text(c.name ?? ''),
                          onTap: () {
                            setState(() => _selectedCategory = c);
                            Navigator.pop(ctx);
                          },
                        )),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedCategory?.name ?? 'Select category'),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Assigned To *',
            value: _selectedStaffId,
            map: _staffs,
            loading: _loadingStaff,
            onChanged: (id) => setState(() => _selectedStaffId = id),
          ),
          const SizedBox(height: 12),
          const Text('Entry allowed', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              _chip('No', !_entryAllowed, () => setState(() => _entryAllowed = false)),
              const SizedBox(width: 12),
              _chip('Yes', _entryAllowed, () => setState(() => _entryAllowed = true)),
            ],
          ),
          const SizedBox(height: 12),
          _dropdown(
            label: 'Vendor',
            value: _selectedVendorId,
            map: _vendors,
            loading: _loadingVendors,
            onChanged: (id) => setState(() => _selectedVendorId = id),
          ),
          if (_tenants.isNotEmpty) ...[
            const SizedBox(height: 12),
            _dropdown(
              label: 'Tenant (optional)',
              value: _selectedTenantId,
              map: _tenants,
              loading: _loadingTenants,
              onChanged: (id) => setState(() => _selectedTenantId = id),
            ),
          ],
          const SizedBox(height: 12),
          _textField('Work to be performed', _workPerformedController,
              hint: 'Describe the work', maxLines: 3),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? blueColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Photos (max $_maxPhotos)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_uploading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _uploading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take photo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _uploading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_imageFiles.length, (i) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFiles[i], width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(i),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          if (_imageFiles.isEmpty && !_uploading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('No photos yet. Tap Take photo or Gallery.', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Cost & Finish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...List.generate(_partsRows.length, (i) => _buildPartsRow(i)),
          TextButton.icon(
            onPressed: _addPartsRow,
            icon: const Icon(Icons.add),
            label: const Text('Add row'),
          ),
          const SizedBox(height: 12),
          _textField('Vendor notes', _vendorNotesController, hint: 'Optional', maxLines: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _billableToTenant,
                onChanged: (v) => setState(() => _billableToTenant = v ?? false),
                activeColor: blueColor,
              ),
              const Text('Billable to tenant'),
            ],
          ),
          const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              _chip('High', _priority == 'High', () => setState(() => _priority = 'High')),
              const SizedBox(width: 8),
              _chip('Normal', _priority == 'Normal', () => setState(() => _priority = 'Normal')),
              const SizedBox(width: 8),
              _chip('Low', _priority == 'Low', () => setState(() => _priority = 'Low')),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Status *', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((s) => _chip(s, _status == s, () => setState(() => _status = s))).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Due date', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(_dueDateController.text) ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) _dueDateController.text = DateFormat('yyyy-MM-dd').format(date);
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dueDateController.text),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsRow(int index) {
    final row = _partsRows[index];
    final qty = row['qtyController'] as TextEditingController;
    final price = row['priceController'] as TextEditingController;
    final desc = row['descController'] as TextEditingController;
    final qtyVal = int.tryParse(qty.text) ?? 1;
    final priceVal = double.tryParse(price.text) ?? 0;
    final total = (qtyVal * priceVal).toStringAsFixed(2);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Parts and labor', style: TextStyle(fontWeight: FontWeight.w600)),
                if (_partsRows.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _removePartsRow(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Qty'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: qty,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Price'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Spacer(),
                Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: row['selectedAccount'] as String? ?? _accountOptions.first,
              decoration: const InputDecoration(labelText: 'Account', isDense: true),
              items: _accountOptions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (v) => setState(() => row['selectedAccount'] = v ?? _accountOptions.first),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: desc,
              decoration: const InputDecoration(labelText: 'Description', isDense: true),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required Map<String, String> map,
    required bool loading,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: loading
              ? null
              : () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ...map.entries.map((e) => ListTile(
                                title: Text(e.value),
                                onTap: () {
                                  onChanged(e.key);
                                  Navigator.pop(ctx);
                                },
                              )),
                        ],
                      ),
                    ),
                  );
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loading ? 'Loading...' : (map[value] ?? 'Select')),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }
}
