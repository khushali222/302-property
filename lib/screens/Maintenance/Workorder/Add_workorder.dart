import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:three_zero_two_property/Model/WorkOrderSetting.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import '../../../widgets/camera_capture_screen.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/repository/SettingWorkorder.dart';
import 'package:three_zero_two_property/repository/workorder.dart';
import 'package:chewie/chewie.dart';
import '../../../Model/All_categories_model.dart';
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../repository/fetch_allcategories.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/titleBar.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/clearable_date_picker.dart';
import '../../../widgets/clearable_date_suffix.dart';
import '../../Rental/Tenants/add_tenants.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../provider/dateProvider.dart';
import 'package:camera/camera.dart' as camera;

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class ResponsiveAddWorkOrder extends StatefulWidget {
  String? rentalid;
  ResponsiveAddWorkOrder({super.key, this.rentalid});
  @override
  State<ResponsiveAddWorkOrder> createState() => _ResponsiveAddWorkOrderState();
}

class _ResponsiveAddWorkOrderState extends State<ResponsiveAddWorkOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return AddWorkOrderForTablet(
              rentalid: widget.rentalid,
            );
          } else {
            return AddWorkOrderForMobile(
              rentalid: widget.rentalid,
            );
          }
        },
      ),
    );
  }
}

class AddWorkOrderForMobile extends StatefulWidget {
  String? rentalid;
  AddWorkOrderForMobile({super.key, this.rentalid});
  @override
  State<AddWorkOrderForMobile> createState() => _AddWorkOrderForMobileState();
}

