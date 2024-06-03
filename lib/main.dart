import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/provider/add_property.dart';

import 'package:three_zero_two_property/screens/Splash_Screen/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => OwnerDetailsProvider(),
      child: MyApp(),
    ),
    // DevicePreview(
    //   enabled: true,
    //   tools: [
    //     ...DevicePreview.defaultTools,
    //   ],
    //   builder: (context) => MyApp(),
    // ),
  );
}



class MyApp extends StatelessWidget {
  MyApp({super.key});
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // navigatorKey: navigatorKey,
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.black),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
