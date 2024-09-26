import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/lease.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '../../../repository/Property_type.dart';
import '../../../repository/applicants.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../model/ApplicantModel.dart';
import '../../../widgets/custom_drawer.dart';

class AddApplicant extends StatefulWidget {
  const AddApplicant({super.key});

  @override
  State<AddApplicant> createState() => _AddApplicantState();
}

class _AddApplicantState extends State<AddApplicant> {
  @override
  void initState() {
    super.initState();
    // print(widget.cosigner?.firstName);

    _loadProperties();
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
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {}; // Mapping of unit_id to rental_unit

  String? _selectedPropertyId;
  String? _selectedProperty;
  String? _selectedUnitId;
  String? _selectedUnit;

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
    String? staffid = prefs.getString("staff_id");
    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffid",
      });
      print('$Api_url/api/unit/rental_unit/$rentalId');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};
        jsonResponse.forEach((data) {
          unitAddresses[data['unit_id'].toString()] =
              data['rental_unit'].toString();
        });

        setState(() {
          units = unitAddresses;
          _isLoading = false;
        });
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
                title: 'Add Applicants',
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

                            // Regular expression for validating an email
                            String pattern =
                                r'^[a-zA-Z0-9]+[a-zA-Z0-9._%-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                            RegExp regex = RegExp(pattern);

                            if (!regex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }

                            return null;
                          },
                          email: true,
                          keyboardType: TextInputType.emailAddress,
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
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
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
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
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
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
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
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          hintText: 'Enter telephone number',
                          controller: telePhoneNumber,
                          optional: true,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Property',
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
                              validator: (value) {
                                if (_selectedPropertyId == null) {
                                  return 'Please select an option';
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField2<String>(
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
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFFb0b6c3),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        items: properties.keys.map((rentalId) {
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
                                            // Notify form field of the change
                                            _selectedUnitId = null;
                                            _selectedPropertyId = value;
                                            _selectedProperty = properties[
                                                value]; // Store selected property

                                            renderId = value.toString();
                                            print(
                                                'Selected Property: $_selectedProperty');
                                            _loadUnits(value!);
                                            state.didChange(
                                                value); // Fetch units for the selected property
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
                            units.isNotEmpty
                                ? const Text('Unit',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey))
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              items: units.keys.map((unitId) {
                                                return DropdownMenuItem<String>(
                                                  value: unitId,
                                                  child: Text(
                                                    units[unitId]!,
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
                                              value: _selectedUnitId,
                                              onChanged: (value) {
                                                setState(() {
                                                  // Notify form field of the change
                                                  unitId = value.toString();
                                                  _selectedUnitId = value;
                                                  _selectedUnit = units[
                                                      value]; // Store selected unit
                                                  state.didChange(value);
                                                  print(
                                                      'Selected Unit: $_selectedUnit');
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
                                                icon:
                                                    Icon(Icons.arrow_drop_down),
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
                                  )
                                : Container(),
                          ],
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
                        width: 170,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () async {
                              if (_formkey.currentState?.validate() ?? false) {
                                print('valid');

                                _submitApplicantAndLease();
                                //charges
                              } else {
                                print('invalid');
                              }
                            },
                            child: const Text(
                              'Create Applicant',
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String adminId = prefs.getString('adminId').toString();

      print(firstName.text);
      print(lastName.text);
      print(email.text);
      print(mobileNumber.text);
      print(homeNumber.text);
      print(telePhoneNumber.text);
      print(bussinessNumber.text);
      print(_selectedProperty.toString());
      print(_selectedUnit.toString());

      // Create the ApplicantDetails object
      ApplicantDetails applicantData = ApplicantDetails(
        adminId: adminId,
        applicantFirstName: firstName.text,
        applicantLastName: lastName.text,
        applicantEmail: email.text,
        applicantPhoneNumber: mobileNumber.text,
        applicantHomeNumber: homeNumber.text,
        applicantTelephoneNumber: telePhoneNumber.text,
        applicantBusinessNumber: bussinessNumber.text,
      );

      // Create the LeaseApplicant object
      LeaseApplicant leaseData = LeaseApplicant(
        adminId: adminId,
        rentalAddress: _selectedPropertyId.toString(),
        rentalUnit: _selectedUnitId.toString(),
      );

      print(_selectedProperty);
      print(_selectedUnit);
      // Create the ApplicantData object
      Datum applicantDataObj = Datum(
        applicant: applicantData,
        lease: leaseData,
      );

      // Make the POST request
      final Map<String, dynamic> response =
          await ApplicantRepository.postApplicant(
        applicantData: applicantDataObj,
      );

      // Handle successful response
      Navigator.pop(context, true);
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
