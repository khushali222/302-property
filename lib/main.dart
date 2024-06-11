import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/provider/add_property.dart';
import 'package:three_zero_two_property/provider/property_summery.dart';

import 'package:three_zero_two_property/screens/Splash_Screen/splash_screen.dart';

// void main() {
//   runApp(
//     MultiProvider(providers: [ ChangeNotifierProvider(
//       create: (context) => OwnerDetailsProvider(),
//       // child: MyApp(),
//     ),
//       ChangeNotifierProvider(
//         create: (context) => Tenants_counts(),
//       ),
//     ],
//       child: MyApp(),
//     ),
//     // DevicePreview(
//     //   enabled: true,
//     //   tools: [
//     //     ...DevicePreview.defaultTools,
//     //   ],
//     //   builder: (context) => MyApp(),
//     // ),
//   );
// }

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      tools: [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => OwnerDetailsProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => Tenants_counts(),
          ),
        ],
        child: MyApp(),
      ),
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
    );
  }
}
