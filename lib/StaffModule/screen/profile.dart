import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constant/constant.dart';
import '../../provider/dateProvider.dart';
import '../widgets/custom_drawer.dart';
import '../../widgets/titleBar.dart';
import '../widgets/appbar.dart';

class Profile_screen extends StatefulWidget {
  const Profile_screen({Key? key}) : super(key: key);

  @override
  State<Profile_screen> createState() => _Profile_screenState();
}

class _Profile_screenState extends State<Profile_screen> {
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic> profiledata = {};
  ConnectivityResult? _connectivityResult;
  List<dynamic> leaseData = [];

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
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/tenant/tenant_profile/$id";
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
        leaseData = response_Data["data"]["leaseData"] ?? [];
        _isLoading = false;
      });
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
      status2FA(); // Fetch 2FA status on screen load
      backupcodeapicall();

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
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString("token");

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('${Api_url}/api/2fa/2fa-status/${id}?user_type=tenant'),
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
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString("token");
    String? userid = prefs.getString("userId");

    final response = await http.get(
      Uri.parse(
          '${Api_url}/api/backup-codes/backup-codes/${userid}?user_type=tenant'),
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
        codes = jsonData["data"]["codes"];
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
      String? id = prefs.getString("tenant_id");
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
          "email": profiledata['tenant_email'],
          "phone_number": profiledata['tenant_phoneNumber'],
          "user_id": id,
          "user_type": "tenant"
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
  void _verifyAndEnable2FA() async {
    if (verificationCodeController.text.length != 6) {
      return;
    }

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
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
          "user_type": "tenant"
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

  // Send disable 2FA code
  void _sendDisable2FACode() async {
    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
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
          "user_type": "tenant"
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
      String? id = prefs.getString("tenant_id");
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse('${Api_url}/api/2fa/disable-2fa'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode(
            {"code": disableVerificationController.text, "user_id": id,"user_type"
                :
            "tenant"}),
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

  // Send regenerate backup codes verification code
  void _sendRegenerateBackupCodesCode() async {
    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
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
        jsonEncode({"tenant_id": id, "method": email2FA ? "email" : "sms"}),
      );

      print('Send regenerate backup codes code response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            showRegenerateVerification = true;
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

  // Regenerate backup codes with verification code
  void _regenerateBackupCodesWithVerification() async {
    // if (regenerateVerificationController.text.length != 6) {
    //   return;
    // }

    setState(() {
      isVerifyingCode = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? token = prefs.getString("token");
      String? userid = prefs.getString("userId");

      final response = await http.post(
        Uri.parse('${Api_url}/api/backup-codes/generate-backup-codes'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({


          "user_id": id,
          "user_type": "tenant"
        }),
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
      }
    } catch (e) {
      setState(() {
        isVerifyingCode = false;
      });
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

                    // Text(
                    //   'Your Backup Codes (${codes.length} remaining)',
                    //   style: const TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Download backup codes to file
  void _downloadBackupCodes() async {
    try {
      // Create the content for the text file
      String content = '';

      content +=
      '';

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup codes file created and ready to share!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating backup codes file: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    return Scaffold(
      key: key,
      // appBar: widget_302.App_Bar(
      //   context: context,
      //   onDrawerIconPressed: () {
      //     print("calling appbar");
      //     key.currentState!.openDrawer();
      //   },
      // ),
      // backgroundColor: Colors.white,
      // drawer: CustomDrawer(
      //   currentpage: 'Profile',
      // ),
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      //drawer: CustomDrawerStaff(currentpage: 'Profile',dropdown: false,),
      body: _connectivityResult != ConnectivityResult.none
          ? _isLoading
          ? Center(
        child: SpinKitSpinningLines(
          color: blueColor,
          size: 50.0,
        ),
      )
          : _hasError
          ? Center(
        child: Text('Error: $_errorMessage'),
      )
          : SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              // Horizontal layout for tablet screens
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    titleBar(
                        title: 'Personal Details',
                        width: MediaQuery.of(context).size.width *
                            0.90),
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
                            2: FlexColumnWidth(3),
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
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
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            'Phone Number',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text('Email',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            "${profiledata['tenant_firstName']} ${profiledata['tenant_lastName']}",
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            profiledata[
                                            'tenant_phoneNumber'],
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            profiledata[
                                            'tenant_email'],
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    titleBar(
                        title: 'Lease Details',
                        width: MediaQuery.of(context).size.width *
                            0.90),
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
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                      padding:
                                      EdgeInsets.all(8.0),
                                      child: Text('Lease Type',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 20,
                                              color: blueColor))),
                                ),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text('Property',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text('Start Date',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text('End Date',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text('Rent Cycle',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text('Rent Amount',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            'Next Due Date',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 20,
                                                color:
                                                blueColor)))),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            "${profiledata['leaseData']['lease_type']}",
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            profiledata[
                                            'leaseData']
                                            ['rental_adress'],
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            dateProvider.formatCurrentDate(
                                                profiledata[
                                                'leaseData']
                                                [
                                                'start_date']),
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            8.0),
                                        child: Text(
                                            dateProvider
                                                .formatCurrentDate(
                                                profiledata[
                                                'leaseData']
                                                [
                                                'end_date']),
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            profiledata[
                                            'leaseData']
                                            ['rent_cycle'],
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            profiledata['leaseData']
                                            ['amount']
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                                TableCell(
                                    child: Padding(
                                        padding:
                                        EdgeInsets.all(8.0),
                                        child: Text(
                                            profiledata[
                                            'leaseData']
                                            ['date'],
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .normal,
                                                fontSize: 20,
                                                color:
                                                greyColor)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Vertical layout for phone screens
              return Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    titleBar(
                      title: 'Personal Details',
                      width: MediaQuery.of(context).size.width *
                          0.91,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                              Border.all(color: blueColor),
                              borderRadius:
                              BorderRadius.circular(6)),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              buildWidget('Name',
                                  "${profiledata['tenant_firstName']}${profiledata['tenant_lastName']}"),
                              buildWidget(
                                  'Phone Number',
                                  profiledata[
                                  'tenant_phoneNumber'] ??
                                      ""),
                              buildWidget(
                                  'Email',
                                  profiledata['tenant_email'] ??
                                      ""),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (leaseData.isNotEmpty) ...[
                      titleBar(
                        title: 'Lease Details',
                        width: MediaQuery.of(context).size.width *
                            0.91,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 20.0),
                      //   child: Card(
                      //     elevation: 0,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius:
                      //           BorderRadius.circular(6),
                      //     ),
                      //     child: Container(
                      //       decoration: BoxDecoration(
                      //           border:
                      //               Border.all(color: blueColor),
                      //           borderRadius:
                      //               BorderRadius.circular(6)),
                      //       padding: const EdgeInsets.all(16.0),
                      //       child: Column(
                      //         children: [
                      //           buildWidget('Lease Type',
                      //               "${profiledata['leaseData']['lease_type']}"),
                      //           buildWidget(
                      //               'Property',
                      //               profiledata['leaseData']
                      //                       ['rental_adress'] ??
                      //                   "N/A"),
                      //           buildWidget(
                      //               'Start Date',
                      //               formatDate4(profiledata[
                      //                           'leaseData']
                      //                       ['start_date']) ??
                      //                   "N/A"),
                      //           buildWidget(
                      //               'End Date',
                      //               formatDate4(profiledata[
                      //                           'leaseData']
                      //                       ['end_date']) ??
                      //                   "N/A"),
                      //           buildWidget(
                      //               'Rent Cycle',
                      //               profiledata['leaseData']
                      //                       ['rent_cycle'] ??
                      //                   "N/A"),
                      //           buildWidget(
                      //               'Rent Amount',
                      //               profiledata['leaseData']
                      //                       ['amount']
                      //                   .toString()),
                      //           buildWidget(
                      //               'Next Due Date',
                      //               formatDate4(profiledata[
                      //                           'leaseData']
                      //                       ['date']) ??
                      //                   "N/A"),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      buildLeaseTable(leaseData),
                    ],
                    SizedBox(
                      height: 20,
                    ),
                    // 2FA Section
                    titleBar(
                      title: 'Two-Factor Authentication (2FA)',
                      width: MediaQuery.of(context).size.width *
                          0.91,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Two-Factor Authentication (2FA) :",
                                    style: TextStyle(
                                      color: Color(0xFF8A95A8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
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
                                  ),
                                ],
                              ),

                              // Show different content based on 2FA state
                              if (!enble2FA && !show2FASetup)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    "Turn on the toggle above to enable Two-Factor Authentication for enhanced security.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),

                              // 2FA Setup Flow
                              if (show2FASetup &&
                                  !showVerificationInput)
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Choose your preferred 2FA method:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

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
                                          ),
                                          const SizedBox(
                                              width: 8),
                                          Expanded(
                                            child: Text(
                                              "SMS (${profiledata['tenant_phoneNumber']})",
                                              style:
                                              const TextStyle(
                                                fontSize: 16,
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
                                          ),
                                          const SizedBox(
                                              width: 8),
                                          Expanded(
                                            child: Text(
                                              "Email (${profiledata['tenant_email']})",
                                              style:
                                              const TextStyle(
                                                fontSize: 16,
                                                color: Colors
                                                    .black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Enable 2FA Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
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
                                          child: const Text(
                                            "Enable 2FA",
                                            style: TextStyle(
                                              fontSize: 16,
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
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Enter verification code sent to your ${selected2FAMethod == 'email' ? 'email' : 'phone'}:",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

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
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Verify & Enable Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
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
                                              ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                            CircularProgressIndicator(
                                              color: Colors
                                                  .white,
                                              strokeWidth:
                                              2,
                                            ),
                                          )
                                              : const Text(
                                            "Verify & Enable",
                                            style:
                                            TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Cancel Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
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
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize: 16,
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
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    email2FA
                                        ? "✓ 2FA is enabled via Email"
                                        : sms2FA
                                        ? "✓ 2FA is enabled via SMS"
                                        : "✓ 2FA is enabled",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Disable 2FA Verification Input
                              if (showDisableVerification)
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Enter verification code to disable 2FA:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

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
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Disable 2FA Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
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
                                              ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                            CircularProgressIndicator(
                                              color: Colors
                                                  .white,
                                              strokeWidth:
                                              2,
                                            ),
                                          )
                                              : const Text(
                                            "Disable 2FA",
                                            style:
                                            TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

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
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize: 16,
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

                              // Regenerate Backup Codes Verification Input
                              if (showRegenerateVerification)
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Enter verification code to regenerate backup codes:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Verification Code Input Field
                                      TextField(
                                        controller:
                                        regenerateVerificationController,
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
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Regenerate Backup Codes Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: isVerifyingCode
                                              ? null
                                              : () =>
                                              _regenerateBackupCodesWithVerification(),
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
                                              ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                            CircularProgressIndicator(
                                              color: Colors
                                                  .white,
                                              strokeWidth:
                                              2,
                                            ),
                                          )
                                              : backupCode
                                              ? Text(
                                            "Regenerate Backup Codes",
                                            style:
                                            TextStyle(
                                              fontSize:
                                              16,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          )
                                              : Text(
                                            "Backup Codes",
                                            style:
                                            TextStyle(
                                              fontSize:
                                              16,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

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
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize: 16,
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
                                          height: 60,
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
                                              padding:
                                              const EdgeInsets
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
                                                const Icon(
                                                    Icons
                                                        .security,
                                                    size: 18),
                                                const SizedBox(
                                                    width: 8),
                                                const Flexible(
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
                                      const SizedBox(width: 12),
                                      // Regenerate Backup Codes Button
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 60,
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
                                              padding:
                                              const EdgeInsets
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
                                                const Icon(
                                                    Icons.refresh,
                                                    size: 18),
                                                const SizedBox(
                                                    width: 8),
                                                Flexible(
                                                  child:
                                                  !backupCode
                                                      ? Text(
                                                    "Backup Codes",
                                                    style:
                                                    TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    textAlign:
                                                    TextAlign.center,
                                                  )
                                                      : Text(
                                                    "Regenerate Backup Codes",
                                                    style:
                                                    TextStyle(
                                                      fontSize: 12,
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
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              );
            }
          },
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

  int? expandedIndex; // Declare this at the top of your StatefulWidget

  Widget buildLeaseTable(List<dynamic> leaseData) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: tableHeaderCell(
                      "Lease Type",
                    )),
                Expanded(child: tableHeaderCell("   Property")),
                Expanded(child: tableHeaderCell("    Start Date")),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: leaseData.asMap().entries.map((entry) {
              int index = entry.key;
              bool isExpanded = expandedIndex == index;
              var lease = entry.value;

              //return CustomExpansionTile(data: Data, index: index);
              return Container(
                decoration: BoxDecoration(
                  color: index % 2 != 0
                      ? Colors.white
                      : blueColor.withOpacity(0.09),
                  border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                ),
                // decoration: BoxDecoration(
                //   border: Border.all(color: blueColor),
                // ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (expandedIndex == index) {
                                    expandedIndex = null;
                                  } else {
                                    expandedIndex = index;
                                  }
                                });
                              },
                              child: Container(
                                margin:
                                const EdgeInsets.only(left: 5, right: 5),
                                padding: !isExpanded
                                    ? const EdgeInsets.only(bottom: 10)
                                    : const EdgeInsets.only(top: 10),
                                child: FaIcon(
                                  isExpanded
                                      ? FontAwesomeIcons.sortUp
                                      : FontAwesomeIcons.sortDown,
                                  size: 20,
                                  color: blueColor,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (expandedIndex == index) {
                                      expandedIndex = null;
                                    } else {
                                      expandedIndex = index;
                                    }
                                  });
                                },
                                child: Text(
                                  '${lease['lease_type']}',
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .04),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${lease['rental_adress']}',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .06),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${dateProvider.formatCurrentDate(lease['start_date'])}',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            // SizedBox(
                            //     width: MediaQuery.of(context).size.width * .01),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        margin: const EdgeInsets.only(bottom: 2),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  FaIcon(
                                    isExpanded
                                        ? FontAwesomeIcons.sortUp
                                        : FontAwesomeIcons.sortDown,
                                    size: 30,
                                    color: Colors.transparent,
                                  ),
                                  Expanded(
                                    child: Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(), // Distribute columns equally
                                        1: FlexColumnWidth(),
                                        // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                        // 1: FlexColumnWidth(),
                                      },
                                      children: [
                                        buildTableRow(
                                            "End Date",
                                            dateProvider.formatCurrentDate(
                                                lease['end_date'])),
                                        buildTableRow(
                                            "Rent Cycle", lease['rent_cycle']),
                                        buildTableRow("Rent Amount",
                                            lease['amount'].toString()),
                                        buildTableRow(
                                            "Next Due Date",
                                            dateProvider.formatCurrentDate(
                                                lease['date'])),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    //SizedBox(height: 13,),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, overflow: TextOverflow.ellipsis),
    );
  }

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            value,
            style: TextStyle(color: grey),
          ),
        ),
      ],
    );
  }

  buildWidget(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
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
