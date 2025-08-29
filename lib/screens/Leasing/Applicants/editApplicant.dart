import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/lease.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/applicants.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../model/ApplicantModel.dart';
import '../../../widgets/custom_drawer.dart';

class EditApplicant extends StatefulWidget {
  Datum applicant;

  final String applicantId;
  EditApplicant({
    required this.applicantId,
    required this.applicant,
  });

  @override
  State<EditApplicant> createState() => _EditApplicantState();
}

class _EditApplicantState extends State<EditApplicant> {
  String? initialFirstName;
  String? initialLastName;
  String? initialEmail;
  String? initialMobileNumber;
  String? initialHomeNumber;
  String? initialBusinessNumber;
  String? initialTelephoneNumber;

  @override
  void initState() {
    // TODO: implement initState
    firstName.text = widget.applicant.applicantFirstName!;
    lastName.text = widget.applicant.applicantLastName!;
    email.text = widget.applicant.applicantEmail!;
    // mobileNumber.text = widget.applicant.applicantPhoneNumber == null
    //     ? ''
    //     :formatPhoneNumberedit( widget.applicant.applicantPhoneNumber!.toString());
    // homeNumber.text = widget.applicant.applicantHomeNumber == null
    //     ? ''
    //     : formatPhoneNumberedit(widget.applicant.applicantHomeNumber!.toString());
    // bussinessNumber.text = widget.applicant.applicantBusinessNumber == null
    //     ? ''
    //     : formatPhoneNumberedit(widget.applicant.applicantBusinessNumber!.toString());
    // telePhoneNumber.text = widget.applicant.applicantTelephoneNumber == null
    //     ? ''
    //     : formatPhoneNumberedit(widget.applicant.applicantTelephoneNumber!.toString());
    mobileNumber.text = formatPhoneNumberedit(
        widget.applicant.applicantPhoneNumber?.toString() ?? '');
    homeNumber.text = formatPhoneNumberedit(
        widget.applicant.applicantHomeNumber?.toString() ?? '');
    bussinessNumber.text = formatPhoneNumberedit(
        widget.applicant.applicantBusinessNumber?.toString() ?? '');
    telePhoneNumber.text = formatPhoneNumberedit(
        widget.applicant.applicantTelephoneNumber?.toString() ?? '');

    initialFirstName = widget.applicant.applicantFirstName;
    initialLastName = widget.applicant.applicantLastName;
    initialEmail = widget.applicant.applicantEmail;
    initialMobileNumber = widget.applicant.applicantPhoneNumber?.toString();
    initialHomeNumber = widget.applicant.applicantHomeNumber?.toString();
    initialBusinessNumber =
        widget.applicant.applicantBusinessNumber?.toString();
    initialTelephoneNumber =
        widget.applicant.applicantTelephoneNumber?.toString();

    super.initState();
  }

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobileNumber = TextEditingController();
  final TextEditingController homeNumber = TextEditingController();
  final TextEditingController bussinessNumber = TextEditingController();
  final TextEditingController telePhoneNumber = TextEditingController();

  bool _isLoading = true;
  bool _Loading = false;
  bool isLoading = false;
  String? errorMessage;
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {}; // Mapping of unit_id to rental_unit

