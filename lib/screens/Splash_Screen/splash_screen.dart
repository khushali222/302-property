
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/services/app_version_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:three_zero_two_property/StaffModule/repository/staffpermission_provider.dart';
import 'package:three_zero_two_property/StaffModule/screen/dashboard.dart';
import 'package:three_zero_two_property/TenantsModule/screen/dashboard.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Dashboard/dashboard_one.dart';
import '../../TenantsModule/repository/permission_provider.dart';
import '../../VendorModule/repository/vendor_permission.dart';
import '../../VendorModule/screen/dashboard.dart';
import '../../VendorModule/screen/mainScreen.dart';
import '../../provider/Plan Purchase/plancheckProvider.dart';
import '../../provider/dateProvider.dart';
import '../Login/login_screen.dart';
import '../Plans/PlansPurcharCard.dart'; // Import your login screen file


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  ConnectivityResult? _connectivityResult ;

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
    _navigateToCorrectScreen();
  }
  void checkInternet()async{

    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });

  }


  bool? isPlanActive;

  void _openStore() async {
    final url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.hostmerchantservices.cloudrentalmanager'
        : 'https://apps.apple.com/app/id0000000000'; // TODO: replace with real iOS app id
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showForceUpdateDialog(String latestVersion) {
    const Color primaryColor = Color.fromRGBO(21, 43, 81, 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phone + download icon in light grey circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_alt_rounded,
                    size: 34,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Update Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: primaryColor,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Version chip — outlined with + prefix
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDE1EC), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'v$latestVersion is now available',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                const Text(
                  'This version is no longer supported.\nPlease update the app to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF8A8FA8),
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                // Full-width Update Now button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _openStore,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Update Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.3,
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
      ),
    );
  }

  void _showSoftUpdateDialog(String latestVersion) {
    const Color primaryColor = Color.fromRGBO(21, 43, 81, 1);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon in light grey circle
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_alt_rounded,
                  size: 34,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Update Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: primaryColor,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Version chip — outlined with + prefix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDDE1EC), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 14, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'v$latestVersion is now available',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Description
              const Text(
                'A new version of the app is ready.\nUpdate now to get the latest features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF8A8FA8),
                  fontFamily: 'Poppins',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              // Full-width Update Now button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _openStore,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Update Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Later text button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _navigateToCorrectScreen() async {

    await Future.delayed(Duration(seconds: 5)); // Simulate splash screen delay

    // ── VERSION CHECK (commented out — uncomment when going to production) ──
    // final versionResult = await AppVersionService.checkVersion();
    // if (!mounted) return;
    //
    // if (versionResult.status == VersionStatus.forceUpdate) {
    //   _showForceUpdateDialog(versionResult.latestVersion ?? '');
    //   return; // Stop navigation — user must update
    // } else if (versionResult.status == VersionStatus.softUpdate) {
    //   _showSoftUpdateDialog(versionResult.latestVersion ?? '');
    //   // Continue navigation after showing dialog
    // }
    // ─────────────────────────────────────────────────────────────────────

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    String role = prefs.getString("role") ??"";
    if(role != ""){
      final dateProvider = Provider.of<DateProvider>(context,listen: false);

    }
    if(role == "Admin") {
      await Provider.of<checkPlanPurchaseProiver>(context, listen: false)
          .fetchPlanPurchaseDetail();

      // Access the expiration date
      var provider =
      Provider.of<checkPlanPurchaseProiver>(context, listen: false);
      var expirationDateString =
          provider.checkplanpurchaseModel?.data?.expirationDate;

      DateTime? expirationDate;
      if (expirationDateString != null) {
        expirationDate = DateFormat('yyyy-MM-dd').parse(expirationDateString);
      }

      print('Expiration Date: $expirationDate');

      DateTime now = DateTime.now();
      String currentDate = DateFormat('yyyy-MM-dd').format(now);
      print(currentDate);

      isPlanActive = expirationDate != null && expirationDate.isAfter(now);

      if (isPlanActive!) {
        print('The plan is active.');
      } else {
        print('The plan is not active.');
      }

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => isAuthenticated == true
      //         ? isPlanActive!
      //         ? Dashboard()
      //         : PlanPurchaseCard()
      //         : Login_Screen(),
      //   ),
      // );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated == true
              ? isPlanActive!
              ? Dashboard()
              : provider.checkplanpurchaseModel != null ? PlanPurchaseCard() : Login_Screen()
              : Login_Screen(),
        ),
      );




     /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated == true ? Dashboard() : Login_Screen(),
        ),
      );*/
    } else if(role == "Staffmember"){
      await Provider.of<StaffPermissionProvider>(context, listen: false).fetchPermissions();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated == true ? Dashboard_staff() : Login_Screen(),
        ),
      );
    }
    else if(role == "Tenant"){
      await Provider.of<PermissionProvider>(context, listen: false).fetchPermissions();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated == true ? Dashboard_tenants() : Login_Screen(),
        ),
      );
    }
    else if(role == "Vendor"){
      await Provider.of<VendorPermission>(context, listen: false).fetchPermissions();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated == true ? MainScreen() : Login_Screen(),
        ),
      );
    }
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>  Login_Screen(),
        ),
      );
    }

    print(isAuthenticated);
    /* Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isAuthenticated == true ? Dashboard() : Login_Screen(),
      ),
    );*/
    /*  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isAuthenticated == true ? Dashboard() : Login_Screen(),
      ),
    );*/
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      _connectivityResult !=ConnectivityResult.none ?

      Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 220,
                width: 300,
              ),
              SizedBox(height: 30),
              Lottie.asset('assets/images/loader.json',height: 130,width: 100,
               ),
              // LoadingAnimationWidget.fourRotatingDots(
              //  color: blueColor,
              //   size: 40,
              // ),
            ],
          ),
        ),
      ):SizedBox(
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
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Check your internet connection',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
