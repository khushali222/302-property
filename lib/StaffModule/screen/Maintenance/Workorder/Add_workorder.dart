import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:three_zero_two_property/Model/WorkOrderSetting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../Model/All_categories_model.dart';
import '../../../../constant/constant.dart';

import '../../../../repository/SettingWorkorder.dart';
import '../../../../repository/fetch_allcategories.dart';
import '../../../../repository/fetch_allcategories.dart';
import '../../../../widgets/VideoPlayerWidget.dart';
import '../../../repository/workorder.dart';
import '../../../model/properties.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../../widgets/titleBar.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_drawer.dart';
import '../../Rental/Tenants/add_tenants.dart';
import '../../../widgets/custom_drawer.dart';

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

  // Dynamic categories
  List<allcategories_model> _dropdownCategories = [];
  allcategories_model? _selectedDropdownCategory;
  bool _isLoadingCategories = false;

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
    super.dispose();
  }

  @override
  void didPopNext() {
    // Always refetch categories when returning to this screen
    _loadDropdownCategories();
    super.didPopNext();
  }

  Future<void> _loadDropdownCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final cats = await FetchAllcategories().fetchAllCategories();
      print('Fetched categories in AddWorkOrderForMobile: ' + cats.toString());
      setState(() {
        _dropdownCategories = cats;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error fetching categories in AddWorkOrderForMobile: ' +
          e.toString());
      setState(() {
        _isLoadingCategories = false;
      });
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
      print('${Api_url}/api/rentals/rentals/$id');
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
    }
  }

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
      print('${Api_url}/api/vendor/vendors/$id');

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
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/staffmember/staff_member/$id');

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

  Future<void> fetchWorkData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Data workorder = await fetchWorkOrderSettingstaff();
      String? entryAllowedString;
      if (workorder.workDefaults?.entryAllowed != null) {
        entryAllowedString =
            workorder.workDefaults!.entryAllowed! ? 'Yes' : 'No';
      }
      if (workorder != null) {
        String? fetchedCategoryId = workorder.workDefaults?.category;
        print("Fetched category_id from workDefaults: " +
            (fetchedCategoryId ?? "null"));
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
          print('vendor check ${workorder.workDefaults?.vendorId ?? ""}');
          if (fetchedCategoryId != null && _dropdownCategories.isNotEmpty) {
            final match = _dropdownCategories
                .where((cat) => cat.categoryId == fetchedCategoryId)
                .toList();
            if (match.length == 1) {
              _selectedDropdownCategory = match.first;
            } else {
              _selectedDropdownCategory = null;
            }
          } else {
            _selectedDropdownCategory = null;
          }
        });
      }
    } catch (e) {
      print('Failed to load workorder data: $e');
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
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('Loading units for rental: $rentalId');

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

        print('Found ${unitAddresses.length} valid units');

        setState(() {
          units = unitAddresses;
          _isLoading = false;

          // Only keep the selected unit if it exists in the new units
          if (_selectedUnitId != null && !units.containsKey(_selectedUnitId)) {
            print('Clearing invalid unit selection: $_selectedUnitId');
            _selectedUnitId = null;
          }
        });

        // Load tenant data if we have a valid unit selected
        if (_selectedUnitId != null && units.containsKey(_selectedUnitId)) {
          _loadTenant(rentalId, _selectedUnitId!);
        }
      } else {
        print('Failed to load units: ${response.statusCode}');
        setState(() {
          units = {};
          _selectedUnitId = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading units: $e');
      setState(() {
        units = {};
        _selectedUnitId = null;
        _isLoading = false;
      });
    }
  }

  //for vendor
  Future<void> _loadTenant(String rentalId, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");
    setState(() {
      _isLoadingtenant = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/leases/get_tenants/$rentalId/$unitId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $staffid",
          });
      print('${Api_url}/api/leases/get_tenants/$rentalId/$unitId');
      print(response.body);
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
        print(tenants);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingtenant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tenants: $e')),
      );
    }
  }

  String? _selectedCategory;
  final List<String> _category = [
    'Complaint',
    'Contribution Request',
    'Feedback/Suggestion',
    'General inquiry',
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
    'New',
    'In Progress',
    'On Hold',
    'Completed',
    'Closed'
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
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Quantity',
            controller: partsAndLabor[index]['qtyController'],
            keyboardType: TextInputType.number,
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
                print(
                    'Selected account: ${partsAndLabor[index]['selectedAccount']}');
              },
              buttonStyleData: ButtonStyleData(
                height: 45,
                // width: 200,
                padding: const EdgeInsets.only(left: 14, right: 14),
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
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
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
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: 'Price',
            controller: partsAndLabor[index]['priceController'],
            keyboardType: TextInputType.number,
            // keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
          ),
          const SizedBox(height: 10),
          const Text(
            "Total",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
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
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
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

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }
  //for tenants

  File? _image;
  List<File> _images = [];
  List<File> videofiles = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  List<bool> isvideo = [];
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Future<void> _pickImage() async {
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

      setState(() {
        _image = File(image.path);
        // _images.add(File(image.path));
      });
      _uploadImage(File(image.path));
    }
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    final String? thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
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
      print('Image upload failed: $e');
    }
  }

  void _showVideoDialog(File videoFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(child: VideoPlayerDialog(videoFile: videoFile));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Work Order",
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
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Add subject',
                            controller: subject,
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
                          const Text('Photos (Maximum of 10) ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 45,
                            width: 140,
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
                              onPressed: _images.length >= 10
                                  ? null // disables the button
                                  : () async {
                                      _pickImage().then((_) {
                                        setState(() {});
                                      });
                                    },
                              // onPressed: () async {
                              //   _pickImage().then((_) {
                              //     setState(
                              //         () {}); // Rebuild the widget after selecting the image
                              //   });
                              // },
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
                                                        isvideo[index]
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  _showVideoDialog(
                                                                      videofiles[
                                                                          index]);
                                                                },
                                                                child: Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Image.file(
                                                                      _images[
                                                                          index],
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    const Icon(
                                                                        Icons
                                                                            .play_circle_fill,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30),
                                                                  ],
                                                                ),
                                                              )
                                                            : Container(
                                                                // color:Colors.blue,
                                                                child:
                                                                    Image.file(
                                                                  _images[
                                                                      index],
                                                                  height: 80,
                                                                  width: 80,
                                                                  fit: BoxFit
                                                                      .cover,
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
                          // _images.isNotEmpty
                          //     ? Row(
                          //         children: [
                          //           Expanded(
                          //             child: Container(
                          //               //color: Colors.blue,
                          //               child: Wrap(
                          //                 spacing:
                          //                     8.0, // Horizontal spacing between items
                          //                 runSpacing:
                          //                     8.0, // Vertical spacing between rows
                          //                 children: List.generate(
                          //                   _images.length,
                          //                   (index) {
                          //                     return Container(
                          //                       // color: Colors.green,
                          //                       width: 85,
                          //                       child: Column(
                          //                         mainAxisAlignment:
                          //                             MainAxisAlignment.start,
                          //                         crossAxisAlignment:
                          //                             CrossAxisAlignment
                          //                                 .start,
                          //                         children: [
                          //                           Row(
                          //                             children: [
                          //                               SizedBox(
                          //                                 width: 60,
                          //                               ),
                          //                               GestureDetector(
                          //                                 onTap: () {
                          //                                   setState(() {
                          //                                     _images
                          //                                         .removeAt(
                          //                                             index);
                          //                                   });
                          //                                 },
                          //                                 child: Icon(
                          //                                   Icons.close,
                          //                                   color:
                          //                                       Colors.grey,
                          //                                 ),
                          //                               ),
                          //                             ],
                          //                           ),
                          //                           Row(
                          //                             mainAxisAlignment:
                          //                                 MainAxisAlignment
                          //                                     .start,
                          //                             crossAxisAlignment:
                          //                                 CrossAxisAlignment
                          //                                     .start,
                          //                             children: [
                          //                               Container(
                          //                                 // color:Colors.blue,
                          //                                 child: Image.file(
                          //                                   _images[index],
                          //                                   height: 80,
                          //                                   width: 80,
                          //                                   fit: BoxFit.cover,
                          //                                 ),
                          //                               ),
                          //                             ],
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     );
                          //                   },
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       )
                          //     : Center(
                          //         child: Text("No images selected."),
                          //       ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Property *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
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
                                                  'Select Property',
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
                                              print(
                                                  'Selected Property: $_selectedProperty');
                                              if (value != null) {
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
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(Icons.arrow_drop_down),
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
                              units.isNotEmpty &&
                                      units.values
                                          .any((unit) => unit.trim().isNotEmpty)
                                  ? const Text('Unit *',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey))
                                  : Container(),
                              const SizedBox(height: 2),
                              units.isNotEmpty &&
                                      units.values
                                          .any((unit) => unit.trim().isNotEmpty)
                                  ? FormField<String>(
                                      validator: (value) {
                                        if (_selectedUnitId == null ||
                                            _selectedUnitId!.isEmpty) {
                                          return 'Please select a unit';
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
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
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
                                                      print(
                                                          'Selected Unit: $_selectedUnit');
                                                    });
                                                    state.didChange(value);
                                                    state.reset();
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
                            height: 10,
                          ),
                          const Text('Category',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<allcategories_model>(
                              isExpanded: true,
                              hint: Text(_isLoadingCategories
                                  ? 'Loading categories...'
                                  : 'Select Category'),
                              value: _dropdownCategories
                                      .contains(_selectedDropdownCategory)
                                  ? _selectedDropdownCategory
                                  : null,
                              items: _dropdownCategories.map((cat) {
                                return DropdownMenuItem<allcategories_model>(
                                  value: cat,
                                  child: Text(cat.name ?? ''),
                                );
                              }).toList(),
                              onChanged: _isLoadingCategories
                                  ? null // disables dropdown while loading
                                  : (allcategories_model? newValue) {
                                      setState(() {
                                        _selectedDropdownCategory = newValue;
                                        _showTextField =
                                            newValue?.name == 'Other';
                                      });
                                    },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 250,
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
                                height: 50,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
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
                                  color: Colors.grey)),
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
                                          items:
                                              staffs.keys.map((staffmember_id) {
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
                                              print(
                                                  'Selected Staffs: $_selectedStaffs');
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
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(Icons.arrow_drop_down),
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
                          const Text('Entery allowed ',
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
                                print('Selected category: $_selectedEntry');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                // width: 200,
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
                            height: 10,
                          ),
                          const Text('Vendor ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
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
                                              print(
                                                  'Selected Vendors: $_selectedVendors');
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
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(Icons.arrow_drop_down),
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
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Enter here',
                            controller: perform,
                            optional: true,
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
                          color: const Color.fromRGBO(21, 43, 103, 1),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('Parts And Labour :',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                              // SizedBox(width: 10),
                              const Text('Total :',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text('\$${totalAmount.toStringAsFixed(2)}'),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: addRow,
                            child: const Text('Add Row'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Vendors Note ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
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
                                "Billable To Tenant",
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
                                                  decoration: const InputDecoration(
                                                      border: InputBorder.none),
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
                                                      print(
                                                          'Selected Tenant: $_selectedTenants');
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
                                  color: Colors.grey)),
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
                                          state.didChange(newValue);
                                        });
                                        state.reset();
                                        // Notify form field of the change
                                        print(
                                            'Selected category: $_selectedStatus');
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 45,
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
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  const BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(1.0,
                                        1.0), // Shadow offset to the bottom right
                                    blurRadius:
                                        8.0, // How much to blur the shadow
                                    spreadRadius:
                                        0.0, // How much the shadow should spread
                                  ),
                                ],
                                border:
                                    Border.all(width: 0, color: Colors.white),
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
                                hintText: 'yyyy-mm-dd',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () {
                                    _selectDate(context);
                                  },
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
                    children: [
                      Container(
                        height: 50,
                        width: 160,
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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

      // Use dynamic category dropdown values
      String? categoryName =
          _selectedDropdownCategory?.name ?? _selectedCategory;
      String? categoryId = _selectedDropdownCategory?.categoryId;
      if (categoryId == null || categoryId.isEmpty) categoryId = null;

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
      print(parts);
      print(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
      try {
        final workorder = await WorkOrderRepository().addWorkOrder(
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
          date: _dateController.text,
          entry: _selectedEntry == 'yes',
          parts: parts,
          notificationTime:
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        );
        Navigator.pop(context, true);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Failed to add work order: $e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print(e);
      } finally {
        setState(() {
          isloading = false;
        });
      }
    } else {
      setState(() {
        formValid = false;
      });
      print('Form is invalid');
    }
  }
}

