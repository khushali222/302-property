import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import '../../constant/constant.dart';
import '../../repository/profile_repository.dart';
import '../widgets/drawer_tiles.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_drawer.dart';
import '../../widgets/titleBar.dart';

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

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  profile? _profile;
  Map<String, dynamic> profiledata = {};

  // 2FA Variables
  bool enble2FA = false;
  bool disable2FA = false;
  bool sms2FA = false;
  bool email2FA = false;
  bool show2FASetup = false;
  bool backupCode = false;
  List<Map<String, dynamic>> codes = [];
  String selected2FAMethod = '';
  TextEditingController verificationCodeController = TextEditingController();
  bool isVerifyingCode = false;
  bool showVerificationInput = false;
  bool showDisableVerification = false;
  bool showRegenerateVerification = false;
  TextEditingController disableVerificationController = TextEditingController();
  TextEditingController regenerateVerificationController =
  TextEditingController();
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

  ConnectivityResult? _connectivityResult;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<void> fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    //  String? token = prefs.getString('token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/staffmember/staffmember_profile/$id";
    final response = await apiGet(
      Uri.parse('$apiUrl'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print('📥 [StaffProfile] GET $apiUrl');
    print('📥 [StaffProfile] http status: ${response.statusCode}');
    print('📥 [StaffProfile] body: ${response.body}');
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      print(
          '📥 [StaffProfile] data == null? ${response_Data["data"] == null}');
      setState(() {
        profiledata = response_Data["data"];
        _isLoading = false;
      });
      status2FA(); // Fetch 2FA status on screen load
      backupcodeapicall();
      // return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {
      print(
          '❌ [StaffProfile] non-200 statusCode in body: ${response_Data["statusCode"]} message: ${response_Data["message"]}');
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load profile');
    }
  }

  Future<void> _fetchProfile() async {
    try {
      await fetchProfile();
      /* final profileData = await fetchProfile();
      setState(() {
        _profile = profileData;
        _firstNameController.text = profileData.firstName ?? '';
        _lastNameController.text = profileData.lastName ?? '';
        _emailController.text = profileData.email ?? '';
        _phoneNumberController.text = profileData.phoneNumber?.toString() ?? '';
        _companyNameController.text = profileData.companyName ?? '';
        _isLoading = false;
      });*/
    } catch (e, st) {
      print('❌ [StaffProfile] load failed: $e');
      print('❌ [StaffProfile] stack: $st');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 2FA Status Check
  void status2FA() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString("token");

    setState(() {
      _isLoading = true;
    });

    final response = await apiGet(
      Uri.parse('${Api_url}/api/2fa/2fa-status/${id}?user_type=staff'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    setState(() {
      _isLoading = false;
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

          if (method.toLowerCase() == "email") {
            email2FA = true;
            sms2FA = false;
          } else if (method.toLowerCase() == "sms") {
            sms2FA = true;
            email2FA = false;
          } else {
            email2FA = false;
            sms2FA = false;
          }
        });

        print("2FA Status - Enabled: $enabled, Method: $method");
        print("Email 2FA: $email2FA, SMS 2FA: $sms2FA");
      } else {
        setState(() {
          enble2FA = false;
          email2FA = false;
          sms2FA = false;
        });
        print("2FA data not found or invalid response");
      }
    } else {
      setState(() {
        enble2FA = false;
        email2FA = false;
        sms2FA = false;
      });
      print("Failed to fetch 2FA status: ${response.statusCode}");
    }
  }

  // Backup Codes API Call
  Future<void> backupcodeapicall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString("token");
    String? userid = prefs.getString("userId");

    final response = await apiGet(
      Uri.parse(
          '${Api_url}/api/backup-codes/backup-codes/${userid}?user_type=staff'),
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

  // Initiate 2FA setup - send verification code
  void _initiate2FASetup() async {
    if (selected2FAMethod.isEmpty) return;

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("staff_id");
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
          "email": _pf('staffmember_email'),
          "phone_number": _pf('staffmember_phoneNumber'),
          "user_id": id,
          "user_type": "staff"
        }),
      );

      print('2FA setup response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            showVerificationInput = true;
            isVerifyingCode = false;
          });
        } else {
          setState(() {
            isVerifyingCode = false;
          });
        }
      } else {
        setState(() {
          isVerifyingCode = false;
        });
      }
    } catch (e) {
      setState(() {
        isVerifyingCode = false;
      });
    }
  }

  // Verify code and enable 2FA
