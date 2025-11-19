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
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:three_zero_two_property/widgets/custom_switch.dart';

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
  Timer? _timer;
  ValueNotifier<int> seconds = ValueNotifier(600);
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    print("selected2FAMethod");
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
          startTimer();
          setState(() {
            showVerificationInput = true;
            isVerifyingCode = false;
          });
        } else {
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
        }
      } else {
        _timer?.cancel();
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
          stopTimer();
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
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
        }
      } else {
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
          _timer?.cancel();
          setState(() {
            showDisableVerification = true;
            isVerifyingCode = false;
          });
        } else {
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
        }
        Fluttertoast.showToast(
          msg: '${jsonData["message"]}',
          backgroundColor: Colors.green,
        );
      } else {
        _timer?.cancel();
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
        body: jsonEncode({
          "code": disableVerificationController.text,
          "user_id": id,
          "user_type": "tenant"
        }),
      );

      print('Disable 2FA response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          _timer?.cancel();
          setState(() {
            enble2FA = false;
            showDisableVerification = false;
            isVerifyingCode = false;
            email2FA = false;
            sms2FA = false;
            disableVerificationController.clear();
          });
        } else {
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
        }
        Fluttertoast.showToast(
          msg: '${jsonData["message"]}',
          backgroundColor: Colors.green,
        );
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
          _timer?.cancel();
          setState(() {
            showRegenerateVerification = true;
            isVerifyingCode = false;
          });
        } else {
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
        }
      } else {
        _timer?.cancel();
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
        body: jsonEncode({"user_id": id, "user_type": "tenant"}),
      );

      print('Regenerate backup codes response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          _timer?.cancel();
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
          _timer?.cancel();
          setState(() {
            isVerifyingCode = false;
          });
        }
      } else {
        _timer?.cancel();
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
  Future<void> _downloadBackupCodes() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();

      // Create the content for the text file
      String content = '';

      content += '';

      for (int i = 0; i < codes.length; i++) {
        content += '${i + 1}. ${codes[i]['code']}\n';
      }

      // Get the Downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create file in the Downloads folder
      final file = File(
          '${directory.path}/backup_codes_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(content);

      // Show success toast
      Fluttertoast.showToast(
        msg: 'Backup codes saved to Downloads!',
        toastLength: Toast.LENGTH_SHORT,
      );

      // Optional: Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup Codes for Cloud Rental Manager',
        subject: 'Backup Codes - Cloud Rental Manager',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error generating backup codes file: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () {
          print("calling appbar");
          key.currentState!.openDrawer();
        },
      ),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: 'Profile',
      ),
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
                                  const SizedBox(height: 30),
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
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  blueColor.withOpacity(0.2)),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            // Name Card
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              decoration: BoxDecoration(
                                                color:
                                                    blueColor.withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: blueColor
                                                        .withOpacity(0.1)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Full Name',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${profiledata['tenant_firstName']} ${profiledata['tenant_lastName']}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Phone and Email Row
                                            Row(
                                              children: [
                                                // Phone Card
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 6),
                                                    decoration: BoxDecoration(
                                                      color: blueColor
                                                          .withOpacity(0.05),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: blueColor
                                                              .withOpacity(
                                                                  0.1)),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Phone Number',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          profiledata[
                                                                  'tenant_phoneNumber'] ??
                                                              'N/A',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // Email Card
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    decoration: BoxDecoration(
                                                      color: blueColor
                                                          .withOpacity(0.05),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: blueColor
                                                              .withOpacity(
                                                                  0.1)),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Email Address',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          profiledata[
                                                                  'tenant_email'] ??
                                                              'N/A',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          overflow: TextOverflow
                                                              .visible,
                                                        ),
                                                      ],
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
                                  const SizedBox(height: 30),
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
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  blueColor.withOpacity(0.2)),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        child: leaseData.isNotEmpty
                                            ? Column(
                                                children: [
                                                  // Lease Type and Property Row
                                                  Row(
                                                    children: [
                                                      // Lease Type Card
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.05),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Lease Type',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                leaseData[0][
                                                                        'lease_type'] ??
                                                                    'N/A',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Property Card
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.05),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Property Address',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                leaseData[0][
                                                                        'rental_adress'] ??
                                                                    'N/A',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .visible,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 12),

                                                  // Start Date and End Date Row
                                                  Row(
                                                    children: [
                                                      // Start Date Card
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.05),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Start Date',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                dateProvider.formatCurrentDate(
                                                                    leaseData[0]
                                                                        [
                                                                        'start_date']),
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // End Date Card
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.05),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'End Date',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                dateProvider.formatCurrentDate(
                                                                    leaseData[0]
                                                                        [
                                                                        'end_date']),
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 12),

                                                  // Rent Cycle, Amount, and Due Date Row
                                                  Row(
                                                    children: [
                                                      // Rent Cycle Card
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.05),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Rent Cycle',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                leaseData[0][
                                                                        'rent_cycle'] ??
                                                                    'N/A',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Rent Amount Card
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.05),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Rent Amount',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                '\$${leaseData[0]['amount']?.toString() ?? 'N/A'}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Next Due Date Card
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: blueColor
                                                                .withOpacity(
                                                                    0.05),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Next Due Date',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                leaseData[0][
                                                                        'date'] ??
                                                                    'N/A',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(40),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .description_outlined,
                                                      size: 48,
                                                      color: Colors.grey[400],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'No lease data available',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Please contact your property manager for lease information.',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[500],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // 2FA Section for Tablet
                                  titleBar(
                                    title: 'Two-Factor Authentication (2FA)',
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04,
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
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Two-Factor Authentication (2FA)",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                CustomSwitch(
                                                  initialValue: enble2FA,
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
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
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
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
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
                                                    Form(
                                                      key: _formKey,
                                                      child: TextFormField(
                                                        autovalidateMode:
                                                            AutovalidateMode
                                                                .onUserInteraction,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter a valid code';
                                                          }
                                                          if (value.length !=
                                                              6) {
                                                            return 'Code must be 6 digits';
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                            verificationCodeController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        maxLength: 6,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Enter 6-digit code",
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                BorderSide(
                                                                    color:
                                                                        blueColor,
                                                                    width: 2),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 2),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 2),
                                                          ),
                                                          counterText: "",
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        if (seconds.value > 0)
                                                          ValueListenableBuilder<
                                                              int>(
                                                            valueListenable:
                                                                seconds,
                                                            builder: (context,
                                                                value, child) {
                                                              return RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "Code will expire in ",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey[600],
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "${getTimerString()}",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                                                seconds.value <=
                                                                    540) {
                                                              _initiate2FASetup();
                                                            }
                                                          },
                                                          child: ValueListenableBuilder<
                                                                  int>(
                                                              valueListenable:
                                                                  seconds,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade200,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(Icons.refresh,
                                                                          color: value <= 540
                                                                              ? blueColor
                                                                              : Colors.grey.shade600,
                                                                          size: 16),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        "Resend Code",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color: value <= 540
                                                                              ? blueColor
                                                                              : Colors.grey.shade600,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 48,
                                                      child: ElevatedButton(
                                                        onPressed: isVerifyingCode
                                                            ? null
                                                            : () => _formKey
                                                                    .currentState!
                                                                    .validate()
                                                                ? _verifyAndEnable2FA()
                                                                : null,
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
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 48,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          stopTimer();
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
                                                          child: const Row(
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
                                                                child: !backupCode
                                                                    ? const Text(
                                                                        "Backup Codes",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      )
                                                                    : const Text(
                                                                        "Regenerate Backup Codes",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600,
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
                                ],
                              ),
                            );
                          } else {
                            // Vertical layout for phone screens
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                //   color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // titleBar(
                                  //   title: 'Personal Details',
                                  //   width: MediaQuery.of(context).size.width *
                                  //       0.91,
                                  // ),

                                  // Single White Card with Profile and 2FA - matching image exactly
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            // Avatar and Name Section
                                            ProfileCard(
                                              profiledata: {
                                                'tenant_firstName':
                                                    '${profiledata['tenant_firstName']}',
                                                'tenant_lastName':
                                                    '${profiledata['tenant_lastName']}',
                                                'tenant_phoneNumber':
                                                    '${profiledata['tenant_phoneNumber']}',
                                                'tenant_email':
                                                    '${profiledata['tenant_email']}',
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            // Divider
                                            Container(
                                              height: 1,
                                              color: Colors.grey[300],
                                            ),
                                            const SizedBox(height: 20),
                                            // 2FA Section - integrated in same card
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Two-Factor Authentication (2FA)",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                CustomSwitch(
                                                  initialValue: enble2FA,
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
                                            const SizedBox(height: 12),

                                            // Show different content based on 2FA state
                                            if (!enble2FA && !show2FASetup)
                                              Text(
                                                "Turn on the toggle above to enable Two-Factor Authentication for enhanced security.",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  height: 1.4,
                                                ),
                                              ),

                                            // 2FA Setup Flow - integrated in same card
                                            if (show2FASetup &&
                                                !showVerificationInput)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Choose your preferred 2FA method:",
                                                    style: TextStyle(
                                                      color: Colors.grey[800],
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),

                                                  // SMS Radio Button
                                                  _buildOptionTile(
                                                    label:
                                                        "SMS (${profiledata['tenant_phoneNumber']})",
                                                    value: 'sms',
                                                  ),
                                                  //  const SizedBox(height: 12),

                                                  // Email Option
                                                  _buildOptionTile(
                                                    label:
                                                        "Email (${profiledata['tenant_email']})",
                                                    value: 'email',
                                                  ),
                                                  const SizedBox(height: 12),

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
                                                                  .circular(8),
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
                                                    Form(
                                                      key: _formKey,
                                                      child: TextFormField(
                                                        autovalidateMode:
                                                            AutovalidateMode
                                                                .onUserInteraction,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter a valid code';
                                                          }
                                                          if (value.length !=
                                                              6) {
                                                            return 'Code must be 6 digits';
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                            verificationCodeController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        maxLength: 6,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Enter 6-digit code",
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                BorderSide(
                                                                    color:
                                                                        blueColor,
                                                                    width: 2),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 2),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 2),
                                                          ),
                                                          counterText: "",
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        if (seconds.value > 0)
                                                          ValueListenableBuilder<
                                                              int>(
                                                            valueListenable:
                                                                seconds,
                                                            builder: (context,
                                                                value, child) {
                                                              return RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                text: TextSpan(
                                                                  children: [
                                                                    // make text smaller
                                                                    TextSpan(
                                                                      text:
                                                                          "Code will expire in ",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey[600],
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "${getTimerString()}",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            print(
                                                                "showVerificationInput: $showVerificationInput");
                                                            // clear the field
                                                            verificationCodeController
                                                                .clear();
                                                            if (showVerificationInput &&
                                                                seconds.value <=
                                                                    540) {
                                                              _initiate2FASetup();
                                                            }
                                                          },
                                                          child: ValueListenableBuilder<
                                                                  int>(
                                                              valueListenable:
                                                                  seconds,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade200,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(Icons.refresh,
                                                                          color: value <= 540
                                                                              ? blueColor
                                                                              : Colors.grey.shade600,
                                                                          size: 14),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        "Resend Code",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: value <= 540
                                                                              ? blueColor
                                                                              : Colors.grey.shade600,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 10),
                                                    // Verify & Enable Button
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 40,
                                                      child: ElevatedButton(
                                                        onPressed: isVerifyingCode
                                                            ? null
                                                            : () => _formKey
                                                                    .currentState!
                                                                    .validate()
                                                                ? _verifyAndEnable2FA()
                                                                : null,
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
                                                                  fontSize: 14,
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
                                                      height: 40,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          stopTimer();
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
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey.shade800,
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
                                                                ? const Text(
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
                                                                : const Text(
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
                                                child: LayoutBuilder(
                                                  builder:
                                                      (context, constraints) {
                                                    // Use Column for narrow screens, Row for wider screens
                                                    if (constraints.maxWidth <
                                                        400) {
                                                      return Column(
                                                        children: [
                                                          // Disable 2FA Button
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height: 50,
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
                                                                        16),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                              child: const Row(
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
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          // Regenerate Backup Codes Button
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height: 50,
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
                                                                          .refresh,
                                                                      size: 18),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  Flexible(
                                                                    child: !backupCode
                                                                        ? const Text(
                                                                            "Backup Codes",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          )
                                                                        : const Text(
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
                                                        ],
                                                      );
                                                    } else {
                                                      return Row(
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
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .security,
                                                                        size:
                                                                            18),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        "Disable 2FA",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
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
                                                          const SizedBox(
                                                              width: 12),
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
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16),
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
                                                                    const Icon(
                                                                        Icons
                                                                            .refresh,
                                                                        size:
                                                                            18),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Flexible(
                                                                      child: !backupCode
                                                                          ? const Text(
                                                                              "Backup Codes",
                                                                              style: TextStyle(
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            )
                                                                          : const Text(
                                                                              "Regenerate Backup Codes",
                                                                              style: TextStyle(
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (leaseData.isNotEmpty) ...[
                                    // Modern Lease Details Section
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Lease Details',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: blueColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
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
                                  const SizedBox(height: 20),
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

  Widget _buildOptionTile({required String label, required String value}) {
    final bool isSelected = selected2FAMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() => selected2FAMethod = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(
          //   color: isSelected ? blueColor : Colors.grey[300]!,
          //   width: isSelected ? 2 : 1,
          // ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: selected2FAMethod,
              onChanged: (val) => setState(() => selected2FAMethod = val!),
              activeColor: blueColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.visible,
              ),
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
          // Modern Table Header - matching the image design
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              border: Border.all(color: const Color(0xFFDBE0E5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Property",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Lease Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 12,
                    ),
                  ),
                ),
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
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: <Widget>[
                    // Main lease item - more compact design
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 12.0),
                        child: Row(
                          children: [
                            // Property address with dropdown icon
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey[500],
                                    size: 18,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${lease['rental_adress']}',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Lease type
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${lease['lease_type']}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Lease details in a modern grid layout
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    "Start Date",
                                    dateProvider
                                        .formatCurrentDate(lease['start_date']),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDetailItem(
                                    "End Date",
                                    dateProvider
                                        .formatCurrentDate(lease['end_date']),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    "Rent Cycle",
                                    lease['rent_cycle'],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDetailItem(
                                    "Rent Amount",
                                    "\$${lease['amount']}",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    "Next Due Date",
                                    dateProvider
                                        .formatCurrentDate(lease['date']),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(), // Empty for alignment
                                ),
                              ],
                            ),
                          ],
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
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
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
            style: const TextStyle(
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

class ProfileCard extends StatelessWidget {
  final Map<String, String> profiledata;
  final Color blueColor;

  const ProfileCard({
    Key? key,
    required this.profiledata,
    this.blueColor = const Color(0xFF0A2E5D),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String firstName = profiledata['tenant_firstName'] ?? '';
    final String lastName = profiledata['tenant_lastName'] ?? '';
    final String initials =
        '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}'
        '${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: blueColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "$firstName $lastName",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),

              // Name and Contact Info
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name

              const SizedBox(height: 10),

              // Phone
              Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.phone_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    profiledata['tenant_phoneNumber'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Email
              Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.email_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profiledata['tenant_email'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
