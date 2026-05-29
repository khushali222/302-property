import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/Plan Purchase/plancheckProvider.dart';
import '../../repository/profile_repository.dart';
import '../../widgets/drawer_tiles.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_switch.dart';

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
  final TextEditingController _createdDate = TextEditingController();
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
  String originalFirstName = '';
  String originalLastName = '';
  String originalEmail = '';
  String originalDate = '';
  String originalPhoneNumber = '';
  String originalCompanyName = '';
  String originalCompanyAddress = '';
  String originalCompanyPostalCode = '';
  String originalCompanyCity = '';
  String originalCompanyState = '';
  String originalCompanyCountry = '';
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
    _loadOldPassword();
    status2FA(); // Fetch 2FA status on screen load
    backupcodeapicall();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // Cancel any existing timer first
    _timer?.cancel();

    // 10 minutes timer for 2FA verification code
    seconds.value = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        _timer?.cancel();
        Fluttertoast.showToast(
          msg: 'Verification code expired',
          backgroundColor: Colors.red,
        );
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    seconds.value = 0;
  }

  String getTimerString() {
    if (seconds.value <= 0) {
      return '0m 0s';
    }
    return '${seconds.value ~/ 60}m ${seconds.value % 60}s';
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
        _phoneNumberController.text =
            formatPhoneNumberedit(profileData.phoneNumber?.toString() ?? '');
        _companyNameController.text = profileData.companyName ?? '';
        _companyAddressController.text = profileData.companyAddress ?? '';
        _companyPostalCodeController.text = profileData.companyPostalCode ?? '';
        _companyCityController.text = profileData.companyCity ?? '';
        _createdDate.text = profileData.createdAt ?? "";
        _companyStateController.text = profileData.companyState ?? '';
        _companyCountryController.text = profileData.companyCountry ?? '';
        password.text = profileData.password ?? "";
        confirmpassword.text = profileData.password ?? "";

        // Store original values
        originalFirstName = profileData.firstName ?? '';
        originalLastName = profileData.lastName ?? '';
        originalEmail = profileData.email ?? '';
        originalPhoneNumber = profileData.phoneNumber?.toString() ?? '';
        originalCompanyName = profileData.companyName ?? '';
        originalCompanyAddress = profileData.companyAddress ?? '';
        originalCompanyPostalCode = profileData.companyPostalCode ?? '';
        originalCompanyCity = profileData.companyCity ?? '';
        originalCompanyState = profileData.companyState ?? '';
        originalCompanyCountry = profileData.companyCountry ?? '';
        originalDate = profileData.createdAt ?? "";
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
  bool passwordsameerror = false;
  bool confirmpassworderror = false;
  bool loading = false;

  bool enble2FA = false;

  bool disable2FA = false;

  // make a radio button for sms and email
  bool sms2FA = false;
  bool email2FA = false;

  // 2FA Setup Flow Variables
  bool show2FASetup = false;
  String selected2FAMethod = ''; // 'sms' or 'email'
  TextEditingController verificationCodeController = TextEditingController();
  bool isVerifyingCode = false;
  bool showVerificationInput = false;

  // 2FA Disable/Regenerate Flow Variables
  bool showDisableVerification = false;
  bool showRegenerateVerification = false;
  TextEditingController disableVerificationController = TextEditingController();
  TextEditingController regenerateVerificationController =
      TextEditingController();

  // Backup Codes Variables
  bool backupCode = false;
  List<Map<String, dynamic>> codes = [];

  // Timer for 2FA verification code
  Timer? _timer;
  ValueNotifier<int> seconds = ValueNotifier(600);
  final GlobalKey<FormState> _formKey2FA = GlobalKey<FormState>();

  String passwordmessage = "";
  String passwordsamemessage = "";
  String confirmpasswordmessage = "";
  bool visiable_password = true;
  bool visiable_password_confirm = true;

  final formKey = GlobalKey<FormState>();

  void changePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? email = prefs.getString("email");
    String? role = prefs.getString("role");
    String? userid = prefs.getString("userId");

    setState(() {
      loading = true; // Set loading to true while changing password
    });

    print(" userid ${userid}");
    final response = await apiPut(
      Uri.parse('${Api_url}/api/admin/app/reset_password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password.text,
        'admin_id': id,
        'role': "admin",
        'user_id': userid,
      }),
    );
    print("${role}");
    setState(() {
      loading = false; // Set loading to false after receiving response
    });
    print(' change password ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["message"] == "Password Updated Successfully") {
        print(jsonData);
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => Login_Screen()));
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Password updated successfully")),
        // );
        await _savePassword(password.text.trim());
        Fluttertoast.showToast(msg: 'Password updated successfully');
      } else {
        // Handle other successful responses or display an error message
      }
    } else {
      // Handle HTTP error responses
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Failed to update password")),
      // );
      Fluttertoast.showToast(msg: 'Failed to update password');
    }
  }

  void status2FA() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? email = prefs.getString("email");
    String? role = prefs.getString("role");
    String? userid = prefs.getString("userId");
    String? token = prefs.getString("token");

    setState(() {
      loading = true; // Set loading to true while fetching 2FA status
    });

    print(" userid ${userid}");
    final response = await apiGet(
      Uri.parse('${Api_url}/api/2fa/2fa-status/${id}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    setState(() {
      loading = false; // Set loading to false after receiving response
    });

    print('2FA status response: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData["statusCode"] == 200 && jsonData["data"] != null) {
        final data = jsonData["data"];
        final bool enabled = data["enabled"] ?? false;
        final String method = data["method"] ?? "";

        setState(() {
          enble2FA = enabled;

          // Set method-specific flags based on the method received
          if (method.toLowerCase() == "email") {
            email2FA = true;
            sms2FA = false;
          } else if (method.toLowerCase() == "sms") {
            sms2FA = true;
            email2FA = false;
          } else {
            // If no method or unknown method, reset both
            email2FA = false;
            sms2FA = false;
          }
        });

        print("2FA Status - Enabled: $enabled, Method: $method");
        print("Email 2FA: $email2FA, SMS 2FA: $sms2FA");
      } else {
        // Handle case where data is null or statusCode is not 200
        setState(() {
          enble2FA = false;
          email2FA = false;
          sms2FA = false;
        });
        print("2FA data not found or invalid response");
      }
    } else {
      // Handle HTTP error responses
      setState(() {
        enble2FA = false;
        email2FA = false;
        sms2FA = false;
      });
      print("Failed to fetch 2FA status: ${response.statusCode}");
      Fluttertoast.showToast(msg: 'Failed to fetch 2FA status');
    }
  }

  // https://staging.cloudrentalmanager.com/api/backup-codes/backup-codes/1730957524276?user_type=admin  call the api for this

  Future<void> backupcodeapicall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString("token");
    String? userid = prefs.getString("userId");

    final response = await apiGet(
      Uri.parse(
          '${Api_url}/api/backup-codes/backup-codes/${userid}?user_type=admin'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      setState(() {
        backupCode = true;
        codes = List<Map<String, dynamic>>.from(jsonData["data"]["codes"]);
      });
      print(jsonData);
    } else {
      setState(() {
        backupCode = false;
      });
      print(jsonData);
    }
  }

  //for save

  Future<void> _savePassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("password", password); // Store the new password
  }

  String oldPassword = "";
  Future<void> _loadOldPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? pass = prefs.getString("password");
    setState(() {
      oldPassword = pass!; // Fetch the old password
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isFreePlan = Provider.of<checkPlanPurchaseProiver>(context)
            .checkplanpurchaseModel
            ?.data
            ?.planDetail
            ?.planName ==
        'Free Plan';

    return Scaffold(
      appBar: widget_302.App_Bar(context: context, isProfilePageActive: true),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Profile",
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
                                                ? 18
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
                                                ? 16
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
                                                ? 16
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
                            Container(
                              //  height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 22),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Account Level :",
                                          style: TextStyle(
                                              color: Color(0xFF8A95A8),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${!isFreePlan ? 'Paid' : "Free"}',
                                          style: TextStyle(
                                              color: blueColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (isFreePlan)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 22),
                                      child: GestureDetector(
                                        onTap: () async {
                                          const url =
                                              'https://www.hostmerchantservices.com/signup/?leadsource=CloudRentalManager';
                                          final uri = Uri.parse(url);

                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication, // Ensures the system browser is used
                                            );
                                          } else {
                                            print('Could not launch URL');
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 35,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              decoration: BoxDecoration(
                                                color: blueColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: loading
                                                    ? const SpinKitFadingCircle(
                                                        color: Colors.white,
                                                        size: 40.0,
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "Upgrade Account",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 15
                                                                  : 20,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (isFreePlan)
                                    const SizedBox(
                                      height: 20,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              //  height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Two-Factor Authentication (2FA) :",
                                          style: TextStyle(
                                              color: Color(0xFF8A95A8),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        CustomSwitch(
                                            initialValue: enble2FA,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value) {
                                                  // Turning ON - show setup flow
                                                  show2FASetup = true;
                                                  showVerificationInput = false;
                                                  selected2FAMethod = '';
                                                } else {
                                                  // Turning OFF - disable 2FA
                                                  enble2FA = false;
                                                  show2FASetup = false;
                                                  showVerificationInput = false;
                                                  selected2FAMethod = '';
                                                  sms2FA = false;
                                                  email2FA = false;
                                                }
                                              });
                                            })
                                      ],
                                    ),
                                  ),
                                  // Show different content based on 2FA state
                                  if (!enble2FA && !show2FASetup)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "Turn on the toggle above to enable Two-Factor Authentication for enhanced security.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),

                                  // 2FA Setup Flow
                                  if (show2FASetup && !showVerificationInput)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Choose your preferred 2FA method:",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 16),

                                          // SMS Radio Button
                                          Row(
                                            children: [
                                              Radio<String>(
                                                value: 'sms',
                                                groupValue: selected2FAMethod,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selected2FAMethod = value!;
                                                  });
                                                },
                                                activeColor: blueColor,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "SMS (${_profile?.phoneNumber ?? 'Phone number'})",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Email Radio Button
                                          Row(
                                            children: [
                                              Radio<String>(
                                                value: 'email',
                                                groupValue: selected2FAMethod,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selected2FAMethod = value!;
                                                  });
                                                },
                                                activeColor: blueColor,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "Email (${_profile?.email ?? 'Email address'})",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 20),

                                          // Enable 2FA Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: selected2FAMethod
                                                      .isNotEmpty
                                                  ? () => _initiate2FASetup()
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    selected2FAMethod.isNotEmpty
                                                        ? blueColor
                                                        : Colors.grey,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Enable 2FA",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Verification Code Input
                                  if (showVerificationInput)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Enter verification code sent to your ${selected2FAMethod == 'email' ? 'email' : 'phone'}:",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 16),

                                          // Verification Code Input Field
                                          Form(
                                            key: _formKey2FA,
                                            child: TextFormField(
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a valid code';
                                                }
                                                if (value.length != 6) {
                                                  return 'Code must be 6 digits';
                                                }
                                                return null;
                                              },
                                              controller:
                                                  verificationCodeController,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: 6,
                                              decoration: InputDecoration(
                                                hintText: "Enter 6-digit code",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: blueColor,
                                                      width: 2),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: 2),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: 2),
                                                ),
                                                counterText: "",
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (seconds.value > 0)
                                                ValueListenableBuilder<int>(
                                                  valueListenable: seconds,
                                                  builder:
                                                      (context, value, child) {
                                                    return RichText(
                                                      textAlign:
                                                          TextAlign.center,
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                "Code will expire in ",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                "${getTimerString()}",
                                                            style:
                                                                const TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              GestureDetector(
                                                onTap: () {
                                                  verificationCodeController
                                                      .clear();
                                                  if (showVerificationInput &&
                                                      seconds.value <= 540) {
                                                    _initiate2FASetup();
                                                  }
                                                },
                                                child:
                                                    ValueListenableBuilder<int>(
                                                  valueListenable: seconds,
                                                  builder:
                                                      (context, value, child) {
                                                    return Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.refresh,
                                                              color: value <=
                                                                      540
                                                                  ? blueColor
                                                                  : Colors.grey
                                                                      .shade600,
                                                              size: 16),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            "Resend Code",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: value <=
                                                                      540
                                                                  ? blueColor
                                                                  : Colors.grey
                                                                      .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 20),

                                          // Verify & Enable Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: isVerifyingCode
                                                  ? null
                                                  : () => _formKey2FA
                                                          .currentState!
                                                          .validate()
                                                      ? _verifyAndEnable2FA()
                                                      : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: blueColor,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: isVerifyingCode
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Verify & Enable",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          SizedBox(height: 12),

                                          // Cancel Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                stopTimer();
                                                setState(() {
                                                  show2FASetup = false;
                                                  showVerificationInput = false;
                                                  selected2FAMethod = '';
                                                  verificationCodeController
                                                      .clear();
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color: Colors.grey),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // 2FA Enabled Status
                                  if (enble2FA && !show2FASetup)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        email2FA
                                            ? "✓ 2FA is enabled via Email"
                                            : sms2FA
                                                ? "✓ 2FA is enabled via SMS"
                                                : "✓ 2FA is enabled",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 20),

                                  // Disable 2FA Verification Input
                                  if (showDisableVerification)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Enter verification code to disable 2FA:",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 16),

                                          // Verification Code Input Field
                                          TextField(
                                            controller:
                                                disableVerificationController,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            decoration: InputDecoration(
                                              hintText: "Enter 6-digit code",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Colors.red,
                                                    width: 2),
                                              ),
                                              counterText: "",
                                            ),
                                          ),

                                          SizedBox(height: 20),

                                          // Disable 2FA Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: isVerifyingCode
                                                  ? null
                                                  : () =>
                                                      _disable2FAWithVerification(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: isVerifyingCode
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Disable 2FA",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          SizedBox(height: 12),

                                          // Cancel Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  showDisableVerification =
                                                      false;
                                                  disableVerificationController
                                                      .clear();
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color: Colors.grey),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Regenerate Backup Codes Verification Input
                                  if (showRegenerateVerification)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Enter verification code to regenerate backup codes:",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 16),

                                          // Verification Code Input Field
                                          TextField(
                                            controller:
                                                regenerateVerificationController,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            decoration: InputDecoration(
                                              hintText: "Enter 6-digit code",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: blueColor, width: 2),
                                              ),
                                              counterText: "",
                                            ),
                                          ),

                                          SizedBox(height: 20),

                                          // Regenerate Backup Codes Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: isVerifyingCode
                                                  ? null
                                                  : () =>
                                                      _regenerateBackupCodesWithVerification(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: blueColor,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: isVerifyingCode
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Regenerate Backup Codes",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          SizedBox(height: 12),

                                          // Cancel Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  showRegenerateVerification =
                                                      false;
                                                  regenerateVerificationController
                                                      .clear();
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color: Colors.grey),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Responsive 2FA Action Buttons
                                  if (enble2FA &&
                                      !showDisableVerification &&
                                      !showRegenerateVerification)
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Determine if we should stack buttons vertically on small screens
                                        bool isSmallScreen =
                                            constraints.maxWidth < 300;

                                        return isSmallScreen
                                            ? Column(
                                                children: [
                                                  // Disable 2FA Button
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height:
                                                        48, // Fixed height for consistency
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _sendDisable2FACode();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red.shade50,
                                                        foregroundColor:
                                                            Colors.red.shade700,
                                                        side: BorderSide(
                                                            color: Colors
                                                                .red.shade300,
                                                            width: 1.5),
                                                        elevation: 2,
                                                        shadowColor:
                                                            Colors.red.shade100,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 16),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.security,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            "Disable 2FA",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 12),
                                                  // Regenerate Backup Codes Button
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height:
                                                        48, // Same fixed height
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _regenerateBackupCodesWithVerification();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            blueColor
                                                                .withOpacity(
                                                                    0.1),
                                                        foregroundColor:
                                                            blueColor,
                                                        side: BorderSide(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.3),
                                                            width: 1.5),
                                                        elevation: 2,
                                                        shadowColor: blueColor
                                                            .withOpacity(0.1),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 16),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.refresh,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Flexible(
                                                            child: Text(
                                                              "Regenerate Backup Codes",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8),
                                                child: Row(
                                                  children: [
                                                    // Disable 2FA Button
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        height:
                                                            60, // Fixed height for consistency
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            _sendDisable2FACode();
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.red
                                                                    .shade50,
                                                            foregroundColor:
                                                                Colors.red
                                                                    .shade700,
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .red
                                                                    .shade300,
                                                                width: 1.5),
                                                            elevation: 2,
                                                            shadowColor: Colors
                                                                .red.shade100,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .security,
                                                                  size: 18),
                                                              SizedBox(
                                                                  width: 8),
                                                              Flexible(
                                                                child: Text(
                                                                  "Disable 2FA",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    // Regenerate Backup Codes Button
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        height:
                                                            60, // Same fixed height
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            _regenerateBackupCodesWithVerification();
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                blueColor
                                                                    .withOpacity(
                                                                        0.1),
                                                            foregroundColor:
                                                                blueColor,
                                                            side: BorderSide(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.3),
                                                                width: 1.5),
                                                            elevation: 2,
                                                            shadowColor:
                                                                blueColor
                                                                    .withOpacity(
                                                                        0.1),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                  Icons.refresh,
                                                                  size: 18),
                                                              SizedBox(
                                                                  width: 8),
                                                              Flexible(
                                                                child: Text(
                                                                  "Regenerate Backup Codes",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                      },
                                    ),
                                ],
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
                                          'First Name *',
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
                                          isRequired: true,
                                        ),
                                        const SizedBox(height: 16.0),
                                        const Text(
                                          'Last Name *',
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
                                          _validateFirstName,
                                          isRequired: true,
                                        ),
                                        const SizedBox(height: 16.0),
                                        const Text(
                                          'Email *',
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
                                          isRequired: true,
                                        ),
                                        const SizedBox(height: 16.0),
                                        const Text(
                                          'Phone Number *',
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
                                          _validateFirstName,
                                          isRequired: true,
                                        ),
                                        const SizedBox(height: 16.0),
                                        const Text(
                                          'Company Name *',
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
                                          _validateFirstName,
                                          isRequired: true,
                                        ),
                                        const SizedBox(height: 16.0),
                                        const Text(
                                          'Created Date *',
                                          style: TextStyle(
                                              color: Color(0xFF8A95A8),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        buildTextField(
                                          'Created Date',
                                          _createdDate,
                                          _validateFirstName,
                                          isEnabled: false,
                                          isRequired: true,
                                        ),
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
                                          _validateFirstName,
                                          isRequired: false,
                                        ),
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
                                              // onTap: () {
                                              //   if (_formKey.currentState!
                                              //       .validate()) {
                                              //     // If the form is valid, proceed with form submission
                                              //
                                              //     _formKey.currentState!.save();
                                              //     ProfileRepository()
                                              //         .Edit_profile({
                                              //       "first_name":
                                              //           _firstNameController
                                              //               .text,
                                              //       "last_name":
                                              //           _lastNameController
                                              //               .text,
                                              //       "email":
                                              //           _emailController.text,
                                              //       "company_name":
                                              //           _companyNameController
                                              //               .text,
                                              //       "phone_number":
                                              //           _phoneNumberController
                                              //               .text,
                                              //       "company_address":
                                              //           _companyAddressController
                                              //               .text,
                                              //       "postal_code":
                                              //           _companyPostalCodeController
                                              //               .text,
                                              //       "city":
                                              //           _companyCityController
                                              //               .text,
                                              //       "state":
                                              //           _companyStateController
                                              //               .text,
                                              //       "country":
                                              //           _companyCountryController
                                              //               .text,
                                              //     });
                                              //   }
                                              // },
                                              onTap: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  // Check if any field has changed
                                                  if (_firstNameController
                                                              .text !=
                                                          originalFirstName ||
                                                      _lastNameController
                                                              .text !=
                                                          originalLastName ||
                                                      _emailController
                                                              .text !=
                                                          originalEmail ||
                                                      _companyNameController
                                                              .text !=
                                                          originalCompanyName ||
                                                      _phoneNumberController
                                                              .text !=
                                                          originalPhoneNumber ||
                                                      _companyAddressController
                                                              .text !=
                                                          originalCompanyAddress ||
                                                      _companyPostalCodeController
                                                              .text !=
                                                          originalCompanyPostalCode ||
                                                      _companyCityController
                                                              .text !=
                                                          originalCompanyCity ||
                                                      _companyStateController
                                                              .text !=
                                                          originalCompanyState ||
                                                      _companyCountryController
                                                              .text !=
                                                          originalCompanyCountry) {
                                                    // If any field has changed, call the API
                                                    _formKey.currentState!
                                                        .save();
                                                    ProfileRepository()
                                                        .Edit_profile({
                                                      "first_name":
                                                          _firstNameController
                                                              .text
                                                              .trim(),
                                                      "last_name":
                                                          _lastNameController
                                                              .text
                                                              .trim(),
                                                      "email": _emailController
                                                          .text
                                                          .trim(),
                                                      "company_name":
                                                          _companyNameController
                                                              .text
                                                              .trim(),
                                                      "phone_number":
                                                          _phoneNumberController
                                                              .text
                                                              .trim(),
                                                      "company_address":
                                                          _companyAddressController
                                                              .text
                                                              .trim(),
                                                      "postal_code":
                                                          _companyPostalCodeController
                                                              .text
                                                              .trim(),
                                                      "city":
                                                          _companyCityController
                                                              .text
                                                              .trim(),
                                                      "state":
                                                          _companyStateController
                                                              .text
                                                              .trim(),
                                                      "country":
                                                          _companyCountryController
                                                              .text
                                                              .trim(),
                                                    });
                                                  } else {
                                                    // Optionally, show a message that no changes were made
                                                    print(
                                                        "No changes detected. API call skipped.");
                                                  }
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
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
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
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
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
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "  Back  ",
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
                                                      const SizedBox(
                                                        width: 8,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const Row(
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
                                                                passwordsameerror =
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
                                                                  const EdgeInsets
                                                                      .all(14),
                                                              enabledBorder:
                                                                  passworderror
                                                                      ? OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(MediaQuery.of(context).size.width * 0.013),
                                                                          borderSide:
                                                                              const BorderSide(color: Colors.red), // Set border color here
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
                                          ? Text(
                                              passwordmessage,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            )
                                          : Container(),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                      ),
                                      const Row(
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
                                                                  const EdgeInsets
                                                                      .all(14),
                                                              enabledBorder:
                                                                  confirmpassworderror
                                                                      ? OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(MediaQuery.of(context).size.width * 0.013),
                                                                          borderSide:
                                                                              const BorderSide(color: Colors.red), // Set border color here
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
                                          ? Text(
                                              confirmpasswordmessage,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            )
                                          : Container(),

                                      // Spacer(),
                                      // Login button
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                      ),
                                      // GestureDetector(
                                      //   onTap: () {
                                      //     if (password.text.isEmpty) {
                                      //       setState(() {
                                      //         passworderror = true;
                                      //         passwordmessage =
                                      //             "Password is required";
                                      //       });
                                      //     } else if (password.text.length < 8) {
                                      //       setState(() {
                                      //         passworderror = true;
                                      //         passwordmessage =
                                      //             "Password must have 8 Characters";
                                      //       });
                                      //     } else if (!RegExp(
                                      //             r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                      //         .hasMatch(password.text)) {
                                      //       setState(() {
                                      //         passworderror = true;
                                      //         passwordmessage =
                                      //             'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
                                      //       });
                                      //     } else if (password.text == oldPassword) { // Check if new password is the same as old
                                      //       Fluttertoast.showToast(msg: "New password cannot be the same as the old password");
                                      //       return;
                                      //     } else {
                                      //       setState(() {
                                      //         passworderror = false;
                                      //       });
                                      //     }
                                      //     if (confirmpassword.text.isEmpty) {
                                      //       setState(() {
                                      //         confirmpassworderror = true;
                                      //         confirmpasswordmessage =
                                      //             "Confirm password is required";
                                      //       });
                                      //     } else if (confirmpassword.text !=
                                      //         password.text) {
                                      //       setState(() {
                                      //         confirmpassworderror = true;
                                      //         confirmpasswordmessage =
                                      //             "Both password is not match";
                                      //       });
                                      //     } else {
                                      //       setState(() {
                                      //         confirmpassworderror = false;
                                      //       });
                                      //     }
                                      //     if (!passworderror &&
                                      //         !confirmpassworderror) {
                                      //       changePassword();
                                      //     }
                                      //   },
                                      //   child: Row(
                                      //     children: [
                                      //       Container(
                                      //         // height: MediaQuery.of(context)
                                      //         //         .size
                                      //         //         .height *
                                      //         //     0.05,
                                      //         height:40,
                                      //          width: MediaQuery.of(context).size.width * 0.45,
                                      //         decoration: BoxDecoration(
                                      //           color: blueColor,
                                      //           borderRadius:
                                      //               BorderRadius.circular(5),
                                      //         ),
                                      //         child: Center(
                                      //           child: loading
                                      //               ? SpinKitFadingCircle(
                                      //                   color: Colors.white,
                                      //                   size: 40.0,
                                      //                 )
                                      //               : Row(
                                      //                   mainAxisAlignment:
                                      //                       MainAxisAlignment
                                      //                           .center,
                                      //                   children: [
                                      //                     // SizedBox(
                                      //                     //   width: 8,
                                      //                     // ),
                                      //                     Text(
                                      //                       "Change password",
                                      //                       style: TextStyle(
                                      //                           color: Colors
                                      //                               .white,
                                      //                           fontWeight:
                                      //                               FontWeight
                                      //                                   .bold,
                                      //                           fontSize: MediaQuery.of(
                                      //                               context)
                                      //                               .size
                                      //                               .width <
                                      //                               500
                                      //                               ? 15
                                      //                               : 20),
                                      //                     ),
                                      //                     // SizedBox(
                                      //                     //   width: 8,
                                      //                     // ),
                                      //                   ],
                                      //                 ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      GestureDetector(
                                        onTap: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          String? pass =
                                              prefs.getString("password");
                                          print(pass);
                                          // Validate the new password
                                          if (password.text.trim().isEmpty) {
                                            setState(() {
                                              passworderror = true;
                                              passwordmessage =
                                                  "Password is required";
                                            });
                                          } else if (password.text
                                                  .trim()
                                                  .length <
                                              12) {
                                            setState(() {
                                              passworderror = true;
                                              passwordmessage =
                                                  "Password must have at least 8 characters";
                                            });
                                          } else if (!RegExp(
                                                  r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                              .hasMatch(password.text.trim())) {
                                            setState(() {
                                              passworderror = true;
                                              passwordmessage =
                                                  'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
                                            });
                                          } else if (password.text.trim() ==
                                              pass) {
                                            setState(() {
                                              passworderror = true;
                                              passwordmessage =
                                                  'New password cannot be the same as the old password';
                                            });
                                          } else {
                                            setState(() {
                                              passworderror =
                                                  false; // Clear the password error
                                            });
                                          }

                                          // Validate the confirmation password
                                          if (confirmpassword.text
                                              .trim()
                                              .isEmpty) {
                                            setState(() {
                                              confirmpassworderror = true;
                                              confirmpasswordmessage =
                                                  "Confirm password is required";
                                            });
                                          } else if (confirmpassword.text
                                                  .trim() !=
                                              password.text.trim()) {
                                            setState(() {
                                              confirmpassworderror = true;
                                              confirmpasswordmessage =
                                                  "Both passwords do not match";
                                            });
                                          } else {
                                            setState(() {
                                              confirmpassworderror =
                                                  false; // Clear the confirmation password error
                                            });
                                          }

                                          // If there are no errors, proceed to change the password
                                          if (!passworderror &&
                                              !confirmpassworderror) {
                                            //await _savePassword(password.text);
                                            changePassword(); // Call the function to change the password
                                          }
                                        },
                                        child: 
                                        Row(
                                          children: [
                                            Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45,
                                              decoration: BoxDecoration(
                                                color: blueColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: loading
                                                    ? const SpinKitFadingCircle(
                                                        color: Colors.white,
                                                        size: 40.0,
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "Change Password",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      500
                                                                  ? 15
                                                                  : 20,
                                                            ),
                                                          ),
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
                            GestureDetector(
                              onTap: () async {
                                _deactivateAccount(context);
                              },
                              child: Container(
                                // button for deactivate Account
                                alignment: Alignment.centerLeft,
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.6,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    "Delete Account",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
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
                  const Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  void _deactivateAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade600,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  "Delete Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                // Content
                const Text(
                  "Are you sure you want to do this ?  This cannot be undone.  All of your data will be permanently removed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "No, Keep My Account ",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Delete Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop(); // Close dialog first
                          await _callDeactivateAPI();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "Yes, Delete It",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _callDeactivateAPI() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");

      if (id == null || token == null) {
        Fluttertoast.showToast(
          msg: 'Unable to get user information',
          backgroundColor: Colors.red,
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Deactivate account..."),
              ],
            ),
          );
        },
      );

      final response = await apiPut(
        Uri.parse('${Api_url}/api/admin/togglestatus/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": "deactivate"}),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      print('Deactivate account response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["success"] == true) {
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Account deactivated successfully',
            backgroundColor: Colors.green,
          );

          // Clear shared preferences and navigate to login screen
          // Note: For account deactivation, we clear all data including Remember Me
          prefs.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login_Screen()),
            (route) => false, // Remove all previous routes
          );
        } else {
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Failed to deactivate account',
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to deactivate account. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator, {
    bool isEnabled = true,
    bool isRequired = false,
  }) {
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
          // validator: validator,
          validator: (value) {
            // Only validate if the field is required
            if (isRequired) {
              return validator != null ? validator(value) : null;
            }
            return null; // No validation for non-required fields
          },
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

  // Initiate 2FA setup - send verification code
  void _initiate2FASetup() async {
    if (selected2FAMethod.isEmpty) return;

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/2fa/enable-2fa'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": selected2FAMethod,
          "email": _emailController.text,
          "phone_number": _phoneNumberController.text,
          "admin_id": id
        }),
      );

      print('2FA setup response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          startTimer();
          setState(() {
            showVerificationInput = true;
            isVerifyingCode = false;
          });
          Fluttertoast.showToast(
            msg: 'Verification code sent to your ${selected2FAMethod}',
            backgroundColor: Colors.green,
          );
        } else {
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Failed to send verification code',
            backgroundColor: Colors.red,
          );
        }
      } else {
        _timer?.cancel();
        setState(() {
          isVerifyingCode = false;
        });
        Fluttertoast.showToast(
          msg: 'Failed to send verification code',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      _timer?.cancel();
      setState(() {
        isVerifyingCode = false;
      });
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  // Verify code and enable 2FA
  void _verifyAndEnable2FA() async {
    if (verificationCodeController.text.length != 6) {
      return;
    }

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/2fa/verify-2fa'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": selected2FAMethod,
          "code": verificationCodeController.text,
          "admin_id": id
        }),
      );

      print('2FA verification response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          stopTimer();
          setState(() {
            enble2FA = true;
            show2FASetup = false;
            showVerificationInput = false;
            isVerifyingCode = false;

            // Set the method flags
            if (selected2FAMethod == 'email') {
              email2FA = true;
              sms2FA = false;
            } else if (selected2FAMethod == 'sms') {
              sms2FA = true;
              email2FA = false;
            }

            selected2FAMethod = '';
            verificationCodeController.clear();
          });

          Fluttertoast.showToast(
            msg: '2FA enabled successfully!',
            backgroundColor: Colors.green,
          );
        } else {
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Invalid verification code',
            backgroundColor: Colors.red,
          );
        }
      } else {
        _timer?.cancel();
        Fluttertoast.showToast(
          msg: 'Invalid or expired verification code',
          backgroundColor: Colors.red,
        );
        setState(() {
          isVerifyingCode = false;
        });
      }
    } catch (e) {
      _timer?.cancel();
      setState(() {
        isVerifyingCode = false;
      });
    }
  }

  // Send disable 2FA code
  void _sendDisable2FACode() async {
    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/2fa/send-disable-2fa-code'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body:
            jsonEncode({"admin_id": id, "method": email2FA ? "email" : "sms"}),
      );

      print('Send disable 2FA code response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            showDisableVerification = true;
            isVerifyingCode = false;
          });

          Fluttertoast.showToast(
            msg:
                'Verification code sent to your ${email2FA ? "email" : "phone"}',
            backgroundColor: Colors.green,
          );
        } else {
          setState(() {
            isVerifyingCode = false;
          });
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Failed to send verification code',
            backgroundColor: Colors.red,
          );
        }
      } else {
        setState(() {
          isVerifyingCode = false;
        });
        Fluttertoast.showToast(
          msg: 'Failed to send verification code',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        isVerifyingCode = false;
      });
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  // Disable 2FA with verification code
  void _disable2FAWithVerification() async {
    if (disableVerificationController.text.length != 6) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid 6-digit code',
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/2fa/disable-2fa'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode(
            {"code": disableVerificationController.text, "admin_id": id}),
      );

      print('Disable 2FA response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            enble2FA = false;
            showDisableVerification = false;
            isVerifyingCode = false;
            email2FA = false;
            sms2FA = false;
            disableVerificationController.clear();
          });

          Fluttertoast.showToast(
            msg: '2FA disabled successfully!',
            backgroundColor: Colors.green,
          );
        } else {
          setState(() {
            isVerifyingCode = false;
          });
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Invalid verification code',
            backgroundColor: Colors.red,
          );
        }
      } else {
        setState(() {
          isVerifyingCode = false;
        });
        Fluttertoast.showToast(
          msg: 'Failed to disable 2FA',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        isVerifyingCode = false;
      });
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  // Send regenerate backup codes verification code
  void _sendRegenerateBackupCodesCode() async {
    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");

      final response = await apiPost(
        Uri.parse(
            '${Api_url}/api/backup-codes/send-regenerate-backup-codes-code'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body:
            jsonEncode({"admin_id": id, "method": email2FA ? "email" : "sms"}),
      );

      print('Send regenerate backup codes code response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            showRegenerateVerification = true;
            isVerifyingCode = false;
          });

          Fluttertoast.showToast(
            msg:
                'Verification code sent to your ${email2FA ? "email" : "phone"}',
            backgroundColor: Colors.green,
          );
        } else {
          setState(() {
            isVerifyingCode = false;
          });
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Failed to send verification code',
            backgroundColor: Colors.red,
          );
        }
      } else {
        setState(() {
          isVerifyingCode = false;
        });
        Fluttertoast.showToast(
          msg: 'Failed to send verification code',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        isVerifyingCode = false;
      });
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  // Regenerate backup codes with verification code
  void _regenerateBackupCodesWithVerification() async {
    // if (regenerateVerificationController.text.length != 6) {
    //   Fluttertoast.showToast(
    //     msg: 'Please enter a valid 6-digit code',
    //     backgroundColor: Colors.orange,
    //   );
    //   return;
    // }

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");
      String? userid = prefs.getString("userId");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/backup-codes/generate-backup-codes'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"user_id": id, "user_type": "admin"}),
      );

      print('Regenerate backup codes response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            showRegenerateVerification = false;
            isVerifyingCode = false;
            regenerateVerificationController.clear();
            // Update the codes with the new generated codes
            codes = List<Map<String, dynamic>>.from(jsonData["data"]["codes"]);
            backupCode = true;
          });
          // Show the backup codes modal
          _showBackupCodesModal();
        } else {
          setState(() {
            isVerifyingCode = false;
          });
          Fluttertoast.showToast(
            msg: jsonData["message"] ?? 'Invalid verification code',
            backgroundColor: Colors.red,
          );
        }
      } else {
        setState(() {
          isVerifyingCode = false;
        });
        Fluttertoast.showToast(
          msg: 'Failed to regenerate backup codes',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        isVerifyingCode = false;
      });
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  // Show backup codes modal
  void _showBackupCodesModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Backup Codes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Important banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'These backup codes can be used to access your account if you lose access to your 2FA device. Each code can only be used once. Store them in a safe place and don\'t share them with anyone.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Download button
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _downloadBackupCodes,
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Backup codes list
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: codes.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> codeData = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                codeData['code'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _copyToClipboard(codeData['code'] ?? ''),
                              icon: const Icon(Icons.copy, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Copy to clipboard function
  void _copyToClipboard(String text) {
    // You'll need to add the clipboard package to pubspec.yaml
    // For now, we'll just show a snackbar
    Fluttertoast.showToast(
      msg: 'Copied: $text',
      backgroundColor: Colors.green,
    );
  }

  // Download backup codes to file
  void _downloadBackupCodes() async {
    try {
      // Create the content for the text file
      String content = '';

      content += '';

      for (int i = 0; i < codes.length; i++) {
        content += '${i + 1}. ${codes[i]['code']}\n';
      }

      // Get the temporary directory
      final directory = await getTemporaryDirectory();
      final file = File(
          '${directory.path}/backup_codes_${DateTime.now().millisecondsSinceEpoch}.txt');

      // Write the content to the file
      await file.writeAsString(content);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup Codes for Cloud Rental Manager',
        subject: 'Backup Codes - Cloud Rental Manager',
      );

      Fluttertoast.showToast(
        msg: 'Backup codes file created and ready to share!',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error generating backup codes file: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  // Dialog for disabling 2FA
  void _showDisable2FADialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600, size: 24),
              SizedBox(width: 8),
              Text(
                'Disable 2FA',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to disable Two-Factor Authentication?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.red.shade600, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will make your account less secure. We recommend keeping 2FA enabled.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement actual disable 2FA functionality
                Fluttertoast.showToast(
                  msg: '2FA disable functionality will be implemented',
                  backgroundColor: Colors.orange,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Disable 2FA'),
            ),
          ],
        );
      },
    );
  }

  // Dialog for regenerating backup codes
  void _showRegenerateBackupCodesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.refresh, color: blueColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Regenerate Backup Codes',
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will generate new backup codes for your account. Your old backup codes will no longer work.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: blueColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: blueColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure to save the new backup codes in a secure location.',
                        style: TextStyle(
                          color: blueColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement actual regenerate backup codes functionality
                Fluttertoast.showToast(
                  msg:
                      'Backup codes regeneration functionality will be implemented',
                  backgroundColor: blueColor,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Generate New Codes'),
            ),
          ],
        );
      },
    );
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
                padding: const EdgeInsets.all(16.0),
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
                    const SizedBox(
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
