import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/login_screen.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainScreen();
  }

  _navigateToMainScreen() async {
    await Future.delayed(Duration(seconds: 3),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login_Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body: Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     Colors.grey[100]!,
            //     Colors.grey[200]!,
            //     Colors.grey[300]!,
            //     Colors.grey[400]!,
            //     Colors.grey[500]!,
            //   ],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Image(image: AssetImage('assets/images/logo.png'), height: 220, width: 300),
              ],
            ),
          ),
        ),
      );
  }
}
