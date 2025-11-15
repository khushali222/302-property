import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:provider/provider.dart';
import '../../../provider/dateProvider.dart';

import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../Model/tenants.dart';

import '../../../repository/tenants.dart';
import '../../../widgets/custom_drawer.dart';

class EditTenants extends StatefulWidget {
  Tenant tenants;

  final String tenantId;
  EditTenants({
    required this.tenantId,
    required this.tenants,
  });
  @override
  State<EditTenants> createState() => _EditTenantsState();
}

class _EditTenantsState extends State<EditTenants> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  bool obsecure = true;
  final TextEditingController workNumber = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController alterEmail = TextEditingController();

  final TextEditingController passWord = TextEditingController();

  // final TextEditingController dob = TextEditingController();

  final TextEditingController taxPayerId = TextEditingController();

  final TextEditingController comments = TextEditingController();

  final TextEditingController contactName = TextEditingController();

  final TextEditingController relationToTenant = TextEditingController();

  final TextEditingController emergencyEmail = TextEditingController();

  final TextEditingController emergencyPhoneNumber = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      try {
        // Try to parse the date using common formats since it's now in user's preferred format
        List<String> dateFormats = [
          'MM/dd/yyyy',
          'MM-dd-yyyy',
          'yyyy-MM-dd',
          'dd/MM/yyyy',
          'dd-MM-yyyy'
        ];

        for (String format in dateFormats) {
          try {
            initialDate = DateFormat(format).parse(_dateController.text);
            break;
          } catch (e) {
            continue;
          }
        }
      } catch (e) {
        // If parsing fails, use current date
        initialDate = DateTime.now();
      }
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      // lastDate: DateTime(2101),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor, // header background color
              onPrimary: Colors.white, // header text color
              // onSurface: Colors.blue, // body text color
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
        // Get dateProvider to format the date according to user's preference
        final dateProvider = Provider.of<DateProvider>(context, listen: false);
        // Display format: Use provider's format for user display
        String apiFormatDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        _dateController.text = dateProvider.formatCurrentDate(apiFormatDate);
      });
    }
  }

  bool isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  String? initialFirstName;
  String? initialLastName;
  String? initialPhoneNumber;
  String? initialWorkNumber;
  String? initialEmail;
  String? initialAlterEmail;
  String? initialPassword;
  String? initialDob;
  String? initialTaxPayerId;
  String? initialComments;
  String? initialContactName;
  String? initialRelationToTenant;
  String? initialEmergencyEmail;
  String? initialEmergencyPhoneNumber;
  bool? initialoverride;

  @override
  void initState() {
    overrideFee.addListener(_validateInput);
    // TODO: implement initState
    firstName.text = widget.tenants.tenantFirstName ?? "";
    lastName.text = widget.tenants.tenantLastName ?? "";
    print(' tenant password ${widget.tenants.tenantPassword}');
    phoneNumber.text = widget.tenants.tenantPhoneNumber != null
        ? formatPhoneNumberedit(widget.tenants.tenantPhoneNumber!)
        : "";
    workNumber.text = widget.tenants.tenantAlternativeNumber != null
        ? formatPhoneNumberedit(widget.tenants.tenantAlternativeNumber!)
        : "";
    email.text = widget.tenants.tenantEmail ?? "";
    alterEmail.text = widget.tenants.tenantAlternativeEmail ?? "";
    // passWord.text = widget.tenants.tenantPassword ?? "";
    // _dateController.text = widget.tenants.tenantBirthDate ?? "";
    taxPayerId.text = widget.tenants.taxPayerId ?? "";
    comments.text = widget.tenants.comments ?? "";
    contactName.text = widget.tenants.emergencyContact?.name ?? "";
    relationToTenant.text = widget.tenants.emergencyContact?.relation ?? "";
    emergencyPhoneNumber.text = widget.tenants.emergencyContact?.phoneNumber !=
            null
        ? formatPhoneNumberedit(widget.tenants.emergencyContact!.phoneNumber!)
        : "";
    emergencyEmail.text = widget.tenants.emergencyContact?.email ?? "";
    print("DOB ${widget.tenants.tenantBirthDate}");
    // Get dateProvider to format the date according to user's preference
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    String birthDate = widget.tenants.tenantBirthDate ?? "";
    if (birthDate.isNotEmpty) {
      _dateController.text = dateProvider.formatCurrentDate(birthDate);
    } else {
      _dateController.text = "";
    }

    // enableOverrideFee = widget.tenants.enableoverrideFee!;
    // overrideFee.text = widget.tenants.overRideFee?.toString() ?? '';

    initialFirstName = widget.tenants.tenantFirstName;
    initialLastName = widget.tenants.tenantLastName;
    initialPhoneNumber = widget.tenants.tenantPhoneNumber;
    initialWorkNumber = widget.tenants.tenantAlternativeNumber;
    initialEmail = widget.tenants.tenantEmail;
    initialAlterEmail = widget.tenants.tenantAlternativeEmail;
    initialPassword = widget.tenants.tenantPassword;
    initialDob = widget.tenants.tenantBirthDate;
    initialTaxPayerId = widget.tenants.taxPayerId;
    initialComments = widget.tenants.comments;
    initialContactName = widget.tenants.emergencyContact?.name;
    initialRelationToTenant = widget.tenants.emergencyContact?.relation;
    initialEmergencyEmail = widget.tenants.emergencyContact?.email;
    initialEmergencyPhoneNumber = widget.tenants.emergencyContact?.phoneNumber;

    fetchCompany();
    fetchTenantOverrideFee(widget.tenants.tenantId!);
    super.initState();
  }

  bool isLoading = false;
  bool isInitialLoading = true; // Add this to track initial loading
  String? errorMessage;
  bool formValid = false;
  String companyName = '';
  // String errorMessage = '';
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

  bool enableOverrideFee = false;
  final TextEditingController overrideFee = TextEditingController();
  String overRideFeeError = '';
  void _validateInput() {
    setState(() {
      String input = overrideFee.text.trim();
      if (input.isEmpty) {
        overRideFeeError = 'This field cannot be empty';
      } else if (!RegExp(r'^(\d{1,2}(\.\d{1,2})?|100(\.0{1,2})?)$')
          .hasMatch(input)) {
        overRideFeeError =
            'Enter a valid number up to 100 with up to 2 decimal places';
      } else {
        overRideFeeError = '';
      }
    });
  }

  // Helper function to convert display format back to API format (yyyy-MM-dd)
  String _convertToApiFormat(String displayDate) {
    if (displayDate.isEmpty) return "";
    try {
      DateTime? parsedDate;

      // Try to parse the date using common formats
      List<String> dateFormats = [
        'MM/dd/yyyy',
        'MM-dd-yyyy',
        'yyyy-MM-dd',
        'dd/MM/yyyy',
        'dd-MM-yyyy'
      ];

      for (String format in dateFormats) {
        try {
          parsedDate = DateFormat(format).parse(displayDate);
          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate != null) {
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      }

      return displayDate; // Return as is if parsing fails
    } catch (e) {
      return displayDate; // Return as is if parsing fails
    }
  }

  @override
  void dispose() {
    overrideFee.removeListener(_validateInput);
    overrideFee.dispose();
    super.dispose();
  }

  Future<void> fetchTenantOverrideFee(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$Api_url/api/tenant/tenant_details/$tenantId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print('reponse ${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final tenantData = jsonResponse['data'][0];

      setState(() {
        enableOverrideFee = tenantData['enable_override_fee'] ?? false;
        overrideFee.text = tenantData['override_fee'] != null
            ? tenantData['override_fee'].toString()
            : '';
        passWord.text = tenantData['tenant_password'] ?? '';

        // Handle null values for phone numbers and other fields
        workNumber.text = tenantData['tenant_alternativeNumber'] != null
            ? formatPhoneNumberedit(tenantData['tenant_alternativeNumber'])
            : '';
        emergencyPhoneNumber.text =
            tenantData['emergency_contact']?['phoneNumber'] != null
                ? formatPhoneNumberedit(
                    tenantData['emergency_contact']['phoneNumber'])
                : '';

        isInitialLoading = false; // Mark initial loading as complete
      });
    } else {
      setState(() {
        isInitialLoading = false; // Mark loading as complete even on error
      });
      throw Exception('Failed to load tenant override fee data');
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
        currentpage: "Tenants",
        dropdown: true,
      ),
      body: isInitialLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: Colors.black,
                    size: 40.0,
                  ),
                  // SizedBox(height: 20),
                  // Text(
                  //   'Loading tenant data...',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.grey[600],
                  //   ),
                  // ),
                ],
              ),
            )
          : Form(
              key: _formkey,
              child: Container(
                color: Colors.white,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth > 600) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          titleBar(
                            width: MediaQuery.of(context).size.width * .91,
                            title: 'Edit Tenant',
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * .04),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('First Name *',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                const SizedBox(height: 10),
                                                CustomTextField(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  hintText: 'Enter first name',
                                                  controller: firstName,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'please enter the first name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Last Name *',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                const SizedBox(height: 10),
                                                CustomTextField(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  hintText: 'Enter last name',
                                                  controller: lastName,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'please enter the last name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Phone Number *',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                const SizedBox(height: 10),
                                                CustomTextField(
                                                  keyboardType: const TextInputType
                                                      .numberWithOptions(
                                                          signed: true,
                                                          decimal: true),
                                                  hintText:
                                                      'Enter phone number',
                                                  controller: phoneNumber,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'please enter the phone number';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Work Number',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                const SizedBox(height: 10),
                                                CustomTextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  // keyboardType:
                                                  //     TextInputType.numberWithOptions(
                                                  //         signed: true,
                                                  //         decimal: true),
                                                  hintText: 'Enter work number',
                                                  controller: workNumber,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                    LengthLimitingTextInputFormatter(
                                                        10),
                                                    PhoneNumberFormatter(),
                                                  ],
                                                  optional: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Email *',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                const SizedBox(height: 10),
                                                CustomTextField(
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  hintText: 'Enter Email',
                                                  controller: email,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'please enter email';
                                                    }
                                                    return null;
                                                  },
                                                  email: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Alternative Email',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                const SizedBox(height: 10),
                                                CustomTextField(
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  hintText:
                                                      'Enter alternative email',
                                                  controller: alterEmail,
                                                  optional: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Password *',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                const SizedBox(height: 10),
                                                /*  CustomTextField(
                                          keyboardType: TextInputType.emailAddress,
                                          hintText: 'Enter alternative email',
                                          controller: alterEmail,
                                        ),*/
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomTextField(
                                                        keyboardType:
                                                            TextInputType.text,
                                                        obscureText: obsecure,
                                                        hintText:
                                                            'Enter password',
                                                        controller: passWord,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'please enter password';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          obsecure = !obsecure;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 38,
                                                        height: 50,
                                                        child: Center(
                                                          child: FaIcon(
                                                            !obsecure
                                                                ? FontAwesomeIcons
                                                                    .eyeSlash
                                                                : FontAwesomeIcons
                                                                    .eye,
                                                            size: 20,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            const BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              offset: Offset(
                                                                  1.2, 1.2),
                                                              blurRadius: 3.0,
                                                              spreadRadius: 1.0,
                                                            ),
                                                          ],
                                                          border: Border.all(
                                                              width: 0,
                                                              color:
                                                                  Colors.white),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Visibility(
                                              visible: false,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Alternative Email',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey)),
                                                  const SizedBox(height: 10),
                                                  CustomTextField(
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    hintText:
                                                        'Enter alternative email',
                                                    controller: alterEmail,
                                                    optional: true,
                                                    email: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * .04),
                            child: Container(
                              width: double.infinity,
                              // height: 410,
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
                                    Text('Personal Information',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: blueColor)),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Date of Birth',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 10),
                                              Container(
                                                height: 50,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      const BoxShadow(
                                                        color: Colors.black26,
                                                        offset:
                                                            Offset(1.2, 1.2),
                                                        blurRadius: 3.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                        width: 0,
                                                        color: Colors.white),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0)),
                                                child: TextFormField(
                                                  style: const TextStyle(
                                                    color: Color(0xFF8898aa),
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  controller: _dateController,
                                                  decoration: InputDecoration(
                                                    hintStyle: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFFb0b6c3)),
                                                    border: InputBorder.none,
                                                    hintText: 'Select Date',
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(
                                                          Icons.calendar_today),
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
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('TaxPayer ID',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 10),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                hintText: 'Enter taxpayer ID',
                                                controller: taxPayerId,
                                                optional: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                                              offset: Offset(1.2,
                                                  1.2), // Shadow offset to the bottom right
                                              blurRadius:
                                                  3.0, // How much to blur the shadow
                                              spreadRadius:
                                                  1.0, // How much the shadow should spread
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
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * .04),
                            child: Container(
                              width: double.infinity,
                              // height: form_valid ? 520 : 430,
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
                                    Text('Emergency Contact',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: blueColor)),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Contact Name',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 10),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                hintText: 'Enter contact name',
                                                controller: contactName,
                                                optional: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Relationship to Tenant',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 10),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                hintText:
                                                    'Enter relationship to tenant',
                                                controller: relationToTenant,
                                                optional: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('E-Mail',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 10),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                hintText: 'Enter email',
                                                controller: emergencyEmail,
                                                optional: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Phone Number',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 10),
                                              CustomTextField(
                                                keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                        signed: true,
                                                        decimal: true),
                                                hintText: 'Enter phone number',
                                                controller:
                                                    emergencyPhoneNumber,
                                                optional: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * .04),
                            child: Container(
                              width: double.infinity,
                              // height: form_valid ? 520 : 430,
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
                                    const Text('Override Debit Card Fee',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            activeColor: blueColor,
                                            value: enableOverrideFee,
                                            onChanged: (value) {
                                              setState(() {
                                                enableOverrideFee = value!;
                                                if (!enableOverrideFee) {
                                                  overrideFee.clear();
                                                  overRideFeeError = '';
                                                }
                                              });
                                            }),
                                        const Text('Enable Debit Card Fee',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    enableOverrideFee
                                        ? Material(
                                            elevation: 2,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Container(
                                              height: 50,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    offset: const Offset(4, 4),
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              child: TextField(
                                                keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                decoration: InputDecoration(
                                                  hintStyle: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFFb0b6c3)),
                                                  border: InputBorder.none,
                                                  hintText:
                                                      "Enter the amount to override fee",
                                                  suffix: Text(
                                                    '%',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  _validateInput();
                                                },
                                                controller: overrideFee,
                                                cursorColor: blueColor,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    overRideFeeError != null
                                        ? Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Text(
                                              overRideFeeError!,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.023),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: () async {
                                      bool isFormValid = true;

                                      // Validate each field and update the state accordingly
                                      if (firstName.text.isEmpty) {
                                        setState(() {
                                          isFormValid = false;
                                        });
                                      }

                                      if (lastName.text.isEmpty) {
                                        setState(() {
                                          isFormValid = false;
                                        });
                                      }

                                      if (email.text.isEmpty ||
                                          !isValidEmail(email.text)) {
                                        setState(() {
                                          isFormValid = false;
                                        });
                                      }

                                      // Check for changes
                                      bool hasChanges =
                                          firstName.text != initialFirstName ||
                                              lastName.text !=
                                                  initialLastName ||
                                              phoneNumber.text !=
                                                  initialPhoneNumber ||
                                              workNumber.text !=
                                                  initialWorkNumber ||
                                              email.text != initialEmail ||
                                              alterEmail.text !=
                                                  initialAlterEmail ||
                                              passWord.text !=
                                                  initialPassword ||
                                              _dateController.text !=
                                                  initialDob ||
                                              taxPayerId.text !=
                                                  initialTaxPayerId ||
                                              comments.text !=
                                                  initialComments ||
                                              contactName.text !=
                                                  initialContactName ||
                                              relationToTenant.text !=
                                                  initialRelationToTenant ||
                                              emergencyEmail.text !=
                                                  initialEmergencyEmail ||
                                              emergencyPhoneNumber.text !=
                                                  initialEmergencyPhoneNumber;

                                      if (!hasChanges) {
                                        print(
                                            "No changes made, API call not necessary.");
                                        Navigator.of(context).pop(
                                            false); // Optionally navigate back
                                        return;
                                      }

                                      if (!isFormValid) {
                                        return; // Exit early if the form is not valid
                                      }

                                      // Proceed with API call
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String? adminId =
                                          prefs.getString("adminId");

                                      if (adminId != null) {
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await TenantsRepository().editTenant(
                                            tenantId:
                                                widget.tenants.tenantId ?? "",
                                            adminId: adminId,
                                            tenantFirstName: firstName.text,
                                            tenantLastName: lastName.text,
                                            tenantPhoneNumber: phoneNumber.text,
                                            tenantAlternativeNumber:
                                                workNumber.text,
                                            tenantEmail: email.text,
                                            tenantAlternativeEmail:
                                                alterEmail.text,
                                            tenantPassword: passWord.text,
                                            tenantBirthDate: _dateController
                                                    .text
                                                    .trim()
                                                    .isNotEmpty
                                                ? _convertToApiFormat(
                                                    _dateController.text.trim())
                                                : "",
                                            taxPayerId: taxPayerId.text,
                                            comments: comments.text,
                                            emergencyContactName:
                                                contactName.text,
                                            emergencyContactRelation:
                                                relationToTenant.text,
                                            emergencyContactEmail:
                                                emergencyEmail.text,
                                            emergencyContactPhoneNumber:
                                                emergencyPhoneNumber.text,
                                            companyName: companyName,
                                            overRideFee: overrideFee.text,
                                            enableOverRideFee:
                                                enableOverrideFee.toString(),
                                          );
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Tenant updated successfully");
                                          // setState(() {
                                          //   isLoading = false;
                                          //   errorMessage = null;
                                          //   widget.tenants.tenantFirstName =
                                          //       firstName.text;
                                          //   widget.tenants.tenantLastName =
                                          //       lastName.text;
                                          //   widget.tenants.tenantPhoneNumber =
                                          //       phoneNumber.text;
                                          //   widget.tenants.tenantAlternativeNumber =
                                          //       workNumber.text;
                                          //   widget.tenants.tenantAlternativeEmail =
                                          //       alterEmail.text;
                                          //   widget.tenants.tenantEmail = email.text;
                                          //   widget.tenants.tenantPassword =
                                          //       passWord.text;
                                          //   widget.tenants.tenantBirthDate =
                                          //       reverseFormatDate(
                                          //       _dateController.text);
                                          //   widget.tenants.taxPayerId =
                                          //       taxPayerId.text;
                                          //   widget.tenants.comments = comments.text;
                                          //   widget.tenants.emergencyContact?.name =
                                          //       contactName.text;
                                          //   widget.tenants.emergencyContact
                                          //       ?.relation = relationToTenant.text;
                                          //   widget.tenants.emergencyContact?.email =
                                          //       emergencyEmail.text;
                                          //   widget.tenants.emergencyContact
                                          //           ?.phoneNumber =
                                          //       emergencyPhoneNumber.text;
                                          // });
                                          Navigator.of(context).pop(true);
                                        } catch (e) {
                                          Fluttertoast.showToast(
                                              msg: "Failed to update tenant");
                                          setState(() {
                                            isLoading = false;
                                          });
                                          print(e.toString());
                                        }
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                          errorMessage = "Admin ID not found";
                                        });
                                      }
                                    },
                                    child: isLoading
                                        ? const Center(
                                            child: SpinKitFadingCircle(
                                              color: Colors.white,
                                              size: 55.0,
                                            ),
                                          )
                                        : const Text(
                                            'Edit Tenant',
                                            style: TextStyle(
                                                color: Color(0xFFf7f8f9)),
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
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFffffff),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0))),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Color(0xFF748097)),
                                        ))),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        titleBar(
                          width: MediaQuery.of(context).size.width * .99,
                          title: 'Edit Tenant',
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            width: double.infinity,
                            // height: !form_valid ? 860 : 830,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: const Color(0xFFDBE0E5),
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const Text('Personal Information',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF152B51))),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  //firstname and last name
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('First Name *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                hintText: 'Enter first name',
                                                controller: firstName,
                                                showElevation: false,
                                                isInRow:
                                                    true, // ADD FOR ROW ALIGNMENT
                                                borderColor: const Color(
                                                    0xFFCED4DA), // ADD BORDER COLOR
                                                borderWidth:
                                                    1.5, // ADD BORDER WIDTH
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r"[a-zA-Z\s]")), // only letters + spaces
                                                ],
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'please enter the first name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Last Name *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                hintText: 'Enter last name',
                                                controller: lastName,
                                                borderColor: const Color(0xFFCED4DA),
                                                isInRow:
                                                    true, // ADD FOR ROW ALIGNMENT
                                                showElevation: false,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r"[a-zA-Z\s]")), // only letters + spaces
                                                ],
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'please enter the last name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  //phone and work number
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Phone Number *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                // keyboardType: TextInputType.numberWithOptions(
                                                //     signed: true, decimal: true),
                                                hintText: 'Enter phone number',
                                                controller: phoneNumber,
                                                borderColor: const Color(0xFFCED4DA),
                                                isInRow:
                                                    true, // ADD FOR ROW ALIGNMENT
                                                showElevation: false,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                  PhoneNumberFormatter(),
                                                ],
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'please enter the phone number';
                                                  }
                                                  if (phoneNumber
                                                          .text.isNotEmpty &&
                                                      value ==
                                                          phoneNumber.text) {
                                                    return "Work number and phone number cannot be the same";
                                                  }
                                                  return null;
                                                },
                                                phonenum: true,
                                                phone: true,
                                                worknum: false,
                                                otherController: workNumber,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Work Number ',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                // keyboardType: TextInputType.numberWithOptions(
                                                //     signed: true, decimal: true),
                                                hintText: 'Enter work number',
                                                controller: workNumber,
                                                borderColor: const Color(0xFFCED4DA),
                                                isInRow:
                                                    true, // ADD FOR ROW ALIGNMENT
                                                showElevation: false,
                                                optional: true,
                                                phone: true,
                                                worknum: true,
                                                phonenum: true,
                                                //   samephonenumber: phoneNumber.text.isNotEmpty ? phoneNumber.text == workNumber.text : false,
                                                otherController: phoneNumber,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                  PhoneNumberFormatter(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  //email and alteremail
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Email *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                hintText: 'Enter Email',
                                                controller: email,
                                                isInRow: true,
                                                alterController: alterEmail,
                                                borderColor: const Color(0xFFCED4DA),
                                                showElevation: false,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'please enter email';
                                                  }

                                                  // else if(!EmailValidator.validate(email.text)){
                                                  //   return 'please enter valid email';
                                                  // }
                                                  return null;
                                                },
                                                email: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Alternative Email',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                hintText:
                                                    'Enter alternative email',
                                                controller: alterEmail,
                                                isInRow: true,
                                                showElevation: false,
                                                borderColor: const Color(0xFFCED4DA),
                                                alterController: email,
                                                optional: true,
                                                email: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  //pass and date of birth
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Label + Tooltip + Refresh aligned horizontally
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Password *',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF101828),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 7),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _tooltipKey.currentState
                                                            ?.ensureTooltipVisible();
                                                      },
                                                      child: Tooltip(
                                                        key: _tooltipKey,
                                                        verticalOffset: 16.0,
                                                        textStyle: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                                horizontal: 42),
                                                        message:
                                                            '''• At least one uppercase letter (A-Z).
    • At least one lowercase letter (a-z).
    • At least one number (0-9).
    • At least one special character (e.g., @ # etc.).
    • Password must be at least 12 characters long.
    • No continuous alphabetical characters (e.g., abcd) or continuous numerical characters (e.g..1234).
    • Avoid strictly sequential patterns (e.g.,Akl 2345678!).
    • Don't use birthdays, names, addresses, or other personal information.
                                                ''',
                                                        child: const Icon(
                                                            Icons.info_outline,
                                                            size: 18),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.refresh,
                                                      size: 20),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () {
                                                    String generatedPassword =
                                                        generateRandomPassword();
                                                    setState(() {
                                                      passWord.text =
                                                          generatedPassword;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // Password Field
                                            CustomTextField(
                                              keyboardType: TextInputType.text,
                                              obscureText: obsecure,
                                              hintText: 'Enter password',
                                              controller: passWord,
                                              isInRow: true,
                                              showElevation: false,
                                              borderColor: const Color(0xFFCED4DA),
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    obsecure = !obsecure;
                                                  });
                                                },
                                                child: Icon(
                                                  !obsecure
                                                      ? CupertinoIcons
                                                          .eye_slash_fill
                                                      : CupertinoIcons.eye_fill,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter password';
                                                }
                                                return null;
                                              },
                                              pass: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Date of Birth',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828),
                                              ),
                                            ),
                                            const SizedBox(height: 11),
                                            Material(
                                              // elevation: 2,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Container(
                                                height: 50,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: const Color(0xFFCED4DA),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  // boxShadow: [
                                                  //   BoxShadow(
                                                  //     color: Colors.black
                                                  //         .withOpacity(0.2),
                                                  //     offset: Offset(2, 2),
                                                  //     blurRadius: 3,
                                                  //   ),
                                                  // ],
                                                ),
                                                child: TextFormField(
                                                  controller: _dateController,
                                                  readOnly: true,
                                                  onTap: () =>
                                                      _selectDate(context),
                                                  style: const TextStyle(
                                                    color: Color(0xFF8898aa),
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: 'Select Date',
                                                    hintStyle: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFFb0b6c3)),
                                                    border: InputBorder.none,
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(
                                                          Icons.calendar_today),
                                                      onPressed: () =>
                                                          _selectDate(context),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  //taxid and comment
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('TaxPayer ID',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(height: 10),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                hintText: 'Enter tax payer id',
                                                controller: taxPayerId,
                                                showElevation: false,
                                                borderColor: const Color(0xFFCED4DA),
                                                optional: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Comments',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF101828))),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                height: 50,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    // boxShadow: [
                                                    //   BoxShadow(
                                                    //     color: Colors.black26,
                                                    //     offset: Offset(1.2,
                                                    //         1.2), // Shadow offset to the bottom right
                                                    //     blurRadius:
                                                    //         3.0, // How much to blur the shadow
                                                    //     spreadRadius:
                                                    //         1.0, // How much the shadow should spread
                                                    //   ),
                                                    // ],
                                                    border: Border.all(
                                                      width: 0,
                                                      color: const Color(0xFFCED4DA),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    controller: comments,
                                                    maxLines: 5,
                                                    decoration: const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintStyle: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFFb0b6c3)),
                                                      hintText:
                                                          'Enter the comment',
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Divider(
                                    color: Color(0xFFCED4DA),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //emergency con
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Emergency Contact',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF152B51))),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Contact Name',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF101828))),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  CustomTextField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    hintText:
                                                        'Enter contact name',
                                                    controller: contactName,
                                                    showElevation: false,
                                                    borderColor:
                                                        const Color(0xFFCED4DA),
                                                    optional: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Relationship to Tenant',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF101828))),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  CustomTextField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    hintText:
                                                        'Enter relationship to tenant',
                                                    controller:
                                                        relationToTenant,
                                                    showElevation: false,
                                                    borderColor:
                                                        const Color(0xFFCED4DA),
                                                    optional: true,
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('E-Mail',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF101828))),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  CustomTextField(
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    hintText: 'Enter email',
                                                    controller: emergencyEmail,
                                                    optional: true,
                                                    showElevation: false,
                                                    borderColor:
                                                        const Color(0xFFCED4DA),
                                                    alterController: email,
                                                    emrgencyController:
                                                        alterEmail,
                                                    email: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Phone Number',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF101828))),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  CustomTextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    // keyboardType: TextInputType.numberWithOptions(
                                                    //     signed: true, decimal: true),
                                                    hintText:
                                                        'Enter phone number',
                                                    controller:
                                                        emergencyPhoneNumber,
                                                    businessnum: true,
                                                    optional: true,
                                                    showElevation: false,
                                                    // samephonenumber: workNumber.text.isNotEmpty ? workNumber.text == emergencyPhoneNumber.text : false,
                                                    otherController: workNumber,
                                                    businessController:
                                                        phoneNumber,
                                                    borderColor:
                                                        const Color(0xFFCED4DA),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          10),
                                                      PhoneNumberFormatter(),
                                                    ],
                                                    phone: true,
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
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Divider(
                                    color: Color(0xFFCED4DA),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //card accepted
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Override Debit Card Fee',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF152B51))),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                              activeColor: blueColor,
                                              value: enableOverrideFee,
                                              onChanged: (value) {
                                                setState(() {
                                                  enableOverrideFee = value!;
                                                  if (!enableOverrideFee) {
                                                    overrideFee.clear();
                                                    overRideFeeError = '';
                                                  }
                                                });
                                              }),
                                          const Text('Enable Debit Card Fee',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF101828))),
                                        ],
                                      ),
                                      enableOverrideFee
                                          ? Material(
                                              // elevation: 2,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Container(
                                                height: 50,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: const Color(0xFFCED4DA),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  // boxShadow: [
                                                  //   BoxShadow(
                                                  //     color: Colors.black
                                                  //         .withOpacity(0.2),
                                                  //     offset: Offset(4, 4),
                                                  //     blurRadius: 3,
                                                  //   ),
                                                  // ],
                                                ),
                                                child: TextField(
                                                  keyboardType: const TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                  decoration: InputDecoration(
                                                    hintStyle: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFFb0b6c3)),
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "Enter the amount to override fee",
                                                    suffix: Text(
                                                      '%',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    _validateInput();
                                                  },
                                                  controller: overrideFee,
                                                  cursorColor: blueColor,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      overRideFeeError != null
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Text(
                                                overRideFeeError!,
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.04),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                          border: Border.all(
                                              color: const Color(0x80152B51))
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.grey,
                                          //     offset: Offset(0.0, 1.0), //(x,y)
                                          //     blurRadius: 6.0,
                                          //   ),
                                          // ],
                                          ),
                                      child: Center(
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 15
                                                  : 18),
                                        ),
                                      ),
                                    )),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (_formkey.currentState!.validate()) {
                                      bool isFormValid = true;

                                      // Validate each field and update the state accordingly
                                      if (firstName.text.trim().isEmpty) {
                                        setState(() {
                                          isFormValid = false;
                                        });
                                      }

                                      if (lastName.text.trim().isEmpty) {
                                        setState(() {
                                          isFormValid = false;
                                        });
                                      }

                                      if (email.text.trim().isEmpty ||
                                          !isValidEmail(email.text)) {
                                        setState(() {
                                          isFormValid = false;
                                        });
                                      }

                                      // Check for changes
                                      bool hasChanges =
                                          firstName.text != initialFirstName ||
                                              lastName.text !=
                                                  initialLastName ||
                                              phoneNumber.text !=
                                                  initialPhoneNumber ||
                                              workNumber.text !=
                                                  initialWorkNumber ||
                                              email.text != initialEmail ||
                                              alterEmail.text !=
                                                  initialAlterEmail ||
                                              passWord.text !=
                                                  initialPassword ||
                                              _dateController.text !=
                                                  initialDob ||
                                              taxPayerId.text !=
                                                  initialTaxPayerId ||
                                              comments.text !=
                                                  initialComments ||
                                              contactName.text !=
                                                  initialContactName ||
                                              relationToTenant.text !=
                                                  initialRelationToTenant ||
                                              emergencyEmail.text !=
                                                  initialEmergencyEmail ||
                                              emergencyPhoneNumber.text !=
                                                  initialEmergencyPhoneNumber;

                                      if (!hasChanges) {
                                        print(
                                            "No changes made, API call not necessary.");
                                        Navigator.of(context).pop(
                                            false); // Optionally navigate back
                                        return;
                                      }

                                      if (!isFormValid) {
                                        return;
                                      }

                                      // Proceed with API call
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String? adminId =
                                          prefs.getString("adminId");

                                      if (adminId != null) {
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await TenantsRepository().editTenant(
                                            tenantId:
                                                widget.tenants.tenantId ?? "",
                                            adminId: adminId,
                                            tenantFirstName:
                                                firstName.text.trim(),
                                            tenantLastName:
                                                lastName.text.trim(),
                                            tenantPhoneNumber:
                                                phoneNumber.text.trim(),
                                            tenantAlternativeNumber:
                                                workNumber.text.trim(),
                                            tenantEmail: email.text.trim(),
                                            tenantAlternativeEmail:
                                                alterEmail.text.trim(),
                                            tenantPassword:
                                                passWord.text.trim(),
                                            tenantBirthDate: _dateController
                                                    .text
                                                    .trim()
                                                    .isNotEmpty
                                                ? _convertToApiFormat(
                                                    _dateController.text.trim())
                                                : "", // This will ensure no empty string is passed to _convertToApiFormat
                                            taxPayerId: taxPayerId.text.trim(),
                                            comments: comments.text.trim(),
                                            emergencyContactName:
                                                contactName.text.trim(),
                                            emergencyContactRelation:
                                                relationToTenant.text.trim(),
                                            emergencyContactEmail:
                                                emergencyEmail.text.trim(),
                                            emergencyContactPhoneNumber:
                                                emergencyPhoneNumber.text
                                                    .trim(),
                                            companyName: companyName,
                                            overRideFee:
                                                overrideFee.text.trim(),
                                            enableOverRideFee:
                                                enableOverrideFee.toString(),
                                          );
                                          print(
                                              ' birth date ${_convertToApiFormat(_dateController.text.trim())}');
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Tenant updated successfully");
                                          setState(() {
                                            isLoading = false;
                                            errorMessage = null;
                                            widget.tenants.tenantFirstName =
                                                firstName.text;
                                            widget.tenants.tenantLastName =
                                                lastName.text;
                                            widget.tenants.tenantPhoneNumber =
                                                phoneNumber.text;
                                            widget.tenants
                                                    .tenantAlternativeNumber =
                                                workNumber.text;
                                            widget.tenants
                                                    .tenantAlternativeEmail =
                                                alterEmail.text;
                                            widget.tenants.tenantEmail =
                                                email.text;
                                            widget.tenants.tenantPassword =
                                                passWord.text;
                                            widget.tenants.tenantBirthDate =
                                                _dateController.text;
                                            widget.tenants.taxPayerId =
                                                taxPayerId.text;
                                            widget.tenants.comments =
                                                comments.text;
                                            widget.tenants.emergencyContact
                                                ?.name = contactName.text;
                                            widget.tenants.emergencyContact
                                                    ?.relation =
                                                relationToTenant.text;
                                            widget.tenants.emergencyContact
                                                ?.email = emergencyEmail.text;
                                            widget.tenants.emergencyContact
                                                    ?.phoneNumber =
                                                emergencyPhoneNumber.text;
                                          });

                                          Navigator.of(context).pop(true);
                                        } catch (e) {
                                          // Fluttertoast.showToast(
                                          //     msg: "Failed to update tenant");
                                          setState(() {
                                            isLoading = false;
                                          });
                                          // String errorMessage = e.toString();
                                          // Fluttertoast.showToast(msg: "$errorMessage");
                                          print(e.toString());
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                        errorMessage = "Admin ID not found";
                                      });
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      height: 50,
                                      // width: MediaQuery.of(context).size.width < 500
                                      //     ? 160
                                      //     : 180,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: blueColor,
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const SpinKitFadingCircle(
                                                color: Colors.white,
                                                size: 25.0,
                                              )
                                            : Text(
                                                "Edit Tenant",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 15
                                                            : 18),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
    );
  }

  reload_Screen() {
    setState(() {});
  }
}

