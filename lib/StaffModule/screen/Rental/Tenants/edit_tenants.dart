import 'dart:convert';
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

import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../Model/tenants.dart';

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
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  bool obsecure = true;
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

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1), // header background color
              onPrimary: Colors.white, // header text color
              // onSurface: Colors.blue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromRGBO(21, 43, 83, 1), // button text color
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

  @override
  void initState() {
    overrideFee.addListener(_validateInput);
    // TODO: implement initState
    firstName.text = widget.tenants.tenantFirstName!;
    lastName.text = widget.tenants.tenantLastName!;
    phoneNumber.text = widget.tenants.tenantPhoneNumber!;
    workNumber.text = widget.tenants.tenantAlternativeNumber!;
    email.text = widget.tenants.tenantEmail!;
    alterEmail.text = widget.tenants.tenantAlternativeEmail!;
    passWord.text = widget.tenants.tenantPassword!;
    dob.text = widget.tenants.tenantBirthDate!;
    taxPayerId.text = widget.tenants.taxPayerId!;
    comments.text = widget.tenants.comments!;
    contactName.text = widget.tenants.emergencyContact?.name ?? "";
    relationToTenant.text = widget.tenants.emergencyContact!.relation ?? "";
    emergencyPhoneNumber.text =
        widget.tenants.emergencyContact!.phoneNumber ?? "";
    emergencyEmail.text = widget.tenants.emergencyContact!.email ?? "";
    _dateController.text = widget.tenants.tenantBirthDate!;

    // enableOverrideFee = widget.tenants.enableoverrideFee!;
    // overrideFee.text = widget.tenants.overRideFee?.toString() ?? '';

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
                          horizontal:
                              MediaQuery.of(context).size.width * .04),
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
                                            TextInputType.numberWithOptions(signed: true,decimal: true),
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
                                            keyboardType:
                                            TextInputType.numberWithOptions(signed: true,decimal: true),
                                            hintText: 'Enter work number',
                                            controller: workNumber,
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
                                            hintText:
                                                'Enter alternative email',
                                            controller: alterEmail,
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
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.grey)),
                                            SizedBox(height: 10),
                                            CustomTextField(
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              hintText:
                                                  'Enter alternative email',
                                              controller: alterEmail,
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
                          horizontal:
                              MediaQuery.of(context).size.width * .04),
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
                                      color: Color.fromRGBO(21, 43, 103, 1))),
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
                                                icon: Icon(
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
                          horizontal:
                              MediaQuery.of(context).size.width * .04),
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
                                      color: Color.fromRGBO(21, 43, 103, 1))),
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
                                          keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                                          hintText: 'Enter phone number',
                                          controller: emergencyPhoneNumber,
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
                          horizontal:
                              MediaQuery.of(context).size.width * .04),
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
                                  ? Material(
                                      elevation: 2,
                                      borderRadius:
                                          BorderRadius.circular(8.0),
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
                                              color: Colors.black
                                                  .withOpacity(0.2),
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
                                            hintText: "Enter number...*",
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
                                          cursorColor: const Color.fromRGBO(
                                              21, 43, 81, 1),
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
                                backgroundColor:
                                    Color.fromRGBO(21, 43, 83, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  formValid = true;
                                });

                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    formValid = false;
                                  });

                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  String? adminId =
                                      prefs.getString("adminId");
                                  if (adminId != null) {
                                    try {
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
                                        tenantBirthDate: _dateController.text,
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
                                          msg: "Tenant updated successfully");
                                      setState(() {
                                        isLoading = false;
                                        errorMessage = null;
                                        widget.tenants.tenantFirstName =
                                            firstName.text;
                                        widget.tenants.tenantLastName =
                                            lastName.text;
                                      });
                                      Navigator.of(context).pop(true);
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                          msg: "Failed to update tenant");
                                      setState(() {
                                        isLoading = false;
                                        errorMessage = e.toString();
                                      });

                                      // Handle error

                                      print(e.toString());
                                    }
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                      errorMessage = "Admin ID not found";
                                    });
                                  }

                                  setState(() {
                                    isLoading = false;
                                  });
                                  // if (success) {
                                  //   print('Form is valid');
                                  // } else {
                                  //   print('Form is invalid');
                                  // }

                                  // SharedPreferences prefs =
                                  //     await SharedPreferences.getInstance();
                                  // String adminId = prefs.getString("adminId")!;
                                  // EmergencyContact emergencyContact =
                                  //     EmergencyContact(
                                  //   name: contactName.text,
                                  //   relation: relationToTenant.text,
                                  //   email: emergencyEmail.text,
                                  //   phoneNumber: emergencyPhoneNumber.text,
                                  // );

                                  // Tenant tenant = Tenant(
                                  //   adminId: adminId,
                                  //   tenantFirstName: firstName.text,
                                  //   tenantLastName: lastName.text,
                                  //   tenantPhoneNumber: phoneNumber.text,
                                  //   tenantAlternativeNumber: workNumber.text,
                                  //   tenantEmail: email.text,
                                  //   tenantAlternativeEmail: alterEmail.text,
                                  //   tenantPassword: passWord.text,
                                  //   tenantBirthDate: _dateController.text,
                                  //   taxPayerId: taxPayerId.text,
                                  //   comments: comments.text,
                                  //   emergencyContact: emergencyContact,
                                  // );

                                  // bool success = await TenantsRepository()
                                  //     .EditTenant(tenant, widget.tenantId);
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  print('Form is invalid');
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
                                    style:
                                        TextStyle(color: Color(0xFF748097)),
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
                    padding: const EdgeInsets.all(12.0),
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
                              keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                              hintText: 'Enter phone number',
                              controller: phoneNumber,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the phone number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Work Number',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              hintText: 'Enter work number',
                              controller: workNumber,
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
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Password *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
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
                                      borderRadius:
                                          BorderRadius.circular(6.0),
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
                    padding: const EdgeInsets.all(12.0),
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
                                    color: Color.fromRGBO(21, 43, 103, 1))),
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
                                  border: Border.all(
                                      width: 0, color: Colors.white),
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
                              hintText: 'Enter contact name',
                              controller: taxPayerId,
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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
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
                                    color: Color.fromRGBO(21, 43, 103, 1))),
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
                              keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                              hintText: 'Enter phone number',
                              controller: emergencyPhoneNumber,
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
                                ? Material(
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
                                          hintText: "Enter number...*",
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
                                        cursorColor: const Color.fromRGBO(
                                            21, 43, 81, 1),
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
                              backgroundColor: Color.fromRGBO(21, 43, 83, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                formValid = true;
                              });

                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  formValid = false;
                                });

                                setState(() {
                                  isLoading = true;
                                  errorMessage = null;
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? adminId = prefs.getString("adminId");
                                if (adminId != null) {
                                  try {
                                    await TenantsRepository().editTenant(
                                      tenantId: widget.tenants.tenantId ?? "",
                                      adminId: adminId,
                                      tenantFirstName: firstName.text,
                                      tenantLastName: lastName.text,
                                      tenantPhoneNumber: phoneNumber.text,
                                      tenantAlternativeNumber:
                                          workNumber.text,
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
                                      errorMessage = e.toString();
                                    });

                                    // Handle error

                                    print(e.toString());
                                  }
                                } else {
                                  setState(() {
                                    isLoading = false;
                                    errorMessage = "Admin ID not found";
                                  });
                                }

                                setState(() {
                                  isLoading = false;
                                });
                                // if (success) {
                                //   print('Form is valid');
                                // } else {
                                //   print('Form is invalid');
                                // }

                                // SharedPreferences prefs =
                                //     await SharedPreferences.getInstance();
                                // String adminId = prefs.getString("adminId")!;
                                // EmergencyContact emergencyContact =
                                //     EmergencyContact(
                                //   name: contactName.text,
                                //   relation: relationToTenant.text,
                                //   email: emergencyEmail.text,
                                //   phoneNumber: emergencyPhoneNumber.text,
                                // );

                                // Tenant tenant = Tenant(
                                //   adminId: adminId,
                                //   tenantFirstName: firstName.text,
                                //   tenantLastName: lastName.text,
                                //   tenantPhoneNumber: phoneNumber.text,
                                //   tenantAlternativeNumber: workNumber.text,
                                //   tenantEmail: email.text,
                                //   tenantAlternativeEmail: alterEmail.text,
                                //   tenantPassword: passWord.text,
                                //   tenantBirthDate: _dateController.text,
                                //   taxPayerId: taxPayerId.text,
                                //   comments: comments.text,
                                //   emergencyContact: emergencyContact,
                                // );

                                // bool success = await TenantsRepository()
                                //     .EditTenant(tenant, widget.tenantId);
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                print('Form is invalid');
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
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// class CustomTextField extends StatefulWidget {
//   final String hintText;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final bool obscureText;
//
//   final Widget? suffixIcon;
//   final IconData? prefixIcon;
//   final void Function()? onSuffixIconPressed;
//   final void Function()? onTap;
//   final bool readOnnly;
//
//   CustomTextField({
//     Key? key,
//     this.controller,
//     required this.hintText,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.emailAddress,
//     this.readOnnly = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.onSuffixIconPressed,
//     this.onTap, // Initialize onTap
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
//
//   @override
//   void dispose() {
//     _textController.dispose(); // Dispose the controller when not needed anymore
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: <Widget>[
//         FormField<String>(
//           validator: (value) {
//             if (widget.controller!.text.isEmpty) {
//               setState(() {
//                 _errorMessage = 'Please ${widget.hintText}';
//               });
//               return '';
//             }
//             setState(() {
//               _errorMessage = null;
//             });
//             return null;
//           },
//           builder: (FormFieldState<String> state) {
//             return Column(
//               children: <Widget>[
//                 Container(
//                   height: 50,
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8.0),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         offset: Offset(4, 4),
//                         blurRadius: 8,
//                       ),
//                     ],
//                   ),
//                   child: TextFormField(
//                     onTap: widget.onTap,
//                     obscureText: widget.obscureText,
//                     readOnly: widget.readOnnly,
//                     keyboardType: widget.keyboardType,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         state.validate();
//                       }
//                       return null;
//                     },
//                     controller: widget.controller,
//                     decoration: InputDecoration(
//                       suffixIcon: widget.suffixIcon,
//                       hintStyle:
//                           TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
//                       border: InputBorder.none,
//                       hintText: widget.hintText,
//                     ),
//                   ),
//                 ),
//                 if (state.hasError)
//                   SizedBox(height: 24), // Reserve space for error message
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
    _textController.dispose(); // Dispose the controller when not needed anymore
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

  @override
  Widget build(BuildContext context) {
    final shouldUseKeyboardActions =
        widget.keyboardType == TextInputType.number;
    Widget textfield = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: (value) {
            if (widget.controller!.text.isEmpty) {
              setState(() {
                if (widget.label == null)
                  _errorMessage = 'Please ${widget.hintText}';
                else
                  _errorMessage = 'Please ${widget.label}';
              });
              return '';
            } else if (widget.amount_check != null &&
                double.parse(widget.controller!.text) >
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
                        print("object calin $value");
                        if (value.isNotEmpty) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }

                        widget.onChanged;
                        print("callllll");
                      },
                      focusNode: _focusNode,
                      onTap: widget.onTap,
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
                if (state.hasError || widget.amount_check != null)
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
            height: 60,
            width: MediaQuery.of(context).size.width * .98,
            child: KeyboardActions(
              config: _buildConfig(context),
              child: textfield,
            ),
          )
        : textfield;
  }
}
