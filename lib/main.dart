//import 'package:device_preview/device_preview.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:three_zero_two_property/provider/add_property.dart';
import 'package:three_zero_two_property/provider/lease_provider.dart';
import 'package:three_zero_two_property/provider/property_summery.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Summary%20Section/AddCard.dart';

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
//   tools: [/
// //     ...DevicePreview.defaultTools,
//     //   ],
//     //   builder: (context) => MyApp(),
//     // ),
//   );
// }

// void main() {
//   runApp(
//    /* DevicePreview(
//       enabled: true,
//       tools: [
//         ...DevicePreview.defaultTools,
//       ],
//       builder: (context) => MultiProvider(
//         providers: [
//           ChangeNotifierProvider(
//             create: (context) => OwnerDetailsProvider(),
//           ),
//           ChangeNotifierProvider(
//             create: (context) => Tenants_counts(),
//           ),
//         ],
//         child: MyApp(),
//       ),
//     ),*/
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (context) => OwnerDetailsProvider(),
//         ),
//         ChangeNotifierProvider(
//           create: (context) => Tenants_counts(),
//         ),
//         ChangeNotifierProvider(
//           create: (context) => SelectedTenantsProvider(),
//         ),
//         ChangeNotifierProvider(
//           create: (context) => SelectedCosignersProvider(),
//         ),
//         ChangeNotifierProvider(
//           create: (context) => NameProvider(),
//         ),
//       ],
//       child: MyApp(),
//     ),
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
          ChangeNotifierProvider(
            create: (context) => SelectedTenantsProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => SelectedCosignersProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => NameProvider(),
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
        iconTheme: const IconThemeData(color: Colors.black),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(21, 43, 83, 1)),
        useMaterial3: false,
      ),
      home: AddCard(),
    );
  }
}

class NameProvider extends ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _workNumber = '';
  String _email = '';
  String _alterEmail = '';
  String _streetAddress = '';
  String _city = '';
  String _country = '';
  String _postalCode = '';

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get phoneNumber => _phoneNumber;
  String get workNumber => _workNumber;
  String get email => _email;
  String get alterEmail => _alterEmail;
  String get streetAddress => _streetAddress;
  String get city => _city;
  String get country => _country;
  String get postalCode => _postalCode;

  void setDetails({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String workNumber,
    required String email,
    required String alterEmail,
    required String streetAddress,
    required String city,
    required String country,
    required String postalCode,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    _workNumber = workNumber;
    _email = email;
    _alterEmail = alterEmail;
    _streetAddress = streetAddress;
    _city = city;
    _country = country;
    _postalCode = postalCode;
    notifyListeners();
  }
}