class AddWorkOrderForTablet extends StatefulWidget {
  String? rentalid;
  AddWorkOrderForTablet({super.key, this.rentalid});
  @override
  State<AddWorkOrderForTablet> createState() => _AddWorkOrderForTabletState();
}

class _AddWorkOrderForTabletState extends State<AddWorkOrderForTablet>
    with RouteAware {
  final TextEditingController subject = TextEditingController();

  // Dynamic categories
  List<allcategories_model> _dropdownCategories = [];
  allcategories_model? _selectedDropdownCategory;
  bool _isLoadingCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Always refetch categories when returning to this screen
    _loadDropdownCategories();
    super.didPopNext();
  }

  Future<void> _loadDropdownCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final cats = await FetchAllcategories().fetchAllCategories();
      print('Fetched categories in AddWorkOrderForTablet: ' + cats.toString());
      setState(() {
        _dropdownCategories = cats;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error fetching categories in AddWorkOrderForTablet: ' +
          e.toString());
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

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
      print('${Api_url}/api/rentals/rentals/$id');
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
        SnackBar(content: Text('Failed to fetch properties: $e')),
      );
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
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
      print('$Api_url/api/unit/rental_unit/$rentalId');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};
        jsonResponse.forEach((data) {
          unitAddresses[data['unit_id'].toString()] =
              data['rental_unit'].toString();
        });
        //  200 no hoy tyare _loadtennant
        setState(() {
          units = unitAddresses;
          _isLoading = false;
        });
      } else {
        _loadTenant(rentalId, unitId);
        throw Exception('Failed to load units');
      }
    } catch (e) {
      setState(() {
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
      print('${Api_url}/api/vendor/vendors/$id');

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
        SnackBar(content: Text('Failed to fetch vendors: $e')),
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
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/staffmember/staff_member/$id');

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
        SnackBar(content: Text('Failed to fetch vendors: $e')),
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
      final response = await http.get(
          Uri.parse('${Api_url}/api/leases/get_tenants/$rentalId/$unitId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/leases/get_tenants/$rentalId/$unitId');
      print(response.body);
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
        print(tenants);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingtenant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tenants: $e')),
      );
    }
  }

  String? _selectedCategory;
  final List<String> _category = [
    'Complaint',
    'Contribution Request',
    'Feedback/Suggestion',
    'General inquiry',
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
    'New',
    'In Progress',
    'On Hold',
    'Completed',
    'Closed'
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
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
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
                print(
                    'Selected account: ${partsAndLabor[index]['selectedAccount']}');
              },
              buttonStyleData: ButtonStyleData(
                height: 45,
                width: 200,
                padding: const EdgeInsets.only(left: 14, right: 14),
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
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
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
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
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
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
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
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
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

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  File? _image;
  List<File> _images = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
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
      print('Image upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: widget_302_Staff.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawerStaff(
          currentpage: "Work Order",
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
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Add subject',
                              controller: subject,
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
                                  _pickImage().then((_) {
                                    setState(
                                        () {}); // Rebuild the widget after selecting the image
                                  });
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
                                                                _images
                                                                    .removeAt(
                                                                        index);
                                                              });
                                                            },
                                                            child: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.grey,
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
                                                          Container(
                                                            // color:Colors.blue,
                                                            child: Image.file(
                                                              _images[index],
                                                              height: 80,
                                                              width: 80,
                                                              fit: BoxFit.cover,
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
                            const Text('Property *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
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
                                          child:
                                              DropdownButtonFormField2<String>(
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
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
                                                          FontWeight.w400,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                print(
                                                    'Selected Property: $_selectedProperty');
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
                                                    BorderRadius.circular(6),
                                                color: Colors.white,
                                              ),
                                              elevation: 2,
                                            ),
                                            iconStyleData: const IconStyleData(
                                              icon: Icon(Icons.arrow_drop_down),
                                              iconSize: 24,
                                              iconEnabledColor:
                                                  Color(0xFFb0b6c3),
                                              iconDisabledColor: Colors.grey,
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.white,
                                              ),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                radius:
                                                    const Radius.circular(6),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                        6),
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
                                        units.values.any(
                                            (unit) => unit.trim().isNotEmpty)
                                    ? const Text('Unit *',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey))
                                    : Container(),
                                const SizedBox(height: 0),
                                // units.isNotEmpty
                                units.isNotEmpty &&
                                        units.values.any(
                                            (unit) => unit.trim().isNotEmpty)
                                    ? FormField<String>(
                                        validator: (value) {
                                          if (_selectedUnitId == null ||
                                              _selectedUnitId!.isEmpty) {
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
                                                child: DropdownButtonFormField2<
                                                    String>(
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
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
                                                  items: units.keys
                                                      .map((unitId) {
                                                        String? unitName =
                                                            units[unitId]
                                                                ?.trim();
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
                                                            units[value]
                                                                ?.trim();
                                                        if (_selectedPropertyId !=
                                                            null) {
                                                          _loadTenant(
                                                              _selectedPropertyId!,
                                                              value);
                                                        }
                                                        print(
                                                            'Selected Unit: $_selectedUnit');
                                                      });
                                                    }
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
                            const SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Category',
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
                                          hint: const Text('Select Category'),
                                          value: _selectedCategory,
                                          items: _category.map((method) {
                                            return DropdownMenuItem<String>(
                                              value: method,
                                              child: Text(method),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedCategory = newValue;
                                              _showTextField =
                                                  _selectedCategory == 'Other';
                                            });
                                            print(
                                                'Selected category: $_selectedCategory');
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
                                                  MaterialStateProperty.all(
                                                      true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 55,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Entery allowed ',
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
                                            print(
                                                'Selected category: $_selectedEntry');
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
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  child:
                                                      DropdownButtonFormField2<
                                                          String>(
                                                    decoration: const InputDecoration(
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
                                                    items: staffs.keys
                                                        .map((staffmember_id) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: staffmember_id,
                                                        child: Text(
                                                          staffs[
                                                              staffmember_id]!,
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
                                                    value: _selectedstaffId,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        // _selectedUnitId = null;
                                                        _selectedstaffId =
                                                            value;
                                                        _selectedStaffs = staffs[
                                                            value]; // Store selected rental_adress

                                                        StaffId =
                                                            value.toString();
                                                        print(
                                                            'Selected Staffs: $_selectedStaffs');
                                                        // _loadUnits(
                                                        //     value!); // Fetch units for the selected property
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
                                                color: Colors.grey)),
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
                                                              border:
                                                                  InputBorder
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
                                                      value: _selectedvendorsId,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          // _selectedUnitId = null;
                                                          _selectedvendorsId =
                                                              value;
                                                          _selectedVendors =
                                                              vendors[
                                                                  value]; // Store selected rental_adress

                                                          vendorId =
                                                              value.toString();
                                                          print(
                                                              'Selected Vendors: $_selectedVendors');
                                                          _loadUnits(
                                                              value!); // Fetch units for the selected property
                                                        });
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
                                                color: Colors.grey)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          hintText: 'Enter here',
                                          controller: perform,
                                          optional: true,
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
                    padding:
                        const EdgeInsets.only(left: 35, right: 35, top: 15),
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
                                            child:Text("\$${row.partsPrice}"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:Text("\$${(row.partsPrice! * row.partsQuantity!)}"),
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
                                                      ['selectedAccount'] =
                                                  newValue;
                                            });
                                            print(
                                                'Selected account: ${partsAndLabor[index]['selectedAccount']}');
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
                                                  MaterialStateProperty.all(
                                                      true),
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
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomTextField(
                                        hintText: 'Price',
                                        controller: partsAndLabor[index]
                                            ['priceController'],
                                        keyboardType: TextInputType.number,
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
                                          child: Text("\$${grandTotal.toString()}",style: TextStyle(
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
                                    color: Colors.grey)),
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
                                                  child:
                                                      DropdownButtonFormField2<
                                                          String>(
                                                    decoration: const InputDecoration(
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
                                                    items: tenants.keys
                                                        .map((tenantId) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: tenantId,
                                                        child: Text(
                                                          tenants[tenantId]!,
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
                                                    value: _selectedtenantId,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantId =
                                                            value.toString();
                                                        _selectedtenantId =
                                                            value;
                                                        _selectedTenants = tenants[
                                                            value]; // Store selected tenant name
                                                        print(
                                                            'Selected Tenant: $_selectedTenants');
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
                                    color: Colors.grey)),
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
                                  print('Selected category: $_selectedStatus');
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: 200,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
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
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.0,
                                          1.0), // Shadow offset to the bottom right
                                      blurRadius:
                                          8.0, // How much to blur the shadow
                                      spreadRadius:
                                          0.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                      Border.all(width: 0, color: Colors.white),
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
                                  hintText: 'yyyy-mm-dd',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () {
                                      _selectDate(context);
                                    },
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
                    padding:
                        const EdgeInsets.only(left: 35, right: 35, top: 15),
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
      ),
    );
  }

  Widget buildTextField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
      String? finalTenantId = _selectedtenantId ?? tenantId;

      List<Map<String, dynamic>> parts = partsAndLabor.map((part) {
        return {
          "parts_quantity":
              int.tryParse(part['qtyController'].text.trim()) ?? 0,
          "account": part['selectedAccount'],
          "description": part['descriptionController'].text.trim(),
          "charge_type": "Workorder Charge",
          "parts_price":
              double.tryParse(part['priceController'].text.trim()) ?? 0.0,
          "amount": double.tryParse(part['totalController'].text.trim()) ?? 0.0,
        };
      }).toList();
      print(parts);
      try {
        final workorder = await WorkOrderRepository().addWorkOrder(
          adminId: id,
          workSubject: subject.text.trim(),
          staffMemberName: _selectedStaffs,
          workCategory: _selectedCategory,
          workPerformed: perform.text.trim(),
          status: _selectedStatus,
          rentalAddress: properties[_selectedPropertyId],
          rentalUnit: units[_selectedUnitId],
          tenant: finalTenantId,
          rentalid: rentalId,
          unitid: unitId,
          workOrderImages: [],
          vendorId: vendorId,
          vendorNotes: vendornote.text.trim(),
          priority: _selectedOption,
          isBillable: isChecked,
          workChargeTo: isChecked == 'Tenants',
          //  workChargeTo: "isbillable true hoy to static tenant mokli devanu",
          date: _dateController.text.trim(),
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
        Navigator.pop(context, true);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Failed to add work order: $e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print(e);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        formValid = false;
      });
      print('Form is invalid');
    }
  }
}
