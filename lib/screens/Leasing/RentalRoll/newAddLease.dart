import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

class addLease extends StatefulWidget {
  const addLease({super.key});

  @override
  State<addLease> createState() => _addLeaseState();
}

class _addLeaseState extends State<addLease>
    with SingleTickerProviderStateMixin {
  bool InValid = false;

  bool isEnjoyNowSelected = true;
  bool isTenantSelected = true;
  String? _selectedProperty;
  String? _selectedLeaseType;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _addRecurringFormKey = GlobalKey<FormState>();

  final TextEditingController Amount = TextEditingController();
  final TextEditingController rentAmount = TextEditingController();
  final TextEditingController rentNextDueDate = TextEditingController();
  final TextEditingController rentMemo = TextEditingController();
  final TextEditingController securityDepositeAmount = TextEditingController();
  final TextEditingController recurringContentAmount = TextEditingController();
  final TextEditingController recurringContentMemo = TextEditingController();
  final TextEditingController oneTimeContentMemo = TextEditingController();
  final TextEditingController oneTimeContentAmount = TextEditingController();
  final TextEditingController signatureController = TextEditingController();
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  String? _selectedRent;
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();

  bool _selectedResidentsEmail = false; // Initialize the boolean variable

  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
  ];
  String? selectedValue;
  List<File> _pdfFiles = [];

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
        files = files.sublist(0, 10);
      }

      setState(() {
        _pdfFiles = files;
      });
    }
  }

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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

  List<Map<String, String>> formDataOneTimeList = [];

  void _showPopupForm(BuildContext context,
      {Map<String, String>? initialData, int? index}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: OneTimeChargePopUp(
            initialData: initialData,
            onSave: (data) {
              setState(() {
                if (index != null) {
                  // Update existing item
                  formDataRecurringList[index] = data;
                } else {
                  // Add new item
                  formDataRecurringList.add(data);
                }
              });
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          formDataRecurringList[index] = result;
        } else {
          formDataRecurringList.add(result);
        }
      });
    }
  }

  List<Map<String, String>> formDataRecurringList = [];

  void _showRecurringPopupForm(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Add Recurring content',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(21, 43, 83, 1),
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: RecurringChargePopUp(
                  onSave: (data) {
                    Navigator.of(context).pop(data);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        formDataRecurringList.add(result);
        print(formDataRecurringList.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          color: const Color.fromRGBO(21, 43, 81, 1),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Add Lease",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 83, 1),
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
                            height: 8,
                          ),
                          CustomDropdown(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a property';
                              }
                              return null;
                            },
                            labelText: 'Select Property',
                            items: items,
                            selectedValue: _selectedProperty,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedProperty = value;
                              });
                            },
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
                          CustomDropdown(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a lease';
                              }
                              return null;
                            },
                            labelText: 'Select Lease',
                            items: items,
                            selectedValue: _selectedLeaseType,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedLeaseType = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text('Start Date *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 8,
                          ),
                          CustomTextField(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                locale: const Locale('en', 'US'),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color.fromRGBO(21, 43, 83,
                                            1), // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface: Color.fromRGBO(
                                            21, 43, 83, 1), // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromRGBO(
                                              21,
                                              43,
                                              83,
                                              1), // button text color
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
                                setState(() {
                                  _startDate.text = formattedDate;
                                });
                              }
                            },
                            readOnnly: true,
                            suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.date_range_rounded)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select start date';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            hintText: 'dd-mm-yyyy',
                            controller: _startDate,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text('End Date *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 8,
                          ),
                          CustomTextField(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                locale: const Locale('en', 'US'),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color.fromRGBO(21, 43, 83,
                                            1), // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface: Color.fromRGBO(
                                            21, 43, 83, 1), // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromRGBO(
                                              21,
                                              43,
                                              83,
                                              1), // button text color
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
                                setState(() {
                                  _endDate.text = formattedDate;
                                });
                              }
                            },
                            readOnnly: true,
                            suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.date_range_rounded)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select end date';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            hintText: 'dd-mm-yyyy',
                            controller: _endDate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 83, 1),
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
                          const Text('Add lease',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF152b51))),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text(
                                            'Add Tenant or Cosigner',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF152b51))),
                                        content: Form(
                                          key: _addRecurringFormKey,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              color: Colors.white,
                                              width: double.infinity,
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
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
                                                              onTap: () {
                                                                setState(() {
                                                                  isTenantSelected =
                                                                      true;
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: isTenantSelected
                                                                      ? null
                                                                      : Border.all(
                                                                          color: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                          width:
                                                                              1),
                                                                  gradient:
                                                                      isTenantSelected
                                                                          ? const LinearGradient(
                                                                              colors: [
                                                                                Color.fromRGBO(21, 43, 83, 1),
                                                                                Color.fromRGBO(21, 43, 83, 1),
                                                                              ],
                                                                            )
                                                                          : null,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            4),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            4),
                                                                  ),
                                                                ),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding: isTenantSelected
                                                                    ? const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            13)
                                                                    : const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            12),
                                                                child: isTenantSelected
                                                                    ? Text(
                                                                        "Tenant",
                                                                        style:
                                                                            TextStyle(
                                                                          color: !isTenantSelected
                                                                              ? Colors.transparent
                                                                              : Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      )
                                                                    : ShaderMask(
                                                                        shaderCallback:
                                                                            (bounds) {
                                                                          return const LinearGradient(
                                                                            colors: [
                                                                              Color.fromRGBO(21, 43, 83, 1),
                                                                              Color.fromRGBO(21, 43, 83, 1),
                                                                            ],
                                                                          ).createShader(
                                                                              bounds);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Tenant",
                                                                          style:
                                                                              TextStyle(
                                                                            color: isTenantSelected
                                                                                ? Colors.transparent
                                                                                : Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  isTenantSelected =
                                                                      false;
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: isTenantSelected ==
                                                                          false
                                                                      ? null
                                                                      : Border.all(
                                                                          color: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                          width:
                                                                              1),
                                                                  gradient: isTenantSelected ==
                                                                          false
                                                                      ? const LinearGradient(
                                                                          colors: [
                                                                            Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                            Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                          ],
                                                                        )
                                                                      : null,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            4),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            4),
                                                                  ),
                                                                ),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding: isTenantSelected
                                                                    ? const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            12)
                                                                    : const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            13),
                                                                child: !isTenantSelected
                                                                    ? Text(
                                                                        "Cosigner",
                                                                        style:
                                                                            TextStyle(
                                                                          color: isTenantSelected
                                                                              ? Colors.transparent
                                                                              : Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      )
                                                                    : ShaderMask(
                                                                        shaderCallback:
                                                                            (bounds) {
                                                                          return const LinearGradient(
                                                                            colors: [
                                                                              Color.fromRGBO(21, 43, 83, 1),
                                                                              Color.fromRGBO(21, 43, 83, 1),
                                                                            ],
                                                                          ).createShader(
                                                                              bounds);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Cosigner",
                                                                          style:
                                                                              TextStyle(
                                                                            color: !isTenantSelected
                                                                                ? Colors.transparent
                                                                                : Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
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
                                                          : const AddCosigner(),
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
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF152b51),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0))),
                                                  onPressed: () {
                                                    if (_addRecurringFormKey
                                                        .currentState!
                                                        .validate()) {
                                                      print('object valid');
                                                    } else {
                                                      print('object invalid');
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Add',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFf7f8f9)),
                                                  ))),
                                          Container(
                                              height: 50,
                                              width: 94,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFffffff),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0))),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF748097)),
                                                  )))
                                        ],
                                      );
                                    });
                                  });
                            },
                            child: const Text('+ Add Tenant or Cosigner',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2ec433))),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 83, 1),
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
                          const Text('Rent',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF152b51))),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Rent Cycle *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 8,
                          ),
                          CustomDropdown(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a rent';
                              }
                              return null;
                            },
                            labelText: 'Select Rent',
                            items: items,
                            selectedValue: _selectedRent,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedRent = value;
                              });
                            },
                          ),
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
                            keyboardType: TextInputType.text,
                            hintText: 'Enter Amount',
                            controller: rentAmount,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text('Next Due Date',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(
                            height: 8,
                          ),
                          CustomTextField(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                locale: const Locale('en', 'US'),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color.fromRGBO(21, 43, 83,
                                            1), // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface: Color.fromRGBO(
                                            21, 43, 83, 1), // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromRGBO(
                                              21,
                                              43,
                                              83,
                                              1), // button text color
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
                                setState(() {
                                  rentNextDueDate.text = formattedDate;
                                });
                              }
                            },
                            readOnnly: true,
                            suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.date_range_rounded)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select Next Due Date';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            hintText: 'dd-mm-yyyy',
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
                        color: const Color.fromRGBO(21, 43, 83, 1),
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
                          const Text(
                            'Charges (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF152b51),
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
                              InkWell(
                                onTap: () {
                                  _showRecurringPopupForm(context);
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
                              const SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  _showPopupForm(context);
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
                              if (formDataRecurringList.isNotEmpty)
                                const SizedBox(
                                  height: 10,
                                ),
                              if (formDataRecurringList.isNotEmpty)
                                const SizedBox(
                                  height: 10,
                                ),
                              if (formDataRecurringList.isNotEmpty)
                                const Text(
                                  'Recurring Information',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                ),
                              if (formDataRecurringList.isNotEmpty)
                                const SizedBox(
                                  height: 5,
                                ),

                              Table(
                                border: TableBorder.all(
                                  width: 1,
                                  color: const Color.fromRGBO(21, 43, 83, 1),
                                ),
                                columnWidths: {
                                  0: const FlexColumnWidth(2),
                                  1: const FlexColumnWidth(2),
                                  2: const FlexColumnWidth(1.3),
                                },
                                children: [
                                  if (formDataRecurringList.isNotEmpty)
                                    const TableRow(
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                        ),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Account',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Amount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Actions',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
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
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${item['property']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                Color.fromRGBO(21, 43, 83, 1),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(children: [
                                            InkWell(
                                              onTap: () {
                                                _showPopupForm(context,
                                                    initialData: item,
                                                    index: index);
                                              },
                                              child: const Icon(
                                                Icons.edit,
                                                color: Color.fromRGBO(
                                                    21, 43, 83, 1),
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
                                              child: const Icon(
                                                Icons.delete,
                                                color: Color.fromRGBO(
                                                    21, 43, 83, 1),
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
                                const Text(
                                  'One Time Information',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                ),
                              if (formDataOneTimeList.isNotEmpty)
                                const SizedBox(
                                  height: 5,
                                ),

                              Table(
                                border: TableBorder.all(
                                  width: 1,
                                  color: const Color.fromRGBO(21, 43, 83, 1),
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(1.3),
                                },
                                children: [
                                  if (formDataOneTimeList.isNotEmpty)
                                    const TableRow(
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                        ),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Account',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Amount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Actions',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
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
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${item['property']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                Color.fromRGBO(21, 43, 83, 1),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(children: [
                                            InkWell(
                                              onTap: () {
                                                // Implement edit functionality here
                                              },
                                              child: const Icon(
                                                Icons.edit,
                                                color: Color.fromRGBO(
                                                    21, 43, 83, 1),
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
                                              child: const Icon(
                                                Icons.delete,
                                                color: Color.fromRGBO(
                                                    21, 43, 83, 1),
                                                size: 18,
                                              ),
                                            )
                                          ]))
                                    ]);
                                  })
                                ],
                              ),

                              // Displaying list of charges here
                              // ListView.builder(
                              //   shrinkWrap: true,
                              //   itemCount: formDataOneTimeList.length,
                              //   itemBuilder: (context, index) {
                              //     final item = formDataOneTimeList[index];
                              //     return Container(
                              //       decoration: BoxDecoration(
                              //           border: Border.all(width: 0.5)),
                              //       child: ListTile(
                              //         trailing: Column(
                              //           children: [
                              //             const SizedBox(
                              //               height: 8,
                              //             ),
                              //             InkWell(
                              //               onTap: () {},
                              //               child: const Icon(
                              //                 Icons.edit,
                              //                 color:
                              //                     Color.fromRGBO(21, 43, 83, 1),
                              //                 size: 18,
                              //               ),
                              //             ),
                              //             const SizedBox(
                              //               height: 10,
                              //             ),
                              //             InkWell(
                              //               onTap: () {
                              //                 setState(() {
                              //                   formDataOneTimeList
                              //                       .removeAt(index);
                              //                 });
                              //               },
                              //               child: const Icon(
                              //                 Icons.delete,
                              //                 color:
                              //                     Color.fromRGBO(21, 43, 83, 1),
                              //                 size: 18,
                              //               ),
                              //             )
                              //           ],
                              //         ),
                              //         title: Text(
                              //           '${item['property']}',
                              //           style: const TextStyle(
                              //               fontSize: 15,
                              //               fontWeight: FontWeight.w700,
                              //               color:
                              //                   Color.fromRGBO(21, 43, 83, 1)),
                              //         ),
                              //         subtitle: Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               '${item['amount']}',
                              //               style: TextStyle(
                              //                   fontSize: 14,
                              //                   fontWeight: FontWeight.w600,
                              //                   color: Colors.grey[600]),
                              //             ),
                              //             Text(
                              //               '${item['memo']}',
                              //               style: TextStyle(
                              //                   fontSize: 14,
                              //                   fontWeight: FontWeight.w500,
                              //                   color: Colors.grey[500]),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // ),
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
                          color: const Color.fromRGBO(21, 43, 83, 1),
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
                          const Text('Security Deposit (Optional)',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF152b51))),
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
                            keyboardType: TextInputType.text,
                            hintText: 'Enter Amount',
                            controller: securityDepositeAmount,
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
                          color: const Color.fromRGBO(21, 43, 83, 1),
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
                          const Text('Upload Files (Maximum of 10)',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF152b51))),
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
                                backgroundColor: const Color(0xFF152b51),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () async {
                                await _pickPdfFiles();
                              },
                              child: const Text(
                                'Upload',
                                style: TextStyle(color: Color(0xFFf7f8f9)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            fit: FlexFit.loose,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _pdfFiles.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      _pdfFiles[index].path.split('/').last,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF748097))),
                                  trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _pdfFiles.removeAt(index);
                                        });
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.remove,
                                        color: Color(0xFF748097),
                                      )),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(21, 43, 83, 1),
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'E-Signature',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF152b51),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 330, // Set a fixed height for TabBarView
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isEnjoyNowSelected = true;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: isEnjoyNowSelected
                                                ? null
                                                : Border.all(
                                                    color: const Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                    width: 1),
                                            gradient: isEnjoyNowSelected
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color.fromRGBO(
                                                          21, 43, 83, 1),
                                                      Color.fromRGBO(
                                                          21, 43, 83, 1),
                                                    ],
                                                  )
                                                : null,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              bottomLeft: Radius.circular(4),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          padding: isEnjoyNowSelected
                                              ? const EdgeInsets.symmetric(
                                                  vertical: 13)
                                              : const EdgeInsets.symmetric(
                                                  vertical: 12),
                                          child: isEnjoyNowSelected
                                              ? Text(
                                                  "Draw Signature",
                                                  style: TextStyle(
                                                    color: !isEnjoyNowSelected
                                                        ? Colors.transparent
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : ShaderMask(
                                                  shaderCallback: (bounds) {
                                                    return const LinearGradient(
                                                      colors: [
                                                        Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                        Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                      ],
                                                    ).createShader(bounds);
                                                  },
                                                  child: Text(
                                                    "Draw Signature",
                                                    style: TextStyle(
                                                      color: isEnjoyNowSelected
                                                          ? Colors.transparent
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                            isEnjoyNowSelected = false;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: isEnjoyNowSelected == false
                                                ? null
                                                : Border.all(
                                                    color: const Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                    width: 1),
                                            gradient:
                                                isEnjoyNowSelected == false
                                                    ? const LinearGradient(
                                                        colors: [
                                                          Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                          Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ],
                                                      )
                                                    : null,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          padding: isEnjoyNowSelected
                                              ? const EdgeInsets.symmetric(
                                                  vertical: 12)
                                              : const EdgeInsets.symmetric(
                                                  vertical: 13),
                                          child: !isEnjoyNowSelected
                                              ? Text(
                                                  "Type Signature",
                                                  style: TextStyle(
                                                    color: isEnjoyNowSelected
                                                        ? Colors.transparent
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : ShaderMask(
                                                  shaderCallback: (bounds) {
                                                    return const LinearGradient(
                                                      colors: [
                                                        Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                        Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                      ],
                                                    ).createShader(bounds);
                                                  },
                                                  child: Text(
                                                    "Type Signature",
                                                    style: TextStyle(
                                                      color: !isEnjoyNowSelected
                                                          ? Colors.transparent
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                isEnjoyNowSelected
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const SizedBox(height: 5),
                                          Container(
                                            height: 36,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(width: 1),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                _signaturePadKey.currentState!
                                                    .clear();
                                              },
                                              child: const Text('Clear'),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            child: SfSignaturePad(
                                              key: _signaturePadKey,
                                              strokeColor: Colors.black,
                                              backgroundColor: Colors.grey[200],
                                            ),
                                            height: 200,
                                            width: 300,
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: Container(
                                          height: 250,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(width: 1),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'please enter signature';
                                                    }
                                                    return null;
                                                  },
                                                  maxLength: 30,
                                                  decoration: InputDecoration(
                                                    hintText: 'Type Signature',
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  controller:
                                                      signatureController,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      signatureController.text =
                                                          newValue;
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Container(
                                                child: Text(
                                                  '${signatureController.text}',
                                                  style:
                                                      GoogleFonts.dancingScript(
                                                    fontSize: 38,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 83, 1),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('Residents center Welcome Email',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF152b51))),
                              const SizedBox(
                                width: 5,
                              ),
                              Switch(
                                activeColor: const Color(0xFF152b51),
                                value: _selectedResidentsEmail,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedResidentsEmail = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                              'We send a welcome email to anyone without resident center access',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF748097))),
                        ],
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
                                borderRadius: BorderRadius.circular(8.0)),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF67758e),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    // If the form is valid, display a snackbar
                                    print('valid');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Processing Data')),
                                    );
                                  } else {
                                    print('invalid');
                                    _handleSubmit();
                                  }
                                },
                                child: const Text(
                                  'Create Lease',
                                  style: TextStyle(color: Color(0xFFf7f8f9)),
                                ))),
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
                                onPressed: () {},
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
      ),
    );
  }
}

