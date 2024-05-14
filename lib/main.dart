import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/add_property.dart';
import 'package:three_zero_two_property/screens/property_table.dart';
import 'package:three_zero_two_property/screens/splash_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      tools: [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => MyApp(),
    ),
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
      //home: Property_Table(),
    );
  }
}
