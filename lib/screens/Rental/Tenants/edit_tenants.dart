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
    DateTime initialDate = _dateController.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(_dateController.text)
        : DateTime.now();

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
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
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
    phoneNumber.text =
        formatPhoneNumberedit(widget.tenants.tenantPhoneNumber ?? "");
    workNumber.text =
        formatPhoneNumberedit(widget.tenants.tenantAlternativeNumber ?? "");
    email.text = widget.tenants.tenantEmail ?? "";
    alterEmail.text = widget.tenants.tenantAlternativeEmail ?? "N/A";
   // passWord.text = widget.tenants.tenantPassword ?? "";
    // _dateController.text = widget.tenants.tenantBirthDate ?? "";
    taxPayerId.text = widget.tenants.taxPayerId ?? "";
    comments.text = widget.tenants.comments ?? "";
    contactName.text = widget.tenants.emergencyContact?.name ?? "";
    relationToTenant.text = widget.tenants.emergencyContact?.relation ?? "";
    emergencyPhoneNumber.text = formatPhoneNumberedit(
        widget.tenants.emergencyContact?.phoneNumber ?? "");
    emergencyEmail.text = widget.tenants.emergencyContact?.email ?? "";
    print("DOB ${widget.tenants.tenantBirthDate}");
    _dateController.text = formatDate(widget.tenants.tenantBirthDate ?? "");

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
        passWord.text = tenantData['tenant_password'];
      });
    } else {
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
      body: Form(
        key: _formkey,
        child: Container(
          color: Colors.white,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    titleBar(
                      width: MediaQuery.of(context).size.width * .91,
                      title: 'Edit Tenant',
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .04),
                      child: Container(
                        width: double.infinity,
                        // height: !form_valid ? 860 : 830,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color.fromRGBO(21, 43, 103, 1),
                            )),
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('First Name *',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 10),
                                          CustomTextField(
                                            keyboardType: TextInputType.text,
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
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Last Name *',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 10),
                                          CustomTextField(
                                            keyboardType: TextInputType.text,
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
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Phone Number *',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 10),
                                          CustomTextField(
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    signed: true,
                                                    decimal: true),
                                            hintText: 'Enter phone number',
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
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Work Number',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 10),
                                          CustomTextField(
                                            keyboardType: TextInputType.number,
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
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Email *',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 10),
                                          CustomTextField(
                                            keyboardType:
                                                TextInputType.emailAddress,
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
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Alternative Email',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 10),
                                          CustomTextField(
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            hintText: 'Enter alternative email',
                                            controller: alterEmail,
                                            optional: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Password *',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                          SizedBox(height: 10),
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
                                                  hintText: 'Enter password',
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
                                              SizedBox(width: 10),
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
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
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
                                                            6.0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Visibility(
                                        visible: false,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Alternative Email',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                            SizedBox(height: 10),
                                            CustomTextField(
                                              keyboardType:
                                                  TextInputType.emailAddress,
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
                                SizedBox(height: 10),
                              ],
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .04),
                      child: Container(
                        width: double.infinity,
                        // height: 410,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color.fromRGBO(21, 43, 103, 1),
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
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Date of Birth',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        SizedBox(height: 10),
                                        Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 0),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  offset: Offset(1.2, 1.2),
                                                  blurRadius: 3.0,
                                                  spreadRadius: 1.0,
                                                ),
                                              ],
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(6.0)),
                                          child: TextFormField(
                                            style: TextStyle(
                                              color: Color(0xFF8898aa),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            controller: _dateController,
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFb0b6c3)),
                                              border: InputBorder.none,
                                              hintText: 'Select Date',
                                              suffixIcon: IconButton(
                                                icon:
                                                    Icon(Icons.calendar_today),
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
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('TaxPayer ID',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        SizedBox(height: 10),
                                        CustomTextField(
                                          keyboardType: TextInputType.text,
                                          hintText: 'Enter taxpayer ID',
                                          controller: taxPayerId,
                                          optional: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Comments',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 90,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
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
                                    borderRadius: BorderRadius.circular(6.0)),
                                child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: comments,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFb0b6c3)),
                                      hintText: 'Enter the comment',
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .04),
                      child: Container(
                        width: double.infinity,
                        // height: form_valid ? 520 : 430,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color.fromRGBO(21, 43, 103, 1),
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
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Contact Name',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        SizedBox(height: 10),
                                        CustomTextField(
                                          keyboardType: TextInputType.text,
                                          hintText: 'Enter contact name',
                                          controller: contactName,
                                          optional: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Relationship to Tenant',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        SizedBox(height: 10),
                                        CustomTextField(
                                          keyboardType: TextInputType.text,
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
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('E-Mail',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        SizedBox(height: 10),
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
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Phone Number',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        SizedBox(height: 10),
                                        CustomTextField(
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true, decimal: true),
                                          hintText: 'Enter phone number',
                                          controller: emergencyPhoneNumber,
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
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .04),
                      child: Container(
                        width: double.infinity,
                        // height: form_valid ? 520 : 430,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color.fromRGBO(21, 43, 103, 1),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Override Debit Card Fee',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              SizedBox(
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
                                  Text('Enable Debit Card Fee',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                ],
                              ),
                              enableOverrideFee
                                  ?
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.black.withOpacity(0.2),
                                        offset: Offset(4, 4),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    keyboardType:
                                    TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFb0b6c3)),
                                      border: InputBorder.none,
                                      hintText: "Enter the amount to override fee",
                                      suffix: Text(
                                        '%',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: blueColor,
                                            fontWeight: FontWeight.bold),
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
                                            fontSize: MediaQuery.of(context)
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
                    SizedBox(
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
                                  borderRadius: BorderRadius.circular(8.0),
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
                                        lastName.text != initialLastName ||
                                        phoneNumber.text !=
                                            initialPhoneNumber ||
                                        workNumber.text != initialWorkNumber ||
                                        email.text != initialEmail ||
                                        alterEmail.text != initialAlterEmail ||
                                        passWord.text != initialPassword ||
                                        _dateController.text != initialDob ||
                                        taxPayerId.text != initialTaxPayerId ||
                                        comments.text != initialComments ||
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
                                  Navigator.of(context)
                                      .pop(false); // Optionally navigate back
                                  return;
                                }

                                if (!isFormValid) {
                                  return; // Exit early if the form is not valid
                                }

                                // Proceed with API call
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? adminId = prefs.getString("adminId");

                                if (adminId != null) {
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await TenantsRepository().editTenant(
                                      tenantId: widget.tenants.tenantId ?? "",
                                      adminId: adminId,
                                      tenantFirstName: firstName.text,
                                      tenantLastName: lastName.text,
                                      tenantPhoneNumber: phoneNumber.text,
                                      tenantAlternativeNumber: workNumber.text,
                                      tenantEmail: email.text,
                                      tenantAlternativeEmail: alterEmail.text,
                                      tenantPassword: passWord.text,
                                      tenantBirthDate: _dateController.text,
                                      taxPayerId: taxPayerId.text,
                                      comments: comments.text,
                                      emergencyContactName: contactName.text,
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
                                        msg: "Tenant updated successfully");
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
                                  ? Center(
                                      child: SpinKitFadingCircle(
                                        color: Colors.white,
                                        size: 55.0,
                                      ),
                                    )
                                  : Text(
                                      'Edit Tenant',
                                      style:
                                          TextStyle(color: Color(0xFFf7f8f9)),
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                              height: 50,
                              width: 120,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFffffff),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0))),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Color(0xFF748097)),
                                  ))),
                        ],
                      ),
                    ),
                    SizedBox(
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
                  SizedBox(
                    height: 25,
                  ),
                  titleBar(
                    width: MediaQuery.of(context).size.width * .91,
                    title: 'Edit Tenant',
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17, right: 17),
                    child: Container(
                      width: double.infinity,
                      // height: !form_valid ? 860 : 830,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('First Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
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
                            SizedBox(
                              height: 10,
                            ),
                            Text('Last Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
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
                            SizedBox(
                              height: 10,
                            ),
                            Text('Phone Number *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              // keyboardType: TextInputType.numberWithOptions(
                              //     signed: true, decimal: true),
                              hintText: 'Enter phone number',
                              controller: phoneNumber,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                PhoneNumberFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the phone number';
                                }
                                if (phoneNumber.text.isNotEmpty && value == phoneNumber.text) {
                                  return "Work number and phone number cannot be the same";
                                }
                                return null;
                              },
                              phonenum: true,
                              phone: true,
                              worknum: false,
                              otherController: workNumber,

                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Work Number ',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              // keyboardType: TextInputType.numberWithOptions(
                              //     signed: true, decimal: true),
                              hintText: 'Enter work number',
                              controller: workNumber,
                              optional: true,
                              phone: true,
                              worknum: true,
                              phonenum: true,
                              //   samephonenumber: phoneNumber.text.isNotEmpty ? phoneNumber.text == workNumber.text : false,
                              otherController: phoneNumber,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                PhoneNumberFormatter(),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Email *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
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
                              alterController: alterEmail,
                              email: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Alternative Email',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter alternative email',
                              controller: alterEmail,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                } else if (!isValidEmail(value)) {
                                  print('!isValidEmail(value) invalid');
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              alterController: email,
                              email: true,
                              optional: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Password *',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          _tooltipKey.currentState
                                              ?.ensureTooltipVisible();
                                        },
                                        child: Tooltip(
                                            verticalOffset: 16.0,
                                            exitDuration: Duration(seconds: 2),
                                            textAlign: TextAlign.start,
                                            textStyle: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                            margin: EdgeInsets.only(
                                              left: 42.0,
                                              right: 42.0,
                                            ),
                                            // padding: EdgeInsets.all(8.0),
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
                                            key: _tooltipKey,
                                            child: Icon(Icons.info)))
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {
                                      String generatedPassword =
                                          generateRandomPassword();
                                      setState(() {
                                        passWord.text = generatedPassword;
                                      });
                                    },
                                    icon: Icon(Icons.refresh))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.text,
                                    obscureText: obsecure,
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
                                SizedBox(
                                    width:
                                        10), // Add some space between the widgets
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
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(1.2, 1.2),
                                          blurRadius: 3.0,
                                          spreadRadius: 1.0,
                                        ),
                                      ],
                                      border: Border.all(
                                          width: 0, color: Colors.white),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 17, right: 17, top: 15, bottom: 15),
                    child: Container(
                      width: double.infinity,
                      // height: 410,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
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
                            SizedBox(
                              height: 15,
                            ),
                            Text('Date of Birth',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.2,
                                          1.2), // Shadow offset to the bottom right
                                      blurRadius:
                                          3.0, // How much to blur the shadow
                                      spreadRadius:
                                          1.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF8898aa), // Text color
                                  fontSize: 16.0, // Text size
                                  fontWeight: FontWeight.w400, // Text weight
                                ),
                                controller: _dateController,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Color(0xFFb0b6c3)),
                                  border: InputBorder.none,
                                  // labelText: 'Select Date',
                                  hintText: 'Select Date',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
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
                            SizedBox(
                              height: 10,
                            ),
                            Text('TaxPayer ID',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter tax payer id',
                              controller: taxPayerId,
                              optional: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Comments',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 90,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.2,
                                          1.2), // Shadow offset to the bottom right
                                      blurRadius:
                                          3.0, // How much to blur the shadow
                                      spreadRadius:
                                          1.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: comments,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 13, color: Color(0xFFb0b6c3)),
                                    hintText: 'Enter the comment',
                                  )),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17, right: 17),
                    child: Container(
                      width: double.infinity,
                      // height: form_valid ? 520 : 430,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
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
                            SizedBox(
                              height: 15,
                            ),
                            Text('Contact Name',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter contact name',
                              controller: contactName,
                              optional: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Relationship to Tenant',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter relationship to tenant',
                              controller: relationToTenant,
                              optional: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('E-Mail',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter email',
                              controller: emergencyEmail,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                } else if (!isValidEmail(value)) {
                                  print('!isValidEmail(value) invalid');
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              emrgencyController: alterEmail,
                              alterController: email,
                              email: true,
                              optional: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Phone Number',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              // keyboardType: TextInputType.numberWithOptions(
                              //     signed: true, decimal: true),
                              hintText: 'Enter phone number',
                              controller: emergencyPhoneNumber,
                              businessnum: true,
                              optional: true,

                              // samephonenumber: workNumber.text.isNotEmpty ? workNumber.text == emergencyPhoneNumber.text : false,
                              otherController: workNumber,
                              businessController: phoneNumber,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                PhoneNumberFormatter(),
                              ],
                              phone: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 17, right: 17, top: 15),
                    child: Container(
                      width: double.infinity,
                      // height: form_valid ? 520 : 430,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Override Debit Card Fee',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
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
                                Text('Enable Debit Card Fee',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              ],
                            ),
                            enableOverrideFee
                                ?
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                height: 50,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withOpacity(0.2),
                                      offset: Offset(4, 4),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  keyboardType:
                                  TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFb0b6c3)),
                                    border: InputBorder.none,
                                    hintText: "Enter the amount to override fee",
                                    suffix: Text(
                                      '%',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: blueColor,
                                          fontWeight: FontWeight.bold),
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
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                    ),
                                  )
                                : Container(),
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
                                        lastName.text != initialLastName ||
                                        phoneNumber.text !=
                                            initialPhoneNumber ||
                                        workNumber.text != initialWorkNumber ||
                                        email.text != initialEmail ||
                                        alterEmail.text != initialAlterEmail ||
                                        passWord.text != initialPassword ||
                                        _dateController.text != initialDob ||
                                        taxPayerId.text != initialTaxPayerId ||
                                        comments.text != initialComments ||
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
                                  Navigator.of(context)
                                      .pop(false); // Optionally navigate back
                                  return;
                                }

                                if (!isFormValid) {
                                  return;
                                }

                                // Proceed with API call
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? adminId = prefs.getString("adminId");

                                if (adminId != null) {
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await TenantsRepository().editTenant(
                                      tenantId: widget.tenants.tenantId ?? "",
                                      adminId: adminId,
                                      tenantFirstName: firstName.text.trim(),
                                      tenantLastName: lastName.text.trim(),
                                      tenantPhoneNumber: phoneNumber.text.trim(),
                                      tenantAlternativeNumber: workNumber.text.trim(),
                                      tenantEmail: email.text.trim(),
                                      tenantAlternativeEmail: alterEmail.text.trim(),
                                      tenantPassword: passWord.text.trim(),
                                      tenantBirthDate:  _dateController.text.trim().isNotEmpty
                                    ? reverseFormatDate(_dateController.text.trim())
                                  : "",  // This will ensure no empty string is passed to reverseFormatDate

                                      taxPayerId: taxPayerId.text.trim(),
                                      comments: comments.text.trim(),
                                      emergencyContactName: contactName.text.trim(),
                                      emergencyContactRelation:
                                          relationToTenant.text.trim(),
                                      emergencyContactEmail:
                                          emergencyEmail.text.trim(),
                                      emergencyContactPhoneNumber:
                                          emergencyPhoneNumber.text.trim(),
                                      companyName: companyName,
                                      overRideFee: overrideFee.text.trim(),
                                      enableOverRideFee:
                                          enableOverrideFee.toString(),
                                    );
                                    print(
                                        ' birth date ${reverseFormatDate(_dateController.text.trim())}');
                                    Fluttertoast.showToast(
                                        msg: "Tenant updated successfully");
                                    setState(() {
                                      isLoading = false;
                                      errorMessage = null;
                                      widget.tenants.tenantFirstName =
                                          firstName.text;
                                      widget.tenants.tenantLastName =
                                          lastName.text;
                                      widget.tenants.tenantPhoneNumber =
                                          phoneNumber.text;
                                      widget.tenants.tenantAlternativeNumber =
                                          workNumber.text;
                                      widget.tenants.tenantAlternativeEmail =
                                          alterEmail.text;
                                      widget.tenants.tenantEmail = email.text;
                                      widget.tenants.tenantPassword =
                                          passWord.text;
                                      widget.tenants.tenantBirthDate =
                                          _dateController.text;
                                      widget.tenants.taxPayerId =
                                          taxPayerId.text;
                                      widget.tenants.comments = comments.text;
                                      widget.tenants.emergencyContact?.name =
                                          contactName.text;
                                      widget.tenants.emergencyContact
                                          ?.relation = relationToTenant.text;
                                      widget.tenants.emergencyContact?.email =
                                          emergencyEmail.text;
                                      widget.tenants.emergencyContact
                                              ?.phoneNumber =
                                          emergencyPhoneNumber.text;
                                    });

                                    Navigator.of(context).pop(true);
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: "Failed to update tenant");
                                    setState(() {
                                      isLoading = false;
                                    });
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
                            child: isLoading
                                ? Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 55.0,
                                    ),
                                  )
                                : Text(
                                    'Edit Tenantt',
                                    style: TextStyle(color: Color(0xFFf7f8f9)),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                            height: 50,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFffffff),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF748097)),
                                ))),
                      ],
                    ),
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

  CustomTextField({
    Key? key,
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
    this.samephonenumber=false
    // Initialize onTap
  }) : super(key: key);

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
                child: Padding(
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
  // void _validatePhoneNumber(String value) {
  //   String formattedPhoneNumber = value.replaceAll(RegExp(r'\D'), '');
  //
  //   // Check if phone number is exactly 10 digits
  //   if (formattedPhoneNumber.length != 10) {
  //     setState(() {
  //       _errorMessage = "Phone number must be 10 digits";
  //     });
  //   } else if (widget.otherController != null  ) {
  //     if(widget.businessController != null ){
  //       if (widget.otherController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'work and business cannot be the same';
  //         });
  //       }
  //      else if (widget.businessController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'Phone and business cannot be the same';
  //         });
  //       }
  //       else if (widget.telephoneController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'Phone and telephone cannot be the same';
  //         });
  //       }
  //       else {
  //         setState(() {
  //           _errorMessage = null; // Clear error message when the number is valid
  //         });
  //       }
  //     }
  //     else{
  //       if (widget.otherController?.text == value) {
  //         setState(() {
  //           _errorMessage = 'Phone number and work number cannot be the same';
  //         });
  //       } else {
  //         setState(() {
  //           _errorMessage = null; // Clear error message when the number is valid
  //         });
  //       }
  //     }
  //     // Compare with the work number
  //
  //   } else {
  //     setState(() {
  //       _errorMessage = null; // Clear error message for valid phone numbers
  //     });
  //   }
  // }
  void _validatePhoneNumber(String value) {
    String formattedPhoneNumber = value.replaceAll(RegExp(r'\D'), '');

    // Check if phone number is exactly 10 digits
    if (formattedPhoneNumber.length != 10) {
      setState(() {
        _errorMessage = "Phone number must be 10 digits";
      });
    } else {
      // Validate uniqueness across all phone number controllers
      if (widget.telephoneController != null &&
          widget.telephoneController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else if (widget.otherController != null &&
          widget.otherController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
      } else if (widget.businessController != null &&
          widget.businessController?.text == value) {
        setState(() {
          _errorMessage = 'Number cannot be the same as another';
        });
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
      }else if (widget.emrgencyController != null &&
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
    Widget textfield = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: widget.optional!
              ? (value) {
            print("work same callling  ${widget.samephonenumber}");
            if (widget.controller!.text.trim().isEmpty) {
              return null;
            }
            else if (widget.phone != null) {
              // String formattedPhoneNumber =
              //     widget.controller!.text.replaceAll(RegExp(r'\D'), '');
              //
              // // Removed the empty check
              // if (formattedPhoneNumber.length != 10) {
              //   setState(() {
              //     _errorMessage = "Phone number must be 10 digits";
              //   });
              //   return '';
              // }
              //   if (widget.samephonenumber != null && widget.samephonenumber ==true ) {
              //       print("Same Work Number calling");
              //       setState(() {
              //         _errorMessage = ' number cannot be the same';
              //       });
              //
              //
              //   return '';
              // }else {
              //   // Clear error message if phone number is valid
              //   setState(() {
              //     _errorMessage = null;
              //   });
              // }
              _validatePhoneNumber(widget.controller!.text.trim());
              return '';
            }else if (widget.email != null) {
              // if (!EmailValidator.validate(widget.controller!.text)) {
              //   setState(() {
              //     _errorMessage = "Email is not valid";
              //   });
              //   return '';
              // }
              _validateEmail(widget.controller!.text.trim());

              // Return an empty string or handle accordingly
              return '';
            }
            else if (widget.amount_check != null &&
                double.parse(widget.controller!.text.trim()) >
                    double.parse(widget.max_amount!))
              setState(() {
                _errorMessage = '${widget.error_mess}';
              });
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
            }

            else if (widget.phone != null) {
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
                  _errorMessage = 'Phone number and work number cannot be the same';
                });
                return '';
              }else {
                // Clear error message if phone number is valid
                setState(() {
                  _errorMessage = null;
                });
              }
            } else if (widget.email != null) {
              if (!EmailValidator.validate(widget.controller!.text.trim())) {
                setState(() {
                  _errorMessage = "Email is not valid";
                });
                return '';
              }
            } else if (widget.pass != null) {
              String? validationMessage =
              ValidatePassword(widget.controller!.text.trim());
              if (validationMessage != null) {
                setState(() {
                  _errorMessage = validationMessage;
                });
                return '';
              }
            }


            else if (widget.amount_check != null &&
                double.parse(widget.controller!.text.trim()) >
                    double.parse(widget.max_amount!))
              setState(() {
                _errorMessage = '${widget.error_mess}';
              });
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 50,
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      //border: Border.all(color: blueColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(4, 4),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      /*    onFieldSubmitted: (value){
                        if(value.isNotEmpty){

                          if(widget.amount_check != null){
                            if(int.parse(value) > int.parse(widget.max_amount!)){
                              setState(() {
                                _errorMessage = '${widget.error_mess}';
                              });
                            }
                          }
                          else{
                            setState(() {
                              _errorMessage = null;
                            });
                          }

                        }
                        print(value);
                        widget.onChanged2;
                      },*/
                      onFieldSubmitted: widget.onChanged2,
                      onChanged: (value) {
                        //  print("object calin $value");
                        if (value.isNotEmpty) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                        if (widget.onChanged != null) widget.onChanged!(value);
//print("callllll");
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
                        TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                        border: InputBorder.none,
                        hintText: widget.hintText,
                      ),
                    ),
                  ),
                ),
                if (state.hasError && _errorMessage != null ||
                    widget.amount_check != null)
                  SizedBox(height: 24),
                // Reserve space for error message
              ],
            );
          },
        ),
        if (_errorMessage != null)
          Positioned(
            top: 60,
            left: 8,
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
    return shouldUseKeyboardActions
        ? SizedBox(
      height: _errorMessage != null ? 75 : 60,
      width: MediaQuery.of(context).size.width * .98,
      child: KeyboardActions(
        config: _buildConfig(context),
        child: textfield,
      ),
    )
        : textfield;
  }
}
