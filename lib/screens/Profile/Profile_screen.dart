import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../repository/profile_repository.dart';
import '../../widgets/drawer_tiles.dart';

class Profile_screen extends StatefulWidget {
  const Profile_screen({Key? key}) : super(key: key);

  @override
  State<Profile_screen> createState() => _Profile_screenState();
}

class _Profile_screenState extends State<Profile_screen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  profile? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profileData = await ProfileRepository().fetchProfile();
      setState(() {
        _profile = profileData;
        _firstNameController.text = profileData.firstName ?? '';
        _lastNameController.text = profileData.lastName ?? '';
        _emailController.text = profileData.email ?? '';
        _phoneNumberController.text = profileData.phoneNumber?.toString() ?? '';
        _companyNameController.text = profileData.companyName ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
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
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(context, Icon(CupertinoIcons.circle_grid_3x3, color: Colors.black,), "Dashboard", false),
              buildListTile(context, Icon(CupertinoIcons.house, color: Colors.black,), "Add Property Type", false),
              buildListTile(context, Icon(CupertinoIcons.person_add, color: Colors.black,), "Add Staff Member", false),
              buildDropdownListTile(context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ), "Rental", ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.thumbsUp,
                size: 20,
                color: Colors.black,
              ), "Leasing", ["Rent Roll", "Applicants"]),
              buildDropdownListTile(context,
                  Image.asset("assets/icons/maintence.png", height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: SpinKitFadingCircle(
          color: Colors.black,
          size: 50.0,
        ),
      )
          : _hasError
          ? Center(
        child: Text('Error: $_errorMessage'),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 220,
                width: MediaQuery.of(context).size.width * .9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 70,
                          height: 70,
                          color: Color.fromRGBO(21, 43, 81, 1),
                          child: Center(
                            child: Text(
                              '${_profile?.firstName?[0].toUpperCase() ?? ''}${_profile?.lastName?[0].toUpperCase() ?? ''}',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '${_profile?.firstName} ${_profile?.lastName}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '${_profile?.email}',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(21, 43, 81, 1),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '${_profile?.adminId}',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(21, 43, 81, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Container(
                              height: 50.0,
                              padding:
                              EdgeInsets.only(top: 8, left: 10),
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(
                                  bottom:
                                  6.0), //Same as `blurRadius` i guess
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(5.0),
                                color: Color.fromRGBO(21, 43, 81, 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Text(
                                "My Account",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            "User information",
                            style: TextStyle(fontSize: 17,color:Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold ),
                          ),
                          SizedBox(height: 16.0),
                          Text('First Name',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                          SizedBox(
                            height: 5,
                          ),
                          buildTextField('First Name',
                              _firstNameController, _validateFirstName),
                          SizedBox(height: 16.0),
                          Text('Last Name',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                          SizedBox(
                            height: 5,
                          ),
                          buildTextField('Last Name',
                              _lastNameController, _validateFirstName),
                          SizedBox(height: 16.0),
                          Text('Email Address',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                          SizedBox(
                            height: 5,
                          ),
                          buildTextField('Email Address',
                              _emailController, _validateFirstName),
                          SizedBox(height: 16.0),
                          Text('Phone Number',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                          SizedBox(
                            height: 5,
                          ),
                          buildTextField(
                              'Phone Number',
                              _phoneNumberController,
                              _validateFirstName),
                          SizedBox(height: 16.0),
                          Text('Company Name',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                          SizedBox(
                            height: 5,
                          ),
                          buildTextField(
                              'Company Name',
                              _companyNameController,
                              _validateFirstName),
                          SizedBox(height: 16.0),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     if (_formKey.currentState!.validate()) {
                          //       // If the form is valid, proceed with form submission
                          //       _formKey.currentState!.save();
                          //       ProfileRepository().Edit_profile({
                          //         "first_name": _firstNameController.text,
                          //         "last_name": _lastNameController.text,
                          //         "email": _emailController.text,
                          //         "company_name": _companyNameController.text,
                          //         "phone_number": int.parse(_phoneNumberController.text),
                          //       });
                          //     }
                          //     // Implement save functionality
                          //   },
                          //   child: Text('Update'),
                          // ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!
                                      .validate()) {
                                    // If the form is valid, proceed with form submission
                                    _formKey.currentState!.save();
                                    ProfileRepository().Edit_profile({
                                      "first_name":
                                      _firstNameController.text,
                                      "last_name":
                                      _lastNameController.text,
                                      "email": _emailController.text,
                                      "company_name":
                                      _companyNameController.text,
                                      "phone_number": int.parse(
                                          _phoneNumberController.text),
                                    });
                                  }
                                },
                                child: Container(
                                  height: MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.05,
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.25,
                                  decoration: BoxDecoration(
                                    color:
                                    Color.fromRGBO(21, 43, 81, 1),
                                    borderRadius:
                                    BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Update",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                            MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            // hintStyle: TextStyle(color: Color(0xFF8A95A8)),
          ),
        ),
      ),
    );
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid name';
    }
    return null;
  }
}
