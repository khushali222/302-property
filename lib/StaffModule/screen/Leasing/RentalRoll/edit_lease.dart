import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:three_zero_two_property/StaffModule/repository/lease.dart';
import 'package:three_zero_two_property/StaffModule/repository/properties.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/model/properties.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../../../Model/ApplicantModel.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../Model/tenants.dart';
import '../../../../model/cosigner.dart';
import '../../../../model/edit_lease.dart';
import '../../../../model/get_lease.dart';
import '../../../../model/lease.dart';

import '../../../../provider/lease_provider.dart';
import '../../../repository/tenants.dart';
import '../../../widgets/custom_drawer.dart';

class Edit_lease extends StatefulWidget {
  Lease1? lease;
  final String leaseId;
  Edit_lease({super.key,  this.lease, required this.leaseId});

  @override
  State<Edit_lease> createState() => _Edit_leaseState();
}

class _Edit_leaseState extends State<Edit_lease>
    with SingleTickerProviderStateMixin {
  late Future<List<Rentals>> futureRentalOwners;

  String? rent_entry_id;
  String? rent_security_id;
  String? initialRentAmount;
  String? initialRentMemo;
  String? initialRentNextDueDate;
  String? initialSelectedLeaseType;
  String? initialSelectedRent;
  String? initialSecurityDepositAmount;
  String? initialStartDate;
  String? initialEndDate;
  @override
  void initState() {
    super.initState();
    // print(widget.cosigner?.firstName);
    futureRentalOwners = PropertiesRepository().fetchProperties();
    _loadProperties();
    _tabController = TabController(length: 2, vsync: this);
    // _selectedProperty = widget.lease.rentalAddress;
    //   _selectedLeaseType = widget.lease.leaseType;
    //  _startDate.text = widget.lease.startDate!;
    //   _endDate.text = widget.lease.endDate!;
    // _selectedRent = widget.lease.rentCycle;
    // rentAmount.text = widget.lease.amount as String;
    //    rentNextDueDate.text = widget.lease.rentDueDate!;

    // Future.delayed(Duration.zero, () {
    //   final selectedTenantsProvider = Provider.of<SelectedTenantsProvider>(context, listen: false);
    //
    //   selectedTenantsProvider.setTenants([
    //     Tenant(tenantFirstName: 'John', tenantLastName: 'Doe'),
    //     Tenant(tenantFirstName: 'Jane', tenantLastName: 'Smith'),
    //    // Tenant(tenantFirstName: '${tenants.first.tenantFirstName}',tenantLastName: tenants.first.tenantLastName),
    //
    //   ]);
    //   setState(() {
    //
    //
    //   });
    // });
    print(widget.leaseId);
    fetchDetails(widget.leaseId);
  }

  Future<void> fetchDetails(String leaseId) async {
    //try {

    LeaseDetails fetchedDetails =
        await LeaseRepository().fetchLeaseDetails(leaseId);
    // print();

    // print(fetchedDetails.re);

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // print(fetchedDetails.rental.rentalAddress);
      initialRentAmount = fetchedDetails.rentCharges!.first.amount.toString();
      initialRentMemo = fetchedDetails.rentCharges?.first.memo ?? "";
      initialRentNextDueDate =
          formatDate(fetchedDetails.rentCharges!.first.date);
      initialSecurityDepositAmount = fetchedDetails.securityCharges!.isNotEmpty
          ? fetchedDetails.securityCharges!.first!.amount.toString()
          : '';
      initialStartDate = formatDate(fetchedDetails.lease.startDate);
      initialEndDate = formatDate(fetchedDetails.lease.endDate);
      initialSelectedLeaseType = fetchedDetails.lease.leaseType ?? "";
      initialSelectedRent = fetchedDetails.rentCharges!.first.rentCycle ?? "";

      _selectedProperty = fetchedDetails.rental.rentalId;
      renderId = fetchedDetails.rental.rentalId!;

      _selectedLeaseType = fetchedDetails.lease.leaseType;
      startDateController.text = formatDate(fetchedDetails.lease.startDate);
      endDateController.text = formatDate(fetchedDetails.lease.endDate);

      _selectedRent = fetchedDetails.rentCharges!.first!.rentCycle;
      rentMemo.text = fetchedDetails.rentCharges!.first!.memo;

      print(fetchedDetails.rentCharges!.first!.memo);
      rent_entry_id = fetchedDetails.rentCharges!.first.entry_id;
      rentNextDueDate.text =
          formatDate(fetchedDetails.rentCharges!.first!.date);
      rentAmount.text = fetchedDetails.rentCharges!.first!.amount.toString();

      // if(fetchedDetails.lease.uploadedFile != "")
      //   _uploadedFileNames.add(fetchedDetails.lease.uploadedFile.first);

      if (fetchedDetails.lease.uploadedFile != null &&
          fetchedDetails.lease.uploadedFile.isNotEmpty) {
        _uploadedFileNames.add(fetchedDetails.lease.uploadedFile.first);
      }

      if (fetchedDetails.securityCharges != null &&
          fetchedDetails.securityCharges!.length > 0)
        securityDepositeAmount.text =
            fetchedDetails.securityCharges!.first!.chargeType ==
                    'Security Deposit'
                ? fetchedDetails.securityCharges!.first!.amount.toString()
                : '';
      if (fetchedDetails.securityCharges != null &&
          fetchedDetails.securityCharges!.length > 0)
        rent_security_id = fetchedDetails.securityCharges!.first!.chargeType ==
                'Security Deposit'
            ? fetchedDetails.securityCharges!.first.entry_id
            : '';
      for (int i = 0; i < fetchedDetails.tenant!.length; i++) {
        Provider.of<SelectedTenantsProvider>(context, listen: false)
            .addTenant(fetchedDetails.tenant![i]);
        // Assuming fetchedDetails.tenant![i].rentShare contains the rent share data

        Provider.of<SelectedTenantsProvider>(context, listen: false)
            .rentShareControllers[i]
            .text = fetchedDetails.tenant![i].rentshare.toString();
      }
      for (int i = 0; i < fetchedDetails.cosigner!.length; i++) {
        Provider.of<SelectedCosignersProvider>(context, listen: false)
            .addCosigner(fetchedDetails.cosigner![i]);
      }
      if (fetchedDetails.one_charge_data != null &&
          fetchedDetails.one_charge_data!.isNotEmpty) {
        formDataOneTimeList = fetchedDetails.one_charge_data!.map((item) {
          // Ensure item is a Map and all keys and values are strings
          if (item is Map) {
            return item.map(
                (key, value) => MapEntry(key.toString(), value.toString()));
          }
          return <String, String>{};
        }).toList();
      }
      if (fetchedDetails.rec_charge_data != null &&
          fetchedDetails.rec_charge_data!.isNotEmpty) {
        formDataRecurringList = fetchedDetails.rec_charge_data!.map((item) {
          // Ensure item is a Map and all keys and values are strings
          if (item is Map) {
            return item.map(
                (key, value) => MapEntry(key.toString(), value.toString()));
          }
          return <String, String>{};
        }).toList();

        log(formDataRecurringList.toList().toString());
      }
    });

    _loadUnits(renderId);
    setState(() {
      _selectedUnit = fetchedDetails.lease.unitId;
    });

    //} catch (e) {
    //print('Failed to fetch lease details: $e');
    //}
  }

  TextEditingController rentShareControllers = TextEditingController();
