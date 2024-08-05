import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/User%20Permission/UserPermissionScreen.dart';
import 'package:three_zero_two_property/provider/Plan%20Purchase/plancheckProvider.dart';
import 'package:three_zero_two_property/User%20Permission/UserPermissionScreen.dart';
import 'package:three_zero_two_property/provider/Plan%20Purchase/plancheckProvider.dart';
import 'package:three_zero_two_property/screens/Profile/Profile_screen.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';


import 'package:three_zero_two_property/screens/Plans/plan_screen.dart';
import 'package:three_zero_two_property/screens/Profile/Settings_screen.dart';

class widget_302 {
  static App_Bar({
    var suffixIcon,
    var leading,
    bool? isPlanPageActive = false,
    bool? isProfilePageActive = false,
    bool? isUserPermitePageActive = false,
    bool? isSettingPageActive = false,
    var fontweight,
    List<Widget>? actions,
    var arrowNearText,
    required BuildContext context,
  }) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,

      //automaticallyImplyLeading: false,
      // title: Image(
      //   image: AssetImage('assets/images/applogo.png'),
      //   height: 40,
      //   width: 40,
      // ),
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Check if the device width is less than 600 (considered as phone screen)
          if (constraints.maxWidth < 500) {
            return Image.asset(
              'assets/images/applogo.png',
              height: 40,
              width: 40,
            );
          } else {
            return Image.asset(
              'assets/images/logo.png',

              // Adjust height and width accordingly for tablet
            );
          }
        },
      ),
      // leading: GestureDetector(
      //   onTap: () {},
      //   child: Icon(Icons.menu),
      // ),
      actions: [
        InkWell(
          onTap: () {
            if (isPlanPageActive != true) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => getPlanDetailScreen()));
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            // width: 50,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(21, 43, 81, 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Consumer<checkPlanPurchaseProiver>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return CircularProgressIndicator(); // or some other loading indicator
                } else {
                  String planName = provider
                          .checkplanpurchaseModel?.data?.planDetail?.planName ??
                      'No Plan';
                  if (planName == 'Free Plan') {
                    planName = 'Buy Now';
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Text(planName,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Icon(
          Icons.notifications_outlined,
          color: Color.fromRGBO(21, 43, 81, 1),
        ),
        //   FaIcon(
        //     FontAwesomeIcons.bell,
        //     size: 20,
        //     color: Color.fromRGBO(21, 43, 81, 1),
        //   ),
        const SizedBox(
          width: 10,
        ),
        FutureBuilder<String>(
          future: _getNameFromSharedPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(21, 43, 81, 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: PopupMenuButton(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    position: PopupMenuPosition.under,
                    child: Center(
                      child: Text(
                        snapshot.data!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    // offset: Offset(0.0, appBarHeight),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        child: Text(
                          "WELCOME",
                        ),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.person),
                            //  FaIcon(
                            //    FontAwesomeIcons.user,
                            //    size: 20,
                            //    color: Colors.black,
                            //  ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("My Profile"),
                          ],
                        ),
                        onTap: () {
                          if (isProfilePageActive != true) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const Profile_screen()));
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.person),
                            //  FaIcon(
                            //    FontAwesomeIcons.user,
                            //    size: 20,
                            //    color: Colors.black,
                            //  ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("User Permission"),
                          ],
                        ),
                        onTap: () {
                          if (isUserPermitePageActive != true) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const UserPermissionScreen()));
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.cog,
                              size: 20,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Settings"),
                          ],
                        ),
                        onTap: () {
                          if (isSettingPageActive != true) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TabBarExample()));
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.directions_run_rounded),
                            //  FaIcon(
                            //    FontAwesomeIcons,
                            //    size: 20,
                            //    color: Colors.black,
                            //  ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Logout"),
                          ],
                        ),
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.clear();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login_Screen()),
                              (route) => false);
                        },
                      ),
                    ],
                  ));
            } else {
              // Display a loading indicator or placeholder
              return Container();
            }
          },
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  static Future<String> _getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString("first_name");
    String? lastName = prefs.getString("last_name");
    String combinationName = '';

    if (firstName != null && firstName.isNotEmpty) {
      combinationName += firstName[0].toUpperCase();
    }

    if (lastName != null && lastName.isNotEmpty) {
      combinationName += lastName[0].toUpperCase();
    }
    return combinationName ?? "L"; // Default to "L" if name is not available
  }
  // static Future<String> _getNameFromSharedPreferences() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? firstName = prefs.getString("first_name");
  //   String? lastName = prefs.getString("last_name");
  //   String combinationName = '';
  //
  //   if (firstName != null && firstName.isNotEmpty) {
  //     combinationName += firstName[0].toUpperCase();
  //   }
  //
  //   if (lastName != null && lastName.isNotEmpty) {
  //     combinationName += lastName[0].toUpperCase();
  //   }
  //   return combinationName ?? "L"; // Default to "L" if name is not available
  // }
}
