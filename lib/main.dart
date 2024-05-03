import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/splash_screen.dart';

void main() {
  runApp(
    DevicePreview(
    enabled: true,
    tools: [
      ...DevicePreview.defaultTools,
    ],
    builder: (context) => MyApp(),
  ),);

}
//   void main(){
//     runApp(MyApp());
//   }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
     home:SplashScreen(),
    );
  }
}