//first container variable
  List<Tenant> selectedTenants = [];
  bool isChecked = false;
  bool isLoading = false;
  int? selectedIndex;
  List<Tenant> tenants = [];
  List<Tenant> filteredTenants = [];
  List<bool> selected = [];
  bool _isLoading = true;
  List<Map<String, String>> properties = [];
  List<Map<String, String>> units = [];
  String? _selectedProperty;
  String? _selectedUnit;
  String? _selectedLeaseType;

  final TextEditingController startDateController = TextEditingController();
  DateTime? _startDate;
  final TextEditingController endDateController = TextEditingController();

  // second container variables
  String? _selectedRent;
  final TextEditingController rentAmount = TextEditingController();
  final TextEditingController rentNextDueDate = TextEditingController();
  final TextEditingController rentMemo = TextEditingController();

  //changes variables
  Future<void> _loadProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/rentals/rentals/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffid",
      });
      print('${Api_url}/api/rentals/rentals/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        List<Map<String, String>> addresses = jsonResponse.map((data) {
          return {
            'rental_id': data['rental_id'].toString(),
            'rental_adress': data['rental_adress'].toString(),
          };
        }).toList();

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

  bool _showUnitDropdown = false;

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
      _showUnitDropdown = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");
    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffid",
      });
      print('$Api_url/api/unit/rental_unit/$rentalId');

      if (response.statusCode == 200) {
        Map<String,dynamic> responses = jsonDecode(response.body);
        if(responses["statusCode"] == 200){
          List jsonResponse = json.decode(response.body)['data'];

          List<Map<String, String>> unitAddresses = jsonResponse.map((data) {
            return {
              'unit_id': data['unit_id'].toString(),
              'rental_unit': data['rental_unit'].toString(),
            };
          }).toList();

          setState(() {
            units = unitAddresses;
            _isLoading = false;
            //_showUnitDropdown = true;
            _showUnitDropdown = units.isNotEmpty;
          });
        }
        else{
          setState(() {

            _isLoading = false;
            //_showUnitDropdown = true;
            _showUnitDropdown = false;
          });
        }

      } else {
        throw Exception('Failed to load units');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch units: $e')),
      );
    }
  }

  List<String> accounts = [];

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('$Api_url/api/accounts/accounts/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        accounts = (data['data'] as List)
            .where((item) => item['charge_type'] == "One Time Charge")
            .map((item) => item['account'] as String)
            .toList();
        _isLoading = false;
        print(accounts.length);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  String companyName = '';
  Future<void> fetchCompany() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");

    if (adminId != null) {
      try {
        String fetchedCompanyName =
            await TenantsRepository().fetchCompanyName(adminId);
        setState(() {
          companyName = fetchedCompanyName;
        });
      } catch (e) {
        print('Failed to fetch company name: $e');
        // Handle error state, e.g., show error message to user
      }
    }
  }

  bool InValid = false;

  bool isEnjoyNowSelected = true;
  bool isTenantSelected = true;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _addRecurringFormKey = GlobalKey<FormState>();

  final TextEditingController Amount = TextEditingController();

  final TextEditingController securityDepositeAmount = TextEditingController();
  final TextEditingController recurringContentAmount = TextEditingController();
  final TextEditingController recurringContentMemo = TextEditingController();
  final TextEditingController oneTimeContentMemo = TextEditingController();
  final TextEditingController oneTimeContentAmount = TextEditingController();
  final TextEditingController signatureController = TextEditingController();
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  bool _selectedResidentsEmail = false; // Initialize the boolean variable
  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 50,
        // color: Colors.blue,
        child: TableCell(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Center(child: Text(text, style: const TextStyle(fontSize: 18))),
          ),
        ),
      ),
    );
  }

  final List<String> leaseTypeitems = [
    'Fixed',
    'Fixed w/rollover',
    'At-will(month to month)',
  ];
  final List<String> rentCycleitems = [
    'Daily',
    'Weekly',
    'Every two weeks',
    'Monthly',
    'Every two months',
    'Quarterly',
    'Yearly',
    'Semi Monthly',
  ];

  DateTime calculateNextDueDate(DateTime startDate, String rentCycle) {
    switch (rentCycle) {
      case 'Daily':
        return startDate.add(Duration(days: 1));
      case 'Weekly':
        return startDate.add(Duration(days: 7));
      case 'Every two weeks':
        return startDate.add(Duration(days: 14));
      case 'Monthly':
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case 'Every two months':
        return DateTime(startDate.year, startDate.month + 2, startDate.day);
      case 'Quarterly':
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case 'Yearly':
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      default:
        return startDate;
    }
  }

  void _updateNextDueDate() {
    if (_startDate != null && _selectedRent != null) {
      DateTime nextDueDate = calculateNextDueDate(_startDate!, _selectedRent!);
      String formattedNextDueDate =
          "${nextDueDate.day.toString().padLeft(2, '0')}-${nextDueDate.month.toString().padLeft(2, '0')}-${nextDueDate.year}";

      setState(() {
        rentNextDueDate.text = formattedNextDueDate;
      });
    }
  }

  String? selectedValue;

  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _validateSignature() async {
    if (isTenantSelected) {
      // Check if the signature pad has any strokes
      final image = await _signaturePadKey.currentState!.toImage();
      final byteData = await image.toByteData();
      final buffer = byteData!.buffer.asUint8List();
      bool isEmpty = buffer.every((byte) => byte == 0);
      return !isEmpty;
    } else {
      // Check if the typed signature is empty
      if (signatureController.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() && await _validateSignature()) {
      // Proceed with submission
      print("Signature validated and form submitted!");
    } else {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide either a drawn or typed signature.')),
      );
    }
  }

  Map<String, String> _popupFormOneTimeData = {
    'property': '',
    'amount': '',
    'memo': ''
  };

  List<Map<String, dynamic>> formDataOneTimeList = [];

  void _showPopupForm(BuildContext context, String rent,
      {Map<String, dynamic>? initialData, int? index}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Add One Time Charge Content',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: blueColor,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OneTimeChargePopUp(
              initialData: initialData,
              onSave: (data) {
                setState(() {
                  data['rent_cycle'] = rent; // Add Rent value to the data map
                  if (index != null) {
                    // Update existing item
                    formDataOneTimeList[index] = data;
                    Fluttertoast.showToast(
                        msg: 'Recurring Charge Updated Sucessfully');
                    Navigator.pop(context);
                  } else {
                    // Add new item
                    formDataOneTimeList.add(data);

                    Fluttertoast.showToast(
                        msg: 'Recurring Charge Added Sucessfully');
                    Navigator.pop(context);
                  }
                });
              },
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        result['rent_cycle'] = rent; // Add Rent value to the result map
        if (index != null) {
          formDataOneTimeList[index] = result;
          Fluttertoast.showToast(msg: 'Recurring Charge Updated Suessfully');
        } else {
          formDataOneTimeList.add(result);

          Fluttertoast.showToast(msg: 'Recurring Charge Added Sucessfully');
        }
      });
    }
  }

  List<Map<String, String>> formDataRecurringList = [];

  void _showRecurringPopupForm(BuildContext context, String Rent,
      {Map<String, String>? initialData, int? index}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RecurringChargePopUp(
              initialData: initialData,
              onSave: (data) {
                setState(() {
                  data['rent_cycle'] = Rent; // Add Rent value to the data map
                  if (index != null) {
                    // Update existing item
                    formDataRecurringList[index] = data;
                    Fluttertoast.showToast(
                        msg: 'Recurring Charge Updated Sucessfully');
                    Navigator.pop(context);
                  } else {
                    // Add new item
                    formDataRecurringList.add(data);

                    Fluttertoast.showToast(
                        msg: 'Recurring Charge Added Sucessfully');
                    Navigator.pop(context);
                  }
                });
              },
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        result['rent_cycle'] = Rent; // Add Rent value to the result map
        if (index != null) {
          formDataRecurringList[index] = result;
          Fluttertoast.showToast(msg: 'Recurring Charge Updated Sucessfully');
        } else {
          formDataRecurringList.add(result);

          Fluttertoast.showToast(msg: 'Recurring Charge Added Sucessfully');
        }
      });
    }
  }

  List<File> _pdfFiles = [];

  List<String> _uploadedFileNames = [];

  Future<void> _pickPdfFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    //  allowedExtensions: ['pdf'],
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
    if (responseBody['status'] == 'ok') {
      Fluttertoast.showToast(msg: 'PDF added successfully');
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  String renderId = '';
  String unitId = '';
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    final cosigners = Provider.of<SelectedCosignersProvider>(context).cosigners;
    Map<int, Map<String, String>> cosignersMap =
        cosigners.asMap().map((index, cosigner) {
      return MapEntry(index, {
        'c_id': cosigner.c_id ?? '',
        'firstName': cosigner.firstName,
        'lastName': cosigner.lastName,
        'phoneNumber': cosigner.phoneNumber,
        'workNumber': cosigner.workNumber,
        'email': cosigner.email,
        'alterEmail': cosigner.alterEmail,
        'streetAddress': cosigner.streetAddress,
        'city': cosigner.city,
        'country': cosigner.country,
        'postalCode': cosigner.postalCode,
      });
    });

    final tenants =
        Provider.of<SelectedTenantsProvider>(context).selectedTenants;
    Map<int, Map<String, String>> tenantsMap =
        tenants.asMap().map((index, tenant) {
      print('in map ${tenant.tenantFirstName}');
      return MapEntry(index, {
        'tenantId': tenant.tenantId ?? "",
        'applicantId': tenant.applicantId ?? "",
        'tenant_residentStatus': tenant.tenant_residentStatus.toString(),
        'firstName': tenant.tenantFirstName ?? "",
        'lastName': tenant.tenantLastName ?? "",
        'passWord': tenant.tenantPassword ?? '',
        if (tenant.rentalUnit != null) 'rental_unit': tenant.rentalUnit!,
        'phoneNumber': tenant.tenantPhoneNumber ?? "",
        'workNumber': tenant.tenantAlternativeNumber ?? "",
        'email': tenant.tenantEmail ?? "",
        'alterEmail': tenant.tenantAlternativeEmail ?? "",
        // 'streetAddress': tenant.rentalAddress ?? "",
        'rental_adress': tenant.rentalAddress ?? '',
        'comments': tenant.comments ?? '',
        'dob': tenant.tenantBirthDate ?? '',
        'taxPayerId': tenant.taxPayerId ?? '',
        'createdAt': tenant.createdAt ?? '',
        'emergencyContactName': tenant.emergencyContact!.name ?? '',
        'emergencyRelation': tenant.emergencyContact!.relation ?? '',
        'emergencyEmail': tenant.emergencyContact!.email ?? '',
        'emergencyPhoneNumber': tenant.emergencyContact!.phoneNumber ?? '',
        'city': '', // Add city if available
        'country': '', // Add country if available
        'postalCode': '', // Add postal code if available
      });
    });

    var selectedTenantsProvider =
        Provider.of<SelectedTenantsProvider>(context, listen: false);
    // var selectedCosignerProvider =
    // Provider.of<SelectedCosignersProvider>(context, listen: false);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Rent Roll",
        dropdown: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height: 50.0,
                    padding: const EdgeInsets.only(top: 14, left: 10),
                    width: MediaQuery.of(context).size.width * .91,
                    margin: const EdgeInsets.only(bottom: 6.0),
                    //Same as `blurRadius` i guess
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: blueColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: const Text(
                      "Edit Lease",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width < 500 ? 15 : 35,
                    right: MediaQuery.of(context).size.width < 500 ? 15 : 35),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
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
                              const Text('Property *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 4,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormField<String>(
                                    //initialValue: _selectedProperty,
                                    validator: (value) {
                                      if (_selectedProperty == null) {
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
                                              decoration: InputDecoration(
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
                                                        color:
                                                            Color(0xFFb0b6c3),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              items: properties.map((property) {
                                                return DropdownMenuItem<String>(
                                                  value: property['rental_id'],
                                                  child: Text(
                                                    property['rental_adress']!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              value: _selectedProperty,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedProperty = value;
                                                  _selectedUnit = null;
                                                  _showUnitDropdown =
                                                      false; // Optionally reset _selectedUnit
                                                  state.didChange(
                                                      value); // Notify the FormField that the value has changed
                                                  renderId = value.toString();

                                                  _loadUnits(
                                                      value!); // Fetch units for the selected property
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
                                              iconStyleData:
                                                  const IconStyleData(
                                                icon: Icon(
                                                  Icons.arrow_drop_down,
                                                ),
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
                                  if (_showUnitDropdown && units.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        'Unit',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  if (_showUnitDropdown && units.isNotEmpty)
                                    FormField<String>(
                                      // initialValue: _selectedUnit,
                                      validator: (value) {
                                        if (_selectedUnit == null) {
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
                                                decoration: InputDecoration(
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
                                                items: units.map((unit) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: unit['unit_id']!,
                                                    child: Text(
                                                      unit['rental_unit']!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black87,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                }).toList(),
                                                value: _selectedUnit == null ||
                                                        _selectedUnit!.isEmpty
                                                    ? null
                                                    : _selectedUnit,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedUnit = value;
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
                                height: 8,
                              ),
                              const Text('Lease Type *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 8,
                              ),
                              FormField<String>(
                                initialValue: _selectedLeaseType,
                                builder: (FormFieldState<String> state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items: [
                                            ...leaseTypeitems
                                                .map(
                                                  (String item) =>
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
                                                  ),
                                                )
                                                .toList(),
                                            if (_selectedLeaseType != null &&
                                                !leaseTypeitems.contains(
                                                    _selectedLeaseType))
                                              DropdownMenuItem<String>(
                                                value: _selectedLeaseType,
                                                child: Text(
                                                  _selectedLeaseType!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                          value: _selectedLeaseType,
                                          onChanged: (value) {
                                            // Update the FormField state
                                            setState(() {
                                              _selectedLeaseType = value;
                                              state.didChange(value);
                                            });
                                            state.reset();
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 50,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                            ),
                                            offset: const Offset(-20, 0),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(40),
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
                                validator: (value) {
                                  if (_selectedLeaseType == null) {
                                    return 'Please select a lease type';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              if (MediaQuery.of(context).size.width < 500)
                                const Text('Start Date *',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              if (MediaQuery.of(context).size.width < 500)
                                const SizedBox(
                                  height: 8,
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                CustomTextField(
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                      locale: const Locale('en', 'US'),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary:
                                                  blueColor, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface:
                                                  blueColor, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    blueColor, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (pickedDate != null) {
                                      // String formattedStartDate =
                                      //     "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                      String formattedStartDate =
                                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                      DateTime endDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month + 1,
                                          pickedDate.day);
                                      String formattedEndDate =
                                          "${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}";

                                      // String formattedEndDate =
                                      //     "${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}";
                                      setState(() {
                                        startDateController.text =
                                            formattedStartDate;
                                        _startDate = pickedDate;
                                        endDateController.text =
                                            formattedEndDate;
                                      });
                                    }
                                  },
                                  readOnnly: true,
                                  suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon:
                                          const Icon(Icons.date_range_rounded)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select start date';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  hintText: 'YYYY-MM-DD',
                                  controller: startDateController,
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                const SizedBox(
                                  height: 8,
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                const Text('End Date *',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              if (MediaQuery.of(context).size.width < 500)
                                const SizedBox(
                                  height: 8,
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                CustomTextField(
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                      locale: const Locale('en', 'US'),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary:
                                                  blueColor, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface:
                                                  blueColor, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    blueColor, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (pickedDate != null) {
                                      // String formattedDate =
                                      //     "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                      String formattedDate =
                                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                      setState(() {
                                        endDateController.text = formattedDate;
                                      });
                                    }
                                  },
                                  readOnnly: true,
                                  suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon:
                                          const Icon(Icons.date_range_rounded)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select end date';
                                    }
                                    return null;
                                  },
                                  optional: true,
                                  keyboardType: TextInputType.text,
                                  hintText: 'YYYY-MM-DD',
                                  controller: endDateController,
                                ),
                              if (MediaQuery.of(context).size.width > 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // First Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Start Date *',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                            SizedBox(height: 5),
                                            CustomTextField(
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                  locale:
                                                      const Locale('en', 'US'),
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        colorScheme:
                                                            const ColorScheme
                                                                .light(
                                                          primary: Color.fromRGBO(
                                                              21,
                                                              43,
                                                              83,
                                                              1), // header background color
                                                          onPrimary: Colors
                                                              .white, // header text color
                                                          onSurface: Color.fromRGBO(
                                                              21,
                                                              43,
                                                              83,
                                                              1), // body text color
                                                        ),
                                                        textButtonTheme:
                                                            TextButtonThemeData(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Colors.white,
                                                            backgroundColor:
                                                                blueColor, // button text color
                                                          ),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );

                                                if (pickedDate != null) {
                                                  // String formattedStartDate =
                                                  //     "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                                  String formattedStartDate =
                                                      "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                                  DateTime endDate = DateTime(
                                                      pickedDate.year,
                                                      pickedDate.month + 1,
                                                      pickedDate.day);
                                                  String formattedEndDate =
                                                      "${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}";

                                                  // String formattedEndDate =
                                                  //     "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
                                                  setState(() {
                                                    startDateController.text =
                                                        formattedStartDate;
                                                    _startDate = pickedDate;
                                                    endDateController.text =
                                                        formattedEndDate;
                                                  });
                                                }
                                              },
                                              readOnnly: true,
                                              suffixIcon: IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                    Icons.date_range_rounded),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select start date';
                                                }
                                                return null;
                                              },
                                              keyboardType: TextInputType.text,
                                              hintText: 'yyyy-mm-dd',
                                              controller: startDateController,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Second Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('End Date *',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                            SizedBox(height: 5),
                                            CustomTextField(
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                  locale:
                                                      const Locale('en', 'US'),
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        colorScheme:
                                                            const ColorScheme
                                                                .light(
                                                          primary: Color.fromRGBO(
                                                              21,
                                                              43,
                                                              83,
                                                              1), // header background color
                                                          onPrimary: Colors
                                                              .white, // header text color
                                                          onSurface: Color.fromRGBO(
                                                              21,
                                                              43,
                                                              83,
                                                              1), // body text color
                                                        ),
                                                        textButtonTheme:
                                                            TextButtonThemeData(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Colors.white,
                                                            backgroundColor:
                                                                blueColor, // button text color
                                                          ),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );

                                                if (pickedDate != null) {
                                                  // String formattedDate =
                                                  //     "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                                  String formattedDate =
                                                      "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                                  setState(() {
                                                    endDateController.text =
                                                        formattedDate;
                                                  });
                                                }
                                              },
                                              readOnnly: true,
                                              optional: true,
                                              suffixIcon: IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                    Icons.date_range_rounded),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select end date';
                                                }
                                                return null;
                                              },
                                              keyboardType: TextInputType.text,
                                              hintText: 'YYYY-MM-DD',
                                              controller: endDateController,
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      //add lease
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: blueColor,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text('Add lease',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: blueColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              var cosignerProvider = Provider.of<SelectedCosignersProvider>(context);
                                              Cosigner? existingCosigner;
                                              int? existingIndex;

                                              if (cosignerProvider.cosigners.isNotEmpty) {
                                                existingCosigner = cosignerProvider.cosigners.first; // Get the first cosigner
                                                existingIndex = 0; // Assuming you want to edit the first cosigner
                                              }
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                contentPadding: EdgeInsets.zero,
                                                title: Text(
                                                  'Add Tenant or Cosigner',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: blueColor,
                                                  ),
                                                ),
                                                content: Form(
                                                  key: _addRecurringFormKey,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      color: Colors.white,
                                                      width: double.infinity,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          isTenantSelected =
                                                                              true;
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: isTenantSelected
                                                                              ? null
                                                                              : Border.all(
                                                                                  color: blueColor,
                                                                                  width: 1,
                                                                                ),
                                                                          gradient: isTenantSelected
                                                                              ? LinearGradient(
                                                                                  colors: [
                                                                                    blueColor,
                                                                                    blueColor,
                                                                                  ],
                                                                                )
                                                                              : null,
                                                                          borderRadius:
                                                                              const BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(4),
                                                                            bottomLeft:
                                                                                Radius.circular(4),
                                                                          ),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        padding: isTenantSelected
                                                                            ? const EdgeInsets.symmetric(vertical: 13)
                                                                            : const EdgeInsets.symmetric(vertical: 12),
                                                                        child: isTenantSelected
                                                                            ? Text(
                                                                                "Tenant",
                                                                                style: TextStyle(
                                                                                  color: !isTenantSelected ? Colors.transparent : Colors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              )
                                                                            : ShaderMask(
                                                                                shaderCallback: (bounds) {
                                                                                  return LinearGradient(
                                                                                    colors: [
                                                                                      blueColor,
                                                                                      blueColor,
                                                                                    ],
                                                                                  ).createShader(bounds);
                                                                                },
                                                                                child: Text(
                                                                                  "Tenant",
                                                                                  style: TextStyle(
                                                                                    color: isTenantSelected ? Colors.transparent : Colors.white,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          isTenantSelected =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: isTenantSelected == false
                                                                              ? null
                                                                              : Border.all(
                                                                                  color: blueColor,
                                                                                  width: 1,
                                                                                ),
                                                                          gradient: isTenantSelected == false
                                                                              ? LinearGradient(
                                                                                  colors: [
                                                                                    blueColor,
                                                                                    blueColor,
                                                                                  ],
                                                                                )
                                                                              : null,
                                                                          borderRadius:
                                                                              const BorderRadius.only(
                                                                            topRight:
                                                                                Radius.circular(4),
                                                                            bottomRight:
                                                                                Radius.circular(4),
                                                                          ),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        padding: isTenantSelected
                                                                            ? const EdgeInsets.symmetric(vertical: 12)
                                                                            : const EdgeInsets.symmetric(vertical: 13),
                                                                        child: !isTenantSelected
                                                                            ? Text(
                                                                                "Cosigner",
                                                                                style: TextStyle(
                                                                                  color: isTenantSelected ? Colors.transparent : Colors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              )
                                                                            : ShaderMask(
                                                                                shaderCallback: (bounds) {
                                                                                  return LinearGradient(
                                                                                    colors: [
                                                                                      blueColor,
                                                                                      blueColor,
                                                                                    ],
                                                                                  ).createShader(bounds);
                                                                                },
                                                                                child: Text(
                                                                                  "Cosigner",
                                                                                  style: TextStyle(
                                                                                    color: !isTenantSelected ? Colors.transparent : Colors.white,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              isTenantSelected
                                                                  ? const AddTenant()
                                                                  : AddCosigner(cosigner: existingCosigner,index: existingIndex,),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      '+ Add Tenant or Cosigner',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2ec433),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(height: 8.0),
                              if (Provider.of<SelectedTenantsProvider>(context)
                                  .selectedTenants
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 13),
                                  child: Text(
                                    'Tenants :',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (Provider.of<SelectedTenantsProvider>(context)
                                  .selectedTenants
                                  .isNotEmpty)
                                const SizedBox(
                                  height: 10,
                                ),
                              if (Provider.of<SelectedTenantsProvider>(context)
                                  .selectedTenants
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, right: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Table(
                                        border: TableBorder.all(
                                          width: 1,
                                          color: const Color.fromRGBO(
                                              21, 43, 83, 1),
                                        ),
                                        columnWidths: const {
                                          0: FlexColumnWidth(2),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(1.3),
                                        },
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              color: blueColor,
                                            ),
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Name',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 20,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Rent share',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 20,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Action',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...Provider.of<
                                                      SelectedTenantsProvider>(
                                                  context)
                                              .selectedTenants
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final tenant = entry.value;

                                            print("Controller length:- ${Provider.of<
                                                SelectedTenantsProvider>(context)
                                                .rentShareControllers.length}  $index");
                                            final controller = Provider.of<
                                                SelectedTenantsProvider>(
                                                context)
                                                .rentShareControllers[index];

                                            return TableRow(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, top: 15),
                                                  child: Text(
                                                    '${tenant.tenantFirstName} ${tenant.tenantLastName}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Material(
                                                    elevation: 3,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 45
                                                              : 50,
                                                      width:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 70
                                                              : 400,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color:
                                                              Colors.grey[300]!,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  bottom: 7),
                                                          child: TextField(
                                                            controller:
                                                                controller,
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 12
                                                                  : 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            onChanged: (value) {
                                                              double
                                                                  enteredValue =
                                                                  double.tryParse(
                                                                          value) ??
                                                                      0;
                                                              if (enteredValue >
                                                                  100) {
                                                                controller
                                                                        .text =
                                                                    '100';
                                                                controller
                                                                        .selection =
                                                                    TextSelection
                                                                        .fromPosition(
                                                                  TextPosition(
                                                                      offset: controller
                                                                          .text
                                                                          .length),
                                                                );
                                                              }
                                                              Provider.of<SelectedTenantsProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .validateRentShares();
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText: "0",
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              10),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Provider.of<SelectedTenantsProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .removeTenant(
                                                                  tenant);
                                                        },
                                                        child: Icon(
                                                          Icons.delete,
                                                          color: const Color
                                                              .fromRGBO(
                                                              21, 43, 83, 1),
                                                          size: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 18
                                                              : 25,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              if (Provider.of<SelectedTenantsProvider>(context)
                                  .selectedTenants
                                  .isNotEmpty)
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Consumer<SelectedTenantsProvider>(
                                      builder: (context,
                                          selectedTenantsProvider, child) {
                                        return selectedTenantsProvider
                                                    .validationMessage !=
                                                null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                  selectedTenantsProvider
                                                      .validationMessage!,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16),
                                                ),
                                              )
                                            : SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              const SizedBox(height: 8.0),
                              if (Provider.of<SelectedCosignersProvider>(
                                      context)
                                  .cosigners
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 13),
                                  child: Text(
                                    'Consigner:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (Provider.of<SelectedCosignersProvider>(
                                      context)
                                  .cosigners
                                  .isNotEmpty)
                                const SizedBox(
                                  height: 10,
                                ),
                              if (Provider.of<SelectedCosignersProvider>(
                                      context)
                                  .cosigners
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: SingleChildScrollView(
                                    // scrollDirection: Axis.horizontal,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: blueColor),
                                          ),
                                          child: Table(
                                            border: TableBorder.all(
                                              width: 1,
                                              color: const Color.fromRGBO(
                                                  21, 43, 83, 1),
                                            ),
                                            columnWidths: const {
                                              0: FlexColumnWidth(2),
                                              1: FlexColumnWidth(2),
                                              2: FlexColumnWidth(1.3),
                                            },
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(
                                                  color: blueColor,
                                                ),
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'Name',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 13
                                                            : 20,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'Phone number',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 13
                                                            : 20,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'Action',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 13
                                                            : 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ...Provider.of<
                                                          SelectedCosignersProvider>(
                                                      context)
                                                  .cosigners
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                int index = entry.key;
                                                Cosigner cosigner = entry.value;
                                                return TableRow(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        '${cosigner.firstName} ${cosigner.lastName}',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 13
                                                              : 20,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        '${cosigner.phoneNumber}',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 13
                                                              : 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 10),
                                                      child: Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                isTenantSelected ==
                                                                    true;
                                                                tenent_popup(
                                                                    cosigner,
                                                                    index);
                                                              });
                                                            },
                                                            child: Icon(
                                                              Icons.edit,
                                                              size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 15
                                                                  : 20,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          InkWell(
                                                            onTap: () {
                                                              Provider.of<SelectedCosignersProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .removeConsigner(
                                                                      cosigner);
                                                            },
                                                            child: Icon(
                                                              Icons.delete,
                                                              size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 15
                                                                  : 20,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      //rent
                      Container(
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
                                height: 10,
                              ),
                              Text('Rent',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: blueColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              if (MediaQuery.of(context).size.width > 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // First Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Rent Cycle *',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                            SizedBox(height: 5),
                                            FormField<String>(
                                              initialValue: _selectedRent,
                                              builder: (FormFieldState<String>
                                                  state) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton2<
                                                          String>(
                                                        isExpanded: true,
                                                        hint: const Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                'Rent Cycle',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        items: rentCycleitems
                                                            .map(
                                                              (String item) =>
                                                                  DropdownMenuItem<
                                                                      String>(
                                                                value: item,
                                                                child: Text(
                                                                  item,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                        value: _selectedRent,
                                                        onChanged: (value) {
                                                          state.didChange(
                                                              value); // Update the FormField state
                                                          setState(() {
                                                            _selectedRent =
                                                                value;
                                                            state.didChange(
                                                                value);
                                                          });
                                                          state.reset();
                                                        },
                                                        buttonStyleData:
                                                            ButtonStyleData(
                                                          height: 50,
                                                          width: 230,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 14,
                                                                  right: 14),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .black26,
                                                            ),
                                                            color: Colors.white,
                                                          ),
                                                          elevation: 3,
                                                        ),
                                                        dropdownStyleData:
                                                            DropdownStyleData(
                                                          maxHeight: 200,
                                                          width: 230,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14),
                                                          ),
                                                          offset: const Offset(
                                                              -20, 0),
                                                          scrollbarTheme:
                                                              ScrollbarThemeData(
                                                            radius: const Radius
                                                                .circular(40),
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
                                                      ),
                                                    ),
                                                    if (state.hasError)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 14,
                                                                top: 8),
                                                        child: Text(
                                                          state.errorText!,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              },
                                              validator: (value) {
                                                if (_selectedRent == null) {
                                                  return 'Please select a rent cycle';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Second Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Next Due Date',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                            SizedBox(height: 5),
                                            CustomTextField(
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                  locale:
                                                      const Locale('en', 'US'),
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        colorScheme:
                                                            const ColorScheme
                                                                .light(
                                                          primary: Color.fromRGBO(
                                                              21,
                                                              43,
                                                              83,
                                                              1), // header background color
                                                          onPrimary: Colors
                                                              .white, // header text color
                                                          onSurface: Color.fromRGBO(
                                                              21,
                                                              43,
                                                              83,
                                                              1), // body text color
                                                        ),
                                                        textButtonTheme:
                                                            TextButtonThemeData(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Colors.white,
                                                            backgroundColor:
                                                                blueColor, // button text color
                                                          ),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );
                                                if (pickedDate != null) {
                                                  // String formattedDate =
                                                  //     "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                                  String formattedDate =
                                                      "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";

                                                  DateTime nextDueDate =
                                                      calculateNextDueDate(
                                                          pickedDate,
                                                          _selectedRent ??
                                                              'Daily');
                                                  // String formattedNextDueDate =
                                                  //     "${nextDueDate.year}-${nextDueDate.month.toString().padLeft(2, '0')}-${nextDueDate.day.toString().padLeft(2, '0')}";
                                                  String formattedNextDueDate =
                                                      "${nextDueDate.day.toString().padLeft(2, '0')}-${nextDueDate.month.toString().padLeft(2, '0')}-${nextDueDate.year}";
                                                  setState(() {
                                                    rentNextDueDate.text =
                                                        formattedNextDueDate;
                                                    rentNextDueDate.text =
                                                        formattedDate;
                                                  });

                                                  print(rentNextDueDate.text);
                                                }
                                              },
                                              optional: true,
                                              readOnnly: true,
                                              suffixIcon: IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                    Icons.date_range_rounded),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select Next Due Date';
                                                }
                                                return null;
                                              },
                                              keyboardType: TextInputType.text,
                                              hintText: 'YYYY-MM-DD',
                                              controller: rentNextDueDate,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                const Text('Rent Cycle *',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              if (MediaQuery.of(context).size.width < 500)
                                const SizedBox(
                                  height: 8,
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                FormField<String>(
                                  initialValue: _selectedRent,
                                  builder: (FormFieldState<String> state) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    'Rent Cycle',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            items: rentCycleitems
                                                .map(
                                                  (String item) =>
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
                                                  ),
                                                )
                                                .toList(),
                                            value: rentCycleitems
                                                    .contains(_selectedRent)
                                                ? _selectedRent
                                                : null,
                                            onChanged: (value) {
                                              state.didChange(
                                                  value); // Update the FormField state
                                              setState(() {
                                                _selectedRent = value;
                                                state.didChange(value);
                                              });
                                              state.reset();
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
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              maxHeight: 200,
                                              width: 230,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              offset: const Offset(-20, 0),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                radius:
                                                    const Radius.circular(40),
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
                                  validator: (value) {
                                    if (_selectedRent == null) {
                                      return 'Please select a rent cycle';
                                    }
                                    return null;
                                  },
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                const SizedBox(
                                  height: 8,
                                ),
                              const Text('Amount *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 8,
                              ),
                              CustomTextField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter amount';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                hintText: 'Enter Amount',
                                controller: rentAmount,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              if (MediaQuery.of(context).size.width < 500)
                                const Text('Next Due Date',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              if (MediaQuery.of(context).size.width < 500)
                                const SizedBox(
                                  height: 8,
                                ),
                              if (MediaQuery.of(context).size.width < 500)
                                CustomTextField(
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                      locale: const Locale('en', 'US'),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary:
                                                  blueColor, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface:
                                                  blueColor, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    blueColor, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (pickedDate != null) {
                                      String formattedDate =
                                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";

                                      // String formattedDate =
                                      //     "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                      setState(() {
                                        rentNextDueDate.text = formattedDate;
                                      });
                                    }
                                  },
                                  optional: true,
                                  readOnnly: true,
                                  suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon:
                                          const Icon(Icons.date_range_rounded)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select Next Due Date';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  hintText: 'YYYY-MM-DD',
                                  controller: rentNextDueDate,
                                ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text('Memo',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 8,
                              ),
                              CustomTextField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter memo';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                hintText: 'Enter Memo',
                                controller: rentMemo,
                                optional: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //charges
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: blueColor,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Charges (Optional)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: blueColor,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'Add Charges',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (MediaQuery.of(context).size.width < 500)
                                    InkWell(
                                      onTap: () {
                                        _showRecurringPopupForm(
                                            context, _selectedRent.toString());
                                      },
                                      child: const Text(
                                        ' + Add Recurring Charge',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2ec433),
                                        ),
                                      ),
                                    ),
                                  if (MediaQuery.of(context).size.width < 500)
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  if (MediaQuery.of(context).size.width < 500)
                                    InkWell(
                                      onTap: () {
                                        _showPopupForm(
                                            context, _selectedRent.toString());
                                      },
                                      child: const Text(
                                        ' + Add One Time Charge',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2ec433),
                                        ),
                                      ),
                                    ),
                                  if (MediaQuery.of(context).size.width > 500)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // First Column
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    _showRecurringPopupForm(
                                                        context,
                                                        _selectedRent
                                                            .toString());
                                                  },
                                                  child: const Text(
                                                    ' + Add Recurring Charge',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2ec433),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          // Second Column
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    _showPopupForm(
                                                        context,
                                                        _selectedRent
                                                            .toString());
                                                  },
                                                  child: const Text(
                                                    ' + Add One Time Charge',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2ec433),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (formDataRecurringList.isNotEmpty)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (formDataRecurringList.isNotEmpty)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (formDataRecurringList.isNotEmpty)
                                    Text(
                                      'Recurring Information',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                    ),
                                  if (formDataRecurringList.isNotEmpty)
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  if (formDataRecurringList.isNotEmpty)
                                    Table(
                                      border: TableBorder.all(
                                        width: 1,
                                        color: blueColor,
                                      ),
                                      columnWidths: {
                                        0: const FlexColumnWidth(2),
                                        1: const FlexColumnWidth(2),
                                        2: const FlexColumnWidth(1.3),
                                      },
                                      children: [
                                        if (formDataRecurringList.isNotEmpty)
                                          TableRow(
                                              decoration: BoxDecoration(
                                                color: blueColor,
                                              ),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Account',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Amount',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Actions',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                        ...formDataRecurringList
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          var item = entry.value;
                                          return TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item['account']}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: blueColor,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item['amount']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(children: [
                                                  InkWell(
                                                    onTap: () {
                                                      _showRecurringPopupForm(
                                                          context,
                                                          _selectedRent
                                                              .toString(),
                                                          initialData: item,
                                                          index: index);
                                                    },
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: blueColor,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        formDataRecurringList
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: blueColor,
                                                      size: 18,
                                                    ),
                                                  )
                                                ]))
                                          ]);
                                        })
                                      ],
                                    ),
                                  if (formDataOneTimeList.isNotEmpty)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (formDataOneTimeList.isNotEmpty)
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  if (formDataOneTimeList.isNotEmpty)
                                    Text(
                                      'One Time Information',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                    ),
                                  if (formDataOneTimeList.isNotEmpty)
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  if (formDataOneTimeList.isNotEmpty)
                                    Table(
                                      border: TableBorder.all(
                                        width: 1,
                                        color: blueColor,
                                      ),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(1.3),
                                      },
                                      children: [
                                        if (formDataOneTimeList.isNotEmpty)
                                          TableRow(
                                              decoration: BoxDecoration(
                                                color: blueColor,
                                              ),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Account',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Amount',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Actions',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                        ...formDataOneTimeList
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          var item = entry.value;
                                          return TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item['account']}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: blueColor,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item['amount']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(children: [
                                                  InkWell(
                                                    onTap: () {
                                                      _showPopupForm(
                                                          context,
                                                          _selectedRent
                                                              .toString(),
                                                          initialData: item,
                                                          index: index);

                                                      // Implement edit functionality here
                                                    },
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: blueColor,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        formDataOneTimeList
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: blueColor,
                                                      size: 18,
                                                    ),
                                                  )
                                                ]))
                                          ]);
                                        })
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: blueColor,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text('Security Deposit (Optional)',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: blueColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Amount',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 8,
                              ),
                              CustomTextField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter amount';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                hintText: 'Enter Amount',
                                controller: securityDepositeAmount,
                                optional: true,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                    'Don\'t forget to record the payment once you have connected the deposite',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: blueColor,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text('Upload Files (Maximum of 10)',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: blueColor)),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 50,
                                width: 95,
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
                                  child: Text('Upload'),
                                ),
                              ),

                              /*  SizedBox(height: 20),
                                const SizedBox(height: 10),*/
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
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16, right: 16, bottom: 16),
                        child: Row(
                          children: [
                            Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: blueColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0))),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      setState(() {
                                        isLoading = true; // Stop loading
                                      });
                                      final provider =
                                          Provider.of<SelectedTenantsProvider>(
                                              context,
                                              listen: false);
                                      final rentShareControllers =
                                          provider.rentShareControllers;
                                      // final provider = Provider.of<SelectedTenantsProvider>(context, listen: false);
                                      // final rentShareControllers = provider.rentShareControllers;
                                      // for (int i = 0; i < rentShareControllers.length; i++) {
                                      //   print('Tenant ${i + 1}: ${rentShareControllers[i].text}');
                                      // }
                                      // bool hasError = false;
                                      // if (hasError || provider.validationMessage != null) {
                                      //   setState(() {
                                      //
                                      //   });
                                      //   return;
                                      // }
                                      // provider.clearValidationMessage();
                                      if (rentShareControllers.length < 1) {
                                        setState(() {
                                          _errorMessage = "required tenants";
                                          // _errorMessagetenants = 'Please select at least one tenant or cosigner.';
                                          // _errorMessage = null;
                                        });
                                        return;
                                      }
                                      setState(() {
                                        // _errorMessagetenants = null;
                                        _errorMessage = null;
                                      });
                                      double totalRentShare = 0.0;
                                      for (var controller
                                          in rentShareControllers) {
                                        double rentShare =
                                            double.tryParse(controller.text.trim()) ??
                                                0.0;
                                        totalRentShare += rentShare;
                                      }
                                      if (totalRentShare != 100.0) {
                                        setState(() {
                                          _errorMessage =
                                              'Total rent share must equal 100';
                                        });
                                        return;
                                      } else {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        String adminId =
                                            prefs.getString("adminId")!;
                                        bool _isLeaseAdded = false;
                                        // // Printing ChargeData object
                                        // // Printing ChargeData object
                                        //Changes
                                        List<Map<String, dynamic>>
                                            mergedFormDataList = [
                                          ...formDataOneTimeList,
                                          ...formDataRecurringList,
                                        ];
                                        log(mergedFormDataList.toString());
                                        // Creating Entry objects from the merged list
                                        print(
                                            "rentDueDate ${rentNextDueDate.text.trim()}");
                                        List<Entry> chargeEntries =
                                            mergedFormDataList.map((data) {
                                          print(data['account']);
                                          return Entry(
                                            entry_id: data['entry_id'] ?? "",
                                            account: data['account'] ?? '',
                                            amount: double.tryParse(
                                                    data['amount'] ?? '0.0') ??
                                                0.0,
                                            chargeType:
                                                data['charge_type'] ?? '',
                                            date: data['charge_type'] == 'Recurring Charge'
                                                ? (data['date'] ?? '')  // Ensuring data['date'] is not null
                                                : rentNextDueDate.text.trim(),
                                            isRepeatable: data['is_repeatable']
                                                    ?.toLowerCase() ==
                                                'true',
                                            memo: data['memo'] ?? '',
                                            rentCycle: data[
                                                'rent_cycle'], // Assuming this field might be present
                                            tenantId: data[
                                                'tenant_id'], // Assuming this field might be present
                                          );
                                        }).toList();
                                        chargeEntries.add(Entry(
                                            account: "Rent Income",
                                            amount: double.tryParse(
                                                    rentAmount.text.trim()) ??
                                                0.0,
                                            chargeType: 'Rent',
                                            date:
                                                rentNextDueDate.text.trim(),
                                            isRepeatable:
                                                false, // Set to false if it's not repeatable, adjust as needed
                                            memo: 'Last Month\'s Rent',
                                            rentCycle: _selectedRent,
                                            entry_id: rent_entry_id

                                            // Set default value or adjust as needed
                                            ));
                                        chargeEntries.add(Entry(
                                          entry_id: rent_security_id,
                                          account: "Security Deposit",
                                          amount: double.tryParse(
                                                  securityDepositeAmount
                                                      .text.trim()) ??
                                              0.0,
                                          chargeType: 'Security Deposit',
                                          date:
                                              rentNextDueDate.text.trim(),
                                          isRepeatable:
                                              false, // Set to false if it's not repeatable, adjust as needed
                                          memo: 'Security Deposit',
                                          rentCycle:
                                              _selectedRent, // Set default value or adjust as needed
                                        ));
                                        // Creating ChargeData object
                                        ChargeData chargeData = ChargeData(
                                          adminId: adminId,
                                          entry: chargeEntries,
                                          isLeaseAdded: _isLeaseAdded,
                                        );
                                        //Tenant
                                        List<TenantData> tenants = [];
                                        Map<String, String>? firstCosigner =
                                            cosignersMap.isNotEmpty
                                                ? cosignersMap[0]
                                                : {};
                                        List<String> applicantids = [];
                                        List<TenantData> tenantDataList =
                                            tenantsMap.entries.map((entry) {
                                          int index = entry.key;
                                          final tenantMap = entry.value;
                                          print(tenantMap['firstName']);
                                          print(tenantMap['firstName']);
                                          if (tenantMap['applicantId']!
                                              .isNotEmpty) {
                                            applicantids
                                                .add(tenantMap['applicantId']!);
                                          }
                                          print("Applicant ids $applicantids");
                                          return TenantData(
                                              adminId: adminId,
                                              comments:
                                                  tenantMap['comments'] ?? '',
                                              emergencyContact:
                                                  EmergencyContacts(
                                                name: tenantMap[
                                                        'emergencyContactName'] ??
                                                    '',
                                                relation: tenantMap[
                                                        'emergencyRelation'] ??
                                                    '',
                                                email: tenantMap[
                                                        'emergencyEmail'] ??
                                                    '',
                                                phoneNumber: tenantMap[
                                                        'emergencyPhoneNumber'] ??
                                                    '',
                                              ),
                                              isDelete: tenantMap['isDelete'] ==
                                                  'true',
                                              taxPayerId:
                                                  tenantMap['taxPayerId'] ?? '',
                                              rentalAddress:
                                                  tenantMap['rental_adress'],
                                              rentalUnit:
                                                  tenantMap['rental_unit'],
                                              tenantAlternativeEmail:
                                                  tenantMap['alterEmail'] ?? '',
                                              tenantAlternativeNumber:
                                                  tenantMap['workNumber'] ?? '',
                                              tenantBirthDate:
                                                  tenantMap['dob'].toString() ??
                                                      '',
                                              tenantEmail:
                                                  tenantMap['email'] ?? '',
                                              createdAt: tenantMap['createdAt'],
                                              tenantFirstName:
                                                  tenantMap['firstName'] ?? '',
                                              tenantId:
                                                  tenantMap['tenantId'] ?? '',
                                              tenantLastName:
                                                  tenantMap['lastName'] ?? '',
                                              tenantPassword:
                                                  tenantMap['passWord'] ?? '',
                                              tenantPhoneNumber:
                                                  tenantMap['phoneNumber'] ??
                                                      '',
                                              rentShare:
                                                  rentShareControllers[index]
                                                      .text);
                                        }).toList();
                                        // Assuming tenantDataList is a List<TenantData>
                                        List<String> tenantIds = tenantDataList
                                            .map((tenant) =>
                                                tenant.tenantId ?? '')
                                            .toList();

                                        // print('selected rent ${_selectedRent}');
                                        // print('rent amount ${rentAmount}');
                                        // print(
                                        //     'start date ${startDateController.text}');
                                        // print('deposite ${securityDepositeAmount}');

                                        print('Rental Id : ${renderId}');
                                        Lease lease = Lease(
                                          chargeData: ChargeData(
                                            adminId: adminId ?? "",
                                            entry: chargeEntries,
                                            isLeaseAdded: true,
                                          ),
                                          cosignerData: CosignerData(
                                              cosignerId:
                                                  firstCosigner?['c_id'],
                                              cosignerFirstName:
                                                  firstCosigner?['firstName'] ??
                                                      '',
                                              cosignerLastName:
                                                  firstCosigner?['lastName'] ??
                                                      '',
                                              cosignerPhoneNumber:
                                                  firstCosigner?['phoneNumber'] ??
                                                      '',
                                              cosignerEmail:
                                                  firstCosigner?['email'] ?? '',
                                              cosignerAlternativeEmail:
                                                  firstCosigner?['alterEmail'] ??
                                                      '',
                                              cosignerAddress: firstCosigner?[
                                                      'streetAddress'] ??
                                                  '',
                                              cosignerCity:
                                                  firstCosigner?['city'] ?? '',
                                              cosignerCountry:
                                                  firstCosigner?['country'] ??
                                                      '',
                                              cosignerPostalcode:
                                                  firstCosigner?[
                                                          'postalCode'] ??
                                                      '',
                                              adminId: adminId),
                                          leaseData: LeaseData(
                                            leaseId: widget.leaseId,
                                            adminId: adminId ?? "",
                                            companyName: companyName,
                                            endDate:
                                                endDateController.text.trim(),
                                            entry: chargeEntries,
                                            leaseAmount: rentAmount.text.trim(),
                                            leaseType: _selectedLeaseType ?? "",
                                            rentalId: renderId,
                                            startDate:
                                                startDateController.text.trim(),
                                            tenantId: tenantDataList
                                                .map((tenant) =>
                                                    tenant.tenantId ?? '')
                                                .toList(),
                                            tenantResidentStatus: false,
                                            unitId: _selectedUnit,
                                            // memo: rentMemo.text,
                                            uploadedFile: _uploadedFileNames,
                                          ),
                                          tenantData: tenantDataList,
                                        );

                                        await updateLeaseAndNavigate(lease);
                                        setState(() {
                                          isLoading = false; // Stop loading
                                        });
                                        if (applicantids != null &&
                                            applicantids!.isNotEmpty) {
                                          ifApplicantMoveIn(
                                              applicantids.first, applicantids);
                                        } else {
                                          print('No applicant id provided');
                                        }
                                        print('valid');
                                      }
                                    } else {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String adminId =
                                          prefs.getString("adminId")!;

                                      bool _isLeaseAdded = false;

                                      // // Printing ChargeData object
                                      //Changes
                                      List<Map<String, dynamic>>
                                          mergedFormDataList = [
                                        ...formDataOneTimeList,
                                        ...formDataRecurringList,
                                      ];

                                      // Creating Entry objects from the merged list
                                      List<Entry> chargeEntries =
                                          mergedFormDataList.map((data) {
                                        print(data['account']);
                                        return Entry(
                                          entry_id: data['entry_id'] ?? "",
                                          account: data['account'] ?? '',
                                          amount: double.tryParse(
                                                  data['amount'] ?? '0.0') ??
                                              0.0,
                                          chargeType: data['charge_type'] ?? '',
                                          date: data['date'] ?? '',
                                          isRepeatable: data['is_repeatable']
                                                  ?.toLowerCase() ==
                                              'true',
                                          memo: data['memo'] ?? '',
                                          rentCycle: data[
                                              'rent_cycle'], // Assuming this field might be present
                                          tenantId: data[
                                              'tenant_id'], // Assuming this field might be present
                                        );
                                      }).toList();
                                      // Creating ChargeData object
                                      ChargeData chargeData = ChargeData(
                                        adminId: adminId,
                                        entry: chargeEntries,
                                        isLeaseAdded: _isLeaseAdded,
                                      );

                                      print(
                                          'ChargeData: ${jsonEncode(chargeData.toJson())}');

                                      //consiger

                                      Map<String, String>? firstCosigner =
                                          cosignersMap.isNotEmpty
                                              ? cosignersMap[0]
                                              : {};
                                      List<TenantData> tenantDataList =
                                          tenantsMap.entries.map((entry) {
                                        final tenantMap = entry.value;
                                        print(tenantMap['firstName']);
                                        print(tenantMap['firstName']);
                                        return TenantData(
                                          adminId: adminId,
                                          comments: tenantMap['comments'] ?? '',
                                          emergencyContact: EmergencyContacts(
                                            name: tenantMap[
                                                    'emergencyContactName'] ??
                                                '',
                                            relation: tenantMap[
                                                    'emergencyRelation'] ??
                                                '',
                                            email:
                                                tenantMap['emergencyEmail'] ??
                                                    '',
                                            phoneNumber: tenantMap[
                                                    'emergencyPhoneNumber'] ??
                                                '',
                                          ),
                                          isDelete:
                                              tenantMap['isDelete'] == 'true',
                                          taxPayerId:
                                              tenantMap['taxPayerId'] ?? '',
                                          tenantAlternativeEmail:
                                              tenantMap['alterEmail'] ?? '',
                                          tenantAlternativeNumber:
                                              tenantMap['workNumber'] ?? '',
                                          tenantBirthDate:
                                              tenantMap['dob'].toString() ?? '',
                                          tenantEmail: tenantMap['email'] ?? '',
                                          tenantFirstName:
                                              tenantMap['firstName'] ?? '',
                                          tenantId: tenantMap['tenantId'] ?? '',
                                          tenantLastName:
                                              tenantMap['lastName'] ?? '',
                                          tenantPassword:
                                              tenantMap['passWord'] ?? '',
                                          tenantPhoneNumber:
                                              tenantMap['phoneNumber'] ?? '',
                                          updatedAt: tenantMap['updatedAt']
                                                  .toString() ??
                                              '',
                                        );
                                      }).toList();
                                      print('invalid');
                                      // _handleSubmit();
                                      print(firstCosigner);
                                      print(companyName);
                                      print(_selectedLeaseType ?? "");
                                      print(tenantDataList
                                          .map(
                                              (tenant) => tenant.tenantId ?? '')
                                          .toList());
                                      print(tenants.first.tenantFirstName);
                                      print(endDateController.text);
                                      print(rentAmount);
                                      //print( _selectedRent ??"");
                                      print(_selectedRent);
                                    }
                                  },