// i want to add a toast message if the verification code is invalid  and if verification code is sent successfully and  if
  void _verifyAndEnable2FA() async {
    if (verificationCodeController.text.length != 6) {
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
      String? id = prefs.getString("staff_id");
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
          "user_id": id,
          "user_type": "staff"
        }),
      );

      print('2FA verification response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            enble2FA = true;
            show2FASetup = false;
            showVerificationInput = false;
            isVerifyingCode = false;

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
            msg: '${jsonData["message"]}',
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

  // Send disable 2FA code
  void _sendDisable2FACode() async {
    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("staff_id");
      String? token = prefs.getString("token");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/2fa/send-disable-2fa-code'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": id,
          "method": email2FA ? "email" : "sms",
          "user_type": "staff"
        }),
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
      return;
    }

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("staff_id");
      String? token = prefs.getString("token");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/2fa/disable-2fa'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "code": disableVerificationController.text,
          "user_id": id,
          "user_type": "staff"
        }),
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
        } else {
          setState(() {
            isVerifyingCode = false;
          });
        }
        Fluttertoast.showToast(
          msg: '${jsonData["message"]}',
          backgroundColor: Colors.green,
        );
      } else {
        setState(() {
          isVerifyingCode = false;
        });
        Fluttertoast.showToast(
          msg: 'Invalid or expired verification code',
          backgroundColor: Colors.red,
        );
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

  // Send regenerate backup codes verification code
  void _sendRegenerateBackupCodesCode() async {
    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("staff_id");
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
        jsonEncode({"staff_id": id, "method": email2FA ? "email" : "sms"}),
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
            msg: '${jsonData["message"]}',
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
    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("staff_id");
      String? token = prefs.getString("token");
      String? userid = prefs.getString("userId");

      final response = await apiPost(
        Uri.parse('${Api_url}/api/backup-codes/generate-backup-codes'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"user_id": id, "user_type": "staff"}),
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
    Fluttertoast.showToast(
      msg: 'Copied: $text',
      backgroundColor: Colors.green,
    );
  }

  // Download backup codes to file
  Future<void> _downloadBackupCodes() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();

      // Create the content for the text file
      String content = '';
      for (int i = 0; i < codes.length; i++) {
        content += '${i + 1}. ${codes[i]['code']}\n';
      }

      // Get the Downloads directory
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create the file
      final file = File(
          '${directory.path}/backup_codes_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(content);

      // Show success toast
      Fluttertoast.showToast(
        msg: 'Backup codes saved to Downloads!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_SHORT,
      );

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup Codes for Cloud Rental Manager',
        subject: 'Backup Codes - Cloud Rental Manager',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error generating backup codes file: $e',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(currentpage: 'Dashboard', dropdown: false),
      body: _connectivityResult != ConnectivityResult.none
          ? _isLoading
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
          : LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                titleBar(
                  title: 'My Profile',
                  width: MediaQuery.of(context).size.width * 0.90,
                  radius: 12,
                ),
                SizedBox(height: 16),
                _personalDetailsCard(),
                SizedBox(height: 30),
                // 2FA Section
                titleBar(
                  title: 'Two-Factor Authentication (2FA)',
                  width: MediaQuery.of(context).size.width * 0.90,
                  radius: 12,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final double screenWidth =
                        MediaQuery.of(context).size.width;

                    // Responsive factors
                    double horizontalPadding = screenWidth < 400
                        ? 8
                        : screenWidth < 600
                        ? screenWidth * 0.04
                        : screenWidth * 0.1;
                    double contentPadding = screenWidth < 400
                        ? 8
                        : screenWidth < 600
                        ? 12
                        : 20;
                    double rowSpacing =
                    screenWidth < 400 ? 6 : 10;
                    double fontSizeTitle =
                    screenWidth < 400 ? 12 : 16;
                    double fontSizeAction =
                    screenWidth < 400 ? 12 : 16;
                    double buttonHeight =
                    screenWidth < 400 ? 38 : 48;
                    double bigButtonHeight =
                    screenWidth < 400 ? 48 : 60;
                    double innerPadding =
                    screenWidth < 400 ? 6 : 16;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 10),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(contentPadding),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Two-Factor Authentication (2FA):",
                                      style: TextStyle(
                                        color: const Color(
                                            0xFF8A95A8),
                                        fontSize: fontSizeTitle,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: rowSpacing),
                                  Switch(
                                    activeColor: blueColor,
                                    value: enble2FA,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value) {
                                          show2FASetup = true;
                                          showVerificationInput =
                                          false;
                                          selected2FAMethod = '';
                                        } else {
                                          enble2FA = false;
                                          show2FASetup = false;
                                          showVerificationInput =
                                          false;
                                          selected2FAMethod = '';
                                          sms2FA = false;
                                          email2FA = false;
                                        }
                                      });
                                    },
                                  )
                                ],
                              ),

                              // Show different content based on 2FA state
                              if (!enble2FA && !show2FASetup)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: innerPadding
                                          .toDouble()),
                                  child: Text(
                                    "Turn on the toggle above to enable Two-Factor Authentication for enhanced security.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: fontSizeTitle,
                                    ),
                                  ),
                                ),

                              // 2FA Setup Flow
                              if (show2FASetup &&
                                  !showVerificationInput)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: innerPadding
                                          .toDouble()),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Choose your preferred 2FA method:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: fontSizeTitle,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                          rowSpacing * 2.0),
                                      // SMS Radio Button
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'sms',
                                            groupValue:
                                            selected2FAMethod,
                                            onChanged: (value) {
                                              setState(() {
                                                selected2FAMethod =
                                                value!;
                                              });
                                            },
                                            activeColor:
                                            blueColor,
                                            materialTapTargetSize:
                                            MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              "SMS (${_pf('staffmember_phoneNumber')})",
                                              style: TextStyle(
                                                fontSize:
                                                fontSizeTitle,
                                                color: Colors
                                                    .black87,
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
                                            groupValue:
                                            selected2FAMethod,
                                            onChanged: (value) {
                                              setState(() {
                                                selected2FAMethod =
                                                value!;
                                              });
                                            },
                                            activeColor:
                                            blueColor,
                                            materialTapTargetSize:
                                            MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              "Email (${_pf('staffmember_email')})",
                                              style: TextStyle(
                                                fontSize:
                                                fontSizeTitle,
                                                color: Colors
                                                    .black87,
                                              ),
                                              overflow:
                                              TextOverflow
                                                  .visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                          rowSpacing * 3.0),

                                      // Enable 2FA Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: buttonHeight,
                                        child: ElevatedButton(
                                          onPressed: selected2FAMethod
                                              .isNotEmpty
                                              ? () =>
                                              _initiate2FASetup()
                                              : null,
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            selected2FAMethod
                                                .isNotEmpty
                                                ? blueColor
                                                : Colors.grey,
                                            foregroundColor:
                                            Colors.white,
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  8),
                                            ),
                                          ),
                                          child: Text(
                                            "Enable 2FA",
                                            style: TextStyle(
                                              fontSize:
                                              fontSizeAction,
                                              fontWeight:
                                              FontWeight.w600,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: innerPadding
                                          .toDouble()),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Enter verification code sent to your ${selected2FAMethod == 'email' ? 'email' : 'phone'}:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: fontSizeTitle,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                          rowSpacing * 2.0),

                                      // Verification Code Input Field
                                      TextField(
                                        controller:
                                        verificationCodeController,
                                        keyboardType:
                                        TextInputType.number,
                                        maxLength: 6,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          "Enter 6-digit code",
                                          border:
                                          OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                            borderSide:
                                            const BorderSide(
                                                color: Colors
                                                    .grey),
                                          ),
                                          focusedBorder:
                                          OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                            borderSide:
                                            BorderSide(
                                                color:
                                                blueColor,
                                                width: 2),
                                          ),
                                          counterText: "",
                                          contentPadding:
                                          EdgeInsets
                                              .symmetric(
                                              vertical: 8,
                                              horizontal:
                                              10),
                                        ),
                                        style: TextStyle(
                                            fontSize:
                                            fontSizeTitle),
                                      ),

                                      SizedBox(
                                          height:
                                          rowSpacing * 3.0),

                                      // Verify & Enable Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: buttonHeight,
                                        child: ElevatedButton(
                                          onPressed: isVerifyingCode
                                              ? null
                                              : () =>
                                              _verifyAndEnable2FA(),
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            blueColor,
                                            foregroundColor:
                                            Colors.white,
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  8),
                                            ),
                                          ),
                                          child: isVerifyingCode
                                              ? SizedBox(
                                            width:
                                            buttonHeight /
                                                2,
                                            height:
                                            buttonHeight /
                                                2,
                                            child:
                                            const CircularProgressIndicator(
                                              color: Colors
                                                  .white,
                                              strokeWidth:
                                              2,
                                            ),
                                          )
                                              : Text(
                                            "Verify & Enable",
                                            style:
                                            TextStyle(
                                              fontSize:
                                              fontSizeAction,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 8),

                                      // Cancel Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: buttonHeight,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              show2FASetup =
                                              false;
                                              showVerificationInput =
                                              false;
                                              selected2FAMethod =
                                              '';
                                              verificationCodeController
                                                  .clear();
                                            });
                                          },
                                          style: OutlinedButton
                                              .styleFrom(
                                            side:
                                            const BorderSide(
                                                color: Colors
                                                    .grey),
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  8),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize:
                                              fontSizeAction,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: Colors.grey,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: innerPadding
                                          .toDouble()),
                                  child: Text(
                                    email2FA
                                        ? "✓ 2FA is enabled via Email"
                                        : sms2FA
                                        ? "✓ 2FA is enabled via SMS"
                                        : "✓ 2FA is enabled",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: fontSizeTitle,
                                    ),
                                  ),
                                ),

                              SizedBox(height: rowSpacing * 3.0),

                              // Disable 2FA Verification Input
                              if (showDisableVerification)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: innerPadding
                                          .toDouble()),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Enter verification code to disable 2FA:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: fontSizeTitle,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                          rowSpacing * 2.0),

                                      // Verification Code Input Field
                                      TextField(
                                        controller:
                                        disableVerificationController,
                                        keyboardType:
                                        TextInputType.number,
                                        maxLength: 6,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          "Enter 6-digit code",
                                          border:
                                          OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                            borderSide:
                                            const BorderSide(
                                                color: Colors
                                                    .grey),
                                          ),
                                          focusedBorder:
                                          OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                            borderSide:
                                            const BorderSide(
                                                color: Colors
                                                    .red,
                                                width: 2),
                                          ),
                                          counterText: "",
                                          contentPadding:
                                          EdgeInsets
                                              .symmetric(
                                              vertical: 8,
                                              horizontal:
                                              10),
                                        ),
                                        style: TextStyle(
                                            fontSize:
                                            fontSizeTitle),
                                      ),

                                      SizedBox(
                                          height:
                                          rowSpacing * 3.0),

                                      // Disable 2FA Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: buttonHeight,
                                        child: ElevatedButton(
                                          onPressed: isVerifyingCode
                                              ? null
                                              : () =>
                                              _disable2FAWithVerification(),
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.red,
                                            foregroundColor:
                                            Colors.white,
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  8),
                                            ),
                                          ),
                                          child: isVerifyingCode
                                              ? SizedBox(
                                            width:
                                            buttonHeight /
                                                2,
                                            height:
                                            buttonHeight /
                                                2,
                                            child:
                                            const CircularProgressIndicator(
                                              color: Colors
                                                  .white,
                                              strokeWidth:
                                              2,
                                            ),
                                          )
                                              : Text(
                                            "Disable 2FA",
                                            style:
                                            TextStyle(
                                              fontSize:
                                              fontSizeAction,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 8),

                                      // Cancel Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: buttonHeight,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              showDisableVerification =
                                              false;
                                              disableVerificationController
                                                  .clear();
                                            });
                                          },
                                          style: OutlinedButton
                                              .styleFrom(
                                            side:
                                            const BorderSide(
                                                color: Colors
                                                    .grey),
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  8),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize:
                                              fontSizeAction,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // 2FA Action Buttons
                              if (enble2FA &&
                                  !showDisableVerification &&
                                  !showRegenerateVerification)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                      innerPadding.toDouble(),
                                      vertical: 6),
                                  child: width > 420
                                      ? Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    children: [
                                      // Disable 2FA Button
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height:
                                          bigButtonHeight,
                                          child:
                                          ElevatedButton(
                                            onPressed: () {
                                              _sendDisable2FACode();
                                            },
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor:
                                              Colors.white,
                                              foregroundColor:
                                              Colors.red
                                                  .shade700,
                                              side: BorderSide(
                                                  color: Colors
                                                      .red
                                                      .shade300,
                                                  width:
                                                  1.5),
                                              elevation: 0,
                                              shadowColor:
                                              Colors.red
                                                  .shade100,
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  8),
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
                                              mainAxisSize:
                                              MainAxisSize
                                                  .min,
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .security,
                                                    size:
                                                    18),
                                                SizedBox(
                                                    width:
                                                    rowSpacing),
                                                Flexible(
                                                  child:
                                                  Text(
                                                    "Disable 2FA",
                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      fontSizeAction - 2,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (width > 420)
                                        SizedBox(
                                            width:
                                            rowSpacing *
                                                2)
                                      else
                                        SizedBox(height: 8),
                                      // Regenerate Backup Codes Button
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height:
                                          bigButtonHeight,
                                          child:
                                          ElevatedButton(
                                            onPressed: () {
                                              _regenerateBackupCodesWithVerification();
                                            },
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor:
                                              Colors.white,
                                              foregroundColor:
                                              greyColor,
                                              side: BorderSide(
                                                  color: Colors
                                                      .grey
                                                      .shade400,
                                                  width:
                                                  1.5),
                                              elevation: 0,
                                              shadowColor:
                                              blueColor
                                                  .withOpacity(
                                                  0.1),
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  8),
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
                                              mainAxisSize:
                                              MainAxisSize
                                                  .min,
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .refresh,
                                                    size:
                                                    18),
                                                SizedBox(
                                                    width:
                                                    rowSpacing),
                                                Flexible(
                                                  child: !backupCode
                                                      ? Text(
                                                    "Backup Codes",
                                                    style: TextStyle(
                                                      fontSize: fontSizeAction - 4,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                      : Text(
                                                    "Regenerate Backup Codes",
                                                    style: TextStyle(
                                                      fontSize: fontSizeAction - 4,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      : Column(
                                    children: [
                                      // Disable 2FA Button
                                      SizedBox(
                                        width:
                                        double.infinity,
                                        height:
                                        bigButtonHeight,
                                        child:
                                        ElevatedButton(
                                          onPressed: () {
                                            _sendDisable2FACode();
                                          },
                                          style:
                                          ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.white,
                                            foregroundColor:
                                            Colors.red
                                                .shade700,
                                            side: BorderSide(
                                                color: Colors
                                                    .red
                                                    .shade300,
                                                width: 1.5),
                                            elevation: 0,
                                            shadowColor:
                                            Colors.red
                                                .shade100,
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                8),
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
                                            mainAxisSize:
                                            MainAxisSize
                                                .min,
                                            children: [
                                              const Icon(
                                                  Icons
                                                      .security,
                                                  size: 18),
                                              SizedBox(
                                                  width:
                                                  rowSpacing),
                                              Flexible(
                                                child: Text(
                                                  "Disable 2FA",
                                                  style:
                                                  TextStyle(
                                                    fontSize:
                                                    fontSizeAction -
                                                        2,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                  ),
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Regenerate Backup Codes Button
                                      SizedBox(
                                        width:
                                        double.infinity,
                                        height:
                                        bigButtonHeight,
                                        child:
                                        ElevatedButton(
                                          onPressed: () {
                                            _regenerateBackupCodesWithVerification();
                                          },
                                          style:
                                          ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.white,
                                            foregroundColor:
                                            greyColor,
                                            side: BorderSide(
                                                color: Colors
                                                    .grey
                                                    .shade400,
                                                width: 1.5),
                                            elevation: 0,
                                            shadowColor:
                                            blueColor
                                                .withOpacity(
                                                0.1),
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                8),
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
                                            mainAxisSize:
                                            MainAxisSize
                                                .min,
                                            children: [
                                              const Icon(
                                                  Icons
                                                      .refresh,
                                                  size: 18),
                                              SizedBox(
                                                  width:
                                                  rowSpacing),
                                              Flexible(
                                                child: !backupCode
                                                    ? Text(
                                                  "Backup Codes",
                                                  style:
                                                  TextStyle(
                                                    fontSize: fontSizeAction - 4,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign:
                                                  TextAlign.center,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                )
                                                    : Text(
                                                  "Regenerate Backup Codes",
                                                  style:
                                                  TextStyle(
                                                    fontSize: fontSizeAction - 4,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign:
                                                  TextAlign.center,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              titleBar(
                title: 'My Profile',
                width: MediaQuery.of(context).size.width - 32,
                radius: 12,
              ),
              const SizedBox(height: 12),
              _personalDetailsCard(),
              const SizedBox(height: 20),
              // 2FA Section
              titleBar(
                title: 'Two-Factor Authentication (2FA)',
                width: MediaQuery.of(context).size.width - 32,
                radius: 12,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardPadding =
                  constraints.maxWidth < 500 ? 16 : 20;
                  double horizontalContentPadding =
                  constraints.maxWidth < 400 ? 8 : 16;
                  double titleFontSize =
                  constraints.maxWidth < 400 ? 14 : 16;
                  double inputFontSize =
                  constraints.maxWidth < 400 ? 14 : 16;
                  double buttonFontSize =
                  constraints.maxWidth < 400 ? 13 : 16;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: cardPadding),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(
                            constraints.maxWidth < 400 ? 8 : 16),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "Two-Factor Authentication (2FA) :",
                                    style: TextStyle(
                                      color:
                                      const Color(0xFF8A95A8),
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                    width:
                                    constraints.maxWidth < 360
                                        ? 5
                                        : 10),
                                Switch(
                                  activeColor: blueColor,
                                  value: enble2FA,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value) {
                                        show2FASetup = true;
                                        showVerificationInput =
                                        false;
                                        selected2FAMethod = '';
                                      } else {
                                        enble2FA = false;
                                        show2FASetup = false;
                                        showVerificationInput =
                                        false;
                                        selected2FAMethod = '';
                                        sms2FA = false;
                                        email2FA = false;
                                      }
                                    });
                                  },
                                )
                              ],
                            ),
                            if (!enble2FA && !show2FASetup)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    horizontalContentPadding),
                                child: Text(
                                  "Turn on the toggle above to enable Two-Factor Authentication for enhanced security.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: inputFontSize,
                                  ),
                                ),
                              ),
                            if (show2FASetup &&
                                !showVerificationInput)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    horizontalContentPadding),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Choose your preferred 2FA method:",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: titleFontSize,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // SMS Radio Button
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: 'sms',
                                          groupValue:
                                          selected2FAMethod,
                                          onChanged: (value) {
                                            setState(() {
                                              selected2FAMethod =
                                              value!;
                                            });
                                          },
                                          activeColor: blueColor,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "SMS (${_pf('staffmember_phoneNumber')})",
                                            style: TextStyle(
                                              fontSize:
                                              inputFontSize,
                                              color:
                                              Colors.black87,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Email Radio Button
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: 'email',
                                          groupValue:
                                          selected2FAMethod,
                                          onChanged: (value) {
                                            setState(() {
                                              selected2FAMethod =
                                              value!;
                                            });
                                          },
                                          activeColor: blueColor,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Email (${_pf('staffmember_email')})",
                                            style: TextStyle(
                                              fontSize:
                                              inputFontSize,
                                              color:
                                              Colors.black87,
                                            ),
                                            overflow: TextOverflow
                                                .visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: selected2FAMethod
                                            .isNotEmpty
                                            ? () =>
                                            _initiate2FASetup()
                                            : null,
                                        style: ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                          selected2FAMethod
                                              .isNotEmpty
                                              ? blueColor
                                              : Colors.grey,
                                          foregroundColor:
                                          Colors.white,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Enable 2FA",
                                          style: TextStyle(
                                            fontSize:
                                            buttonFontSize,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (showVerificationInput)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    horizontalContentPadding),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Enter verification code sent to your ${selected2FAMethod == 'email' ? 'email' : 'phone'}:",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: titleFontSize,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      controller:
                                      verificationCodeController,
                                      keyboardType:
                                      TextInputType.number,
                                      maxLength: 6,
                                      style: TextStyle(
                                          fontSize:
                                          inputFontSize),
                                      decoration: InputDecoration(
                                        hintText:
                                        "Enter 6-digit code",
                                        border:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.grey),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(8),
                                          borderSide: BorderSide(
                                              color: blueColor,
                                              width: 2),
                                        ),
                                        counterText: "",
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: isVerifyingCode
                                            ? null
                                            : () =>
                                            _verifyAndEnable2FA(),
                                        style: ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                          blueColor,
                                          foregroundColor:
                                          Colors.white,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                          ),
                                        ),
                                        child: isVerifyingCode
                                            ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child:
                                          CircularProgressIndicator(
                                            color: Colors
                                                .white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : Text(
                                          "Verify & Enable",
                                          style: TextStyle(
                                            fontSize:
                                            buttonFontSize,
                                            fontWeight:
                                            FontWeight
                                                .w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            show2FASetup = false;
                                            showVerificationInput =
                                            false;
                                            selected2FAMethod =
                                            '';
                                            verificationCodeController
                                                .clear();
                                          });
                                        },
                                        style: OutlinedButton
                                            .styleFrom(
                                          side: BorderSide(
                                              color: Colors.grey),
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize:
                                            buttonFontSize,
                                            fontWeight:
                                            FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (enble2FA && !show2FASetup)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    horizontalContentPadding),
                                child: Text(
                                  email2FA
                                      ? "✓ 2FA is enabled via Email"
                                      : sms2FA
                                      ? "✓ 2FA is enabled via SMS"
                                      : "✓ 2FA is enabled",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: inputFontSize,
                                  ),
                                ),
                              ),
                            SizedBox(height: 20),
                            // Disable 2FA Verification Input
                            if (showDisableVerification)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    horizontalContentPadding),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Enter verification code to disable 2FA:",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: titleFontSize,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // Verification Code Input Field
                                    TextField(
                                      controller:
                                      disableVerificationController,
                                      keyboardType:
                                      TextInputType.number,
                                      maxLength: 6,
                                      style: TextStyle(
                                          fontSize:
                                          inputFontSize),
                                      decoration: InputDecoration(
                                        hintText:
                                        "Enter 6-digit code",
                                        border:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.grey),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 2),
                                        ),
                                        counterText: "",
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: isVerifyingCode
                                            ? null
                                            : () =>
                                            _disable2FAWithVerification(),
                                        style: ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                          Colors.red,
                                          foregroundColor:
                                          Colors.white,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                          ),
                                        ),
                                        child: isVerifyingCode
                                            ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child:
                                          CircularProgressIndicator(
                                            color: Colors
                                                .white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : Text(
                                          "Disable 2FA",
                                          style: TextStyle(
                                            fontSize:
                                            buttonFontSize,
                                            fontWeight:
                                            FontWeight
                                                .w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            showDisableVerification =
                                            false;
                                            disableVerificationController
                                                .clear();
                                          });
                                        },
                                        style: OutlinedButton
                                            .styleFrom(
                                          side: BorderSide(
                                              color: Colors.grey),
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize:
                                            buttonFontSize,
                                            fontWeight:
                                            FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // 2FA Action Buttons
                            if (enble2FA &&
                                !showDisableVerification &&
                                !showRegenerateVerification)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    horizontalContentPadding,
                                    vertical: 8),
                                child: constraints.maxWidth < 430
                                    ? Column(
                                  children: [
                                    SizedBox(
                                      width:
                                      double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _sendDisable2FACode();
                                        },
                                        style:
                                        ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                          Colors.white,
                                          foregroundColor:
                                          Colors.red
                                              .shade700,
                                          side: BorderSide(
                                              color: Colors
                                                  .red
                                                  .shade300,
                                              width: 1.5),
                                          elevation: 0,
                                          shadowColor:
                                          Colors.red
                                              .shade100,
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                              horizontal:
                                              8),
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
                                          mainAxisSize:
                                          MainAxisSize
                                              .min,
                                          children: [
                                            Icon(
                                                Icons
                                                    .security,
                                                size: 18),
                                            SizedBox(
                                                width: 6),
                                            Flexible(
                                              child: Text(
                                                "Disable 2FA",
                                                style:
                                                TextStyle(
                                                  fontSize:
                                                  buttonFontSize -
                                                      1,
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
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width:
                                      double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _regenerateBackupCodesWithVerification();
                                        },
                                        style:
                                        ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                          Colors.white,
                                          foregroundColor:
                                          greyColor,
                                          side: BorderSide(
                                              color: Colors
                                                  .grey
                                                  .shade400,
                                              width: 1.5),
                                          elevation: 0,
                                          shadowColor:
                                          blueColor
                                              .withOpacity(
                                              0.1),
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                              horizontal:
                                              8),
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
                                          mainAxisSize:
                                          MainAxisSize
                                              .min,
                                          children: [
                                            Icon(
                                                Icons
                                                    .refresh,
                                                size: 18),
                                            SizedBox(
                                                width: 6),
                                            Flexible(
                                              child:
                                              !backupCode
                                                  ? Text(
                                                "Backup Codes",
                                                style: TextStyle(
                                                  fontSize: buttonFontSize - 2,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                                  : Text(
                                                "Regenerate Backup Codes",
                                                style: TextStyle(
                                                  fontSize: buttonFontSize - 2,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                    : Row(
                                  children: [
                                    // Disable 2FA Button
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 60,
                                        child:
                                        ElevatedButton(
                                          onPressed: () {
                                            _sendDisable2FACode();
                                          },
                                          style:
                                          ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.white,
                                            foregroundColor:
                                            Colors.red
                                                .shade700,
                                            side: BorderSide(
                                                color: Colors
                                                    .red
                                                    .shade300,
                                                width: 1.5),
                                            elevation: 0,
                                            shadowColor:
                                            Colors.transparent,
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
                                                    buttonFontSize -
                                                        2,
                                                    fontWeight:
                                                    FontWeight.w600,
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
                                        height: 60,
                                        child:
                                        ElevatedButton(
                                          onPressed: () {
                                            _regenerateBackupCodesWithVerification();
                                          },
                                          style:
                                          ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.white,
                                            foregroundColor:
                                            greyColor,
                                            side: BorderSide(
                                                color: Colors
                                                    .grey
                                                    .shade400,
                                                width: 1.5),
                                            elevation: 0,
                                            shadowColor:
                                            Colors.transparent,
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
                                                      .refresh,
                                                  size: 18),
                                              SizedBox(
                                                  width: 8),
                                              Flexible(
                                                child: !backupCode
                                                    ? Text(
                                                  "Backup Codes",
                                                  style:
                                                  TextStyle(
                                                    fontSize: buttonFontSize - 2,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign:
                                                  TextAlign.center,
                                                )
                                                    : Text(
                                                  "Regenerate Backup Codes",
                                                  style:
                                                  TextStyle(
                                                    fontSize: buttonFontSize - 2,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign:
                                                  TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      })
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

  // Web renders staff fields with optional chaining (blank when the field is
  // absent), so a new staff member with no designation shows an empty value
  // instead of crashing. Mirror that here: read every profile field through
  // this helper so a missing/null key becomes "" rather than a null that
  // blows up a non-nullable String.
  String _pf(String key) => (profiledata[key] ?? '').toString();

  // Show "N/A" for any empty/missing field (consistent with the Phone field),
  // so a blank value can never fall through to a stray placeholder.
  String _orNA(String v) => v.trim().isEmpty ? 'N/A' : v.trim();

  // Initials for the avatar, derived from the staff member's name.
  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  // One icon + value row inside the profile card (phone / email).
  Widget _profileInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: greyColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 15, color: greyColor, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  // Web-aligned, VIEW-ONLY personal details card: avatar + name + designation
  // subtitle, then phone/email rows. Replaces the old read-only text fields so
  // an empty Designation shows "N/A" instead of a leftover date placeholder.
  Widget _personalDetailsCard() {
    final name = _orNA(_pf('staffmember_name'));
    final designation = _orNA(_pf('staffmember_designation'));
    final phone = formatPhoneNumber(_pf('staffmember_phoneNumber'));
    final email = _orNA(_pf('staffmember_email'));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E9F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(_pf('staffmember_name')),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      designation,
                      style: TextStyle(fontSize: 14, color: greyColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Colors.grey.withOpacity(0.25)),
          ),
          _profileInfoRow(Icons.phone_outlined, phone),
          _profileInfoRow(Icons.email_outlined, email),
        ],
      ),
    );
  }

}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label',
              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
            ),
          ),
          Text(":  "),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
              //overflow: TextOverflow.,
            ),
          ),
        ],
      ),
    );
  }
}