class _AddWorkOrderForMobileState extends State<AddWorkOrderForMobile>
    with RouteAware {
  final TextEditingController subject = TextEditingController();

  final TextEditingController other = TextEditingController();

  final TextEditingController perform = TextEditingController();
  final TextEditingController vendornote = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;

  bool _isLoading = false;
  bool _isLoadingvendors = false;
  bool _isLoadingstaff = false;
  bool _isLoadingtenant = false;
  bool _Loading = false;
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {}; // Mapping of unit_id to rental_unit
  String? _selectedPropertyId;
  String? _selectedProperty;
  String? _selectedUnitId;
  String? _selectedUnit;

  //for vendor
  Map<String, String> vendors = {};
  String? _selectedvendorsId;
  String? _selectedVendors;

  //for Staffmember
  Map<String, String> staffs = {};
  String? _selectedstaffId;
  String? _selectedStaffs;
  //for tenants
  Map<String, String> tenants = {};
  String? _selectedtenantId;
  String? _selectedTenants;

  @override
  void initState() {
    super.initState();
    _loadDropdownCategories();
    _loadProperties();
    _loadVendor();
    _loadStaff();
    _selectedPropertyId = widget.rentalid;
    fetchWorkData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    subject.dispose();
    other.dispose();
    perform.dispose();
    vendornote.dispose();
    _dateController.dispose();
    for (final row in partsAndLabor) {
      (row['qtyController'] as TextEditingController?)?.dispose();
      (row['accountController'] as TextEditingController?)?.dispose();
      (row['descriptionController'] as TextEditingController?)?.dispose();
      (row['priceController'] as TextEditingController?)?.dispose();
      (row['totalController'] as TextEditingController?)?.dispose();
      (row['subtotalcontroller'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // Only refetch categories if they're not already loaded
    // This prevents clearing the dropdown unnecessarily
    if (_dropdownCategories.isEmpty) {
      _loadDropdownCategories();
    }
    super.didPopNext();
  }

  Future<void> _loadDropdownCategories({bool forceRefresh = false}) async {
    // Prevent refetch if categories are already loaded (unless forced)
    if (!forceRefresh &&
        _dropdownCategories.isNotEmpty &&
        !_isLoadingCategories) {
      return;
    }

    // Preserve the selected category ID before refetching
    String? selectedCategoryId = _selectedDropdownCategory?.categoryId;

    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final cats = await FetchAllcategories().fetchAllCategories();

      // Print each category details
      for (int i = 0; i < cats.length; i++) {
      }

      // Sort categories alphabetically by name
      cats.sort((a, b) {
        final nameA = (a.name ?? '').toLowerCase();
        final nameB = (b.name ?? '').toLowerCase();
        return nameA.compareTo(nameB);
      });

      // Restore the selected category if it exists
      allcategories_model? restoredCategory;
      String? categoryIdToRestore = selectedCategoryId ?? _pendingCategoryId;

      if (categoryIdToRestore != null && cats.isNotEmpty) {
        try {
          restoredCategory = cats.firstWhere(
            (cat) => cat.categoryId == categoryIdToRestore,
          );
          _pendingCategoryId =
              null; // Clear pending ID after successful restore
        } catch (e) {
          // Category not found in new list, keep it as null
          logError(
              '=== Selected category not found in new list, clearing selection ===');
          restoredCategory = null;
        }
      }

      setState(() {
        _dropdownCategories = cats;
        _isLoadingCategories = false;
        // Restore selected category if it was previously selected or pending
        if (restoredCategory != null) {
          _selectedDropdownCategory = restoredCategory;
        }
      });
    } catch (e) {
      logError('=== Error fetching categories in AddWorkOrderForMobile ===');
      logError('Error: ${e.toString()}');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> fetchWorkData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Data workorder = await fetchWorkOrderSetting();
      String? entryAllowedString;
      if (workorder.workDefaults?.entryAllowed != null) {
        entryAllowedString =
            workorder.workDefaults!.entryAllowed! ? 'Yes' : 'No';
      }
      if (workorder != null) {
        String? fetchedCategoryId = workorder.workDefaults?.category;
        setState(() {
          _selectedvendorsId = workorder.workDefaults?.vendorId?.isEmpty ?? true
              ? null
              : workorder.workDefaults?.vendorId;
          _selectedCategory = workorder.workDefaults?.category ?? "";
          _selectedstaffId =
              workorder.workDefaults?.staffmemberId?.isEmpty ?? true
                  ? null
                  : workorder.workDefaults?.staffmemberId;
          _selectedEntry = entryAllowedString;
          if (fetchedCategoryId != null) {
            if (_dropdownCategories.isNotEmpty) {
              // Categories already loaded, set selected category immediately
              final match = _dropdownCategories
                  .where((cat) => cat.categoryId == fetchedCategoryId)
                  .toList();
              if (match.length == 1) {
                _selectedDropdownCategory = match.first;
              } else {
                _selectedDropdownCategory = null;
              }
            } else {
              // Categories not loaded yet, store the ID for later
              _pendingCategoryId = fetchedCategoryId;
            }
          } else {
            _selectedDropdownCategory = null;
            _pendingCategoryId = null;
          }
        });
      }
    } catch (e) {
      logError('Failed to load workorder data: $e');
    }
  }

  Future<void> _loadProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/rentals/rentals/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> addresses = {};
        jsonResponse.forEach((data) {
          addresses[data['rental_id'].toString()] =
              data['rental_adress'].toString();
        });

        // Sort properties alphabetically by address (A-Z)
        final sortedEntries = addresses.entries.toList()
          ..sort(
              (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
        final sortedAddresses = Map<String, String>.fromEntries(sortedEntries);

        setState(() {
          properties = sortedAddresses;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
      // Clear units and selection when loading new units
      units = {};
      _selectedUnitId = null;
      _selectedUnit = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};

        // Filter out any null or empty unit names
        for (var data in jsonResponse) {
          String unitId = data['unit_id']?.toString() ?? '';
          String unitName = data['rental_unit']?.toString() ?? '';

          if (unitId.isNotEmpty && unitName.trim().isNotEmpty) {
            unitAddresses[unitId] = unitName.trim();
          }
        }


        setState(() {
          units = unitAddresses;
          _isLoading = false;

          // Only keep the selected unit if it exists in the new units
          if (_selectedUnitId != null && !units.containsKey(_selectedUnitId)) {
            _selectedUnitId = null;
          }
        });

        // Load tenant data if we have a valid unit selected
        if (_selectedUnitId != null && units.containsKey(_selectedUnitId)) {
          _loadTenant(rentalId, _selectedUnitId!);
        }
      } else {
        setState(() {
          units = {};
          _selectedUnitId = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      logError('Error loading units: $e');
      setState(() {
        units = {};
        _selectedUnitId = null;
        _isLoading = false;
      });
    }
  }

  //for vendor
  Future<void> _loadVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingvendors = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/vendor/vendors/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> names = {};
        jsonResponse.forEach((data) {
          names[data['vendor_id'].toString()] = data['vendor_name'].toString();
        });

        setState(() {
          vendors = names;
          _isLoadingvendors = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingvendors = false;
      });
    }
  }

  Future<void> _loadStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await apiGet(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });

      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> staffnames = {};
        jsonResponse.forEach((data) {
          staffnames[data['staffmember_id'].toString()] =
              data['staffmember_name'].toString();
        });

        setState(() {
          staffs = staffnames;
          _isLoadingstaff = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingstaff = false;
      });
    }
  }

  Future<void> _loadTenant(String rentalId, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingtenant = true;
    });
    try {
      final response = await apiGet(
          Uri.parse('${Api_url}/api/leases/get_tenants/$rentalId/$unitId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> tenantsnames = {};
        jsonResponse.forEach((data) {
          tenantsnames[data['tenant_id'].toString()] =
              data['tenant_firstName'].toString() +
                  " " +
                  data['tenant_lastName'].toString();
        });
        setState(() {
          tenants = tenantsnames;
          _isLoadingtenant = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingtenant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tenants: ${friendlyErrorMessage(e)}')),
      );
    }
  }

  String? _selectedCategory;
  final List<String> _category = [
    'Complaint',
    'Contribution Request',
    'Feedback/Suggestion',
    'General Inquiry',
    'Maintenance Request',
    'Other'
  ];
  String? _selectedEntry;
  final List<String> _entry = [
    'Yes',
    'No',
  ];
  String? _selectedStatus = "New";
  final List<String> _status = [
    'Closed',
    'Completed',
    'In Progress',
    'New',
    'On Hold'
  ];
  final List<String> _account = [
    'Advertising',
    'Association Fees',
    'Bank Fees',
    'Auto and Travel',
    'Cleaning and Maintenance',
    'Commissions',
    'Depreciation Expense',
    'Insurance',
    'Legal and Professional Fees',
    'Licenses and Permits',
    'Management Fees',
    'Mortgage Interest',
    'Other Expenses',
    'Other Interest Expenses',
    'Postage and Delivery',
    'Repairs',
  ];
  List<Map<String, dynamic>> rows = [];
  bool _showTextField = false;
  String renderId = '';
  String unitId = '';
  String vendorId = '';
  String StaffId = '';
  String tenantId = '';
  bool isChecked = false;
  //for parts and lebours
  List<bool> isvideo = [];
  List<Map<String, dynamic>> partsAndLabor = [];

  void addRow() {
    setState(() {
      TextEditingController qtyController = TextEditingController();
      TextEditingController priceController = TextEditingController();
      TextEditingController totalController = TextEditingController();
      TextEditingController subtotalcontroller = TextEditingController();

      qtyController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });
      priceController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });

      partsAndLabor.add({
        'qtyController': qtyController,
        'accountController': TextEditingController(),
        'descriptionController': TextEditingController(),
        'priceController': priceController,
        'totalController': totalController,
        'subtotalcontroller': subtotalcontroller,
        'selectedAccount': null,
      });
    });
  }

  void deleteRow(int index) {
    setState(() {
      final row = partsAndLabor[index];
      (row['qtyController'] as TextEditingController?)?.dispose();
      (row['accountController'] as TextEditingController?)?.dispose();
      (row['descriptionController'] as TextEditingController?)?.dispose();
      (row['priceController'] as TextEditingController?)?.dispose();
      (row['totalController'] as TextEditingController?)?.dispose();
      (row['subtotalcontroller'] as TextEditingController?)?.dispose();
      partsAndLabor.removeAt(index);
      updateTotalAmount();
    });
  }

  void calculateTotal(
      TextEditingController qtyController,
      TextEditingController priceController,
      TextEditingController totalController,
      TextEditingController subtotalcontroller) {
    double quantity = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    double total = quantity * price;
    totalController.text = total.toStringAsFixed(2);
    double subtotal = total += total;
    subtotalcontroller.text = subtotal.toStringAsFixed(2);
    updateTotalAmount();
  }

  double totalAmount = 0.0;
  void updateTotalAmount() {
    double total = 0.0;
    for (var item in partsAndLabor) {
      double itemTotal = double.tryParse(item['totalController'].text) ?? 0;
      total += itemTotal;
    }
    setState(() {
      totalAmount = total;
    });
  }

  Widget buildRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                deleteRow(index);
              },
            ),
          ),
          const Text(
            "Quantity",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Quantity',
            controller: partsAndLabor[index]['qtyController'],
            keyboardType: TextInputType.number,
            showElevation: false,
            borderColor: const Color(0xFFCED4DA),
            borderWidth: 1.5,
            // keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
          ),
          const SizedBox(height: 10),
          const Text(
            "Account",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: const Text('Select'),
              value: partsAndLabor[index]['selectedAccount'],
              items: _account.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  partsAndLabor[index]['selectedAccount'] = newValue;
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 45,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFCED4DA),
                    width: 1.5,
                  ),
                ),
                elevation: 0,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                iconEnabledColor: Color(0xFFb0b6c3),
                iconDisabledColor: Colors.grey,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                offset: const Offset(0, -5),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(6),
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
          const SizedBox(height: 10),
          const Text(
            "Description",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Description',
            controller: partsAndLabor[index]['descriptionController'],
            keyboardType: TextInputType.text,
            showElevation: false,
            borderColor: const Color(0xFFCED4DA),
            borderWidth: 1.5,
          ),
          const SizedBox(height: 10),
          const Text(
            "Price",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Price',
            controller: partsAndLabor[index]['priceController'],
            keyboardType: TextInputType.number,
            showElevation: false,
            borderColor: const Color(0xFFCED4DA),
            borderWidth: 1.5,
            // keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
          ),
          const SizedBox(height: 10),
          const Text(
            "Total",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Total',
            controller: partsAndLabor[index]['totalController'],
            keyboardType: TextInputType.number,
            showElevation: false,
            borderColor: const Color(0xFFCED4DA),
            borderWidth: 1.5,
            readOnnly: true,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _selectedOption = 'button 1';

  void _handleRadioValueChange(String? value) {
    setState(() {
      _selectedOption = value!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    // Due Date is optional here (no validator, empty submits as ""), so the
    // picker offers Clear the way the web date input does.
    final result = await showClearableDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Due date cannot be earlier than today
      lastDate: DateTime(2101),
      helpText: 'Select due date',
    );

    if (result == null) return; // cancelled: keep the old value
    if (result.cleared) {
      setState(() => _dateController.clear());
      return;
    }

    final DateTime selectedDate = result.date!;
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    setState(() {
      _dateController.text =
          DateFormat(dateProvider.dateFormat).format(selectedDate);
    });
  }
  //for tenants

  File? _image;
  List<File> _images = [];
  List<File> videofiles = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  Future<String?> uploadImage(File imageFile) async {
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await apiSend(request);
    var responseData = await http.Response.fromStream(response);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Select Media From',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Options Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Option
                    _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImageFromSource(ImageSource.gallery);
                      },
                    ),

                    const SizedBox(width: 20),

                    // Camera Option
                    _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.of(context).pop();
                        _openCameraInterface();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build individual source option
  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: blueColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from specific source
  Future<void> _pickImageFromSource(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickMedia();

    if (image != null) {
      final File file = File(image.path);
      bool isVideo = image.path.endsWith('.mp4') || image.path.endsWith('.mov');
      if (isVideo) {
        String? thumbnailPath = await _generateVideoThumbnail(image.path);
        if (thumbnailPath != null) {
          setState(() {
            _images.add(File(thumbnailPath));
            isvideo.add(true);
            videofiles.add(file);
          });
        }
      } else {
        setState(() {
          _images.add(file);
          isvideo.add(false);
          videofiles.add(file);
        });
      }
      _uploadImage(file);
    }
  }

  // Open unified camera interface for both photos and videos
  Future<void> _openCameraInterface() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorDialog('No cameras found on this device');
        return;
      }

      // Use the first available camera (usually back camera)
      final camera = cameras.first;

      // Navigate to camera screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraCaptureScreen(
            camera: camera,
            onImageCaptured: (File imageFile) {
              // Handle captured image
              setState(() {
                _images.add(imageFile);
                isvideo.add(false);
                videofiles.add(imageFile);
              });
              _uploadImage(imageFile);
            },
            onVideoCaptured: (File videoFile) async {
              // Handle captured video
              String? thumbnailPath =
                  await _generateVideoThumbnail(videoFile.path);
              if (thumbnailPath != null) {
                setState(() {
                  _images.add(File(thumbnailPath));
                  isvideo.add(true);
                  videofiles.add(videoFile);
                });
              }
              _uploadImage(videoFile);
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog('Failed to open camera: $e');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    final String? thumbPath =
        await video_thumbnail.VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: video_thumbnail.ImageFormat.PNG,
      maxHeight: 80,
      quality: 50,
    );
    return thumbPath;
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? fileName = await uploadImage(imageFile);
      setState(() {
        _uploadedFileNames.add(fileName!);
        _uploadedFileName = fileName;
      });
    } catch (e) {
      logError('Image upload failed: $e');
    }
  }

  void _showVideoDialog(File videoFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: VideoPlayerDialog(videoFile: videoFile),
        );
      },
    );
  }

  void _showImageDialog(
      File imageFile, int imageIndex, File? originalFile, bool isVideo) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: blueColor, width: 1),
                        ),
                        child: Icon(
                          Icons.close,
                          color: blueColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Image with rounded corners and camera icon overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        height: 300,
                        width: 300,
                      ),
                    ),
                    // Camera icon overlay
                    Positioned(
                      top: 10,
                      right: 5,
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image = await _picker.pickMedia();

                          if (image != null) {
                            final File newFile = File(image.path);
                            bool isNewVideo = image.path.endsWith('.mp4') ||
                                image.path.endsWith('.mov');

                            if (isNewVideo) {
                              String? thumbnailPath =
                                  await _generateVideoThumbnail(image.path);
                              if (thumbnailPath != null) {
                                // Update the preview with new image
                                Navigator.of(context).pop();
                                _showImageDialog(File(thumbnailPath),
                                    imageIndex, newFile, true);
                              }
                            } else {
                              // Update the preview with new image
                              Navigator.of(context).pop();
                              _showImageDialog(
                                  newFile, imageIndex, newFile, false);
                            }
                          }
                        },
                        child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              //  color: Colors.white.withOpacity(0.8),
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                "assets/icons/bxs_edit.png",
                                fit: BoxFit.cover,
                                color: Colors.white,
                                height: 10,
                                width: 10,
                              ),
                            )
                            // Icon(
                            //   Icons.camera_alt,
                            //   color: Colors.white,
                            //   size: 20,
                            // ),
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: blueColor,
                        side: BorderSide(color: blueColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: blueColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Update the existing image in the list
                        setState(() {
                          _images[imageIndex] = imageFile;
                          isvideo[imageIndex] = isVideo;
                          if (originalFile != null) {
                            videofiles[imageIndex] = originalFile;
                          } else {
                            videofiles[imageIndex] = imageFile;
                          }
                        });

                        // Upload the new image
                        try {
                          String? fileName =
                              await uploadImage(originalFile ?? imageFile);
                          if (fileName != null &&
                              imageIndex < _uploadedFileNames.length) {
                            setState(() {
                              _uploadedFileNames[imageIndex] = fileName;
                            });
                          }
                        } catch (e) {
                          logError('Image upload failed: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[100],
                        // foregroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateImageAtIndex(int index) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickMedia();

    if (image != null) {
      final File file = File(image.path);
      bool isVideo = image.path.endsWith('.mp4') || image.path.endsWith('.mov');

      // Show preview dialog first
      if (isVideo) {
        String? thumbnailPath = await _generateVideoThumbnail(image.path);
        if (thumbnailPath != null) {
          _showImageDialog(File(thumbnailPath), index, file, true);
        }
      } else {
        _showImageDialog(file, index, file, false);
      }
    }
  }

  List<allcategories_model> _dropdownCategories = [];
  allcategories_model? _selectedDropdownCategory;
  bool _isLoadingCategories = false;
  String?
      _pendingCategoryId; // Store category ID from work defaults until categories are loaded
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Work Orders",
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
                const SizedBox(
                  height: 25,
                ),
                titleBar(
                  width: MediaQuery.of(context).size.width * .91,
                  title: 'Add Work Order',
                ),
                const SizedBox(
                  height: 15,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Subject *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Add subject',
                            controller: subject,
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
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Photos (Maximum of 10)',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          // Container(
                          //   height: 45,
                          //   width: 130,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(8.0),
                          //   ),
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: blueColor,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8.0),
                          //       ),
                          //     ),
                          //     onPressed: _images.length >= 10
                          //         ? null // disables the button
                          //         : () async {
                          //             _showImageSourceDialog();
                          //           },
                          //     // onPressed: () async {
                          //     //   _pickImage().then((_) {
                          //     //     setState(
                          //     //         () {}); // Rebuild the widget after selecting the image
                          //     //   });
                          //     // },
                          //     child: isLoading
                          //         ? const Center(
                          //             child: SpinKitFadingCircle(
                          //               color: Colors.white,
                          //               size: 55.0,
                          //             ),
                          //           )
                          //         : const Text(
                          //             'Upload here',
                          //             style:
                          //                 TextStyle(color: Color(0xFFf7f8f9)),
                          //           ),
                          //   ),
                          // ),

                          // Container(
                          //   height: 45,
                          //   width: 130,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(8.0),
                          //   ),
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: blueColor,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8.0),
                          //       ),
                          //     ),
                          //     onPressed: _images.length >= 10
                          //         ? null // disables the button
                          //         : () async {
                          //             _showImageSourceDialog();
                          //           },
                          //     // onPressed: () async {
                          //     //   _pickImage().then((_) {
                          //     //     setState(
                          //     //         () {}); // Rebuild the widget after selecting the image
                          //     //   });
                          //     // },
                          //     child: isLoading
                          //         ? const Center(
                          //             child: SpinKitFadingCircle(
                          //               color: Colors.white,
                          //               size: 55.0,
                          //             ),
                          //           )
                          //         : const Text(
                          //             'Upload here',
                          //             style:
                          //                 TextStyle(color: Color(0xFFf7f8f9)),
                          //           ),
                          //   ),
                          // ),
                          if (_images.isEmpty)
                            GestureDetector(
                              onTap: () {
                                _showImageSourceDialog();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload your Photo here',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Maximum File Size is 20MB',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const Text(
                                      'Supported File Types are .png, .jpeg, .pdf, .csv',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_images.isEmpty)
                            const SizedBox(
                              height: 10,
                            ),
                          _images.isNotEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_images.length < 10)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          // crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  _showImageSourceDialog();
                                                },
                                                child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                      color: blueColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                    ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ))),
                                          ],
                                        ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              //color: Colors.blue,
                                              child: Wrap(
                                                spacing:
                                                    8.0, // Horizontal spacing between items
                                                runSpacing:
                                                    8.0, // Vertical spacing between rows
                                                children: List.generate(
                                                  _images.length,
                                                  (index) {
                                                    return Container(
                                                      // color: Colors.green,
                                                      width: 85,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 60,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _images.removeAt(
                                                                        index);
                                                                  });
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              isvideo[index]
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _showVideoDialog(
                                                                            videofiles[index]);
                                                                      },
                                                                      child:
                                                                          Stack(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        children: [
                                                                          Image
                                                                              .file(
                                                                            _images[index],
                                                                            height:
                                                                                80,
                                                                            width:
                                                                                80,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                          const Icon(
                                                                              Icons.play_circle_fill,
                                                                              color: Colors.white,
                                                                              size: 30),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _showImageDialog(
                                                                            _images[index],
                                                                            index,
                                                                            _images[index],
                                                                            false);
                                                                      },
                                                                      child:
                                                                          Stack(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        children: [
                                                                          Image
                                                                              .file(
                                                                            _images[index],
                                                                            height:
                                                                                80,
                                                                            width:
                                                                                80,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                          Positioned(
                                                                            top:
                                                                                28,
                                                                            right:
                                                                                28,
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(4),
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.black54,
                                                                                borderRadius: BorderRadius.circular(15),
                                                                              ),
                                                                              child: Icon(
                                                                                Icons.visibility,
                                                                                color: Colors.white,
                                                                                size: 16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Property *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 2,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormField<String>(
                                validator: (value) {
                                  if (_selectedPropertyId == null) {
                                    return 'Please select an option';
                                  }
                                  return null;
                                },
                                builder: (FormFieldState<String> state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField2<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          isExpanded: true,
                                          hint: const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Select here',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFb0b6c3),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items:
                                              properties.keys.map((rentalId) {
                                            return DropdownMenuItem<String>(
                                              value: rentalId,
                                              child: Text(
                                                properties[rentalId]!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          value: _selectedPropertyId,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedUnitId = null;
                                              _selectedPropertyId = value;
                                              _selectedProperty = properties[
                                                  value]; // Store selected rental_adress
                                              renderId = value.toString();
                                              if (value != null) {
                                                units =
                                                    {}; // Clear existing units
                                                _loadUnits(value);
                                              }
                                              state.didChange(
                                                  value); // Notify FormField of change
                                            });
                                            state.reset();
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: const Color(0xFFCED4DA),
                                                width: 1.5,
                                              ),
                                            ),
                                            elevation: 0,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(Icons.arrow_drop_down),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 300,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            offset: const Offset(0, -5),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness:
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
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
                              // units.isNotEmpty
                              units.isNotEmpty &&
                                      units.values
                                          .any((unit) => unit.trim().isNotEmpty)
                                  ? const Text('Unit *',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF101828)))
                                  : Container(),
                              const SizedBox(height: 0),
                              // units.isNotEmpty
                              units.isNotEmpty &&
                                      units.values
                                          .any((unit) => unit.trim().isNotEmpty)
                                  ? FormField<String>(
                                      validator: (value) {
                                        if (_selectedUnitId == null ||
                                            _selectedUnitId!.isEmpty) {
                                          return 'Please select an option';
                                        }
                                        return null;
                                      },
                                      builder: (FormFieldState<String> state) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField2<
                                                  String>(
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                                isExpanded: true,
                                                hint: const Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Select here',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xFFb0b6c3),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                items: units.keys
                                                    .map((unitId) {
                                                      String? unitName =
                                                          units[unitId]?.trim();
                                                      if (unitName
                                                              ?.isNotEmpty !=
                                                          true) return null;

                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: unitId,
                                                        child: Text(
                                                          unitName!,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    })
                                                    .whereType<
                                                        DropdownMenuItem<
                                                            String>>()
                                                    .toList(),
                                                value: units.containsKey(
                                                        _selectedUnitId)
                                                    ? _selectedUnitId
                                                    : null,
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      unitId = value;
                                                      _selectedUnitId = value;
                                                      _selectedUnit =
                                                          units[value]?.trim();
                                                      if (_selectedPropertyId !=
                                                          null) {
                                                        _loadTenant(
                                                            _selectedPropertyId!,
                                                            value);
                                                      }
                                                    });
                                                    state.didChange(value);
                                                  }
                                                },
                                                buttonStyleData:
                                                    ButtonStyleData(
                                                  height: 45,
                                                  width: 160,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 14, right: 14),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFCED4DA),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Icon(
                                                      Icons.arrow_drop_down),
                                                  iconSize: 24,
                                                  iconEnabledColor:
                                                      Color(0xFFb0b6c3),
                                                  iconDisabledColor:
                                                      Colors.grey,
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  maxHeight: 300,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: Colors.white,
                                                  ),
                                                  offset: const Offset(0, -5),
                                                  scrollbarTheme:
                                                      ScrollbarThemeData(
                                                    radius:
                                                        const Radius.circular(
                                                            6),
                                                    thickness:
                                                        MaterialStateProperty
                                                            .all(6),
                                                    thumbVisibility:
                                                        MaterialStateProperty
                                                            .all(true),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  height: 40,
                                                  padding: EdgeInsets.only(
                                                      left: 14, right: 14),
                                                ),

                                                // validator: (value) {
                                                //   if (value == null || value.isEmpty) {
                                                //     return 'Please select an option';
                                                //   }
                                                //   return null;
                                                // },
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
                                    )
                                  : Container(),
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          const Text('Category ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          // FormField<String>(
                          //   validator: (value) {
                          //     if (_selectedCategory == null ||
                          //         _selectedCategory!.isEmpty) {
                          //       return 'Please select a category';
                          //     }
                          //     return null;
                          //   },
                          //   builder: (FormFieldState<String> state) {
                          //     return Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         DropdownButtonHideUnderline(
                          //           child: DropdownButton2<String>(
                          //             isExpanded: true,
                          //             hint: const Text('Select Category'),
                          //             value: _selectedCategory,
                          //             items: _category.map((method) {
                          //               return DropdownMenuItem<String>(
                          //                 value: method,
                          //                 child: Text(method),
                          //               );
                          //             }).toList(),
                          //             onChanged: (String? newValue) {
                          //               setState(() {
                          //                 _selectedCategory = newValue;
                          //                 _showTextField =
                          //                     _selectedCategory == 'Other';
                          //                 state.didChange(newValue);
                          //               });
                          //               print(
                          //                   'Selected category: $_selectedCategory');
                          //               state.reset();
                          //               // Notify FormField of value change
                          //             },
                          //             buttonStyleData: ButtonStyleData(
                          //               height: 45,
                          //               padding: const EdgeInsets.only(
                          //                   left: 14, right: 14),
                          //               decoration: BoxDecoration(
                          //                 borderRadius:
                          //                     BorderRadius.circular(6),
                          //                 color: Colors.white,
                          //               ),
                          //               elevation: 2,
                          //             ),
                          //             iconStyleData: const IconStyleData(
                          //               icon: Icon(Icons.arrow_drop_down),
                          //               iconSize: 24,
                          //               iconEnabledColor: Color(0xFFb0b6c3),
                          //               iconDisabledColor: Colors.grey,
                          //             ),
                          //             dropdownStyleData: DropdownStyleData(
                          //               decoration: BoxDecoration(
                          //                 borderRadius:
                          //                     BorderRadius.circular(6),
                          //                 color: Colors.white,
                          //               ),
                          //               scrollbarTheme: ScrollbarThemeData(
                          //                 radius: const Radius.circular(6),
                          //                 thickness:
                          //                     MaterialStateProperty.all(6),
                          //                 thumbVisibility:
                          //                     MaterialStateProperty.all(true),
                          //               ),
                          //             ),
                          //             menuItemStyleData:
                          //                 const MenuItemStyleData(
                          //               height: 50,
                          //               padding: EdgeInsets.only(
                          //                   left: 14, right: 14),
                          //             ),
                          //           ),
                          //         ),
                          //         if (state.hasError)
                          //           Padding(
                          //             padding: const EdgeInsets.only(
                          //                 left: 14, top: 8),
                          //             child: Text(
                          //               state.errorText!,
                          //               style: const TextStyle(
                          //                 color: Colors.red,
                          //                 fontSize: 12,
                          //               ),
                          //             ),
                          //           ),
                          //       ],
                          //     );
                          //   },
                          // ),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonHideUnderline(
                              child: Builder(
                              builder: (context) {
                                if (_dropdownCategories.isNotEmpty) {
                                }

                                return DropdownButton2<allcategories_model>(
                                  key: ValueKey(
                                      'category_dropdown_${_dropdownCategories.length}'),
                                  isExpanded: true,
                                  hint: Text(_isLoadingCategories
                                      ? 'Select here'
                                      : _dropdownCategories.isEmpty
                                          ? 'Select here'
                                          : 'Select here',style: TextStyle(fontSize: 14, color: Color(0xFFb0b6c3),fontWeight: FontWeight.w400),),
                                  value: _selectedDropdownCategory != null &&
                                          _dropdownCategories.any((cat) =>
                                              cat.categoryId ==
                                              _selectedDropdownCategory
                                                  ?.categoryId)
                                      ? _selectedDropdownCategory
                                      : null,
                                  items: _dropdownCategories.isEmpty
                                      ? []
                                      : _dropdownCategories.map((cat) {
                                          return DropdownMenuItem<
                                              allcategories_model>(
                                            value: cat,
                                            child: Text(cat.name ?? ''),
                                          );
                                        }).toList(),
                                  onChanged: _isLoadingCategories
                                      ? null // disables dropdown while loading
                                      : (allcategories_model? newValue) {
                                          setState(() {
                                            _selectedDropdownCategory =
                                                newValue;
                                            _showTextField =
                                                newValue?.name == 'Other';
                                          });
                                        },
                                  buttonStyleData: ButtonStyleData(
                                    height: 45,
                                    padding: const EdgeInsets.only(
                                         right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFCED4DA),
                                        width: 1.5,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    iconEnabledColor: Color(0xFFb0b6c3),
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.white,
                                    ),
                                    offset: const Offset(0, -5),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(6),
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
                                );
                              },
                            ),
                          ),
                          ),
                          _showTextField
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: buildTextField('Other Category',
                                      'Enter Other Category', other),
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Assigned To *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 2,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormField<String>(
                                validator: (value) {
                                  if (_selectedstaffId == null ||
                                      _selectedstaffId!.isEmpty) {
                                    return 'Please select a staff member';
                                  }
                                  return null;
                                },
                                builder: (FormFieldState<String> state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField2<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          isExpanded: true,
                                          hint: const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Select here',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFb0b6c3),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items: (staffs.keys.toList()
                                                ..sort((a, b) => (staffs[a] ??
                                                        '')
                                                    .toLowerCase()
                                                    .compareTo((staffs[b] ?? '')
                                                        .toLowerCase())))
                                              .map((staffmember_id) {
                                            return DropdownMenuItem<String>(
                                              value: staffmember_id,
                                              child: Text(
                                                staffs[staffmember_id]!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          value: _selectedstaffId,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedstaffId = value;
                                              _selectedStaffs = staffs[value];
                                              StaffId = value.toString();
                                              state.didChange(value);
                                            });
                                            state.reset();
                                            // Notify form field of the change
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: const Color(0xFFCED4DA),
                                                width: 1.5,
                                              ),
                                            ),
                                            elevation: 0,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(Icons.arrow_drop_down),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 300,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            offset: const Offset(0, -5),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness:
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
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
                            height: 10,
                          ),
                          const Text('Entry Allowed ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text('Select here',style: TextStyle(fontSize: 14, color: Color(0xFFb0b6c3),fontWeight: FontWeight.w400),),
                              value: _selectedEntry,
                              items: _entry.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedEntry = newValue;
                                  //_selectedPaymentMethod = addRow();
                                  // if(_selectedCategory == 'Other')
                                  // addRow();
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                padding:
                                    const EdgeInsets.only(right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFCED4DA),
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                ),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                offset: const Offset(0, -5),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
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
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Vendor ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 2,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormField<String>(
                                validator: (value) {
                                  if (_selectedvendorsId == null ||
                                      _selectedvendorsId!.isEmpty) {
                                    return 'Please select a vendor';
                                  }
                                  return null;
                                },
                                builder: (FormFieldState<String> state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField2<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          isExpanded: true,
                                          hint: const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Select here',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFb0b6c3),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items: vendors.keys.map((vender_id) {
                                            return DropdownMenuItem<String>(
                                              value: vender_id,
                                              child: Text(
                                                vendors[vender_id]!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          value: _selectedvendorsId,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedvendorsId = value;
                                              _selectedVendors = vendors[value];
                                              vendorId = value.toString();
                                              _loadUnits(value!);
                                              state.didChange(
                                                  value); // Fetch units for the selected vendor
                                            });
                                            state.reset();
                                            // Notify form field of the change
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: const Color(0xFFCED4DA),
                                                width: 1.5,
                                              ),
                                            ),
                                            elevation: 0,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(Icons.arrow_drop_down),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 300,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            offset: const Offset(0, -5),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness:
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 40,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                          // validator: (value) {
                                          //   if (value == null || value.isEmpty) {
                                          //     return 'Please select a vendor';
                                          //   }
                                          //   return null;
                                          // },
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
                            height: 10,
                          ),
                          const Text('Work To Be Performed',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Enter here',
                            controller: perform,
                            optional: true,
                            showElevation: false,
                            borderColor: const Color(0xFFCED4DA),
                            borderWidth: 1.5,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('Parts and Labor :',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                          ...partsAndLabor.asMap().entries.map((entry) {
                            int index = entry.key;
                            return buildRow(index);
                          }).toList(),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      addRow();
                                    },
                                    child: Text(
                                      ' +   Add Row',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    )),
                              ),
                              Expanded(
                                child: Container(
                                  child: Row(
                                    children: [
                                      // SizedBox(width: 10),
                                      const Text('Total :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            '\$${totalAmount.toStringAsFixed(2)}'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // ElevatedButton(
                          //   onPressed: addRow,
                          //   style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.white),
                          //   child:  Text('Add Row',style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),),
                          // ),

                          const SizedBox(
                            height: 15,
                          ),
                          const Text('Vendor Notes ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Enter here',
                            controller: vendornote,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please enter the note here';
                              }
                              return null;
                            },
                            optional: true,
                            showElevation: false,
                            borderColor: const Color(0xFFCED4DA),
                            borderWidth: 1.5,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 24.0, // Standard width for checkbox
                                height: 24.0,
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value ?? false;
                                    });
                                  },
                                  activeColor:
                                      isChecked ? blueColor : Colors.black,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Billable To Tenant",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF101828)),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (isChecked)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _isLoadingtenant
                                    ? const Center(
                                        child: SpinKitFadingCircle(
                                          color: Colors.black,
                                          size: 50.0,
                                        ),
                                      )
                                    : tenants.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Tenant',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField2<
                                                    String>(
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none),
                                                  isExpanded: true,
                                                  hint: const Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Select Tenant',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFFb0b6c3),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  items: tenants.keys
                                                      .map((tenantId) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: tenantId,
                                                      child: Text(
                                                        tenants[tenantId]!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value: _selectedtenantId,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      tenantId =
                                                          value.toString();
                                                      _selectedtenantId = value;
                                                      _selectedTenants = tenants[
                                                          value]; // Store selected tenant name
                                                    });
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 45,
                                                    width: 160,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xFFCED4DA),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                        Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    iconEnabledColor:
                                                        Color(0xFFb0b6c3),
                                                    iconDisabledColor:
                                                        Colors.grey,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    maxHeight: 300,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    offset: const Offset(0, -5),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              6),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please select an option';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                              ],
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Row(
                            children: [
                              Text(
                                "Priority",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF101828)),
                              ),
                            ],
                          ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     ListTile(
                          //       title: const Text(' High'),
                          //       leading: Radio<String>(
                          //         value: 'High ',
                          //         groupValue: _selectedOption,
                          //         onChanged: _handleRadioValueChange,
                          //       ),
                          //     ),
                          //     ListTile(
                          //       title: const Text(' Normal'),
                          //       leading: Radio<String>(
                          //         value: 'Normal',
                          //         groupValue: _selectedOption,
                          //         onChanged: _handleRadioValueChange,
                          //       ),
                          //     ),
                          //     ListTile(
                          //       title: const Text(' Low'),
                          //       leading: Radio<String>(
                          //         value: 'Low ',
                          //         groupValue: _selectedOption,
                          //         onChanged: _handleRadioValueChange,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /*  Expanded(
                                    child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                      title: const Text(' High'),
                                      leading: Radio<String>(
                                        value: 'High',
                                        groupValue: _selectedOption,
                                        onChanged: _handleRadioValueChange,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text(' Normal'),
                                      leading: Radio<String>(
                                        value: 'Normal',
                                        groupValue: _selectedOption,
                                        onChanged: _handleRadioValueChange,
                                      ),
                                    ),
                                  ),*/
                              Row(
                                children: [
                                  Container(
                                    width: 25,
                                    child: Radio<String>(
                                      value: 'High',
                                      groupValue: _selectedOption,
                                      onChanged: _handleRadioValueChange,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(' High')
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 25,
                                    child: Radio<String>(
                                      value: 'Normal',
                                      groupValue: _selectedOption,
                                      onChanged: _handleRadioValueChange,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(' Normal')
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 25,
                                    child: Radio<String>(
                                      value: 'Low',
                                      groupValue: _selectedOption,
                                      onChanged: _handleRadioValueChange,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(' Low')
                                ],
                              )
                              /* ListTile(

                                    tileColor: Colors.amber,
                                    contentPadding: EdgeInsets.only(left:5),
                                    title: Container(
                                    color: Colors.cyan,
                                      child: const Text(' Low')),
                                    leading: Container(
                                      color: Colors.grey,
                                      width: 25,
                                      child: Radio<String>(
                                        value: 'Low',
                                        groupValue: _selectedOption,
                                        onChanged: _handleRadioValueChange,
                                      ),
                                    ),
                                  ),*/
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Status *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          FormField<String>(
                            validator: (value) {
                              if (_selectedStatus == null ||
                                  _selectedStatus!.isEmpty) {
                                return 'Please select a status';
                              }
                              return null;
                            },
                            builder: (FormFieldState<String> state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: const Text('New',style: TextStyle(fontSize: 14, color: Color(0xFFb0b6c3),fontWeight: FontWeight.w400),),
                                      value: _selectedStatus,
                                      items: _status.map((method) {
                                        return DropdownMenuItem<String>(
                                          value: method,
                                          child: Text(method),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedStatus = newValue;
                                          state.didChange(newValue);
                                        });
                                        state.reset();
                                        // Notify form field of the change
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 45,
                                        padding: const EdgeInsets.only(
                                             right: 14),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFFCED4DA),
                                            width: 1.5,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      iconStyleData: const IconStyleData(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                        iconSize: 24,
                                        iconEnabledColor: Color(0xFFb0b6c3),
                                        iconDisabledColor: Colors.grey,
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        maxHeight: 300,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: Colors.white,
                                        ),
                                        offset: const Offset(0, -5),
                                        scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(6),
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
                          const SizedBox(
                            height: 15,
                          ),
                          const Text('Due Date',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                // boxShadow: [
                                //   const BoxShadow(
                                //     color: Colors.black26,
                                //     offset: Offset(1.0,
                                //         1.0), // Shadow offset to the bottom right
                                //     blurRadius:
                                //     8.0, // How much to blur the shadow
                                //     spreadRadius:
                                //     0.0, // How much the shadow should spread
                                //   ),
                                // ],
                                border: Border.all(
                                  width: 0,
                                  color: Color(0xFFCED4DA),
                                ),
                                borderRadius: BorderRadius.circular(6.0)),
                            child: TextFormField(
                              style: const TextStyle(
                                color: Color(0xFF8898aa), // Text color
                                fontSize: 16.0, // Text size
                                fontWeight: FontWeight.w400, // Text weight
                              ),
                              controller: _dateController,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Color(0xFFb0b6c3)),
                                border: InputBorder.none,
                                // labelText: 'Select Date',
                                hintText: Provider.of<DateProvider>(context)
                                    .dateFormat,
                                suffixIcon: ClearableDateSuffix(
                                  controller: _dateController,
                                  onPick: () => _selectDate(context),
                                  icon: Icons.calendar_today,
                                ),
                              ),
                              readOnly: true,
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                            height: 50,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: const Color(0xFFCED4DA),
                                )),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFffffff),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ))),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          // width: 160,
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
                            onPressed: _submitForm,
                            child: isloading
                                ? const Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 55.0,
                                    ),
                                  )
                                : const Text(
                                    'Add Work Order',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
      ),
    );
  }

  Widget buildTextField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8.0),
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: FocusNode(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isloading = false;
  bool formValid = true;

  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      String? rentalId = _selectedPropertyId;
      String? unitId = _selectedUnitId;
      String? finalVendorId = _selectedvendorsId ?? vendorId;
      String? finalTenantId = _selectedtenantId ?? tenantId;

      List<Map<String, dynamic>> parts = partsAndLabor.map((part) {
        return {
          "parts_quantity": int.tryParse(part['qtyController'].text) ?? 0,
          "account": part['selectedAccount'],
          "description": part['descriptionController'].text,
          "charge_type": "Workorder Charge",
          "parts_price": double.tryParse(part['priceController'].text) ?? 0.0,
          "amount": double.tryParse(part['totalController'].text) ?? 0.0,
        };
      }).toList();
      try {
        // Use dynamic category dropdown values
        String? categoryName =
            _selectedDropdownCategory?.name ?? _selectedCategory;
        String? categoryId = _selectedDropdownCategory?.categoryId;
        if (categoryId == null || categoryId.isEmpty) categoryId = null;
        final workorder = await WorkOrderRepository()
            .addWorkOrder(
          adminId: id,
          workSubject: subject.text,
          staffMemberName: _selectedstaffId,
          workCategory: categoryName,
          categoryId: categoryId,
          workPerformed: perform.text,
          status: _selectedStatus,
          rentalAddress: properties[_selectedPropertyId],
          rentalUnit: units[_selectedUnitId],
          tenant: finalTenantId,
          rentalid: rentalId,
          unitid: unitId,
          workOrderImages: _uploadedFileNames,
          vendorId: finalVendorId,
          vendorNotes: vendornote.text,
          priority: _selectedOption,
          isBillable: isChecked,
          workChargeTo: isChecked == 'Tenants',
          date: reverseFormatDate(_dateController.text),
          entry: _selectedEntry == 'yes',
          parts: parts,
          notificationTime:
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        )
            .then((value) {
          if (mounted) Navigator.pop(context, true);
        });
        // Fluttertoast.showToast(
        //     msg: "Work order added successfully",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.green,
        //     textColor: Colors.white,
        //     fontSize: 16.0
        // );
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Failed to add work order: ${friendlyErrorMessage(e)}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        logError(e);
      } finally {
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
      }
    } else {
      setState(() {
        formValid = false;
      });
    }
  }
}