//                                     onPressed: () async {
//                                       // Validate the form
//                                       if (_formKey.currentState?.validate() ?? false) {
//                                         setState(() {
//                                           isLoading = true; // Stop loading
//                                         });
//                                         final provider = Provider.of<SelectedTenantsProvider>(context, listen: false);
//                                         final rentShareControllers = provider.rentShareControllers;
//
//                                         // Check for required tenants
//                                         if (rentShareControllers.length < 1) {
//                                           setState(() {
//                                             _errorMessage = "Required tenants";
//                                           });
//                                           return;
//                                         }
//
//                                         setState(() {
//                                           _errorMessage = null;
//                                         });
//
//                                         // Calculate total rent share
//                                         double totalRentShare = 0.0;
//                                         for (var controller in rentShareControllers) {
//                                           double rentShare = double.tryParse(controller.text) ?? 0.0;
//                                           totalRentShare += rentShare;
//                                         }
//
//                                         // Check if total rent share equals 100
//                                         if (totalRentShare != 100.0) {
//                                           setState(() {
//                                             _errorMessage = 'Total rent share must equal 100';
//                                           });
//                                           return;
//                                         }
//
//                                         // Check for changes in the form fields
//                                         bool hasChanges = rentAmount.text != initialRentAmount ||
//                                             rentMemo.text != initialRentMemo ||
//                                             rentNextDueDate.text != initialRentNextDueDate ||
//                                             securityDepositeAmount.text != initialSecurityDepositAmount ||
//                                             startDateController.text != initialStartDate ||
//                                             endDateController.text != initialEndDate ||
//                                             _selectedLeaseType != initialSelectedLeaseType ||
//                                             _selectedRent != initialSelectedRent;
//
//
//                                         if (!hasChanges) {
//                                           Navigator.pop(context,false);
//                                           return; // Exit the method if no changes
//                                         }
//
//                                         // Proceed with form submission
//                                         SharedPreferences prefs = await SharedPreferences.getInstance();
//                                         String adminId = prefs.getString("adminId")!;
//                                         bool _isLeaseAdded = false;
//
//                                         // Merge form data
//                                         List<Map<String, dynamic>> mergedFormDataList = [
//                                           ...formDataOneTimeList,
//                                           ...formDataRecurringList,
//                                         ];
//                                         log(mergedFormDataList.toString());
//
//                                         // Create charge entries from the merged list
//                                         List<Entry> chargeEntries = mergedFormDataList.map((data) {
//                                           return Entry(
//                                             entry_id: data['entry_id'] ?? "",
//                                             account: data['account'] ?? '',
//                                             amount: double.tryParse(data['amount'] ?? '0.0') ?? 0.0,
//                                             chargeType: data['charge_type'] ?? '',
//                                             date: data['date'] ?? '',
//                                             isRepeatable: data['is_repeatable']?.toLowerCase() == 'true',
//                                             memo: data['memo'] ?? '',
//                                             rentCycle: data['rent_cycle'],
//                                             tenantId: data['tenant_id'],
//                                           );
//                                         }).toList();
//
//                                         // Add rent entry
//                                         chargeEntries.add(Entry(
//                                           account: "Rent Income",
//                                           amount: double.tryParse(rentAmount.text) ?? 0.0,
//                                           chargeType: 'Rent',
//                                           date: reverseFormatDate(rentNextDueDate.text),
//                                           isRepeatable: false,
//                                           memo: 'Last Month\'s Rent',
//                                           rentCycle: _selectedRent,
//                                           entry_id: rent_entry_id,
//                                         ));
//
//                                         // Add security deposit entry
//                                         chargeEntries.add(Entry(
//                                           entry_id: rent_security_id,
//                                           account: "Security Deposit",
//                                           amount: double.tryParse(securityDepositeAmount.text) ?? 0.0,
//                                           chargeType: 'Security Deposit',
//                                           date: reverseFormatDate(rentNextDueDate.text),
//                                           isRepeatable: false,
//                                           memo: 'Security Deposit',
//                                           rentCycle: _selectedRent,
//                                         ));
//
//                                         // Create ChargeData object
//                                         ChargeData chargeData = ChargeData(
//                                           adminId: adminId,
//                                           entry: chargeEntries,
//                                           isLeaseAdded: _isLeaseAdded,
//                                         );
//                                         Map<String, String>? firstCosigner =
//                                         cosignersMap.isNotEmpty
//                                             ? cosignersMap[0]
//                                             : {};
//                                         // Prepare tenant data
//                                         List<TenantData> tenantDataList = tenantsMap.entries.map((entry) {
//                                           final tenantMap = entry.value;
//                                           return TenantData(
//                                             adminId: adminId,
//                                             comments: tenantMap['comments'] ?? '',
//                                             emergencyContact: EmergencyContacts(
//                                               name: tenantMap['emergencyContactName'] ?? '',
//                                               relation: tenantMap['emergencyRelation'] ?? '',
//                                               email: tenantMap ['emergencyEmail'] ?? '',
//                                               phoneNumber: tenantMap['emergencyPhoneNumber'] ?? '',
//                                             ),
//                                             isDelete: tenantMap['isDelete'] == 'true',
//                                             taxPayerId: tenantMap['taxPayerId'] ?? '',
//                                             rentalAddress: tenantMap['rental_adress'],
//                                             rentalUnit: tenantMap['rental_unit'],
//                                             tenantAlternativeEmail: tenantMap['alterEmail'] ?? '',
//                                             tenantAlternativeNumber: tenantMap['workNumber'] ?? '',
//                                             tenantBirthDate: tenantMap['dob'].toString() ?? '',
//                                             tenantEmail: tenantMap['email'] ?? '',
//                                             tenantFirstName: tenantMap['firstName'] ?? '',
//                                             tenantId: tenantMap['tenantId'] ?? '',
//                                             tenantLastName: tenantMap['lastName'] ?? '',
//                                             tenantPassword: tenantMap['passWord'] ?? '',
//                                             tenantPhoneNumber: tenantMap['phoneNumber'] ?? '',
//                                             rentShare: rentShareControllers[entry.key].text,
//                                           );
//                                         }).toList();
//
//                                         // Prepare lease data
//                                         Lease lease = Lease(
//                                           chargeData: ChargeData(
//                                             adminId: adminId,
//                                             entry: chargeEntries,
//                                             isLeaseAdded: true,
//                                           ),
//                                           cosignerData: CosignerData(
//                                               cosignerId:
//                                               firstCosigner?['c_id'],
//                                               cosignerFirstName:
//                                               firstCosigner?['firstName'] ??
//                                                   '',
//                                               cosignerLastName:
//                                               firstCosigner?['lastName'] ??
//                                                   '',
//                                               cosignerPhoneNumber:
//                                               firstCosigner?['phoneNumber'] ??
//                                                   '',
//                                               cosignerEmail:
//                                               firstCosigner?['email'] ??
//                                                   '',
//                                               cosignerAlternativeEmail:
//                                               firstCosigner?['alterEmail'] ??
//                                                   '',
//                                               cosignerAddress: firstCosigner?[
//                                               'streetAddress'] ??
//                                                   '',
//                                               cosignerCity:
//                                               firstCosigner?['city'] ??
//                                                   '',
//                                               cosignerCountry:
//                                               firstCosigner?['country'] ??
//                                                   '',
//                                               cosignerPostalcode:
//                                               firstCosigner?['postalCode'] ??
//                                                   '',
//                                               adminId: adminId),
//                                           leaseData: LeaseData(
//                                             leaseId: widget.leaseId,
//                                             adminId: adminId,
//                                             companyName: companyName,
//                                             endDate: reverseFormatDate(endDateController.text),
//                                             entry: chargeEntries,
//                                             leaseAmount: rentAmount.text,
//                                             leaseType: _selectedLeaseType,
//                                             rentalId: renderId,
//                                             startDate: reverseFormatDate(startDateController.text),
//                                             tenantId: tenantDataList.map((tenant) => tenant.tenantId ?? '').toList(),
//                                             tenantResidentStatus: false,
//                                             unitId: _selectedUnit,
//                                             uploadedFile: _uploadedFileNames,
//                                           ),
//
//                                           tenantData: tenantDataList,
//                                         );
// print(' start date ${reverseFormatDate(startDateController.text)}');
// print(' end date ${reverseFormatDate(endDateController.text)}');
//                                        await  updateLeaseAndNavigate(lease);
//                                         setState(() {
//                                           isLoading = false; // Stop loading
//                                         });
//                                       } else {
//                                         SharedPreferences prefs = await SharedPreferences.getInstance();
//                                         String adminId = prefs.getString("adminId")!;
//
//                                         bool _isLeaseAdded = false;
//
//                                         // Merge form data
//                                         List<Map<String, dynamic>> mergedFormDataList = [
//                                           ...formDataOneTimeList,
//                                           ...formDataRecurringList,
//                                         ];
//
//                                         // Create charge entries from the merged list
//                                         List<Entry> chargeEntries = mergedFormDataList.map((data) {
//                                           return Entry(
//                                             entry_id: data['entry_id'] ?? "",
//                                             account: data['account'] ?? '',
//                                             amount: double.tryParse(data['amount'] ?? '0.0') ?? 0.0,
//                                             chargeType: data['charge_type'] ?? '',
//                                             date: data['date'] ?? '',
//                                             isRepeatable: data['is_repeatable']?.toLowerCase() == 'true',
//                                             memo: data['memo'] ?? '',
//                                             rentCycle: data['rent_cycle'],
//                                             tenantId: data['tenant_id'],
//                                           );
//                                         }).toList();
//
//                                         // Create ChargeData object
//                                         ChargeData chargeData = ChargeData(
//                                           adminId: adminId,
//                                           entry: chargeEntries,
//                                           isLeaseAdded: _isLeaseAdded,
//                                         );
//
//                                         // Prepare tenant data
//                                         List<TenantData> tenantDataList = tenantsMap.entries.map((entry) {
//                                           final tenantMap = entry.value;
//                                           return TenantData(
//                                             adminId: adminId,
//                                             comments: tenantMap['comments'] ?? '',
//                                             emergencyContact: EmergencyContacts(
//                                               name: tenantMap['emergencyContactName'] ?? '',
//                                               relation: tenantMap['emergencyRelation'] ?? '',
//                                               email: tenantMap['emergencyEmail'] ?? '',
//                                               phoneNumber: tenantMap['emergencyPhoneNumber'] ?? '',
//                                             ),
//                                             isDelete: tenantMap['isDelete'] == 'true',
//                                             taxPayerId: tenantMap['taxPayerId'] ?? '',
//                                             rentalAddress: tenantMap['rental_adress'],
//                                             rentalUnit: tenantMap['rental_unit'],
//                                             tenantAlternativeEmail: tenantMap['alterEmail'] ?? '',
//                                             tenantAlternativeNumber: tenantMap['workNumber'] ?? '',
//                                             tenantBirthDate: tenantMap['dob'].toString() ?? '',
//                                             tenantEmail: tenantMap['email'] ?? '',
//                                             tenantFirstName: tenantMap['firstName'] ?? '',
//                                             tenantId: tenantMap['tenantId'] ?? '',
//                                             tenantLastName: tenantMap['lastName'] ?? '',
//                                             tenantPassword: tenantMap['passWord'] ?? '',
//                                             tenantPhoneNumber: tenantMap['phoneNumber'] ?? '',
//                                           );
//                                         }).toList();
//
//                                         print('invalid');
//                                       }
//                                     },
                                  child: Center(
                                      child: isLoading
                                          ? SpinKitFadingCircle(
                                              color: Colors.white,
                                              size: 25.0,
                                            )
                                          : Text(
                                              'Edit Lease',
                                              style: TextStyle(
                                                  color: Color(0xFFf7f8f9),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                )),
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
                                        backgroundColor:
                                            const Color(0xFFffffff),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style:
                                          TextStyle(color: Color(0xFF748097)),
                                    )))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> ifApplicantMoveIn(
      String applicantId, List<String> apnt_Id) async {
    bool success =
        await LeaseRepository().ifApplicantMoveInTrue(applicantId, apnt_Id);

    if (success) {
      Navigator.pop(context); // Replace with the actual navigation logic
    } else {
      // Handle the failure case, maybe show a message
      print('Failed to update applicant status');
    }
  }

  String reverseFormatDate(String inputDate) {
    DateTime parsedDate;

    try {
      // Try parsing the date as yyyy-MM-dd
      parsedDate = DateFormat('yyyy-MM-dd').parseStrict(inputDate);
    } catch (e) {
      try {
        // If the above fails, try parsing the date as dd-MM-yyyy
        parsedDate = DateFormat('dd-MM-yyyy').parseStrict(inputDate);
      } catch (e) {
        // Handle invalid date format or return an error
        throw FormatException("Invalid date format");
      }
    }

    // Return the date in the yyyy-MM-dd format
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  Future<void> updateLeaseAndNavigate(Lease lease) async {
    bool success = await LeaseRepository().updateLease(lease);

    if (success) {
      Navigator.pop(context, true); // Replace with the actual navigation logic
    } else {
      // Handle the failure case, maybe show a message
    }
  }

  Future<void> addLease() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString("adminId")!;

    bool _isLeaseAdded = false;

    // // Printing ChargeData object

    List<Map<String, dynamic>> mergedFormDataList = [
      ...formDataOneTimeList,
      ...formDataRecurringList,
    ];

    // Creating Entry objects from the merged list
    List<Entry> chargeEntries = mergedFormDataList.map((data) {
      print(data['account']);
      return Entry(
        account: data['account'] ?? '',
        amount: double.tryParse(data['amount'] ?? '0.0') ?? 0.0,
        chargeType: data['charge_type'] ?? '',
        date: data['date'] ?? '',
        isRepeatable: data['is_repeatable']?.toLowerCase() == 'true',
        memo: data['memo'] ?? '',
        rentCycle: data['rent_cycle'], // Assuming this field might be present
        tenantId: data['tenant_id'], // Assuming this field might be present
      );
    }).toList();

    // Creating ChargeData object
    ChargeData chargeData = ChargeData(
      adminId: adminId,
      entry: chargeEntries,
      isLeaseAdded: _isLeaseAdded,
    );

    print('ChargeData: ${jsonEncode(chargeData.toJson())}');

    setState(() {
      isLoading = false;
    });

    // if (success) {
    //   print('Form is valid');
    //   Fluttertoast.showToast(msg: "Tenant added successfully");
    //   Navigator.of(context).pop(true);
    // } else {
    //   print('Form is invalid');
    // }
  }

  tenent_popup(dynamic person, int index) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              title: Text('Add Tenant or Cosigner',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: blueColor)),
              content: Form(
                key: _addRecurringFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isTenantSelected = true;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: isTenantSelected
                                            ? null
                                            : Border.all(
                                                color: blueColor, width: 1),
                                        gradient: isTenantSelected
                                            ? LinearGradient(
                                                colors: [
                                                  blueColor,
                                                  blueColor,
                                                ],
                                              )
                                            : null,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding: isTenantSelected
                                          ? const EdgeInsets.symmetric(
                                              vertical: 13)
                                          : const EdgeInsets.symmetric(
                                              vertical: 12),
                                      child: isTenantSelected
                                          ? Text(
                                              "Tenant",
                                              style: TextStyle(
                                                color: !isTenantSelected
                                                    ? Colors.transparent
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : ShaderMask(
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  colors: [
                                                    blueColor,
                                                  ],
                                                ).createShader(bounds);
                                              },
                                              child: Text(
                                                "Tenant",
                                                style: TextStyle(
                                                  color: isTenantSelected
                                                      ? Colors.transparent
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isTenantSelected = false;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: isTenantSelected == false
                                            ? null
                                            : Border.all(
                                                color: blueColor, width: 1),
                                        gradient: isTenantSelected == false
                                            ? LinearGradient(
                                                colors: [
                                                  blueColor,
                                                  blueColor,
                                                ],
                                              )
                                            : null,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding: isTenantSelected
                                          ? const EdgeInsets.symmetric(
                                              vertical: 12)
                                          : const EdgeInsets.symmetric(
                                              vertical: 13),
                                      child: !isTenantSelected
                                          ? Text(
                                              "Cosigner",
                                              style: TextStyle(
                                                color: isTenantSelected
                                                    ? Colors.transparent
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : ShaderMask(
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  colors: [
                                                    blueColor,
                                                  ],
                                                ).createShader(bounds);
                                              },
                                              child: Text(
                                                "Cosigner",
                                                style: TextStyle(
                                                  color: !isTenantSelected
                                                      ? Colors.transparent
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            isTenantSelected
                                ? const AddTenant()
                                : AddCosigner(
                                    cosigner: person,
                                    index: index,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                    height: 50,
                    width: 90,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0))),
                        onPressed: () {
                          if (_addRecurringFormKey.currentState!.validate()) {
                            print('object valid');
                          } else {
                            print('object invalid');
                          }
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Color(0xFFf7f8f9)),
                        ))),
                Container(
                    height: 50,
                    width: 94,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFffffff),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF748097)),
                        )))
              ],
            );
          });
        });
  }
}

