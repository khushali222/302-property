import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../repository/profile_repository.dart';
import '../../widgets/drawer_tiles.dart';
import '../../widgets/custom_drawer.dart';

class Profile_screen extends StatefulWidget {
  // final String email;
  // final String admin_id;
  // final String role;
  // const Profile_screen({super.key, required this.email,required this.admin_id, required this.role});
  const Profile_screen({super.key});

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
  ConnectivityResult? _connectivityResult;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    _fetchProfile();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
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

  //for change password

  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  bool passworderror = false;
  bool confirmpassworderror = false;
  bool loading = false;

  String passwordmessage = "";
  String confirmpasswordmessage = "";
  bool visiable_password = true;
  bool visiable_password_confirm = true;

  final formKey = GlobalKey<FormState>();
  void changePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? email = prefs.getString("email");
    String? role = prefs.getString("role");
    setState(() {
      loading = true; // Set loading to true while changing password
    });

    final response = await http.put(
      Uri.parse('${Api_url}/api/admin/app/reset_password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password.text,
        'admin_id': id,
        'role': "admin"
      }),
    );
    print("${role}");
    setState(() {
      loading = false; // Set loading to false after receiving response
    });
    print( ' change password ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["message"] == "Password Updated Successfully") {
        print(jsonData);
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => Login_Screen()));
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Password updated successfully")),
        // );
        Fluttertoast.showToast(
            msg: 'Password updated successfully');
      } else {
        // Handle other successful responses or display an error message
      }
    } else {
      // Handle HTTP error responses
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Failed to update password")),
      // );
      Fluttertoast.showToast(
          msg: 'Failed to update password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context, isProfilePageActive: true),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Dashboard",
        dropdown: false,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? _isLoading
              ? const ProfileShimmer()
              : _hasError
                  ? Center(
                      child: Text('Error: $_errorMessage'),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width < 500 ? 16 : 30),
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
                                        color: blueColor,
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
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 16
                                                : 22,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      '${_profile?.email}',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 13
                                                : 18,
                                        fontWeight: FontWeight.w400,
                                        color: blueColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      '${_profile?.adminId}',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 13
                                                : 18,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          child: Container(
                                            height: 50.0,
                                            padding: const EdgeInsets.only(
                                                top: 8, left: 10),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: const EdgeInsets.only(
                                                bottom:
                                                    6.0), //Same as `blurRadius` i guess
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: blueColor,
                                              boxShadow: [
                                                const BoxShadow(
                                                  color: Colors.grey,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
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
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 17
                                                  : 20,
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
                                            _validateFirstName,

                                        ),
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
                                        buildTextField(
                                            'Email Address',
                                            _emailController,
                                            _validateFirstName,
                                          isEnabled: false,

                                        ),
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
                                                  ProfileRepository()
                                                      .Edit_profile({
                                                    "first_name":
                                                        _firstNameController
                                                            .text,
                                                    "last_name":
                                                        _lastNameController
                                                            .text,
                                                    "email":
                                                        _emailController.text,
                                                    "company_name":
                                                        _companyNameController
                                                            .text,
                                                    "phone_number":
                                                        _phoneNumberController
                                                            .text,
                                                    "company_address":
                                                        _companyAddressController
                                                            .text,
                                                    "postal_code":
                                                        _companyPostalCodeController
                                                            .text,
                                                    "city":
                                                        _companyCityController
                                                            .text,
                                                    "state":
                                                        _companyStateController
                                                            .text,
                                                    "country":
                                                        _companyCountryController
                                                            .text,
                                                  });
                                                }
                                              },
                                              child: Container(
                                                height: 40,
                                                //width: 160,
                                                decoration: BoxDecoration(
                                                  color: blueColor,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Center(

                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(width: 8,),
                                                      Text(
                                                        "Update",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    500
                                                                ? 15
                                                                : 20),
                                                      ),
                                                      SizedBox(width: 8,),
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
                            Container(
                              // height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Form(
                                key: formKey,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      // const SizedBox(height: 20),
                                      // Login text
                                      Row(
                                        children: [
                                          Text(
                                            "Change Password ",
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.045),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.03,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Password',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Material(
                                              elevation: 3,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.013),
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.013),
                                                  color: Colors.white,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.00),
                                                        child: Center(
                                                          child: TextField(
                                                            onChanged: (value) {
                                                              setState(() {
                                                                passworderror =
                                                                    false;
                                                              });
                                                            },
                                                            obscureText:
                                                                visiable_password,
                                                            controller:
                                                                password,
                                                            cursorColor:
                                                                blueColor,
                                                            decoration:
                                                                InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(14),
                                                              enabledBorder:
                                                                  passworderror
                                                                      ? OutlineInputBorder(
                                                                          borderRadius:
                                                                          BorderRadius.circular(
                                                                              MediaQuery.of(context)
                                                                                  .size
                                                                                  .width *
                                                                                  0.013),
                                                                          borderSide:
                                                                              BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                      : InputBorder
                                                                          .none,
                                                              prefixIcon:
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        15.0),
                                                                child: Image.asset(
                                                                    'assets/icons/pasword.png'),
                                                              ),
                                                              hintText:
                                                                  "Password",
                                                              suffixIcon:
                                                                  InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    visiable_password =
                                                                        !visiable_password;
                                                                  });
                                                                },
                                                                child: Icon(
                                                                  visiable_password
                                                                      ? Icons
                                                                          .remove_red_eye_outlined
                                                                      : Icons
                                                                          .visibility_off_outlined,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      passworderror
                                          ? Center(
                                              child: Text(
                                              passwordmessage,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ))
                                          : Container(),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Confirm Password',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          // SizedBox(
                                          //   width: MediaQuery.of(context).size.width * 0.099,
                                          // ),
                                          Expanded(
                                            child: Material(
                                              elevation: 3,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.013),
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.013),
                                                  color: Colors.white,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.00),
                                                        child: Center(
                                                          child: TextField(
                                                            onChanged: (value) {
                                                              setState(() {
                                                                confirmpassworderror =
                                                                    false;
                                                              });
                                                            },
                                                            obscureText:
                                                                visiable_password_confirm,
                                                            controller:
                                                                confirmpassword,
                                                            cursorColor:
                                                                blueColor,
                                                            decoration:
                                                                InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(14),
                                                              enabledBorder:
                                                                  confirmpassworderror
                                                                      ? OutlineInputBorder(
                                                                          borderRadius:
                                                                          BorderRadius.circular(
                                                                              MediaQuery.of(context)
                                                                                  .size
                                                                                  .width *
                                                                                  0.013),
                                                                          borderSide:
                                                                              BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                      : InputBorder
                                                                          .none,
                                                              prefixIcon:
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        15.0),
                                                                child: Image.asset(
                                                                    'assets/icons/pasword.png'),
                                                              ),
                                                              hintText:
                                                                  "Confirm password",
                                                              suffixIcon:
                                                                  InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    visiable_password_confirm =
                                                                        !visiable_password_confirm;
                                                                  });
                                                                },
                                                                child: Icon(
                                                                  visiable_password_confirm
                                                                      ? Icons
                                                                          .remove_red_eye_outlined
                                                                      : Icons
                                                                          .visibility_off_outlined,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // SizedBox(
                                          //   width: MediaQuery.of(context).size.width * 0.099,
                                          // ),
                                        ],
                                      ),
                                      confirmpassworderror
                                          ? Center(
                                              child: Text(
                                              confirmpasswordmessage,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ))
                                          : Container(),

                                      // Spacer(),
                                      // Login button
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (password.text.isEmpty) {
                                            setState(() {
                                              passworderror = true;
                                              passwordmessage =
                                                  "Password is required";
                                            });
                                          } else if (password.text.length < 8) {
                                            setState(() {
                                              passworderror = true;
                                              passwordmessage =
                                                  "Password must have 8 Characters";
                                            });
                                          } else if (!RegExp(
                                                  r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                              .hasMatch(password.text)) {
                                            setState(() {
                                              passworderror = true;
                                              passwordmessage =
                                                  'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
                                            });
                                          } else {
                                            setState(() {
                                              passworderror = false;
                                            });
                                          }
                                          if (confirmpassword.text.isEmpty) {
                                            setState(() {
                                              confirmpassworderror = true;
                                              confirmpasswordmessage =
                                                  "Confirm password is required";
                                            });
                                          } else if (confirmpassword.text !=
                                              password.text) {
                                            setState(() {
                                              confirmpassworderror = true;
                                              confirmpasswordmessage =
                                                  "Both password is not match";
                                            });
                                          } else {
                                            setState(() {
                                              confirmpassworderror = false;
                                            });
                                          }
                                          if (!passworderror &&
                                              !confirmpassworderror) {
                                            changePassword();
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              // height: MediaQuery.of(context)
                                              //         .size
                                              //         .height *
                                              //     0.05,
                                              height:40,
                                               width: MediaQuery.of(context).size.width * 0.45,
                                              decoration: BoxDecoration(
                                                color: blueColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: loading
                                                    ? SpinKitFadingCircle(
                                                        color: Colors.white,
                                                        size: 40.0,
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          // SizedBox(
                                                          //   width: 8,
                                                          // ),
                                                          Text(
                                                            "Change password",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: MediaQuery.of(
                                                                    context)
                                                                    .size
                                                                    .width <
                                                                    500
                                                                    ? 15
                                                                    : 20),
                                                          ),
                                                          // SizedBox(
                                                          //   width: 8,
                                                          // ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    )
          : SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/no_internet.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                  Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator , {bool isEnabled = true} ) {
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
          enabled: isEnabled,
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
