import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/provider/Plan%20Purchase/plancheckProvider.dart';
import 'package:three_zero_two_property/screens/Dashboard/dashboard_one.dart';
import 'package:three_zero_two_property/screens/Plans/PlansPurcharCard.dart';
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
    print(isAuthenticated);

    bool? isPlanActive = false;
    if (isAuthenticated) {
      if (!mounted) return;
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

      if (isPlanActive) {
        print('The plan is active.');
      } else {
        print('The plan is not active.');
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isAuthenticated == true ? Dashboard() : Login_Screen(),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isAuthenticated == true
            ? isPlanActive!
                ? Dashboard()
                : PlanPurchaseCard()
            : Login_Screen(),
      ),
    );
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