class AddWorkOrderForTablet extends StatefulWidget {
  String? rentalid;
  AddWorkOrderForTablet({super.key, this.rentalid});
  @override
  State<AddWorkOrderForTablet> createState() => _AddWorkOrderForTabletState();
}

class _AddWorkOrderForTabletState extends State<AddWorkOrderForTablet> {
  final TextEditingController subject = TextEditingController();

  final TextEditingController other = TextEditingController();

  final TextEditingController perform = TextEditingController();
  final TextEditingController vendornote = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;

  bool _isLoading = false;
  bool _isLoadingvendors = false;
  bool _isLoadingstaff = false;
  bool _isLoadingtenant = false;
  bool _Loading = false;
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {}; // Mapping of unit_id to rental_unit
  String? _selectedPropertyId;
  String? _selectedProperty;
  String? _selectedUnitId;
  String? _selectedUnit;

  //for vendor
  Map<String, String> vendors = {};
  String? _selectedvendorsId;
  String? _selectedVendors;

  //for Staffmember
  Map<String, String> staffs = {};
  String? _selectedstaffId;
  String? _selectedStaffs;
  //for tenants
  Map<String, String> tenants = {};
  String? _selectedtenantId;
  String? _selectedTenants;

  @override
  void dispose() {
    subject.dispose();
    other.dispose();
    perform.dispose();
    vendornote.dispose();
    _dateController.dispose();
    for (final row in partsAndLabor) {
      (row['qtyController'] as TextEditingController?)?.dispose();
      (row['accountController'] as TextEditingController?)?.dispose();
      (row['descriptionController'] as TextEditingController?)?.dispose();
      (row['priceController'] as TextEditingController?)?.dispose();
      (row['totalController'] as TextEditingController?)?.dispose();
      (row['subtotalcontroller'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _loadProperties();
    _loadVendor();
    _loadStaff();
    // _loadTenant();
    _selectedPropertyId = widget.rentalid;
  }

  Future<void> _loadProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/rentals/rentals/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> addresses = {};
        jsonResponse.forEach((data) {
          addresses[data['rental_id'].toString()] =
              data['rental_adress'].toString();
        });

        setState(() {
          properties = addresses;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch properties: ${friendlyErrorMessage(e)}')),
      );
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
      // Clear units and selection when loading new units
      units = {};
      _selectedUnitId = null;
      _selectedUnit = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};

        // Filter out any null or empty unit names
        for (var data in jsonResponse) {
          String unitId = data['unit_id']?.toString() ?? '';
          String unitName = data['rental_unit']?.toString() ?? '';

          if (unitId.isNotEmpty && unitName.trim().isNotEmpty) {
            unitAddresses[unitId] = unitName.trim();
          }
        }


        setState(() {
          units = unitAddresses;
          _isLoading = false;

          // Only keep the selected unit if it exists in the new units
          if (_selectedUnitId != null && !units.containsKey(_selectedUnitId)) {
            _selectedUnitId = null;
          }
        });

        // Load tenant data if we have a valid unit selected
        if (_selectedUnitId != null && units.containsKey(_selectedUnitId)) {
          _loadTenant(rentalId, _selectedUnitId!);
        }
      } else {
        setState(() {
          units = {};
          _selectedUnitId = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      logError('Error loading units: $e');
      setState(() {
        units = {};
        _selectedUnitId = null;
        _isLoading = false;
      });
    }
  }

  //for vendor
  Future<void> _loadVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingvendors = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/vendor/vendors/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> names = {};
        jsonResponse.forEach((data) {
          names[data['vendor_id'].toString()] = data['vendor_name'].toString();
        });

        setState(() {
          vendors = names;
          _isLoadingvendors = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingvendors = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: ${friendlyErrorMessage(e)}')),
      );
    }
  }

  Future<void> _loadStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await apiGet(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });

      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> staffnames = {};
        jsonResponse.forEach((data) {
          staffnames[data['staffmember_id'].toString()] =
              data['staffmember_name'].toString();
        });

        setState(() {
          staffs = staffnames;
          _isLoadingstaff = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingstaff = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: ${friendlyErrorMessage(e)}')),
      );
    }
  }