class OneTimeChargePopUp extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  OneTimeChargePopUp({required this.onSave, this.initialData});

  @override
  State<OneTimeChargePopUp> createState() => _OneTimeChargePopUpState();
}

class _OneTimeChargePopUpState extends State<OneTimeChargePopUp> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _subFormKey = GlobalKey<FormState>();
  String? _selectedAccountType;
  String? _selectedFundType;
  final TextEditingController _accountNameController = TextEditingController();
  String? _selectedProperty;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();
  bool _isInvalid = true;
  List<String> items = []; // Example items

  List<String> accountTypeItems = [
    'Income',
    'Non Operating Income ',
    'Liability Account',
  ]; // Example items
  List<String> fundTypeItems = [
    'Reverse',
    'Operating',
  ]; // Example items

  bool _isLoading = true;
  List<String> accounts = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedProperty = widget.initialData!['account'] ?? '';
      _amountController.text = widget.initialData!['amount'] ?? '';
      _memoController.text = widget.initialData!['memo'] ?? '';
    }
    fetchData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('$Api_url/api/accounts/accounts/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $staffid",
    });
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        items = (data['data'] as List)
            .where((item) => item['charge_type'] == "One Time Charge")
            .map((item) => item['account'] as String)
            .toList();
        _isLoading = false;
        print(items.length);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              child: Container(
                  color: Colors.white,
                  height: _isInvalid ? 385 : 395,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          'Add One Time Charge Content',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Account *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isLoading
                            ? const Center(
                                child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 50.0,
                              ))
                            : DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Select',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFFb0b6c3),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: [
                                    ...items.map((String item) =>
                                        DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                                    //updated

                                    DropdownMenuItem<String>(
                                      value: 'button_item',
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0)),
                                            elevation: 0,
                                            backgroundColor: Colors.white),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                return AlertDialog(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  backgroundColor: Colors.white,
                                                  title: Text(
                                                    'Add Account',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                  content: Container(
                                                    height: 450,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Form(
                                                        key: _subFormKey,
                                                        child: ListView(
                                                          children: [
                                                            const Text(
                                                              'Account Name *',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            CustomTextField(
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Please enter Account Name';
                                                                }
                                                                return null;
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              hintText:
                                                                  'Enter Account Name',
                                                              controller:
                                                                  _accountNameController,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            const Text(
                                                              'Account Type',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            CustomDropdown(
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Please select a Account Type';
                                                                }
                                                                return null;
                                                              },
                                                              labelText:
                                                                  'Select Account Type',
                                                              items:
                                                                  accountTypeItems,
                                                              selectedValue:
                                                                  _selectedAccountType,
                                                              onChanged:
                                                                  (String?
                                                                      value) {
                                                                setState(() {
                                                                  _selectedAccountType =
                                                                      value;
                                                                });
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            const Text(
                                                              'Fund Type',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            CustomDropdown(
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Please select a Fund Type';
                                                                }
                                                                return null;
                                                              },
                                                              labelText:
                                                                  'Select Fund Type',
                                                              items:
                                                                  fundTypeItems,
                                                              selectedValue:
                                                                  _selectedFundType,
                                                              onChanged:
                                                                  (String?
                                                                      value) {
                                                                setState(() {
                                                                  _selectedFundType =
                                                                      value;
                                                                });
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            const Text(
                                                              'Notes',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            CustomTextField(
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Please enter Notes';
                                                                }
                                                                return null;
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              hintText:
                                                                  'Enter Notes',
                                                              controller:
                                                                  _notesController,
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            RichText(
                                                              text:
                                                                  const TextSpan(
                                                                children: <TextSpan>[
                                                                  TextSpan(
                                                                    text:
                                                                        'We stores this information ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        'Privately',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' and ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        'Securely',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Container(
                                                                    height: 50,
                                                                    width: 90,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0)),
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(backgroundColor: blueColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                                                        onPressed: () {
                                                                          _submitSubForm();
                                                                        },
                                                                        child: const Text(
                                                                          'Add',
                                                                          style:
                                                                              TextStyle(color: Color(0xFFf7f8f9)),
                                                                        ))),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Container(
                                                                    height: 50,
                                                                    width: 94,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0)),
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFffffff), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                          'Cancel',
                                                                          style:
                                                                              TextStyle(color: Color(0xFF748097)),
                                                                        )))
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                          );
                                        },
                                        child: const Text(
                                          'Add New Account',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ],
                                  value: _selectedProperty,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedProperty = value;
                                    });
                                    // widget.onChanged(value);
                                    // state.didChange(value);
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 45,
                                    width: 160,
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
                                    padding:
                                        EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 8),
                        const Text(
                          'Amount *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          hintText: 'Enter Amount',
                          controller: _amountController,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Memo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter memo';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          hintText: 'Enter Memo',
                          controller: _memoController,
                          optional: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                height: 50,
                                width: 90,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0))),
                                    onPressed: () {
                                      _submitForm();
                                    },
                                    child: const Text(
                                      'Add',
                                      style:
                                          TextStyle(color: Color(0xFFf7f8f9)),
                                    ))),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                                height: 50,
                                width: 94,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFffffff),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style:
                                          TextStyle(color: Color(0xFF748097)),
                                    )))
                          ],
                        ),
                      ])),
            )));
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isInvalid = true;
      });
      final formData = {
        'account': _selectedProperty ?? '',
        'amount': _amountController.text.trim(),
        'memo': _memoController.text.trim(),
        'charge_type': 'One Time Charge',
        'date': DateTime.now().toString()
      };
      widget.onSave(formData);
      setState(() {
        _isInvalid = false;
      });
    } else {
      setState(() {
        _isInvalid = false;
      });
    }
  }

  Future _submitSubForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId').toString();
    print(adminId);
    if (_subFormKey.currentState?.validate() ?? false) {
      final formData = {
        'admin_id': adminId,
        'account': _accountNameController.text.trim(),
        'account_type': _selectedAccountType ?? '',
        'fund_type': _selectedFundType ?? '',
        'notes': _notesController.text.trim(),
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('adminId');
      String? staffid = prefs.getString("staff_id");
      String? token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('$Api_url/api/accounts/accounts'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $staffid",
          'Content-Type': 'application/json'
        },
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        widget.onSave(formData);
        Navigator.of(context).pop();
        print(response.body);
        Fluttertoast.showToast(msg: 'Account Added Successfully');
      } else {
        // Handle error response
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add account')),
        );
      }
    } else {
      setState(() {
        _isInvalid = true;
      });
    }
  }
}