// class CustomTextField extends StatefulWidget {
//   final String hintText;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final bool obscureText;
//   final Function(String)? onChanged;
//   final Function(String)? onChanged2;
//   final Widget? suffixIcon;
//   final IconData? prefixIcon;
//   final void Function()? onSuffixIconPressed;
//   final void Function()? onTap;
//   final String? label;
//   final bool readOnnly;
//   final bool? amount_check;
//   final String? max_amount;
//   final String? error_mess;
//   final bool? optional;
//   final bool? email;
//   final bool? pass;
//   final bool? phone;
//   final List<TextInputFormatter>? inputFormatters;
//   final bool? worknum;
//   final bool? phonenum;
//   final bool? businessnum;
//   final TextEditingController? otherController;
//   final TextEditingController? businessController;
//   final TextEditingController? telephoneController;
//   final bool? samephonenumber;
//
//   CustomTextField({
//     Key? key,
//     this.onChanged,
//     this.controller,
//     required this.hintText,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.emailAddress,
//     this.readOnnly = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.onSuffixIconPressed,
//     this.label,
//     this.onTap,
//     this.onChanged2,
//     this.amount_check,
//     this.max_amount,
//     this.error_mess,
//     this.optional = false,
//     this.email,
//     this.pass,
//     this.phone,
//     this.inputFormatters,
//     this.worknum,
//     this.phonenum,
//     this.businessnum,
//     this.otherController, // For work number comparison
//     this.businessController,
//     this.telephoneController,
//     this.samephonenumber=false
//     // Initialize onTap
//   }) : super(key: key);
//
//   @override
//   CustomTextFieldState createState() => CustomTextFieldState();
// }
//
// class CustomTextFieldState extends State<CustomTextField> {
//   String? _errorMessage;
//   TextEditingController _textController =
//       TextEditingController(); // Add this line
//   late FocusNode _focusNode;
//   @override
//   void dispose() {
//     _textController.dispose(); // Dispose the controller when not needed anymore
//     super.dispose();
//     _focusNode.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _textController = widget.controller ?? TextEditingController();
//     _focusNode = FocusNode();
//   }
//
//   KeyboardActionsConfig _buildConfig(BuildContext context) {
//     return KeyboardActionsConfig(
//       actions: [
//         KeyboardActionsItem(
//           focusNode: _focusNode,
//           toolbarButtons: [
//             (node) {
//               return GestureDetector(
//                 onTap: () {
//                   if (widget.onChanged2 != null) {
//                     widget.onChanged2!(_textController.text);
//                   }
//                   node.unfocus(); // Dismiss the keyboard
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.all(14.0),
//                   child: Text(
//                     "Done",
//                     style: TextStyle(
//                         color: Colors.blue, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               );
//             },
//           ],
//         ),
//       ],
//     );
//   }
//   void _validatePhoneNumber(String value) {
//     String formattedPhoneNumber = value.replaceAll(RegExp(r'\D'), '');
//
//     // Check if phone number is exactly 10 digits
//     if (formattedPhoneNumber.length != 10) {
//       setState(() {
//         _errorMessage = "Phone number must be 10 digits";
//       });
//     } else {
//       // Validate uniqueness across all phone number controllers
//       if (widget.telephoneController != null &&
//           widget.telephoneController?.text == value) {
//         setState(() {
//           _errorMessage = 'Number cannot be the same as another';
//         });
//       } else if (widget.otherController != null &&
//           widget.otherController?.text == value) {
//         setState(() {
//           _errorMessage = 'Number cannot be the same as another';
//         });
//       } else if (widget.businessController != null &&
//           widget.businessController?.text == value) {
//         setState(() {
//           _errorMessage = 'Number cannot be the same as another';
//         });
//       } else {
//         setState(() {
//           _errorMessage = null; // Clear error message when the number is valid
//         });
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     final shouldUseKeyboardActions =
//         widget.keyboardType == TextInputType.number;
//     Widget textfield = Stack(
//       clipBehavior: Clip.none,
//       children: <Widget>[
//         FormField<String>(
//           validator: widget.optional!
//               ? (value) {
//                   if (widget.controller!.text.isEmpty) {
//                     return null;
//                   } else if (widget.phone != null) {
//                     print(" num calling ${widget.phone}");
//                     // String formattedPhoneNumber =
//                     //     widget.controller!.text.replaceAll(RegExp(r'\D'), '');
//                     //
//                     // // Removed the empty check
//                     // if (formattedPhoneNumber.length != 10) {
//                     //   setState(() {
//                     //     _errorMessage = "Phone number must be 10 digits";
//                     //   });
//                     //   return '';
//                     // }
//                     _validatePhoneNumber(widget.controller!.text);
//                     return '';
//                   } else if (widget.amount_check != null &&
//                       double.parse(widget.controller!.text) >
//                           double.parse(widget.max_amount!))
//                     setState(() {
//                       _errorMessage = '${widget.error_mess}';
//                     });
//                   return null;
//                 }
//               : (value) {
//                   if (widget.controller!.text.isEmpty) {
//                     setState(() {
//                       if (widget.label == null)
//                         _errorMessage = 'Please ${widget.hintText}';
//                       else
//                         _errorMessage = 'Please ${widget.label}';
//                     });
//                     return '';
//                   } else if (widget.phone != null) {
//                     String formattedPhoneNumber =
//                         widget.controller!.text.replaceAll(RegExp(r'\D'), '');
//
//                     // Removed the empty check
//                     if (formattedPhoneNumber.length != 10) {
//                       setState(() {
//                         _errorMessage = "Phone number must be 10 digits";
//                       });
//                       return '';
//                     }
//                   } else if (widget.email != null) {
//                     if (!EmailValidator.validate(widget.controller!.text)) {
//                       setState(() {
//                         _errorMessage = "Email is not valid";
//                       });
//                       return '';
//                     }
//                   } else if (widget.pass != null) {
//                     String? validationMessage =
//                         ValidatePassword(widget.controller!.text);
//                     if (validationMessage != null) {
//                       setState(() {
//                         _errorMessage = validationMessage;
//                       });
//                       return '';
//                     }
//                   }
//                   // else if (widget.pass != null) {
//                   //   // Validate as password
//                   //   String? validationMessage = ValidatePassword(value ?? '');
//                   //   if (validationMessage != null) {
//                   //     setState(() {
//                   //       _errorMessage = validationMessage;
//                   //     });
//                   //     return ''; // Return empty string to indicate error
//                   //   }
//                   // }
//
//                   else if (widget.amount_check != null &&
//                       double.parse(widget.controller!.text) >
//                           double.parse(widget.max_amount!))
//                     setState(() {
//                       _errorMessage = '${widget.error_mess}';
//                     });
//                   return null;
//                 },
//           builder: (FormFieldState<String> state) {
//             return Column(
//               children: <Widget>[
//                 Material(
//                   elevation: 2,
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Container(
//                     height: 50,
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.0),
//                       //border: Border.all(color: blueColor),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           offset: Offset(4, 4),
//                           blurRadius: 3,
//                         ),
//                       ],
//                     ),
//                     child: TextFormField(
//                       /*    onFieldSubmitted: (value){
//                         if(value.isNotEmpty){
//
//                           if(widget.amount_check != null){
//                             if(int.parse(value) > int.parse(widget.max_amount!)){
//                               setState(() {
//                                 _errorMessage = '${widget.error_mess}';
//                               });
//                             }
//                           }
//                           else{
//                             setState(() {
//                               _errorMessage = null;
//                             });
//                           }
//
//                         }
//                         print(value);
//                         widget.onChanged2;
//                       },*/
//                       onFieldSubmitted: widget.onChanged2,
//                       onChanged: (value) {
//                         //  print("object calin $value");
//                         if (value.isNotEmpty) {
//                           setState(() {
//                             _errorMessage = null;
//                           });
//                         }
//                         if (widget.onChanged != null) widget.onChanged!(value);
// //print("callllll");
//                       },
//                       inputFormatters: widget.inputFormatters ?? [],
//                       focusNode: _focusNode,
//                       onTap: () {
//                         if (widget.onTap != null) {
//                           widget.onTap!();
//                           setState(() {
//                             _errorMessage = null;
//                           });
//                         }
//                       },
//                       obscureText: widget.obscureText,
//                       readOnly: widget.readOnnly,
//                       keyboardType: widget.keyboardType,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           state.validate();
//                         }
//                         return null;
//                       },
//                       controller: widget.controller,
//                       decoration: InputDecoration(
//                         suffixIcon: widget.suffixIcon,
//                         hintStyle:
//                             TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
//                         border: InputBorder.none,
//                         hintText: widget.hintText,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (state.hasError && _errorMessage != null ||
//                     widget.amount_check != null)
//                   SizedBox(height: 24),
//                 // Reserve space for error message
//               ],
//             );
//           },
//         ),
//         if (_errorMessage != null)
//           Positioned(
//             top: 60,
//             left: 8,
//             child: Text(
//               _errorMessage!,
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 12.0,
//               ),
//             ),
//           ),
//       ],
//     );
//     return shouldUseKeyboardActions
//         ? SizedBox(
//             height: 60,
//             width: MediaQuery.of(context).size.width * .98,
//             child: KeyboardActions(
//               config: _buildConfig(context),
//               child: textfield,
//             ),
//           )
//         : textfield;
//   }
// }
class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final Function(String)? onChanged2;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final String? label;
  final bool readOnnly;
  final bool? amount_check;
  final String? max_amount;
  final String? error_mess;
  final bool? optional;
  final bool? email;
  final bool? pass;
  final bool? phone;
  final bool? worknum;
  final bool? phonenum;
  final bool? businessnum;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? otherController;
  final TextEditingController? businessController;
  final TextEditingController? telephoneController;
  final TextEditingController? alterController;
  final TextEditingController? emrgencyController;
  final bool? samephonenumber;
  final bool? isInRow; // NEW PARAMETER FOR ROW LAYOUT
  final Border? customBorder; // NEW PARAMETER FOR CUSTOM BORDER
  final Color? borderColor; // NEW PARAMETER FOR BORDER COLOR
  final double? borderWidth; // NEW PARAMETER FOR BORDER WIDTH
  final bool showElevation; // NEW PARAMETER TO CONTROL ELEVATION AND SHADOW
  final int? errorMaxLines; // NEW PARAMETER FOR ERROR MESSAGE MAX LINES
  final TextInputAction? textInputAction; // NEW PARAMETER FOR TEXT INPUT ACTION

  CustomTextField(
      {Key? key,
      this.onChanged,
      this.controller,
      required this.hintText,
      this.obscureText = false,
      this.keyboardType = TextInputType.emailAddress,
      this.readOnnly = false,
      this.prefixIcon,
      this.suffixIcon,
      this.validator,
      this.onSuffixIconPressed,
      this.label,
      this.onTap,
      this.onChanged2,
      this.amount_check,
      this.max_amount,
      this.error_mess,
      this.optional = false,
      this.email,
      this.pass,
      this.phone,
      this.inputFormatters,
      this.worknum,
      this.phonenum,
      this.businessnum,
      this.otherController, // For work number comparison
      this.businessController,
      this.telephoneController,
      this.alterController,
      this.emrgencyController,
      this.samephonenumber = false,
      this.isInRow = false, // DEFAULT TO FALSE FOR SINGLE COLUMN LAYOUT
      this.customBorder, // CUSTOM BORDER PARAMETER
      this.borderColor, // BORDER COLOR PARAMETER
      this.borderWidth, // BORDER WIDTH PARAMETER
      this.showElevation =
          true, // DEFAULT TO TRUE TO MAINTAIN EXISTING BEHAVIOR
      this.errorMaxLines, // PARAMETER FOR ERROR MESSAGE MAX LINES
      this.textInputAction // PARAMETER FOR TEXT INPUT ACTION
      })
      : super(key: key);

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  TextEditingController _textController =
      TextEditingController(); // Add this line
  late FocusNode _focusNode;
  @override
  void dispose() {
    //  _textController.dispose(); // Dispose the controller when not needed anymore
    super.dispose();
    _focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  if (widget.onChanged2 != null) {
                    widget.onChanged2!(_textController.text);
                  }
                  node.unfocus(); // Dismiss the keyboard
                },
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    "Done",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  void _validatePhoneNumber(String value) {
    String formattedPhoneNumber = value.replaceAll(RegExp(r'\D'), '');
    print("for num ${formattedPhoneNumber}");
    // Check if phone number is exactly 10 digits
    if (formattedPhoneNumber.length != 10) {
      setState(() {
        _errorMessage = "Phone number must be 10 digits";
      });
      print("step 1 ${formattedPhoneNumber}");
    } else {
      // Validate uniqueness across all phone number controllers
      if (widget.telephoneController != null &&
          widget.telephoneController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
        print("step 2 ${formattedPhoneNumber}");
      } else if (widget.otherController != null &&
          widget.otherController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
        print("step 3 ${formattedPhoneNumber}");
      } else if (widget.businessController != null &&
          widget.businessController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
        print("step 4 ${formattedPhoneNumber}");
      } else {
        setState(() {
          _errorMessage = null; // Clear error message when the number is valid
        });
      }
    }
  }

  void _validateEmail(String value) {
    // Validate email format using EmailValidator
    if (!EmailValidator.validate(value)) {
      setState(() {
        _errorMessage = "Email is not valid";
      });
    } else {
      // Check if email is not the same as another email (example: other controllers)
      if (widget.alterController != null &&
          widget.alterController?.text == value) {
        setState(() {
          _errorMessage = 'Email cannot be the same';
        });
      } else if (widget.emrgencyController != null &&
          widget.emrgencyController?.text == value) {
        setState(() {
          _errorMessage = 'Email cannot be the same';
        });
      } else {
        setState(() {
          _errorMessage = null; // Clear error message when email is valid
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldUseKeyboardActions =
        widget.keyboardType == TextInputType.number;

    bool hasError = _errorMessage != null && _errorMessage!.isNotEmpty;

    Widget textfield = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // SHRINK TO CONTENT LIKE YOUR STAFF FILE
      children: [
        FormField<String>(
          validator: widget.optional!
              ? (value) {
                  print("work same callling  ${widget.samephonenumber}");
                  if (widget.controller!.text.trim().isEmpty) {
                    return null;
                  } else if (widget.phone != null) {
                    _validatePhoneNumber(widget.controller!.text.trim());
                    print("erroe ${_errorMessage}");
                    if (_errorMessage == null) {
                      return null;
                    }
                    return '';
                  } else if (widget.email != null) {
                    _validateEmail(widget.controller!.text.trim());
                    print("erroe2 ${_errorMessage}");
                    // Return an empty string or handle accordingly
                    if (_errorMessage == null) {
                      return null;
                    }
                    return '';
                  } else if (widget.amount_check != null &&
                      double.parse(widget.controller!.text.trim()) >
                          double.parse(widget.max_amount!))
                    setState(() {
                      _errorMessage = '${widget.error_mess}';
                    });
                  print("value ${value}");
                  return null;
                }
              : (value) {
                  if (widget.controller!.text.trim().isEmpty) {
                    setState(() {
                      if (widget.label == null)
                        _errorMessage = 'Please ${widget.hintText}';
                      else
                        _errorMessage = 'Please ${widget.label}';
                    });
                    return '';
                  } else if (widget.phone != null) {
                    // Check if it's a phone number
                    String formattedPhoneNumber =
                        widget.controller!.text.replaceAll(RegExp(r'\D'), '');

                    if (formattedPhoneNumber.length != 10) {
                      setState(() {
                        _errorMessage = "Phone number must be 10 digits";
                      });
                      return '';
                    }
                    if (widget.samephonenumber != null &&
                        widget.samephonenumber!) {
                      setState(() {
                        _errorMessage =
                            'Phone number and work number cannot be the same';
                      });
                      return '';
                    } else {
                      // Clear error message if phone number is valid
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  } else if (widget.email != null) {
                    if (!EmailValidator.validate(
                        widget.controller!.text.trim())) {
                      setState(() {
                        _errorMessage = "Email is not valid";
                      });
                      return '';
                    }
                    //   _validateEmail(widget.controller!.text);
                    //
                    //   // Return an empty string or handle accordingly
                    //   return '';
                  } else if (widget.pass != null) {
                    String? validationMessage =
                        ValidatePassword(widget.controller!.text.trim());
                    if (validationMessage != null) {
                      setState(() {
                        _errorMessage = validationMessage;
                      });
                      return '';
                    }
                  } else if (widget.amount_check != null &&
                      double.parse(widget.controller!.text.trim()) >
                          double.parse(widget.max_amount!))
                    setState(() {
                      _errorMessage = '${widget.error_mess}';
                    });
                  return null;
                },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  elevation: widget.showElevation ? 2 : 0,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      // Custom border implementation
                      border: widget.customBorder ??
                          (widget.borderColor != null
                              ? Border.all(
                                  color: widget.borderColor!,
                                  width: widget.borderWidth ?? 1.0)
                              : null),
                      boxShadow: widget.showElevation
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(4, 4),
                                blurRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: TextFormField(
                      onFieldSubmitted: widget.onChanged2,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                        if (widget.onChanged != null) widget.onChanged!(value);
                      },
                      inputFormatters: widget.inputFormatters ?? [],
                      focusNode: _focusNode,
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      obscureText: widget.obscureText,
                      readOnly: widget.readOnnly,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          state.validate();
                        }
                        return null;
                      },
                      controller: widget.controller,
                      decoration: InputDecoration(
                        suffixIcon: widget.suffixIcon,
                        hintStyle:
                            const TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                        border: InputBorder.none,
                        hintText: widget.hintText,
                      ),
                    ),
                  ),
                ),
                hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.pass == true) const SizedBox(width: 4),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11.0, // Even smaller font size
                                      height: 1.1, // Even tighter line height
                                      letterSpacing:
                                          -0.2, // Slightly tighter letter spacing
                                    ),
                                    maxLines: widget.pass == true
                                        ? 6
                                        : 1, // Increased to 6 lines for very long messages
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ],
    );
    return shouldUseKeyboardActions
        ? SizedBox(
            height: widget.isInRow == true
                ? 70
                : (hasError
                    ? (widget.pass == true ? 150 : 74)
                    : 54), // Increased height for password errors with icon
            child: KeyboardActions(
              config: _buildConfig(context),
              child: textfield,
            ),
          )
        : widget.isInRow == true
            ? SizedBox(
                height:
                    82, // Compact height for row alignment with minimal space
                child: textfield,
              )
            : textfield; // Dynamic shrink only for single column fields
  }
}
