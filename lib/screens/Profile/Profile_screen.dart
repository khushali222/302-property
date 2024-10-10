import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../repository/profile_repository.dart';
import '../../widgets/drawer_tiles.dart';
import '../../widgets/custom_drawer.dart';
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
  final TextEditingController _companyAddressController =
      TextEditingController();
  final TextEditingController _companyPostalCodeController =
      TextEditingController();
  final TextEditingController _companyCityController = TextEditingController();
  final TextEditingController _companyStateController = TextEditingController();
  final TextEditingController _companyCountryController =
      TextEditingController();
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
        _companyAddressController.text = profileData.companyAddress ?? '';
        _companyPostalCodeController.text = profileData.companyPostalCode ?? '';
        _companyCityController.text = profileData.companyCity ?? '';

        _companyStateController.text = profileData.companyState ?? '';
        _companyCountryController.text = profileData.companyCountry ?? '';

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
      appBar: widget_302.App_Bar(context: context, isProfilePageActive: true),
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Dashboard",dropdown: false,),
      body: _isLoading
          ? const ProfileShimmer()
          : _hasError
              ? Center(
                  child: Text('Error: $_errorMessage'),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding:  EdgeInsets.all(MediaQuery.of(context).size.width < 500 ? 16 : 30),
                    child: Column(
                      children: [
                        // const SizedBox(height: 20),
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            // color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    color:blueColor,
                                    child: Center(
                                      child: Text(
                                        '${_profile?.firstName?[0].toUpperCase() ?? ''}${_profile?.lastName?[0].toUpperCase() ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${_profile?.firstName} ${_profile?.lastName}',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 500 ? 16 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${_profile?.email}',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 500 ? 13 :  18,
                                    fontWeight: FontWeight.w400,
                                    color: blueColor,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${_profile?.adminId}',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 500 ? 13 : 18,
                                    fontWeight: FontWeight.w400,
                                    color: blueColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        height: 50.0,
                                        padding: const EdgeInsets.only(
                                            top: 8, left: 10),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.only(
                                            bottom:
                                                6.0), //Same as `blurRadius` i guess
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: blueColor


,
                                          boxShadow: [
                                            const BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          "My Account",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                     Text(
                                      "User information",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width < 500 ? 17 : 20,
                                          color: blueColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'First Name',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'First Name',
                                        _firstNameController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'Last Name',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'Last Name',
                                        _lastNameController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'Email Address',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField('Email Address',
                                        _emailController, _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'Phone Number',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'Phone Number',
                                        _phoneNumberController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'Company Name',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'Company Name',
                                        _companyNameController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'Company Address',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'Company Address',
                                        _companyAddressController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'Postal Code',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'Postal Code',
                                        _companyPostalCodeController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'City',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'City',
                                        _companyCityController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'State',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'State',
                                        _companyStateController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),
                                    const Text(
                                      'Country',
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    buildTextField(
                                        'Country',
                                        _companyCountryController,
                                        _validateFirstName),
                                    const SizedBox(height: 16.0),

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
                                                "phone_number":
                                                    _phoneNumberController.text,
                                                "company_address":
                                                    _companyAddressController
                                                        .text,
                                                "postal_code":
                                                    _companyPostalCodeController
                                                        .text,
                                                "city":
                                                    _companyCityController.text,
                                                "state": _companyStateController
                                                    .text,
                                                "country":
                                                    _companyCountryController
                                                        .text,
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 160,
                                            decoration: BoxDecoration(
                                              color: blueColor


,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                      MediaQuery.of(context).size.width < 500 ? 16 : 20
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
                        const SizedBox(height: 20),
                      ],
                    ),
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
        padding: const EdgeInsets.only(left: 10),
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

class ProfileShimmer extends StatefulWidget {
  const ProfileShimmer({super.key});

  @override
  State<ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<ProfileShimmer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(10.0)),
                height: 220,
                width: double.infinity,
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
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 50,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 20,
                        width: 180,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 15,
                        width: 120,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 50,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 15,
                        width: 120,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 50,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 15,
                        width: 120,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 50,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 15,
                        width: 120,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 50,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 30,
                        width: 140,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
