import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

class AddTenant extends StatefulWidget {
  @override
  State<AddTenant> createState() => _AddTenantState();
}

class _AddTenantState extends State<AddTenant> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  bool obsecure = true;
  bool hasPasswordError = false;
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
  bool enableOverrideFee = false;
  final TextEditingController overrideFee = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      // initialDate: DateTime.now(),
      // firstDate: DateTime(1900),
      // lastDate: DateTime(2101),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // You can adjust this to your needs
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
  void initState() {
    super.initState();
    overrideFee.addListener(_validateInput);
  }

  @override
  void dispose() {
    overrideFee.removeListener(_validateInput);
    overrideFee.dispose();
    super.dispose();
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
      body: LayoutBuilder(builder: (context, constraint) {
        if (constraint.maxWidth > 500) {
          return Form(
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
                          title: 'Add Tenant',
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(height: 10),
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
                                        SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Last Name *',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(height: 10),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(height: 10),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                  PhoneNumberFormatter(),
                                                ],
                                                hintText: 'Enter phone number',
                                                controller: phoneNumber,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'please enter the phone number';
                                                  }
                                                  return null;
                                                },
                                                phone: true,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey)),
                                              SizedBox(height: 10),
                                              CustomTextField(
                                                // keyboardType: TextInputType
                                                //     .numberWithOptions(
                                                //         signed: true,
                                                //         decimal: true),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                  PhoneNumberFormatter(),
                                                ],
                                                hintText: 'Enter work number',
                                                optional: true,
                                                controller: workNumber,
                                                phone: true,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      hintText:
                                                          'Enter password',
                                                      controller: passWord,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          setState(() {
                                                            hasPasswordError =
                                                                true;
                                                          });
                                                          return 'Please enter password';
                                                        }
                                                        String?
                                                            validationMessage =
                                                            ValidatePassword(
                                                                value);
                                                        if (validationMessage !=
                                                            null) {
                                                          setState(() {
                                                            hasPasswordError =
                                                                true;
                                                          });
                                                          return validationMessage;
                                                        }
                                                        setState(() {
                                                          hasPasswordError =
                                                              false;
                                                        });
                                                        return null;
                                                      },
                                                      pass: true,
                                                      errorMaxLines:
                                                          hasPasswordError
                                                              ? 3
                                                              : 1,
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
                                                            color:
                                                                Colors.black26,
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
                                                                .circular(6.0),
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
                                                  horizontal: 12.0,
                                                  vertical: 0),
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
                                                      BorderRadius.circular(
                                                          6.0)),
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
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
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
                                              // keyboardType: TextInputType
                                              //     .numberWithOptions(
                                              //         signed: true,
                                              //         decimal: true),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                                PhoneNumberFormatter(),
                                              ],
                                              hintText: 'Enter phone number',
                                              controller: emergencyPhoneNumber,
                                              optional: true,
                                              phone: true,
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
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
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
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * .04),
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
                                    setState(() {
                                      formValid = true;
                                    });
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        formValid = false;
                                      });

                                      await addTenant();
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
                                          'Add Tenant',
                                          style: TextStyle(
                                              color: Color(0xFFf7f8f9)),
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
                                      )))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        titleBar(
                          width: MediaQuery.of(context).size.width * .91,
                          title: 'Add Tenant',
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
                                    keyboardType: TextInputType.number,
                                    hintText: 'Enter phone number',
                                    controller: phoneNumber,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'please enter the phone number';
                                      }
                                      return null;
                                    },
                                    phone: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                      PhoneNumberFormatter(),
                                    ],
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
                                    optional: true,
                                    phone: true,
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
                                        return 'please enter email';
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
                                    optional: true,
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
                                            if (value == null ||
                                                value.isEmpty) {
                                              setState(() {
                                                hasPasswordError = true;
                                              });
                                              return 'Please enter password';
                                            }
                                            String? validationMessage =
                                                ValidatePassword(value);
                                            if (validationMessage != null) {
                                              setState(() {
                                                hasPasswordError = true;
                                              });
                                              return validationMessage;
                                            }
                                            setState(() {
                                              hasPasswordError = false;
                                            });
                                            return null;
                                          },
                                          pass: true,
                                          errorMaxLines:
                                              hasPasswordError ? 3 : 1,
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: Color(0xFF8898aa), // Text color
                                        fontSize: 16.0, // Text size
                                        fontWeight:
                                            FontWeight.w400, // Text weight
                                      ),
                                      controller: _dateController,
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFb0b6c3)),
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
                                    hintText: 'Enter tex payer id',
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
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
                                    optional: true,
                                    alterController: email,
                                    emrgencyController: alterEmail,
                                    email: true,
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
                          padding: const EdgeInsets.only(
                              left: 17, right: 17, top: 15),
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
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              decoration: InputDecoration(
                                                hintStyle: TextStyle(
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
                                    setState(() {
                                      formValid = true;
                                    });
                                    print("work number ${workNumber.text}");
                                    if (_formkey.currentState!.validate() &&
                                        overRideFeeError == "") {
                                      setState(() {
                                        formValid = false;
                                      });
                                      await addTenant();
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
                                          'Add Tenant',
                                          style: TextStyle(
                                              color: Color(0xFFf7f8f9)),
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
                                      )))
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),
          );
        }
        return Form(
          key: _formkey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  titleBar(
                    width: MediaQuery.of(context).size.width * .99,
                    title: 'Add Tenant',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      // height: !form_valid ? 860 : 830,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color(0xFFDBE0E5),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 4,
                            ),
                            Text('Personal Information',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF152B51))),
                            SizedBox(
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
                                        Text('First Name *',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          keyboardType: TextInputType.text,
                                          hintText: 'Enter first name',
                                          controller: firstName,
                                          showElevation: false,
                                          isInRow:
                                              true, // ADD FOR ROW ALIGNMENT
                                          borderColor: Color(
                                              0xFFCED4DA), // ADD BORDER COLOR
                                          borderWidth: 1.5, // ADD BORDER WIDTH
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
                                SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Last Name *',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          keyboardType: TextInputType.text,
                                          hintText: 'Enter last name',
                                          controller: lastName,
                                          borderColor: Color(0xFFCED4DA),
                                          isInRow:
                                              true, // ADD FOR ROW ALIGNMENT
                                          showElevation: false,
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
                                        Text('Phone Number *',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          keyboardType: TextInputType.number,
                                          // keyboardType: TextInputType.numberWithOptions(
                                          //     signed: true, decimal: true),
                                          hintText: 'Enter phone number',
                                          controller: phoneNumber,
                                          borderColor: Color(0xFFCED4DA),
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
                                            if (phoneNumber.text.isNotEmpty &&
                                                value == phoneNumber.text) {
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
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Work Number ',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          keyboardType: TextInputType.number,
                                          // keyboardType: TextInputType.numberWithOptions(
                                          //     signed: true, decimal: true),
                                          hintText: 'Enter work number',
                                          controller: workNumber,
                                          borderColor: Color(0xFFCED4DA),
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
                                        Text('Email *',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          hintText: 'Enter Email',
                                          controller: email,
                                          isInRow: true,
                                          alterController: alterEmail,
                                          borderColor: Color(0xFFCED4DA),
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
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Alternative Email',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          hintText: 'Enter alternative email',
                                          controller: alterEmail,
                                          isInRow: true,
                                          showElevation: false,
                                          borderColor: Color(0xFFCED4DA),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Label + Tooltip + Refresh aligned horizontally
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Password *',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF101828),
                                                ),
                                              ),
                                              SizedBox(width: 7),
                                              GestureDetector(
                                                onTap: () {
                                                  _tooltipKey.currentState
                                                      ?.ensureTooltipVisible();
                                                },
                                                child: Tooltip(
                                                  key: _tooltipKey,
                                                  verticalOffset: 16.0,
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                  margin: EdgeInsets.symmetric(
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
                                                  child: Icon(
                                                      Icons.info_outline,
                                                      size: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.refresh, size: 20),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
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
                                      SizedBox(height: 6),
                                      // Password Field
                                      CustomTextField(
                                        keyboardType: TextInputType.text,
                                        obscureText: obsecure,
                                        hintText: 'Enter password',
                                        controller: passWord,
                                        isInRow: true,
                                        showElevation: false,
                                        borderColor: Color(0xFFCED4DA),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              obsecure = !obsecure;
                                            });
                                          },
                                          child: Icon(
                                            !obsecure
                                                ? CupertinoIcons.eye_slash_fill
                                                : CupertinoIcons.eye_fill,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter password';
                                          }
                                          return null;
                                        },
                                        pass: true,
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
                                      Text(
                                        'Date of Birth',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF101828),
                                        ),
                                      ),
                                      SizedBox(height: 11),
                                      Material(
                                        // elevation: 2,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xFFCED4DA),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                                            onTap: () => _selectDate(context),
                                            style: TextStyle(
                                              color: Color(0xFF8898aa),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Select Date',
                                              hintStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFb0b6c3)),
                                              border: InputBorder.none,
                                              suffixIcon: IconButton(
                                                icon:
                                                    Icon(Icons.calendar_today),
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
                                        Text('TaxPayer ID',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(height: 10),
                                        CustomTextField(
                                          keyboardType: TextInputType.text,
                                          hintText: 'Enter tax payer id',
                                          controller: taxPayerId,
                                          showElevation: false,
                                          borderColor: Color(0xFFCED4DA),
                                          optional: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Comments',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF101828))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 0),
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
                                                color: Color(0xFFCED4DA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
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
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(
                              color: Color(0xFFCED4DA),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //emergency con
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Emergency Contact',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF152B51))),
                                SizedBox(
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
                                            Text('Contact Name',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF101828))),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CustomTextField(
                                              keyboardType: TextInputType.text,
                                              hintText: 'Enter contact name',
                                              controller: contactName,
                                              showElevation: false,
                                              borderColor: Color(0xFFCED4DA),
                                              optional: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Relationship to Tenant',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF101828))),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CustomTextField(
                                              keyboardType: TextInputType.text,
                                              hintText:
                                                  'Enter relationship to tenant',
                                              controller: relationToTenant,
                                              showElevation: false,
                                              borderColor: Color(0xFFCED4DA),
                                              optional: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
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
                                            Text('E-Mail',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF101828))),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CustomTextField(
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              hintText: 'Enter email',
                                              controller: emergencyEmail,
                                              optional: true,
                                              showElevation: false,
                                              borderColor: Color(0xFFCED4DA),
                                              alterController: email,
                                              emrgencyController: alterEmail,
                                              email: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Phone Number',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF101828))),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CustomTextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              // keyboardType: TextInputType.numberWithOptions(
                                              //     signed: true, decimal: true),
                                              hintText: 'Enter phone number',
                                              controller: emergencyPhoneNumber,
                                              businessnum: true,
                                              optional: true,
                                              showElevation: false,
                                              // samephonenumber: workNumber.text.isNotEmpty ? workNumber.text == emergencyPhoneNumber.text : false,
                                              otherController: workNumber,
                                              businessController: phoneNumber,
                                              borderColor: Color(0xFFCED4DA),
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
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              color: Color(0xFFCED4DA),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //card accepted
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Override Debit Card Fee',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF152B51))),
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xFFCED4DA),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(
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
                                              fontSize: MediaQuery.of(context)
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
                  SizedBox(
                    height: 10,
                  ),
                  //button of add
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    border: Border.all(color: Color(0x80152B51))
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
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 15
                                                : 18),
                                  ),
                                ),
                              )),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                formValid = true;
                              });
                              print("work number ${workNumber.text}");
                              if (_formkey.currentState!.validate() &&
                                  overRideFeeError == "") {
                                setState(() {
                                  formValid = false;
                                });
                                await addTenant();
                              } else {
                                print('Form is invalid');
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
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: blueColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? SpinKitFadingCircle(
                                          color: Colors.white,
                                          size: 25.0,
                                        )
                                      : Text(
                                          "Add Tenant",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
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
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  bool isLoading = false;
  bool formValid = true;

  Future<void> addTenant() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString("adminId")!;
    EmergencyContact emergencyContact = EmergencyContact(
      name: contactName.text.trim(),
      relation: relationToTenant.text.trim(),
      email: emergencyEmail.text.trim(),
      phoneNumber: emergencyPhoneNumber.text.trim(),
    );
    double? overRideFee = double.tryParse(overrideFee.text.trim());
    Tenant tenant = Tenant(
      adminId: adminId,
      tenantFirstName: firstName.text.trim(),
      tenantLastName: lastName.text.trim(),
      tenantPhoneNumber: phoneNumber.text.trim(),
      tenantAlternativeNumber: workNumber.text.trim(),
      tenantEmail: email.text.trim(),
      tenantAlternativeEmail: alterEmail.text.trim(),
      tenantPassword: passWord.text.trim(),
      tenantBirthDate: _dateController.text.trim().isNotEmpty
          ? reverseFormatDate(_dateController.text.trim())
          : "",
      taxPayerId: taxPayerId.text.trim(),
      comments: comments.text.trim(),
      emergencyContact: emergencyContact,
      enableoverrideFee: enableOverrideFee,
      overRideFee: overRideFee,
    );

    bool success = await TenantsRepository().addTenant(tenant);

    setState(() {
      isLoading = false;
    });

    if (success) {
      print('Form is valid');
      Fluttertoast.showToast(msg: "Tenant added successfully");
      Navigator.of(context).pop(true);
    } else {
      print(tenant);
      print('Form is invalid');
    }
  }
}

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
      this.errorMaxLines // PARAMETER FOR ERROR MESSAGE MAX LINES
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
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
                                offset: Offset(4, 4),
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
                hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.pass == true) SizedBox(width: 4),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
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
                    : SizedBox.shrink(),
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