  Future<void> _loadTenant(String rentalId, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingtenant = true;
    });
    try {
      final response = await apiGet(
          Uri.parse('${Api_url}/api/leases/get_tenants/$rentalId/$unitId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      if (!mounted) return;
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> tenantsnames = {};
        jsonResponse.forEach((data) {
          tenantsnames[data['tenant_id'].toString()] =
              data['tenant_firstName'].toString() +
                  " " +
                  data['tenant_lastName'].toString();
        });
        setState(() {
          tenants = tenantsnames;
          _isLoadingtenant = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingtenant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tenants: ${friendlyErrorMessage(e)}')),
      );
    }
  }

  String? _selectedCategory;
  final List<String> _category = [
    'Complaint',
    'Contribution Request',
    'Feedback/Suggestion',
    'General Inquiry',
    'Maintenance Request',
    'Other'
  ];
  String? _selectedEntry;
  final List<String> _entry = [
    'Yes',
    'No',
  ];
  String? _selectedStatus = "New";
  final List<String> _status = [
    'Closed',
    'Completed',
    'In Progress',
    'New',
    'On Hold',
    'Pending'
  ];
  final List<String> _account = [
    'Advertising',
    'Association Fees',
    'Bank Fees',
    'Auto and Travel',
    'Cleaning and Maintenance',
    'Commissions',
    'Depreciation Expense',
    'Insurance',
    'Legal and Professional Fees',
    'Licenses and Permits',
    'Management Fees',
    'Mortgage Interest',
    'Other Expenses',
    'Other Interest Expenses',
    'Postage and Delivery',
    'Repairs',
  ];
  List<Map<String, dynamic>> rows = [];
  bool _showTextField = false;
  String renderId = '';
  String unitId = '';
  String vendorId = '';
  String StaffId = '';
  String tenantId = '';
  bool isChecked = false;
  //for parts and lebours
  List<Map<String, dynamic>> partsAndLabor = [];

  void addRow() {
    setState(() {
      TextEditingController qtyController = TextEditingController();
      TextEditingController priceController = TextEditingController();
      TextEditingController totalController = TextEditingController();
      TextEditingController subtotalcontroller = TextEditingController();

      qtyController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });
      priceController.addListener(() {
        calculateTotal(qtyController, priceController, totalController,
            subtotalcontroller);
      });

      partsAndLabor.add({
        'qtyController': qtyController,
        'accountController': TextEditingController(),
        'descriptionController': TextEditingController(),
        'priceController': priceController,
        'totalController': totalController,
        'subtotalcontroller': subtotalcontroller,
        'selectedAccount': null,
      });
    });
  }

  void deleteRow(int index) {
    setState(() {
      final row = partsAndLabor[index];
      (row['qtyController'] as TextEditingController?)?.dispose();
      (row['accountController'] as TextEditingController?)?.dispose();
      (row['descriptionController'] as TextEditingController?)?.dispose();
      (row['priceController'] as TextEditingController?)?.dispose();
      (row['totalController'] as TextEditingController?)?.dispose();
      (row['subtotalcontroller'] as TextEditingController?)?.dispose();
      partsAndLabor.removeAt(index);
      updateTotalAmount();
    });
  }

  void calculateTotal(
      TextEditingController qtyController,
      TextEditingController priceController,
      TextEditingController totalController,
      TextEditingController subtotalcontroller) {
    double quantity = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    double total = quantity * price;
    totalController.text = total.toStringAsFixed(2);
    double subtotal = total += total;
    subtotalcontroller.text = subtotal.toStringAsFixed(2);
    updateTotalAmount();
  }

  double totalAmount = 0.0;
  void updateTotalAmount() {
    double total = 0.0;
    for (var item in partsAndLabor) {
      double itemTotal = double.tryParse(item['totalController'].text) ?? 0;
      total += itemTotal;
    }
    setState(() {
      totalAmount = total;
    });
  }

  Widget buildRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                deleteRow(index);
              },
            ),
          ),
          const Text(
            "Quantity",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Quantity',
            controller: partsAndLabor[index]['qtyController'],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          const Text(
            "Account",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: const Text('Select'),
              value: partsAndLabor[index]['selectedAccount'],
              items: _account.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  partsAndLabor[index]['selectedAccount'] = newValue;
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 45,
                width: 200,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFCED4DA),
                    width: 1.5,
                  ),
                ),
                elevation: 0,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                ),
                iconSize: 24,
                iconEnabledColor: Color(0xFFb0b6c3),
                iconDisabledColor: Colors.grey,
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(6),
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
          const SizedBox(height: 10),
          const Text(
            "Description",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Description',
            controller: partsAndLabor[index]['descriptionController'],
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          const Text(
            "Price",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Price',
            controller: partsAndLabor[index]['priceController'],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          const Text(
            "Total",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101828)),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Total',
            controller: partsAndLabor[index]['totalController'],
            keyboardType: TextInputType.number,
            readOnnly: true,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _selectedOption = 'button 1';

  void _handleRadioValueChange(String? value) {
    setState(() {
      _selectedOption = value!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    // Due Date is optional here (no validator, empty submits as ""), so the
    // picker offers Clear the way the web date input does.
    final result = await showClearableDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Due date cannot be earlier than today
      lastDate: DateTime(2101),
      helpText: 'Select due date',
    );

    if (result == null) return; // cancelled: keep the old value
    if (result.cleared) {
      setState(() => _dateController.clear());
      return;
    }

    final DateTime selectedDate = result.date!;
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    setState(() {
      _dateController.text =
          DateFormat(dateProvider.dateFormat).format(selectedDate);
    });
  }

  File? _image;
  List<File> _images = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  Future<String?> uploadImage(File imageFile) async {
    final String uploadUrl = '${image_upload_url}/api/images/upload';
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await apiSend(request);
    var responseData = await http.Response.fromStream(response);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Select Image From',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Options Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Option
                    _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImageFromSource(ImageSource.gallery);
                      },
                    ),

                    const SizedBox(width: 20),

                    // Camera Option
                    _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.of(context).pop();
                        _openCameraInterface();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build individual source option
  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: blueColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from specific source
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickMedia();

      if (image != null) {
        setState(() {
          _image = File(image.path);
          _images.add(File(image.path));
        });
        _uploadImage(File(image.path));
      }
    } catch (e) {
      logError('Image upload failed: $e');
    }
  }

  // Open unified camera interface for both photos and videos
  Future<void> _openCameraInterface() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorDialog('No cameras found on this device');
        return;
      }

      // Use the first available camera (usually back camera)
      final camera = cameras.first;

      // Navigate to camera screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraCaptureScreen(
            camera: camera,
            onImageCaptured: (File imageFile) {
              // Handle captured image
              setState(() {
                _image = File(imageFile.path);
                _images.add(imageFile);
              });
              _uploadImage(imageFile);
            },
            onVideoCaptured: (File videoFile) async {
              // Handle captured video
              String? thumbnailPath =
                  await _generateVideoThumbnail(videoFile.path);
              if (thumbnailPath != null) {
                setState(() {
                  _images.add(File(thumbnailPath));
                });
              }
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog('Failed to open camera: $e');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    final String? thumbPath =
        await video_thumbnail.VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: video_thumbnail.ImageFormat.PNG,
      maxHeight: 80,
      quality: 50,
    );
    return thumbPath;
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
      });
    } catch (e) {
      logError('Image upload failed: $e');
    }
  }

  void _showImageDialog(
      File imageFile, int imageIndex, File? originalFile, bool isVideo) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.blue[800]!, width: 1),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.blue[800],
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Image with rounded corners and camera icon overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        height: 300,
                        width: 300,
                      ),
                    ),
                    // Camera icon overlay
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image = await _picker.pickMedia();

                          if (image != null) {
                            final File newFile = File(image.path);
                            bool isNewVideo = image.path.endsWith('.mp4') ||
                                image.path.endsWith('.mov');

                            if (isNewVideo) {
                              String? thumbnailPath =
                                  await _generateVideoThumbnail(image.path);
                              if (thumbnailPath != null) {
                                // Update the preview with new image
                                Navigator.of(context).pop();
                                _showImageDialog(File(thumbnailPath),
                                    imageIndex, newFile, true);
                              }
                            } else {
                              // Update the preview with new image
                              Navigator.of(context).pop();
                              _showImageDialog(
                                  newFile, imageIndex, newFile, false);
                            }
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[800],
                        side: BorderSide(color: Colors.blue[800]!, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Update the existing image in the list
                        setState(() {
                          _images[imageIndex] = imageFile;
                        });

                        // Upload the new image
                        try {
                          String? fileName =
                              await uploadImage(originalFile ?? imageFile);
                          if (fileName != null &&
                              imageIndex < _uploadedFileNames.length) {
                            setState(() {
                              _uploadedFileNames[imageIndex] = fileName;
                            });
                          }
                        } catch (e) {
                          logError('Image upload failed: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateImageAtIndex(int index) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickMedia();

    if (image != null) {
      final File file = File(image.path);
      bool isVideo = image.path.endsWith('.mp4') || image.path.endsWith('.mov');

      // Show preview dialog first
      if (isVideo) {
        String? thumbnailPath = await _generateVideoThumbnail(image.path);
        if (thumbnailPath != null) {
          _showImageDialog(File(thumbnailPath), index, file, true);
        }
      } else {
        _showImageDialog(file, index, file, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Work Orders",
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
                const SizedBox(
                  height: 25,
                ),
                titleBar(
                  width: MediaQuery.of(context).size.width * .91,
                  title: 'Add Work Order',
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35),
                  child: Container(
                    width: double.infinity,
                    // height: !form_valid ? 860 : 830,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 103, 1),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Subject *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Add subject',
                            controller: subject,
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
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Photo ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 40,
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
                              onPressed: () async {
                                _showImageSourceDialog();
                              },
                              child: isLoading
                                  ? const Center(
                                      child: SpinKitFadingCircle(
                                        color: Colors.white,
                                        size: 55.0,
                                      ),
                                    )
                                  : const Text(
                                      'Upload here',
                                      style:
                                          TextStyle(color: Color(0xFFf7f8f9)),
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _images.isNotEmpty
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        //color: Colors.blue,
                                        child: Wrap(
                                          spacing:
                                              8.0, // Horizontal spacing between items
                                          runSpacing:
                                              8.0, // Vertical spacing between rows
                                          children: List.generate(
                                            _images.length,
                                            (index) {
                                              return Container(
                                                // color: Colors.green,
                                                width: 85,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 60,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _images.removeAt(
                                                                  index);
                                                            });
                                                          },
                                                          child: const Icon(
                                                            Icons.close,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            _showImageDialog(
                                                                _images[index],
                                                                index,
                                                                _images[index],
                                                                false);
                                                          },
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Image.file(
                                                                _images[index],
                                                                height: 80,
                                                                width: 80,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              Positioned(
                                                                top: 5,
                                                                right: 5,
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .black54,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .visibility,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Text("No images selected."),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Property *',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF101828))),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FormField<String>(
                                          validator: (value) {
                                            if (_selectedPropertyId == null) {
                                              return 'Please select an option';
                                            }
                                            return null;
                                          },
                                          builder:
                                              (FormFieldState<String> state) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButtonFormField2<
                                                          String>(
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      errorText: state
                                                          .errorText, // Show validation error text
                                                    ),
                                                    isExpanded: true,
                                                    hint: const Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'Select Property',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color(
                                                                  0xFFb0b6c3),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    items: properties.keys
                                                        .map((rentalId) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: rentalId,
                                                        child: Text(
                                                          properties[rentalId]!,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    }).toList(),
                                                    value: _selectedPropertyId,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedUnitId = null;
                                                        _selectedPropertyId =
                                                            value;
                                                        _selectedProperty =
                                                            properties[value];
                                                        renderId =
                                                            value.toString();
                                                        if (value != null) {
                                                          units =
                                                              {}; // Clear existing units
                                                          _loadUnits(value);
                                                        }
                                                        state.didChange(value);
                                                      });
                                                      state.reset();
                                                    },
                                                    buttonStyleData:
                                                        ButtonStyleData(
                                                      height: 45,
                                                      width: 160,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 14,
                                                              right: 14),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.white,
                                                      ),
                                                      elevation: 2,
                                                    ),
                                                    iconStyleData:
                                                        const IconStyleData(
                                                      icon: Icon(
                                                        Icons.arrow_drop_down,
                                                      ),
                                                      iconSize: 24,
                                                      iconEnabledColor:
                                                          Color(0xFFb0b6c3),
                                                      iconDisabledColor:
                                                          Colors.grey,
                                                    ),
                                                    dropdownStyleData:
                                                        DropdownStyleData(
                                                      maxHeight: 300,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.white,
                                                      ),
                                                      offset:
                                                          const Offset(0, -5),
                                                      scrollbarTheme:
                                                          ScrollbarThemeData(
                                                        radius: const Radius
                                                            .circular(6),
                                                        thickness:
                                                            MaterialStateProperty
                                                                .all(6),
                                                        thumbVisibility:
                                                            MaterialStateProperty
                                                                .all(true),
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
                                                    padding:
                                                        const EdgeInsets.only(
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
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    units.isNotEmpty
                                        ? const Text('Unit',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828)))
                                        : Container(),
                                    const SizedBox(height: 0),
                                    units.isNotEmpty
                                        ? FormField<String>(
                                            validator: (value) {
                                              if (_selectedUnitId == null) {
                                                return 'Please select an option';
                                              }
                                              return null;
                                            },
                                            builder:
                                                (FormFieldState<String> state) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButtonFormField2<
                                                            String>(
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      isExpanded: true,
                                                      hint: const Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'Select Unit',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFFb0b6c3),
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      items: units.keys
                                                          .map((unitId) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: unitId,
                                                          child: Text(
                                                            units[unitId]!,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        );
                                                      }).toList(),
                                                      value: _selectedUnitId,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          unitId =
                                                              value.toString();
                                                          _selectedUnitId =
                                                              value;
                                                          _selectedUnit = units[
                                                              value]; // Store selected rental_unit
                                                          _loadTenant(
                                                              _selectedPropertyId!,
                                                              unitId);
                                                          state.didChange(
                                                              value); // Notify FormField of change
                                                        });
                                                        state.reset();
                                                      },
                                                      buttonStyleData:
                                                          ButtonStyleData(
                                                        height: 45,
                                                        width: 160,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 14,
                                                                right: 14),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          color: Colors.white,
                                                        ),
                                                        elevation: 2,
                                                      ),
                                                      iconStyleData:
                                                          const IconStyleData(
                                                        icon: Icon(Icons
                                                            .arrow_drop_down),
                                                        iconSize: 24,
                                                        iconEnabledColor:
                                                            Color(0xFFb0b6c3),
                                                        iconDisabledColor:
                                                            Colors.grey,
                                                      ),
                                                      dropdownStyleData:
                                                          DropdownStyleData(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          color: Colors.white,
                                                        ),
                                                        scrollbarTheme:
                                                            ScrollbarThemeData(
                                                          radius: const Radius
                                                              .circular(6),
                                                          thickness:
                                                              MaterialStateProperty
                                                                  .all(6),
                                                          thumbVisibility:
                                                              MaterialStateProperty
                                                                  .all(true),
                                                        ),
                                                      ),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                        height: 40,
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 14,
                                                                right: 14),
                                                      ),
                                                      // validator: (value) {
                                                      //   if (value == null || value.isEmpty) {
                                                      //     return 'Please select an option';
                                                      //   }
                                                      //   return null;
                                                      // },
                                                    ),
                                                  ),
                                                  if (state.hasError)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    // FormField<String>(
                                    //   validator: (value) {
                                    //     if (_selectedCategory == null ||
                                    //         _selectedCategory!.isEmpty) {
                                    //       return 'Please select a category';
                                    //     }
                                    //     return null;
                                    //   },
                                    //   builder: (FormFieldState<String> state) {
                                    //     return Column(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //         DropdownButtonHideUnderline(
                                    //           child: DropdownButton2<String>(
                                    //             isExpanded: true,
                                    //             hint: const Text(
                                    //                 'Select Category'),
                                    //             value: _selectedCategory,
                                    //             items: _category.map((method) {
                                    //               return DropdownMenuItem<
                                    //                   String>(
                                    //                 value: method,
                                    //                 child: Text(method),
                                    //               );
                                    //             }).toList(),
                                    //             onChanged: (String? newValue) {
                                    //               setState(() {
                                    //                 _selectedCategory =
                                    //                     newValue;
                                    //                 _showTextField =
                                    //                     _selectedCategory ==
                                    //                         'Other';
                                    //                 state.didChange(newValue);
                                    //               });
                                    //               print(
                                    //                   'Selected category: $_selectedCategory');
                                    //               state.reset();
                                    //               // Notify FormField of value change
                                    //             },
                                    //             buttonStyleData:
                                    //                 ButtonStyleData(
                                    //               height: 45,
                                    //               padding:
                                    //                   const EdgeInsets.only(
                                    //                       left: 14, right: 14),
                                    //               decoration: BoxDecoration(
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(
                                    //                         6),
                                    //                 color: Colors.white,
                                    //               ),
                                    //               elevation: 2,
                                    //             ),
                                    //             iconStyleData:
                                    //                 const IconStyleData(
                                    //               icon: Icon(
                                    //                   Icons.arrow_drop_down),
                                    //               iconSize: 24,
                                    //               iconEnabledColor:
                                    //                   Color(0xFFb0b6c3),
                                    //               iconDisabledColor:
                                    //                   Colors.grey,
                                    //             ),
                                    //             dropdownStyleData:
                                    //                 DropdownStyleData(
                                    //               decoration: BoxDecoration(
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(
                                    //                         6),
                                    //                 color: Colors.white,
                                    //               ),
                                    //               scrollbarTheme:
                                    //                   ScrollbarThemeData(
                                    //                 radius:
                                    //                     const Radius.circular(
                                    //                         6),
                                    //                 thickness:
                                    //                     MaterialStateProperty
                                    //                         .all(6),
                                    //                 thumbVisibility:
                                    //                     MaterialStateProperty
                                    //                         .all(true),
                                    //               ),
                                    //             ),
                                    //             menuItemStyleData:
                                    //                 const MenuItemStyleData(
                                    //               height: 50,
                                    //               padding: EdgeInsets.only(
                                    //                   left: 14, right: 14),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //         if (state.hasError)
                                    //           Padding(
                                    //             padding: const EdgeInsets.only(
                                    //                 left: 14, top: 8),
                                    //             child: Text(
                                    //               state.errorText!,
                                    //               style: const TextStyle(
                                    //                 color: Colors.red,
                                    //                 fontSize: 12,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //       ],
                                    //     );
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Entry Allowed ',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: const Text('Select'),
                                        value: _selectedEntry,
                                        items: _entry.map((method) {
                                          return DropdownMenuItem<String>(
                                            value: method,
                                            child: Text(method),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedEntry = newValue;
                                            //_selectedPaymentMethod = addRow();
                                            // if(_selectedCategory == 'Other')
                                            // addRow();
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 45,
                                          width: 200,
                                          padding: const EdgeInsets.only(
                                              left: 14, right: 14),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: Colors.white,
                                          ),
                                          elevation: 2,
                                        ),
                                        iconStyleData: const IconStyleData(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          iconSize: 24,
                                          iconEnabledColor: Color(0xFFb0b6c3),
                                          iconDisabledColor: Colors.grey,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: Colors.white,
                                          ),
                                          scrollbarTheme: ScrollbarThemeData(
                                            radius: const Radius.circular(6),
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Assigned To *',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    _isLoadingstaff
                                        ? const Center(
                                            child: SpinKitFadingCircle(
                                              color: Colors.black,
                                              size: 50.0,
                                            ),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField2<
                                                    String>(
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none),
                                                  isExpanded: true,
                                                  hint: const Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Select here',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFFb0b6c3),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  items: (staffs.keys.toList()
                                                        ..sort((a, b) => (staffs[
                                                                    a] ??
                                                                '')
                                                            .toLowerCase()
                                                            .compareTo((staffs[
                                                                        b] ??
                                                                    '')
                                                                .toLowerCase())))
                                                      .map((staffmember_id) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: staffmember_id,
                                                      child: Text(
                                                        staffs[staffmember_id]!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value: _selectedstaffId,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      // _selectedUnitId = null;
                                                      _selectedstaffId = value;
                                                      _selectedStaffs = staffs[
                                                          value]; // Store selected rental_adress

                                                      StaffId =
                                                          value.toString();
                                                      // _loadUnits(
                                                      //     value!); // Fetch units for the selected property
                                                    });
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 45,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    iconSize: 24,
                                                    iconEnabledColor:
                                                        Color(0xFFb0b6c3),
                                                    iconDisabledColor:
                                                        Colors.grey,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    maxHeight: 250,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              6),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please select an option';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _showTextField
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: buildTextField('Other Category',
                                      'Enter Other Category', other),
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Vendors *',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF101828))),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      _isLoadingvendors
                                          ? const Center(
                                              child: SpinKitFadingCircle(
                                                color: Colors.black,
                                                size: 50.0,
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButtonFormField2<
                                                          String>(
                                                    decoration:
                                                        const InputDecoration(
                                                            border: InputBorder
                                                                .none),
                                                    isExpanded: true,
                                                    hint: const Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'Select here',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color(
                                                                  0xFFb0b6c3),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    items: vendors.keys
                                                        .map((vender_id) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: vender_id,
                                                        child: Text(
                                                          vendors[vender_id]!,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    }).toList(),
                                                    value: _selectedvendorsId,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        // _selectedUnitId = null;
                                                        _selectedvendorsId =
                                                            value;
                                                        _selectedVendors = vendors[
                                                            value]; // Store selected rental_adress

                                                        vendorId =
                                                            value.toString();
                                                        _loadUnits(
                                                            value!); // Fetch units for the selected property
                                                      });
                                                    },
                                                    buttonStyleData:
                                                        ButtonStyleData(
                                                      height: 45,
                                                      width: 160,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 14,
                                                              right: 14),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.white,
                                                      ),
                                                      elevation: 2,
                                                    ),
                                                    iconStyleData:
                                                        const IconStyleData(
                                                      icon: Icon(
                                                        Icons.arrow_drop_down,
                                                      ),
                                                      iconSize: 24,
                                                      iconEnabledColor:
                                                          Color(0xFFb0b6c3),
                                                      iconDisabledColor:
                                                          Colors.grey,
                                                    ),
                                                    dropdownStyleData:
                                                        DropdownStyleData(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.white,
                                                      ),
                                                      scrollbarTheme:
                                                          ScrollbarThemeData(
                                                        radius: const Radius
                                                            .circular(6),
                                                        thickness:
                                                            MaterialStateProperty
                                                                .all(6),
                                                        thumbVisibility:
                                                            MaterialStateProperty
                                                                .all(true),
                                                      ),
                                                    ),
                                                    menuItemStyleData:
                                                        const MenuItemStyleData(
                                                      height: 40,
                                                      padding: EdgeInsets.only(
                                                          left: 14, right: 14),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please select an option';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Work To Be Performed',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF101828))),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        hintText: 'Enter here',
                                        controller: perform,
                                        optional: true,
                                        showElevation: false,
                                        borderColor: const Color(0xFFCED4DA),
                                        borderWidth: 1.5,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35, top: 15),
                  child: Container(
                    width: double.infinity,
                    // height: !form_valid ? 860 : 830,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 103, 1),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('Parts And Labour ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Table(
                            border: TableBorder.all(width: 1),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(3),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('QTY',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Account',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Description',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Price',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Amount',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]),
                              /* ...summery.partsandchargeData!.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      PartsandchargeData row = entry.value;
                                      grandTotal += (row.partsQuantity! * row.partsPrice!);
                                      return TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:Text("${row.partsQuantity}"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:Text("${row.account}"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:Text("${row.description}"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:Text("\$${(row.partsPrice ?? 0).toStringAsFixed(2)}"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:Text("\$${(row.partsPrice! * row.partsQuantity!).toStringAsFixed(2)}"),
                                        ),
                                      ]);
                                    }).toList(),*/
                              ...partsAndLabor.asMap().entries.map((entry) {
                                int index = entry.key;
                                return TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomTextField(
                                      hintText: 'Quantity',
                                      controller: partsAndLabor[index]
                                          ['qtyController'],
                                      keyboardType: TextInputType.number,
                                      showElevation: false,
                                      borderColor: const Color(0xFFCED4DA),
                                      borderWidth: 1.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: const Text('Select'),
                                        value: partsAndLabor[index]
                                            ['selectedAccount'],
                                        items: _account.map((method) {
                                          return DropdownMenuItem<String>(
                                            value: method,
                                            child: Text(method),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            partsAndLabor[index]
                                                ['selectedAccount'] = newValue;
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 45,
                                          // width: 300,
                                          //  padding: const EdgeInsets.only(left: 14, right: 14),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: Colors.white,
                                          ),
                                          elevation: 2,
                                        ),
                                        iconStyleData: const IconStyleData(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          iconSize: 24,
                                          iconEnabledColor: Color(0xFFb0b6c3),
                                          iconDisabledColor: Colors.grey,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: Colors.white,
                                          ),
                                          scrollbarTheme: ScrollbarThemeData(
                                            radius: const Radius.circular(6),
                                            thickness:
                                                MaterialStateProperty.all(6),
                                            thumbVisibility:
                                                MaterialStateProperty.all(true),
                                          ),
                                        ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 50,
                                          padding: EdgeInsets.only(
                                              left: 14, right: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomTextField(
                                      hintText: 'Description',
                                      controller: partsAndLabor[index]
                                          ['descriptionController'],
                                      keyboardType: TextInputType.text,
                                      showElevation: false,
                                      borderColor: const Color(0xFFCED4DA),
                                      borderWidth: 1.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomTextField(
                                      hintText: 'Price',
                                      controller: partsAndLabor[index]
                                          ['priceController'],
                                      keyboardType: TextInputType.number,
                                      showElevation: false,
                                      borderColor: const Color(0xFFCED4DA),
                                      borderWidth: 1.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomTextField(
                                      hintText: 'Total',
                                      controller: partsAndLabor[index]
                                          ['totalController'],
                                      keyboardType: TextInputType.number,
                                      readOnnly: true,
                                      showElevation: false,
                                      borderColor: const Color(0xFFCED4DA),
                                      borderWidth: 1.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.black),
                                      onPressed: () {
                                        deleteRow(index);
                                      },
                                    ),
                                  ),
                                  /* Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("\$${grandTotal.toStringAsFixed(2)}",style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      ),*/

                                  /* Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              '\$${totalAmount.toStringAsFixed(2)}'),
                        ),*/
                                ]);
                              }).toList(),
                              TableRow(children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                /* const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),*/
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      '\$${totalAmount.toStringAsFixed(2)}'),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(''),
                                ),

                                /* Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              '\$${totalAmount.toStringAsFixed(2)}'),
                        ),*/
                              ]),
                              /*TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1),
                                borderRadius:
                                BorderRadius.circular(10.0)),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          10.0)),
                                  elevation: 0,
                                  backgroundColor: Colors.white),
                              onPressed: addRow,
                              child: const Text(
                                'Add Row',
                                style: TextStyle(
                                  color:
                                  blueColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox.shrink(),
                        const SizedBox.shrink(),
                      ]),*/
                            ],
                          ),
                          ElevatedButton(
                            onPressed: addRow,
                            child: const Text('Add Row'),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('Vendors Note *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Enter here',
                            controller: vendornote,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please enter the note here';
                              }
                              return null;
                            },
                            optional: true,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Billable To Tenants",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: 24.0, // Standard width for checkbox
                                height: 24.0,
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value ?? false;
                                    });
                                  },
                                  activeColor:
                                      isChecked ? blueColor : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (isChecked)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _isLoadingtenant
                                    ? const Center(
                                        child: SpinKitFadingCircle(
                                          color: Colors.black,
                                          size: 50.0,
                                        ),
                                      )
                                    : tenants.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Tenant',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField2<
                                                    String>(
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none),
                                                  isExpanded: true,
                                                  hint: const Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Select Tenant',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFFb0b6c3),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  items: tenants.keys
                                                      .map((tenantId) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: tenantId,
                                                      child: Text(
                                                        tenants[tenantId]!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value: _selectedtenantId,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      tenantId =
                                                          value.toString();
                                                      _selectedtenantId = value;
                                                      _selectedTenants = tenants[
                                                          value]; // Store selected tenant name
                                                    });
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 45,
                                                    width: 160,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                        Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    iconEnabledColor:
                                                        Color(0xFFb0b6c3),
                                                    iconDisabledColor:
                                                        Colors.grey,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              6),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please select an option';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                              ],
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Row(
                            children: [
                              Text(
                                "Priority",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: const Text(' High'),
                                leading: Radio<String>(
                                  value: 'High ',
                                  groupValue: _selectedOption,
                                  onChanged: _handleRadioValueChange,
                                ),
                              ),
                              ListTile(
                                title: const Text(' Normal'),
                                leading: Radio<String>(
                                  value: 'Normal',
                                  groupValue: _selectedOption,
                                  onChanged: _handleRadioValueChange,
                                ),
                              ),
                              ListTile(
                                title: const Text(' Low'),
                                leading: Radio<String>(
                                  value: 'Low ',
                                  groupValue: _selectedOption,
                                  onChanged: _handleRadioValueChange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Status *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text('New'),
                              value: _selectedStatus,
                              items: _status.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStatus = newValue;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                width: 200,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                ),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
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
                            height: 15,
                          ),
                          const Text('Due Date',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFCED4DA),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: TextFormField(
                              style: const TextStyle(
                                color: Color(0xFF8898aa), // Text color
                                fontSize: 16.0, // Text size
                                fontWeight: FontWeight.w400, // Text weight
                              ),
                              controller: _dateController,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Color(0xFFb0b6c3)),
                                border: InputBorder.none,
                                // labelText: 'Select Date',
                                hintText: Provider.of<DateProvider>(context)
                                    .dateFormat,
                                suffixIcon: ClearableDateSuffix(
                                  controller: _dateController,
                                  onPick: () => _selectDate(context),
                                  icon: Icons.calendar_today,
                                ),
                              ),
                              readOnly: true,
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35, top: 15),
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
                          onPressed: _submitForm,
                          child: isLoading
                              ? const Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 55.0,
                                  ),
                                )
                              : const Text(
                                  'Add Work Order',
                                  style: TextStyle(color: Color(0xFFf7f8f9)),
                                ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                          height: 50,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0))),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Color(0xFF748097)),
                              )))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8.0),
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: FocusNode(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isLoading = false;
  bool formValid = true;

  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      String? rentalId = _selectedPropertyId;
      String? unitId = _selectedUnitId;
      String? finalVendorId = _selectedvendorsId ?? vendorId;
      List<Map<String, dynamic>> parts = partsAndLabor.map((part) {
        return {
          "parts_quantity": int.tryParse(part['qtyController'].text) ?? 0,
          "account": part['selectedAccount'],
          "description": part['descriptionController'].text,
          "charge_type": "Workorder Charge",
          "parts_price": double.tryParse(part['priceController'].text) ?? 0.0,
          "amount": double.tryParse(part['totalController'].text) ?? 0.0,
        };
      }).toList();
      try {
        final workorder = await WorkOrderRepository().addWorkOrder(
          adminId: id,
          workSubject: subject.text,
          staffMemberName: _selectedStaffs,
          workCategory: _selectedCategory,
          workPerformed: perform.text,
          status: _selectedStatus,
          rentalAddress: properties[_selectedPropertyId],
          rentalUnit: units[_selectedUnitId],
          tenant: tenantId,
          rentalid: rentalId,
          unitid: unitId,
          workOrderImages: [],
          vendorId: finalVendorId,
          vendorNotes: vendornote.text,
          priority: _selectedOption,
          isBillable: isChecked,
          workChargeTo: isChecked == 'Tenants',
          //  workChargeTo: "isbillable true hoy to static tenant mokli devanu",
          date: reverseFormatDate(_dateController.text),
          entry: _selectedEntry == 'yes',
          parts: parts,
        );
        // Fluttertoast.showToast(
        //     msg: "Work order added successfully",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.green,
        //     textColor: Colors.white,
        //     fontSize: 16.0
        // );
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Failed to add work order: ${friendlyErrorMessage(e)}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        logError(e);
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        formValid = false;
      });
    }
  }
}

class VideoPlayerDialog extends StatefulWidget {
  final File videoFile;
  const VideoPlayerDialog({Key? key, required this.videoFile})
      : super(key: key);

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.file(widget.videoFile);
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior:
          Clip.none, // Allows the button to be positioned outside the container
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
              : const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
        ),
        Positioned(
          top: -50, // Moves the close button above the container
          right: 0, // Aligns it to the right
          child: IconButton(
            icon: const Icon(Icons.close,
                color: Colors.white, size: 30), // Customize as needed
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