class RecurringChargePopUp extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final Map<String, String>? initialData;

  RecurringChargePopUp({required this.onSave, this.initialData});

  @override
  State<RecurringChargePopUp> createState() => _RecurringChargePopUpState();
}

class _RecurringChargePopUpState extends State<RecurringChargePopUp> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _subFormKey = GlobalKey<FormState>();
  String? _selectedAccountType;
  String? _selectedFundType;
  final TextEditingController _accountNameController = TextEditingController();
  String? _selectedProperty;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();
  bool _isInvalid = true;
  List<String> items = []; // Example items

  List<String> accountTypeItems = [
    'Income',
    'Non Operating Income ',
    'Liability Account',
  ]; // Example items
  List<String> fundTypeItems = [
    'Reverse',
    'Operating',
  ]; // Example items

  bool _isLoading = true;
  List<String> accounts = [];

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.initialData != null) {
  //     _selectedProperty = widget.initialData!['property'] ?? '';
  //     _amountController.text = widget.initialData!['amount'] ?? '';
  //     _memoController.text = widget.initialData!['memo'] ?? '';
  //   }
  //   fetchData();
  // }

  // @override
  // void dispose() {
  //   _amountController.dispose();
  //   _memoController.dispose();
  //   super.dispose();
  // }

  // Future<void> fetchData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String adminId = prefs.getString('adminId').toString();
  //   final response =
  //       await http.get(Uri.parse('$Api_url/api/accounts/accounts/$adminId'));
  //   print(response.body);
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     setState(() {
  //       items = (data['data'] as List)
  //           .where((item) => item['charge_type'] == "One Time Charge")
  //           .map((item) => item['account'] as String)
  //           .toList();
  //       _isLoading = false;
  //       print(items.length);
  //     });
  //   } else {
  //     // Handle error
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to fetch data')),
  //     );
  //   }
  // }

// updated
  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedProperty = widget.initialData!['account'] ?? '';
      _amountController.text = widget.initialData!['amount'] ?? '';
      _memoController.text = widget.initialData!['memo'] ?? '';
      String dateString = widget.initialData!['date'] ?? "";
      if (dateString.isNotEmpty) {
        DateTime date = DateTime.parse(dateString);
        selectedDay = date.day.toString(); // Extracts only the day
      } else {
        selectedDay = ""; // Handle empty case
      }
    }
    fetchData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('$Api_url/api/accounts/accounts/$adminid'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        items = (data['data'] as List)
            .where((item) => item['charge_type'] == "Recurring Charge")
            .map((item) => item['account'] as String)
            .toList();
        _isLoading = false;
        print(items.length);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }
  String? selectedDay;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          child: Container(
            color: Colors.white,
            height: _isInvalid ? 460 : 475,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2),
                Text(
                  'Add Recurring content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Account *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 50.0,
                      ))
                    : DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Select',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFb0b6c3),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: [
                            ...items
                                .map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                            //updated
                            DropdownMenuItem<String>(
                              value: 'button_item',
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return Dialog(
                                          backgroundColor: Colors.white,
                                          surfaceTintColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: SingleChildScrollView(
                                            child: Container(
                                              // height: 450,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Form(
                                                  key: _subFormKey,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Add account',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        'Account Name *',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      CustomTextField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter Account Name';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType:
                                                            TextInputType.text,
                                                        hintText:
                                                            'Enter Account Name',
                                                        controller:
                                                            _accountNameController,
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        'Account Type',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      CustomDropdown(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please select a Account Type';
                                                          }
                                                          return null;
                                                        },
                                                        labelText:
                                                            'Select Account Type',
                                                        items: accountTypeItems,
                                                        selectedValue:
                                                            _selectedAccountType,
                                                        onChanged:
                                                            (String? value) {
                                                          setState(() {
                                                            _selectedAccountType =
                                                                value;
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        'Fund Type',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      CustomDropdown(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please select a Fund Type';
                                                          }
                                                          return null;
                                                        },
                                                        labelText:
                                                            'Select Fund Type',
                                                        items: fundTypeItems,
                                                        selectedValue:
                                                            _selectedFundType,
                                                        onChanged:
                                                            (String? value) {
                                                          setState(() {
                                                            _selectedFundType =
                                                                value;
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        'Notes',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      CustomTextField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter Notes';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType:
                                                            TextInputType.text,
                                                        hintText: 'Enter Notes',
                                                        controller:
                                                            _notesController,
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      RichText(
                                                        text: const TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text:
                                                                  'We stores this information ',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' Privately ',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: ' and ',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' Securely ',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                              height: 50,
                                                              width: 90,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          8.0)),
                                                              child:
                                                                  ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          backgroundColor: const Color(
                                                                              0xFF152b51),
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                  8.0))),
                                                                      onPressed:
                                                                          () {
                                                                        _submitSubForm();
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Add',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFFf7f8f9)),
                                                                      ))),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Container(
                                                              height: 50,
                                                              width: 94,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          8.0)),
                                                              child:
                                                                  ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          backgroundColor: const Color(
                                                                              0xFFffffff),
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                  8.0))),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Cancel',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFF748097)),
                                                                      )))
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Add New Account',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          value: _selectedProperty,
                          onChanged: (value) {
                            setState(() {
                              _selectedProperty = value;
                            });
                            // widget.onChanged(value);
                            // state.didChange(value);
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 45,
                            width: 160,
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
                const SizedBox(height: 8),
                Text(
                  'Amount *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  hintText: 'Enter Amount',
                  controller: _amountController,
                ),
                const SizedBox(height: 8),
                Text(
                  'Memo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter memo';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  hintText: 'Enter Memo',
                  controller: _memoController,
                  optional: true,
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose Day of Month *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  //width: 200,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Day'),
                      isExpanded: true,
                      menuMaxHeight: 200,
                      value: selectedDay,
                      items: List.generate(28, (i) => i + 1)
                          .map((day) => DropdownMenuItem<String>(
                        value: day.toString(),
                        child: Text('$day'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value;
                        });
                      },

                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        height: 50,
                        width: 90,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () {
                              _submitForm();
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(color: Color(0xFFf7f8f9)),
                            ))),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                        height: 50,
                        width: 94,
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
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF748097)),
                            )))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isInvalid = true;
      });
      DateTime now = DateTime.now();
      int selectedYear = now.year;
      int selectedMonth = now.month;

      // Construct the date using the selected day, current year, and month
      int selectedDayInt = int.parse(selectedDay!);
      DateTime currentDate = DateTime(selectedYear, selectedMonth, selectedDayInt);

      // Add one month
      DateTime nextMonthDate = DateTime(
        currentDate.year,
        currentDate.month + 1,
        currentDate.day,
      );

      // Format date to always have two-digit months and days
      String formattedDate = "${nextMonthDate.year}-"
          "${nextMonthDate.month.toString().padLeft(2, '0')}-"
          "${nextMonthDate.day.toString().padLeft(2, '0')}";
      String? id =  widget.initialData!['entry_id'] != "" ?
      widget.initialData!['entry_id']
          : "";
      final formData = {
        'account': _selectedProperty ?? '',
        'amount': _amountController.text.trim(),
        'memo': _memoController.text.trim(),
        'entry_id':id!,
        'charge_type': 'Recurring Charge',
        'date': formattedDate,
      };
      widget.onSave(formData);
      setState(() {
        _isInvalid = false;
      });
    } else {
      setState(() {
        _isInvalid = false;
      });
    }
  }

  Future _submitSubForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId').toString();
    print(adminId);
    if (_subFormKey.currentState?.validate() ?? false) {
      final formData = {
        'admin_id': adminId,
        'account': _accountNameController.text.trim(),
        'account_type': _selectedAccountType ?? '',
        'fund_type': _selectedFundType ?? '',
        'notes': _notesController.text.trim(),
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('adminId');
      String? token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('$Api_url/api/accounts/accounts'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
        body: json.encode(formData),
      );
      if (response.statusCode == 200) {
        widget.onSave(formData);
        Navigator.of(context).pop(true);
        print(response.body);
        Fluttertoast.showToast(msg: 'Account Added Successfully');
      } else {
        // Handle error response
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add account')),
        );
      }
    } else {
      setState(() {
        _isInvalid = true;
      });
    }
  }
}