  String? _selectedPropertyId;
  String? _selectedProperty;
  String? _selectedUnitId;
  String? _selectedUnit;

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String renderId = '';
  String unitId = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Applicants",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              titleBar(
                width: MediaQuery.of(context).size.width * .91,
                title: 'Edit Applicants',
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
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
                          height: 8,
                        ),
                        const Text('First Name *',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          hintText: 'Enter first name',
                          controller: firstName,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Last Name *',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          hintText: 'Enter last name',
                          controller: lastName,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Email*',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            return null;
                          },
                          email: true,
                          keyboardType: TextInputType.text,
                          hintText: 'Enter email',
                          controller: email,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Mobile Number *',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter mobile number';
                            }
                            return null;
                          },
                          phone: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                            PhoneNumberFormatter(),
                          ],
                          // keyboardType: TextInputType.numberWithOptions(
                          //     signed: true, decimal: true),
                          hintText: 'Enter mobile number',
                          controller: mobileNumber,
                          otherController: homeNumber,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Home Number',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextField(
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter home number';
                          //   }
                          //   return null;
                          // },
                          // keyboardType: TextInputType.numberWithOptions(
                          //     signed: true, decimal: true),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                            PhoneNumberFormatter(),
                          ],
                          phone: true,
                          hintText: 'Enter home number',
                          controller: homeNumber,
                          otherController: mobileNumber,
                          optional: true,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Business Number',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextField(
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter business number';
                          //   }
                          //   return null;
                          // },
                          // keyboardType: TextInputType.numberWithOptions(
                          //     signed: true, decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                            PhoneNumberFormatter(),
                          ],
                          keyboardType: TextInputType.number,
                          hintText: 'Enter business number',
                          controller: bussinessNumber,
                          otherController: homeNumber,
                          businessController: mobileNumber,
                          optional: true,
                          phone: true,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Telephone Number',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextField(
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter telephone number';
                          //   }
                          //   return null;
                          // },
                          // keyboardType: TextInputType.numberWithOptions(
                          //     signed: true, decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                            PhoneNumberFormatter(),
                          ],
                          keyboardType: TextInputType.number,
                          hintText: 'Enter telephone number',
                          controller: telePhoneNumber,
                          otherController: bussinessNumber,
                          businessController: homeNumber,
                          telephoneController: mobileNumber,
                          optional: true,
                          phone: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 170,
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

                            if (email.text.trim().isEmpty) {
                              setState(() {
                                isFormValid = false;
                              });
                            }

                            // Check for changes
                            bool hasChanges = firstName.text !=
                                    initialFirstName ||
                                lastName.text != initialLastName ||
                                email.text != initialEmail ||
                                mobileNumber.text != initialMobileNumber ||
                                homeNumber.text != initialHomeNumber ||
                                bussinessNumber.text != initialBusinessNumber ||
                                telePhoneNumber.text != initialTelephoneNumber;

                            if (!hasChanges) {
                              print("No changes made, API call not necessary.");
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
                                // Create the applicant data map
                                Map<String, dynamic> applicantData = {
                                  "applicant_firstName":
                                      firstName.text.trim().isNotEmpty
                                          ? firstName.text.trim()
                                          : '',
                                  "applicant_lastName":
                                      lastName.text.trim().isNotEmpty
                                          ? lastName.text.trim()
                                          : '',
                                  "applicant_email":
                                      email.text.trim().isNotEmpty
                                          ? email.text.trim()
                                          : '',
                                  "applicant_phoneNumber":
                                      mobileNumber.text.trim().isNotEmpty
                                          ? mobileNumber.text.trim()
                                          : '',
                                  "applicant_homeNumber":
                                      homeNumber.text.trim().isNotEmpty
                                          ? homeNumber.text.trim()
                                          : '',
                                  "applicant_telephoneNumber":
                                      telePhoneNumber.text.trim().isNotEmpty
                                          ? telePhoneNumber.text.trim()
                                          : '',
                                  "applicant_businessNumber":
                                      bussinessNumber.text.trim().isNotEmpty
                                          ? bussinessNumber.text.trim()
                                          : '',
                                };

                                // Make the API call using updateApplicants
                                final response =
                                    await ApplicantRepository.updateApplicants(
                                  applicantId: widget.applicantId,
                                  applicantData: applicantData,
                                );

                                Fluttertoast.showToast(
                                    msg: "Applicant updated successfully");
                                Navigator.of(context).pop(true);
                                setState(() {
                                  widget.applicant.applicant!
                                      .applicantFirstName = firstName.text;
                                  widget.applicant.applicant!
                                      .applicantLastName = lastName.text;
                                  widget.applicant.applicant!
                                      .applicantPhoneNumber = mobileNumber.text;
                                  widget.applicant.applicant!
                                      .applicantHomeNumber = homeNumber.text;
                                  widget.applicant.applicant!
                                          .applicantBusinessNumber =
                                      bussinessNumber.text;
                                  widget.applicant.applicant!
                                          .applicantTelephoneNumber =
                                      telePhoneNumber.text;
                                  widget.applicant.applicant!.applicantEmail =
                                      email.text;
                                  isLoading = false;
                                });
                              } catch (e) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                              errorMessage = "Admin ID not found";
                            });
                            //  Fluttertoast.showToast(msg: "Admin ID not found");
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
                                'Update Applicant',
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
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () {
                              Navigator.pop(context);
                              firstName.clear();
                              lastName.clear();
                              email.clear();
                              mobileNumber.clear();
                              bussinessNumber.clear();
                              homeNumber.clear();
                              telePhoneNumber.clear();
                              _selectedProperty = null;
                              _selectedUnit = null;
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
    );
  }

  void _submitApplicantAndLease() async {
    setState(() {
      _Loading = true;
    });
    try {
      // Handle successful response

      // print('Response: $response');
    } catch (e) {
      // Handle error
      print('Error posting applicant and lease: $e');
    } finally {
      setState(() {
        _Loading = false;
      });
    }
  }
}
