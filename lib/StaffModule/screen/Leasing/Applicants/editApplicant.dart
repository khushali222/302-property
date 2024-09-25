import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/lease.dart';
import 'package:three_zero_two_property/StaffModule/repository/applicants.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../model/ApplicantModel.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    firstName.text = widget.applicant.applicantFirstName!;
    lastName.text = widget.applicant.applicantLastName!;
    email.text = widget.applicant.applicantEmail!;
    mobileNumber.text = widget.applicant.applicantPhoneNumber == null
        ? ''
        : widget.applicant.applicantPhoneNumber!.toString();
    homeNumber.text = widget.applicant.applicantHomeNumber == null
        ? ''
        : widget.applicant.applicantHomeNumber!.toString();
    bussinessNumber.text = widget.applicant.applicantBusinessNumber == null
        ? ''
        : widget.applicant.applicantBusinessNumber!.toString();
    telePhoneNumber.text = widget.applicant.applicantTelephoneNumber == null
        ? ''
        : widget.applicant.applicantTelephoneNumber!.toString();

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

  // Future<void> _loadProperties() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? id = prefs.getString("adminId");

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response =
  //         await http.get(Uri.parse('${Api_url}/api/rentals/rentals/$id'));
  //     print('${Api_url}/api/rentals/rentals/$id');

  //     if (response.statusCode == 200) {
  //       List jsonResponse = json.decode(response.body)['data'];
  //       Map<String, String> addresses = {};
  //       jsonResponse.forEach((data) {
  //         addresses[data['rental_id'].toString()] =
  //             data['rental_adress'].toString();
  //       });

  //       setState(() {
  //         properties = addresses;
  //         _isLoading = false;
  //       });
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to fetch properties: $e')),
  //     );
  //   }
  // }

  // Future<void> _loadUnits(String rentalId) async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response =
  //         await http.get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'));
  //     print('$Api_url/api/unit/rental_unit/$rentalId');

  //     if (response.statusCode == 200) {
  //       List jsonResponse = json.decode(response.body)['data'];
  //       Map<String, String> unitAddresses = {};
  //       jsonResponse.forEach((data) {
  //         unitAddresses[data['unit_id'].toString()] =
  //             data['rental_unit'].toString();
  //       });

  //       setState(() {
  //         units = unitAddresses;
  //         _isLoading = false;
  //       });
  //     } else {
  //       throw Exception('Failed to load units');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to fetch units: $e')),
  //     );
  //   }
  // }

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String renderId = '';
  String unitId = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Applicants",dropdown: true,),
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
                        color: const Color.fromRGBO(21, 43, 83, 1),
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
                          keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                          hintText: 'Enter mobile number',
                          controller: mobileNumber,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('home number',
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
                          keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                          hintText: 'Enter home number',
                          controller: homeNumber,
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
                          keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                          hintText: 'Enter business number',
                          controller: bussinessNumber,
                          optional: true,
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
                          keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                          hintText: 'Enter telephone number',
                          controller: telePhoneNumber,
                          optional: true,
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
                      width: 155,
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
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? adminId = prefs.getString("adminId");
                            print(firstName.text);
                            print(lastName.text);
                            print(email.text);
                            print(mobileNumber.text);
                            print(homeNumber.text);
                            print(telePhoneNumber.text);
                            print(bussinessNumber.text);
                            print(_selectedProperty.toString());
                            print(_selectedUnit.toString());

                            try {
                              // Create the applicant data map
                              Map<String, dynamic> applicantData = {
                                "admin_id": adminId,
                                "applicant_firstName": firstName.text.isNotEmpty
                                    ? firstName.text
                                    : 'N/A',
                                "applicant_lastName": lastName.text.isNotEmpty
                                    ? lastName.text
                                    : 'N/A',
                                "applicant_email":
                                    email.text.isNotEmpty ? email.text : 'N/A',
                                "applicant_phoneNumber":
                                    mobileNumber.text.isNotEmpty
                                        ? mobileNumber.text
                                        : 'N/A',
                                "applicant_homeNumber":
                                    homeNumber.text.isNotEmpty
                                        ? homeNumber.text
                                        : 'N/A',
                                "applicant_telephoneNumber":
                                    telePhoneNumber.text.isNotEmpty
                                        ? telePhoneNumber.text
                                        : 'N/A',
                                "applicant_businessNumber":
                                    bussinessNumber.text.isNotEmpty
                                        ? bussinessNumber.text
                                        : 'N/A',
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

                                widget.applicant.applicant!.applicantFirstName =
                                    firstName.text;
                                widget.applicant.applicant!.applicantLastName =
                                    lastName.text;
                                widget.applicant.applicant!
                                    .applicantPhoneNumber = mobileNumber.text;
                                widget.applicant.applicant!
                                    .applicantHomeNumber = homeNumber.text;
                                widget.applicant.applicant!
                                    .applicantBusinessNumber = bussinessNumber.text;
                                widget.applicant.applicant!
                                    .applicantTelephoneNumber = telePhoneNumber.text;
                                widget.applicant.applicant!.applicantEmail =
                                    email.text;
                                isLoading = false;
                              });

                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                              errorMessage = "Admin ID not found";
                            });
                            Fluttertoast.showToast(msg: "Admin ID not found");
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
                            ))),

                  ],
                ),
              ),
              SizedBox(
                height: 10,
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
