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
    final response = await http.get(
      Uri.parse('$apiUrl'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print('hello$apiUrl');
    print(response.body);
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      print("hello");
      setState(() {
        profiledata = response_Data["data"];
        _isLoading = false;
      });
      status2FA(); // Fetch 2FA status on screen load
      backupcodeapicall();
      // return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {
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
    } catch (e) {
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

    final response = await http.get(
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

    final response = await http.get(
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

      final response = await http.post(
        Uri.parse('${Api_url}/api/2fa/enable-2fa'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": selected2FAMethod,
          "email": profiledata['staffmember_email'],
          "phone_number": profiledata['staffmember_phoneNumber'],
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

      final response = await http.post(
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

      final response = await http.post(
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

      final response = await http.post(
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

      final response = await http.post(
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

      final response = await http.post(
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
      //drawer: CustomDrawerStaff(currentpage: 'Profile',dropdown: false,),
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
                    title: 'Personal Details',
                    width:
                    MediaQuery.of(context).size.width * 0.90),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                      MediaQuery.of(context).size.width *
                          0.04,
                      vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Name',
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 20,
                                          color: blueColor),
                                    ))),
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Designation',
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 20,
                                            color: blueColor)))),
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Phone Number',
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 20,
                                            color: blueColor)))),
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Email',
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 20,
                                            color: blueColor)))),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                        "${profiledata['staffmember_name']}",
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.normal,
                                            fontSize: 20,
                                            color: greyColor)))),
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                        profiledata[
                                        'staffmember_designation'],
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.normal,
                                            fontSize: 20,
                                            color: greyColor)))),
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                        formatPhoneNumber(profiledata[
                                        'staffmember_phoneNumber']),
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.normal,
                                            fontSize: 20,
                                            color: greyColor)))),
                            TableCell(
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                        profiledata[
                                        'staffmember_email'],
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.normal,
                                            fontSize: 20,
                                            color: greyColor)))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // 2FA Section
                titleBar(
                  title: 'Two-Factor Authentication (2FA)',
                  width: MediaQuery.of(context).size.width * 0.90,
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: blueColor),
                            borderRadius:
                            BorderRadius.circular(6),
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
                                              "SMS (${profiledata['staffmember_phoneNumber']})",
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
                                              "Email (${profiledata['staffmember_email']})",
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
                                              Colors.red
                                                  .shade50,
                                              foregroundColor:
                                              Colors.red
                                                  .shade700,
                                              side: BorderSide(
                                                  color: Colors
                                                      .red
                                                      .shade300,
                                                  width:
                                                  1.5),
                                              elevation: 2,
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
                                              blueColor
                                                  .withOpacity(
                                                  0.1),
                                              foregroundColor:
                                              blueColor,
                                              side: BorderSide(
                                                  color: blueColor
                                                      .withOpacity(
                                                      0.3),
                                                  width:
                                                  1.5),
                                              elevation: 2,
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
                title: 'Personal Details',
                width: MediaQuery.of(context).size.width * 0.91,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: blueColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        buildWidget('Name',
                            profiledata['staffmember_name']),
                        buildWidget(
                            'Designation',
                            profiledata[
                            'staffmember_designation']),
                        buildWidget(
                            'Phone Number',
                            formatPhoneNumber(profiledata[
                            'staffmember_phoneNumber'])),
                        buildWidget('Email',
                            profiledata['staffmember_email']),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 2FA Section
              titleBar(
                title: 'Two-Factor Authentication (2FA)',
                width: MediaQuery.of(context).size.width * 0.91,
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardPadding =
                  constraints.maxWidth < 500 ? 10 : 20;
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: blueColor),
                          borderRadius: BorderRadius.circular(6),
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
                                            "SMS (${profiledata['staffmember_phoneNumber']})",
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
                                            "Email (${profiledata['staffmember_email']})",
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
                                            shadowColor:
                                            Colors.red
                                                .shade100,
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

  buildWidget(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: blueColor)),
        const SizedBox(
          height: 5,
        ),
        Material(
          //elevation: 3,
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    offset:
                    Offset(1.0, 1.0), // Shadow offset to the bottom right
                    blurRadius: 8.0, // How much to blur the shadow
                    spreadRadius: 0.0, // How much the shadow should spread
                  ),
                ],
                border: Border.all(width: 0, color: Colors.white),
                borderRadius: BorderRadius.circular(6.0)),
            child: TextFormField(
              style: const TextStyle(
                color: Color(0xFF8898aa), // Text color
                fontSize: 16.0, // Text size
                fontWeight: FontWeight.w400, // Text weight
              ),
              //  controller: _dateController,
              initialValue: value,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xFFb0b6c3)),
                border: InputBorder.none,
                // labelText: 'Select Date',
                hintText: 'dd-mm-yyyy',
              ),
              readOnly: true,
              onTap: () {
                //_selectDate(context);
              },
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
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