class OneTimeChargePopUp extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final Map<String, String>? initialData;

  OneTimeChargePopUp({required this.onSave, this.initialData});

  @override
  State<OneTimeChargePopUp> createState() => _OneTimeChargePopUpState();
}

// class _OneTimeChargePopUpState extends State<OneTimeChargePopUp> {
//   final _formKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> _subFormKey = GlobalKey<FormState>();
//   String? _selectedAccountType;
//   String? _selectedFundType;
//   final TextEditingController _accountNameController = TextEditingController();
//   String? _selectedProperty;

//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _memoController = TextEditingController();

//   final TextEditingController _notesController = TextEditingController();
//   bool _isInvalid = true;
//   List<String> items = []; // Example items

//   List<String> accountTypeItems = [
//     'Income',
//     'Non Operating Income ',
//   ]; // Example items
//   List<String> fundTypeItems = [
//     'Reverse',
//     'Operating',
//   ]; // Example items

//   bool _isLoading = true;
//   List<String> accounts = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialData != null) {
//       _selectedProperty = widget.initialData!['property'] ?? '';
//       _amountController.text = widget.initialData!['amount'] ?? '';
//       _memoController.text = widget.initialData!['memo'] ?? '';
//     }
//     fetchData();
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _memoController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String adminId = prefs.getString('adminId').toString();
//     final response =
//         await http.get(Uri.parse('$Api_url/api/accounts/accounts/$adminId'));
//     print(response.body);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         items = (data['data'] as List)
//             .where((item) => item['charge_type'] == "One Time Charge")
//             .map((item) => item['account'] as String)
//             .toList();
//         _isLoading = false;
//         print(items.length);
//       });
//     } else {
//       // Handle error
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to fetch data')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           color: Colors.white,
//           height: _isInvalid ? 326 : 350,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Property *',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _isLoading
//                   ? const Center(
//                       child: SpinKitFadingCircle(
//                       color: Colors.black,
//                       size: 50.0,
//                     ))
//                   : DropdownButtonHideUnderline(
//                       child: DropdownButton2<String>(
//                         isExpanded: true,
//                         hint: const Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 'Select property' ?? '',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w400,
//                                   color: Color(0xFFb0b6c3),
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         items: [
//                           ...items
//                               .map((String item) => DropdownMenuItem<String>(
//                                     value: item,
//                                     child: Text(
//                                       item,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w400,
//                                         color: Colors.black87,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   )),
//                           DropdownMenuItem<String>(
//                             value: 'button_item',
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(0)),
//                                   elevation: 0,
//                                   backgroundColor: Colors.white),
//                               onPressed: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return StatefulBuilder(
//                                         builder: (context, setState) {
//                                       return AlertDialog(
//                                         contentPadding: EdgeInsets.zero,
//                                         backgroundColor: Colors.white,
//                                         title: const Text(
//                                           'Add Account',
//                                           style: TextStyle(
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.w500,
//                                             color:
//                                                 Color.fromRGBO(21, 43, 83, 1),
//                                           ),
//                                         ),
//                                         content: Container(
//                                           height: 450,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(16.0),
//                                             child: Form(
//                                               key: _subFormKey,
//                                               child: ListView(
//                                                 children: [
//                                                   const Text(
//                                                     'Account Name *',
//                                                     style: TextStyle(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 5),
//                                                   CustomTextField(
//                                                     validator: (value) {
//                                                       if (value == null ||
//                                                           value.isEmpty) {
//                                                         return 'Please enter Account Name';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     keyboardType:
//                                                         TextInputType.text,
//                                                     hintText:
//                                                         'Enter Account Name',
//                                                     controller:
//                                                         _accountNameController,
//                                                   ),
//                                                   const SizedBox(height: 8),
//                                                   const Text(
//                                                     'Account Type',
//                                                     style: TextStyle(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 5),
//                                                   CustomDropdown(
//                                                     validator: (value) {
//                                                       if (value == null ||
//                                                           value.isEmpty) {
//                                                         return 'Please select a Account Type';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     labelText:
//                                                         'Select Account Type',
//                                                     items: accountTypeItems,
//                                                     selectedValue:
//                                                         _selectedAccountType,
//                                                     onChanged: (String? value) {
//                                                       setState(() {
//                                                         _selectedAccountType =
//                                                             value;
//                                                       });
//                                                     },
//                                                   ),
//                                                   const SizedBox(height: 8),
//                                                   const Text(
//                                                     'Fund Type',
//                                                     style: TextStyle(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 5),
//                                                   CustomDropdown(
//                                                     validator: (value) {
//                                                       if (value == null ||
//                                                           value.isEmpty) {
//                                                         return 'Please select a Fund Type';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     labelText:
//                                                         'Select Fund Type',
//                                                     items: fundTypeItems,
//                                                     selectedValue:
//                                                         _selectedFundType,
//                                                     onChanged: (String? value) {
//                                                       setState(() {
//                                                         _selectedFundType =
//                                                             value;
//                                                       });
//                                                     },
//                                                   ),
//                                                   const SizedBox(height: 8),
//                                                   const Text(
//                                                     'Notes',
//                                                     style: TextStyle(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 5),
//                                                   CustomTextField(
//                                                     validator: (value) {
//                                                       if (value == null ||
//                                                           value.isEmpty) {
//                                                         return 'Please enter Notes';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     keyboardType:
//                                                         TextInputType.text,
//                                                     hintText: 'Enter Notes',
//                                                     controller:
//                                                         _notesController,
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 20,
//                                                   ),
//                                                   RichText(
//                                                     text: const TextSpan(
//                                                       children: <TextSpan>[
//                                                         TextSpan(
//                                                           text:
//                                                               'We stores this information ',
//                                                           style: TextStyle(
//                                                             fontSize: 11,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.grey,
//                                                           ),
//                                                         ),
//                                                         TextSpan(
//                                                           text: 'Privately',
//                                                           style: TextStyle(
//                                                             fontSize: 11,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     21,
//                                                                     43,
//                                                                     83,
//                                                                     1),
//                                                           ),
//                                                         ),
//                                                         TextSpan(
//                                                           text: ' and ',
//                                                           style: TextStyle(
//                                                             fontSize: 11,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .normal,
//                                                             color: Colors.grey,
//                                                           ),
//                                                         ),
//                                                         TextSpan(
//                                                           text: 'Securely',
//                                                           style: TextStyle(
//                                                             fontSize: 11,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     21,
//                                                                     43,
//                                                                     83,
//                                                                     1),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 20,
//                                                   ),
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.end,
//                                                     children: [
//                                                       Container(
//                                                           height: 50,
//                                                           width: 90,
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           8.0)),
//                                                           child: ElevatedButton(
//                                                               style: ElevatedButton.styleFrom(
//                                                                   backgroundColor:
//                                                                       const Color(
//                                                                           0xFF152b51),
//                                                                   shape: RoundedRectangleBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               8.0))),
//                                                               onPressed: () {
//                                                                 _submitSubForm();
//                                                               },
//                                                               child: const Text(
//                                                                 'Add',
//                                                                 style: TextStyle(
//                                                                     color: Color(
//                                                                         0xFFf7f8f9)),
//                                                               ))),
//                                                       const SizedBox(
//                                                         width: 10,
//                                                       ),
//                                                       Container(
//                                                           height: 50,
//                                                           width: 94,
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           8.0)),
//                                                           child: ElevatedButton(
//                                                               style: ElevatedButton.styleFrom(
//                                                                   backgroundColor:
//                                                                       const Color(
//                                                                           0xFFffffff),
//                                                                   shape: RoundedRectangleBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               8.0))),
//                                                               onPressed: () {
//                                                                 Navigator.pop(
//                                                                     context);
//                                                               },
//                                                               child: const Text(
//                                                                 'Cancel',
//                                                                 style: TextStyle(
//                                                                     color: Color(
//                                                                         0xFF748097)),
//                                                               )))
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     });
//                                   },
//                                 );
//                               },
//                               child: const Text(
//                                 'Add New Account',
//                                 style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                           ),
//                         ],
//                         value: _selectedProperty,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedProperty = value;
//                           });
//                           // widget.onChanged(value);
//                           // state.didChange(value);
//                         },
//                         buttonStyleData: ButtonStyleData(
//                           height: 45,
//                           width: 160,
//                           padding: const EdgeInsets.only(left: 14, right: 14),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(6),
//                             color: Colors.white,
//                           ),
//                           elevation: 2,
//                         ),
//                         iconStyleData: const IconStyleData(
//                           icon: Icon(
//                             Icons.arrow_drop_down,
//                           ),
//                           iconSize: 24,
//                           iconEnabledColor: Color(0xFFb0b6c3),
//                           iconDisabledColor: Colors.grey,
//                         ),
//                         dropdownStyleData: DropdownStyleData(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(6),
//                             color: Colors.white,
//                           ),
//                           scrollbarTheme: ScrollbarThemeData(
//                             radius: const Radius.circular(6),
//                             thickness: MaterialStateProperty.all(6),
//                             thumbVisibility: MaterialStateProperty.all(true),
//                           ),
//                         ),
//                         menuItemStyleData: const MenuItemStyleData(
//                           height: 40,
//                           padding: EdgeInsets.only(left: 14, right: 14),
//                         ),
//                       ),
//                     ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Amount *',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               CustomTextField(
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter amount';
//                   }
//                   return null;
//                 },
//                 keyboardType: TextInputType.number,
//                 hintText: 'Enter Amount',
//                 controller: _amountController,
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Memo',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               CustomTextField(
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter memo';
//                   }
//                   return null;
//                 },
//                 keyboardType: TextInputType.text,
//                 hintText: 'Enter Memo',
//                 controller: _memoController,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Container(
//                       height: 50,
//                       width: 90,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8.0)),
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF152b51),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0))),
//                           onPressed: () {
//                             _submitForm();
//                           },
//                           child: const Text(
//                             'Add',
//                             style: TextStyle(color: Color(0xFFf7f8f9)),
//                           ))),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Container(
//                       height: 50,
//                       width: 94,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8.0)),
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFffffff),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0))),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(color: Color(0xFF748097)),
//                           )))
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _submitForm() {
//     if (_formKey.currentState?.validate() ?? false) {
//       final formData = {
//         'property': _selectedProperty ?? '',
//         'amount': _amountController.text,
//         'memo': _memoController.text,
//       };
//       widget.onSave(formData);
//     } else {
//       setState(() {
//         _isInvalid = true;
//       });
//     }
//   }

//   Future _submitSubForm() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String adminId = prefs.getString('adminId').toString();
//     print(adminId);
//     if (_subFormKey.currentState?.validate() ?? false) {
//       final formData = {
//         'admin_id': adminId,
//         'account': _accountNameController.text,
//         'account_type': _selectedAccountType ?? '',
//         'fund_type': _selectedFundType ?? '',
//         'charge_type': 'One Time Charge',
//         'notes': _notesController.text,
//       };

//       final response = await http.post(
//         Uri.parse('$Api_url/api/accounts/accounts'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(formData),
//       );

//       if (response.statusCode == 200) {
//         widget.onSave(formData);
//         Navigator.of(context).pop();
//         print(response.body);
//         Fluttertoast.showToast(msg: 'Account Added Successfully');
//       } else {
//         // Handle error response
//         print(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to add account')),
//         );
//       }
//     } else {
//       setState(() {
//         _isInvalid = true;
//       });
//     }
//   }
// }

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
      _selectedProperty = widget.initialData!['property'] ?? '';
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
    String adminId = prefs.getString('adminId').toString();
    final response =
        await http.get(Uri.parse('$Api_url/api/accounts/accounts/$adminId'));
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
            height: _isInvalid ? 326 : 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Property *',
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
                                  'Select property' ?? '',
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
                            DropdownMenuItem<String>(
                              value: 'button_item',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0)),
                                    elevation: 0,
                                    backgroundColor: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.white,
                                          title: const Text(
                                            'Add Account',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Color.fromRGBO(21, 43, 83, 1),
                                            ),
                                          ),
                                          content: Container(
                                            height: 450,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Form(
                                                key: _subFormKey,
                                                child: ListView(
                                                  children: [
                                                    const Text(
                                                      'Account Name *',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
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
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'Account Type',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
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
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'Fund Type',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
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
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'Notes',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
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
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: 'Privately',
                                                            style: TextStyle(
                                                              fontSize: 11,
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
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: 'Securely',
                                                            style: TextStyle(
                                                              fontSize: 11,
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
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                            height: 50,
                                                            width: 90,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                            child:
                                                                ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            const Color(
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                            child:
                                                                ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            const Color(
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
                                backgroundColor: const Color(0xFF152b51),
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
    print('okay');
    if (_formKey.currentState?.validate() ?? false) {
      final formData = {
        'property': _selectedProperty ?? '',
        'amount': _amountController.text,
        'memo': _memoController.text,
      };
      widget.onSave(formData);
      print(formData);
    } else {
      setState(() {
        _isInvalid = true;
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
        'account': _accountNameController.text,
        'account_type': _selectedAccountType ?? '',
        'fund_type': _selectedFundType ?? '',
        'charge_type': 'One Time Charge',
        'notes': _notesController.text,
      };

      final response = await http.post(
        Uri.parse('$Api_url/api/accounts/accounts'),
        headers: {'Content-Type': 'application/json'},
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

  const RecurringChargePopUp({Key? key, required this.onSave})
      : super(key: key);

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
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId').toString();
    final response =
        await http.get(Uri.parse('$Api_url/api/accounts/accounts/$adminId'));

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white,
          height: _isInvalid ? 326 : 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Property *',
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
                                'Select property' ?? '',
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
                          DropdownMenuItem<String>(
                            value: 'button_item',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  elevation: 0,
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return AlertDialog(
                                        contentPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.white,
                                        title: const Text(
                                          'Add Account',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Color.fromRGBO(21, 43, 83, 1),
                                          ),
                                        ),
                                        content: Container(
                                          height: 450,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Form(
                                              key: _subFormKey,
                                              child: ListView(
                                                children: [
                                                  const Text(
                                                    'Account Name *',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
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
                                                        TextInputType.number,
                                                    hintText:
                                                        'Enter Account Name',
                                                    controller:
                                                        _accountNameController,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Account Type',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
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
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _selectedAccountType =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Fund Type',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
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
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _selectedFundType =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Notes',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
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
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'Privately',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: ' and ',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'Securely',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
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
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                          height: 50,
                                                          width: 90,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xFF152b51),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0))),
                                                              onPressed: () {
                                                                _submitSubForm();
                                                              },
                                                              child: const Text(
                                                                'Add',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFFf7f8f9)),
                                                              ))),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                          height: 50,
                                                          width: 94,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xFFffffff),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0))),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF748097)),
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
                          if (value != 'button_item') {
                            setState(() {
                              _selectedProperty = value;
                            });
                            // widget.onChanged(value);
                            // state.didChange(value);
                          }
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
                              backgroundColor: const Color(0xFF152b51),
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
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final formData = {
        'property': _selectedProperty ?? '',
        'amount': _amountController.text,
        'memo': _memoController.text,
      };
      widget.onSave(formData);
    } else {
      setState(() {
        _isInvalid = true;
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
        'account': _accountNameController.text,
        'account_type': _selectedAccountType ?? '',
        'fund_type': _selectedFundType ?? '',
        'charge_type': 'Recurring Charge',
        'notes': _notesController.text,
      };

      final response = await http.post(
        Uri.parse('$Api_url/api/accounts/accounts'),
        headers: {'Content-Type': 'application/json'},
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

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
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
  bool _obscureText = true;
  final TextEditingController _dateController = TextEditingController();

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
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color.fromRGBO(21, 43, 103, 1),
                border: Border.all(
                  color: const Color.fromRGBO(21, 43, 83, 1),
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
                  hintText: 'Enter phone number',
                  controller: phoneNumber,
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
                              keyboardType: TextInputType.number,
                              hintText: 'Enter work number',
                              controller: workNumber,
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
                            ),
                          ],
                        ),
                      )
                    : Container(),
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
                        validator: (value) {
                          if (value == null) {
                            return 'please enter password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Add some space between the widgets
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
                        border: Border.all(width: 0, color: Colors.white),
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
                  color: const Color.fromRGBO(21, 43, 103, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(21, 43, 83, 1),
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
                                blurRadius: 8.0, // How much to blur the shadow
                                spreadRadius:
                                    0.0, // How much the shadow should spread
                              ),
                            ],
                            border: Border.all(width: 0, color: Colors.white),
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
                            hintText: 'dd-mm-yyyy',
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
                                blurRadius: 8.0, // How much to blur the shadow
                                spreadRadius:
                                    0.0, // How much the shadow should spread
                              ),
                            ],
                            border: Border.all(width: 0, color: Colors.white),
                            borderRadius: BorderRadius.circular(6.0)),
                        child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: comments,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 13, color: Color(0xFFb0b6c3)),
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
                  color: const Color.fromRGBO(21, 43, 103, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(21, 43, 83, 1),
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
                        hintText: 'Enter phone number',
                        controller: emergencyPhoneNumber,
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
    );
  }
}

class AddCosigner extends StatefulWidget {
  const AddCosigner({super.key});

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
                color: const Color.fromRGBO(21, 43, 103, 1),
                border: Border.all(
                  color: const Color.fromRGBO(21, 43, 83, 1),
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
                              keyboardType: TextInputType.number,
                              hintText: 'Enter work number',
                              controller: workNumber,
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
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(21, 43, 83, 1)),
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
                const Text('Postal code',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  hintText: 'Enter postal code',
                  controller: postalCode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter postal code';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
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