class AddTenant extends StatefulWidget {
  const AddTenant({super.key});

  @override
  State<AddTenant> createState() => _AddTenantState();
}

class _AddTenantState extends State<AddTenant> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController workNumber = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController alterEmail = TextEditingController();
  final TextEditingController passWord = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController taxPayerId = TextEditingController();
  final TextEditingController comments = TextEditingController();
  final TextEditingController contactName = TextEditingController();
  final TextEditingController relationToTenant = TextEditingController();
  final TextEditingController emergencyEmail = TextEditingController();
  final TextEditingController emergencyPhoneNumber = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool _obscureText = true;
  //bool _ischecked = false;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredTenants = tenants;
    selected = List<bool>.generate(tenants.length, (index) => false);

    fetchTenantsAndApplicants();
    filteredApplicant = Applicant;
    select = List<bool>.generate(Applicant.length, (index) => false);
    // fetchTenants();
  }

  List<Datum> Applicant = [];
  List<Datum> filteredApplicant = [];
  List<Datum> selectedApplicant = [];
  List<bool> select = [];
  Future<void> fetchTenantsAndApplicants() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminid = prefs.getString("adminId");
      String? id = prefs.getString("staff_id");
      String? token = prefs.getString('token');

      // Fetch tenants
      final tenantResponse = await http
          .get(Uri.parse('${Api_url}/api/tenant/tenants/$adminid'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      // if (tenantResponse.statusCode == 200) {
      //   Map<String, dynamic> tenantData = json.decode(tenantResponse.body);
      //   if (tenantData.containsKey('data')) {
      //     List<dynamic> tenantList = tenantData['data']['tenants'];
      //     tenants = tenantList.map((item) => Tenant.fromJson(item)).toList();
      //   } else {
      //     print("Unexpected tenant response structure: Missing 'data' key");
      //   }
      // } else {
      //   print("Failed to load tenants: ${tenantResponse.statusCode}");
      // }

      if (tenantResponse.statusCode == 200) {
        Map<String, dynamic> tenantData = json.decode(tenantResponse.body);
        if (tenantData.containsKey('data')) {
          List<dynamic> tenantList = tenantData['data']['tenants'];
          List<dynamic> applicantlist = tenantData['data']['applicants'];

          tenants = tenantList.map((item) => Tenant.fromJson(item)).toList();
          tenants.addAll(applicantlist
              .map((item) => convertApplicantToTenant(Datum.fromJson(item)))
              .toList());
        } else {
          print("Unexpected tenant response structure: Missing 'data' key");
        }
      } else {
        print("Failed to load tenants: ${tenantResponse.statusCode}");
      }

      // Fetch applicants
      // final applicantResponse = await http
      //     .get(Uri.parse('${Api_url}/api/applicant/applicant/$adminid'), headers: {
      //   "authorization": "CRM $token",
      //   "id": "CRM $id",
      // });

      // if (applicantResponse.statusCode == 200) {
      //   Map<String, dynamic> applicantData = json.decode(applicantResponse.body);
      //   if (applicantData.containsKey('data')) {
      //     List<dynamic> applicantList = applicantData['data'];
      //     List<Tenant> convertedApplicants = applicantList
      //         .map((item) => convertApplicantToTenant(Datum.fromJson(item)))
      //         .toList();
      //
      //     // Merge tenants and converted applicants
      //     tenants.addAll(convertedApplicants);
      //   } else {
      //     print("Unexpected applicant response structure: Missing 'data' key");
      //   }
      // } else {
      //   print("Failed to load applicants: ${applicantResponse.statusCode}");
      // }

      // Update filtered list and selection state
      filteredTenants = List.from(tenants);
      selected = List<bool>.filled(tenants.length, false);
    } catch (e) {
      print("Error fetching tenants or applicants: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Tenant convertApplicantToTenant(Datum applicant) {
    return Tenant(
      applicantId: applicant.applicantId,
      tenantFirstName: applicant.applicantFirstName,
      tenantLastName: applicant.applicantLastName,
      tenantEmail: applicant.applicantEmail,
      tenantPhoneNumber: applicant.applicantPhoneNumber.toString(),
      tenantId: null, // Explicitly set tenantId as null
    );
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
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.blue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  bool isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _showalterNumber = false;
  bool _showalterEmail = false;
  bool _showPersonalDetail = false;
  bool _showEmergancyDetail = false;
  bool isChecked = false;
  bool isLoading = false;
  int? selectedIndex;
  List<Tenant> tenants = [];
  List<Tenant> filteredTenants = [];
  List<Tenant> selectedTenants = [];
  List<bool> selected = [];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> fetchTenants() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //String? id = prefs.getString("adminId");
      String? id = prefs.getString("adminId");
      String? staffid = prefs.getString("staff_id");
      String? token = prefs.getString('token');
      final response = await http
          .get(Uri.parse('${Api_url}/api/tenant/tenants/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffid",
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the response contains the expected keys
        if (responseData.containsKey('data')) {
          List<dynamic> data = responseData['data']['tenants'];
          tenants = data.map((item) => Tenant.fromJson(item)).toList();
          filteredTenants = List.from(tenants);
          selected = List<bool>.filled(tenants.length, false);
        } else {
          // Handle unexpected response structure
          print("Unexpected response structure: Missing 'data' key");
        }
      } else {
        // Handle HTTP errors
        print("Failed to load tenants: ${response.statusCode}");
      }
    } catch (e) {
      // Handle other errors
      print("Error fetching tenants: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //
  // void filterOwners(String query) {
  //   setState(() {
  //     filteredOwners = owners.where((owner) {
  //       final fullName = '${owner.firstName} ${owner.lastName}'.toLowerCase();
  //       return fullName.contains(query.toLowerCase());
  //     }).toList();
  //   });
  // }
  List<Tenant> selectedTenantsTemp = [];
  @override
  Widget build(BuildContext context) {
    var selectedTenantsProvider =
        Provider.of<SelectedTenantsProvider>(context, listen: false);
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            //checked
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
                    activeColor: isChecked ? blueColor : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            isChecked
                ? Column(
                    children: [
                      SizedBox(height: 16.0),
                      SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Tenant Name')),
                            DataColumn(label: Text('Select')),
                          ],
                          rows: filteredTenants.map((tenant) {
                            final matchingTenants =
                            Provider.of<SelectedTenantsProvider>(context)
                                .selectedTenants
                                .where((test) => tenant.tenantId != null ?
                            test.tenantId == tenant.tenantId : test.applicantId ==tenant.applicantId)
                                .toList();
                            print(matchingTenants);

                            final isSelected =
                            matchingTenants.length > 0 ? true : false;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                      '${tenant.tenantFirstName} ${tenant.tenantLastName}'),
                                ),
                                DataCell(
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        if (value!) {
                                          selectedTenantsProvider
                                              .addTenant(tenant);
                                        } else {
                                          selectedTenantsProvider
                                              .removeTenant(tenant);
                                        }
                                        setState(() {});
                                      },
                                      activeColor: blueColor,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                for (var tenant in selectedTenantsTemp) {
                                  selectedTenantsProvider.addTenant(tenant);
                                }
                                // Clear the temporary list after adding
                                selectedTenantsTemp.clear();
                              });
                              Navigator.pop(context);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: 40.0,
                                width: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: blueColor,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Add",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      //contact information
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: blueColor,
                            border: Border.all(
                              color: blueColor,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Contact information tenant',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white)),
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('First Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter first name',
                              controller: firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the first name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Last Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter last name',
                              controller: lastName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the last name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Phone Number *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                PhoneNumberFormatter(),
                              ],
                              hintText: 'Enter phone number',
                              controller: phoneNumber,
                              otherController: workNumber,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the phone number';
                                }
                                return null;
                              },
                              phone: true,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            _showalterNumber
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text('Work Number',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                            PhoneNumberFormatter(),
                                          ],
                                          keyboardType: TextInputType.number,
                                          hintText: 'Enter work number',
                                          controller: workNumber,
                                          otherController: phoneNumber,
                                          optional: true,
                                          phone: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            if (_showalterNumber == false)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showalterNumber = !_showalterNumber;
                                  });
                                },
                                child: const Text('+Add alternative Phone',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2ec433))),
                              ),
                            if (_showalterNumber == true)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showalterNumber = !_showalterNumber;
                                  });
                                },
                                child: const Text('-Remove alternative Phone',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2ec433))),
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Email *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter Email',
                              controller: email,
                              email: true,
                              alterController: alterEmail,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                } else if (!isValidEmail(value)) {
                                  print('!isValidEmail(value) invalid');
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            _showalterEmail
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text('Alternative Email',
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
                                          hintText: 'Enter alternative email',
                                          controller: alterEmail,
                                          optional: true,
                                          email: true,
                                          alterController: email,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            if (_showalterEmail == false)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showalterEmail = !_showalterEmail;
                                  });
                                },
                                child: const Text('+Add alternative Email',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2ec433))),
                              ),
                            if (_showalterEmail == true)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showalterEmail = !_showalterEmail;
                                  });
                                },
                                child: const Text('-Remove alternative Email',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2ec433))),
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Password *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.text,
                                    obscureText: !_obscureText,
                                    hintText: 'Enter password',
                                    controller: passWord,
                                    optional: true,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'please enter password';
                                      }
                                      return null;
                                    },
                                    pass: true,
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        10), // Add some space between the widgets
                                Container(
                                  width: 38,
                                  height: 40,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: _toggleObscureText,
                                      child: FaIcon(
                                        _obscureText
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      const BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 8.0,
                                        spreadRadius: 1.0,
                                      ),
                                    ],
                                    border: Border.all(
                                        width: 0, color: Colors.white),
                                    borderRadius: BorderRadius.circular(6.0),
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
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPersonalDetail = !_showPersonalDetail;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: blueColor,
                              border: Border.all(
                                color: blueColor,
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('+    Personal Information',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                      _showPersonalDetail
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Text('Date of Birth',
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    child: TextFormField(
                                      style: const TextStyle(
                                        color: Color(0xFF8898aa), // Text color
                                        fontSize: 16.0, // Text size
                                        fontWeight:
                                            FontWeight.w400, // Text weight
                                      ),
                                      controller: _dateController,
                                      decoration: InputDecoration(
                                        hintStyle: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Color(0xFFb0b6c3)),
                                        border: InputBorder.none,
                                        // labelText: 'Select Date',
                                        hintText: 'YYYY-MM-DD',
                                        suffixIcon: IconButton(
                                          icon:
                                              const Icon(Icons.calendar_today),
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
                                  const Text('TaxPayer ID',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    keyboardType: TextInputType.text,
                                    hintText: 'Enter contact name',
                                    controller: taxPayerId,
                                    optional: true,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('Comments',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 90,
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: comments,
                                        maxLines: 5,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFFb0b6c3)),
                                          hintText: 'Enter the comment',
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showEmergancyDetail = !_showEmergancyDetail;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: blueColor,
                              border: Border.all(
                                color: blueColor,
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('+    Emergency Contact',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                      _showEmergancyDetail
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Text('Contact Name',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    keyboardType: TextInputType.text,
                                    hintText: 'Enter contact name',
                                    controller: contactName,
                                    optional: true,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('Relationship to Tenant',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    keyboardType: TextInputType.text,
                                    hintText: 'Enter relationship to tenant',
                                    controller: relationToTenant,
                                    optional: true,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('E-Mail',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    keyboardType: TextInputType.emailAddress,
                                    hintText: 'Enter email',
                                    controller: emergencyEmail,
                                    optional: true,
                                    email: true,
                                    emrgencyController: alterEmail,
                                    alterController: email,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('Phone Number',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                      PhoneNumberFormatter(),
                                    ],
                                    hintText: 'Enter phone number',
                                    controller: emergencyPhoneNumber,
                                    optional: true,
                                    otherController: phoneNumber,
                                    businessController: workNumber,
                                    phone: true,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 30,
                      ),
                      if (isChecked == false)
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  final tenant = Tenant(
                                    tenantFirstName: firstName.text.trim(),
                                    tenantLastName: lastName.text.trim(),
                                    tenantPhoneNumber: phoneNumber.text.trim(),
                                    tenantAlternativeNumber: workNumber.text.trim(),
                                    tenantEmail: email.text.trim(),
                                    tenantAlternativeEmail: alterEmail.text.trim(),
                                    tenantPassword: passWord.text.trim(),
                                    tenantBirthDate: _dateController.text.trim(),
                                    taxPayerId: taxPayerId.text.trim(),
                                    comments: comments.text.trim(),
                                    rentshare: "",
                                    emergencyContact: EmergencyContact(
                                      name: contactName.text.trim(),
                                      relation: relationToTenant.text.trim(),
                                      email: emergencyEmail.text.trim(),
                                      phoneNumber: emergencyPhoneNumber.text.trim(),
                                    ),
                                  );
                                  Provider.of<SelectedTenantsProvider>(context,
                                          listen: false)
                                      .addTenant(tenant);
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  height: 40.0,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: blueColor,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Add",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class AddCosigner extends StatefulWidget {
  Cosigner? cosigner;
  int? index;
  AddCosigner({super.key, this.cosigner, this.index});

  @override
  State<AddCosigner> createState() => _AddCosignerState();
}

class _AddCosignerState extends State<AddCosigner> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController workNumber = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController alterEmail = TextEditingController();
  final TextEditingController streetAddrees = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  bool _showalterNumber = false;
  bool _showalterEmail = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.cosigner != null) {
      firstName.text = widget.cosigner!.firstName;
      lastName.text = widget.cosigner!.lastName;
      phoneNumber.text = widget.cosigner!.phoneNumber;
      workNumber.text = widget.cosigner!.workNumber;
      email.text = widget.cosigner!.email;
      alterEmail.text = widget.cosigner!.alterEmail;
      streetAddrees.text = widget.cosigner!.streetAddress;
      city.text = widget.cosigner!.city;
      country.text = widget.cosigner!.country;
      postalCode.text = widget.cosigner!.postalCode;
      _showalterNumber = widget.cosigner!.workNumber.isNotEmpty ? true : false;
      _showalterEmail = widget.cosigner!.alterEmail.isNotEmpty ? true : false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: blueColor,
                border: Border.all(
                  color: blueColor,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Contact information cosinger',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white)),
            ),
          ),
          Container(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('First Name *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    keyboardType: TextInputType.text,
                    hintText: 'Enter first name',
                    controller: firstName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter the first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Last Name *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    keyboardType: TextInputType.text,
                    hintText: 'Enter last name',
                    controller: lastName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter the last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Phone Number *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    keyboardType: TextInputType.number,
                    hintText: 'Enter phone number',
                    controller: phoneNumber,
                    otherController: workNumber,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                      PhoneNumberFormatter(),
                    ],
                    phone: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter the phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_showalterNumber == false)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showalterNumber = !_showalterNumber;
                        });
                      },
                      child: const Text('+Add alternative Phone',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2ec433))),
                    ),
                  if (_showalterNumber == true)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showalterNumber = !_showalterNumber;
                        });
                      },
                      child: const Text('-Remove alternative Phone',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2ec433))),
                    ),
                  _showalterNumber
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Work Number',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                  PhoneNumberFormatter(),
                                ],
                                keyboardType: TextInputType.number,
                                hintText: 'Enter work number',
                                controller: workNumber,
                                otherController: phoneNumber,
                                optional: true,
                                phone: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Email *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter Email',
                    controller: email,
                    email: true,
                    alterController: alterEmail,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_showalterEmail == false)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showalterEmail = !_showalterEmail;
                        });
                      },
                      child: const Text('+Add alternative Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2ec433))),
                    ),
                  if (_showalterEmail == true)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showalterEmail = !_showalterEmail;
                        });
                      },
                      child: const Text('-Remove alternative Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2ec433))),
                    ),
                  _showalterEmail
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Alternative Email',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'Enter alternative email',
                                controller: alterEmail,
                                alterController: email,
                                email: true,
                                optional: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: blueColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('City',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  hintText: 'Enter city',
                  controller: city,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter the city';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Country',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  hintText: 'Enter country',
                  controller: country,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter country';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Zip code',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return TextEditingValue(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                  hintText: 'Enter zip code',
                  controller: postalCode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter zip code';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if (widget.cosigner == null) {
                            final cosigner = Cosigner(
                              c_id: firstName.text.trim(),
                              firstName: firstName.text.trim(),
                              lastName: lastName.text.trim(),
                              phoneNumber: phoneNumber.text.trim(),
                              workNumber: workNumber.text.trim(),
                              email: email.text.trim(),
                              alterEmail: alterEmail.text.trim(),
                              streetAddress: streetAddrees.text.trim(),
                              city: city.text.trim(),
                              country: country.text.trim(),
                              postalCode: postalCode.text.trim(),
                            );
                            Provider.of<SelectedCosignersProvider>(context,
                                    listen: false)
                                .addCosigner(cosigner);
                          } else {
                            final cosigner = Cosigner(
                              //c_id : firstName.text,
                              firstName: firstName.text.trim(),
                              lastName: lastName.text.trim(),
                              phoneNumber: phoneNumber.text.trim(),
                              workNumber: workNumber.text.trim(),
                              email: email.text.trim(),
                              alterEmail: alterEmail.text.trim(),
                              streetAddress: streetAddrees.text.trim(),
                              city: city.text.trim(),
                              country: country.text.trim(),
                              postalCode: postalCode.text.trim(),
                            );
                            Provider.of<SelectedCosignersProvider>(context,
                                    listen: false)
                                .updateCosigner(cosigner, widget.index!);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => Edit_lease(cosigner: cosigner),
                            //   ),
                            // );
                          }
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 40.0,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: blueColor,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? labelText;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  CustomDropdown({
    Key? key,
    required this.labelText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.validator,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.labelText ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFb0b6c3),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                items: widget.items
                    .map((String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                value: widget.selectedValue,
                onChanged: (value) {
                  widget.onChanged(value);
                  state.didChange(value);
                },
                buttonStyleData: ButtonStyleData(
                  height: 45,
                  width: 160,
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
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 8),
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
    );
  }
}
