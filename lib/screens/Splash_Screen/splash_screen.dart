
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/repository/staffpermission_provider.dart';
import 'package:three_zero_two_property/StaffModule/screen/dashboard.dart';
import 'package:three_zero_two_property/TenantsModule/screen/dashboard.dart';
import 'package:three_zero_two_property/screens/Dashboard/dashboard_one.dart';
import '../../TenantsModule/repository/permission_provider.dart';
import '../../VendorModule/screen/dashboard.dart';
import '../Login/login_screen.dart'; // Import your login screen file


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToCorrectScreen();
  }
  _navigateToCorrectScreen() async {

    await Future.delayed(Duration(seconds: 3)); // Simulate splash screen delay
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    String role = prefs.getString("role") ??"";
    if(role == "Admin") {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated == true ? Dashboard() : Login_Screen(),
        ),
      );
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated == true ? Dashboard_vendors() : Login_Screen(),
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
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 220,
                width: 300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

