import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Profile/Profile_screen.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Profile/Profile_screen.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:three_zero_two_property/screens/Plans/plan_screen.dart';
import 'package:three_zero_two_property/screens/Profile/Settings_screen.dart';
import 'package:three_zero_two_property/widgets/test.dart';

import '../../constant/constant.dart';
import '../../provider/notification_provider.dart';
import '../screen/notifications/notifications.dart';
import '../screen/change_password.dart';

class widget_302 {
  static App_Bar({
    var suffixIcon,
    required VoidCallback onDrawerIconPressed,
    var leading,
    var fontweight,
    List<Widget>? actions,
    var arrowNearText,
    required BuildContext context,
  }) {
    Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotificationsTenant(context);
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 3,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing: 05,
      // leading: GestureDetector(
      //   onTap: onDrawerIconPressed,
      //   child: Padding(
      //     padding: const EdgeInsets.all(15.0),
      //     child: SvgPicture.asset(
      //       "assets/images/tenants/drawer.svg",
      //       height: 20,
      //       width: 30,
      //       fit: BoxFit.fill,
      //     ),
      //   ),
      // ),
      //automaticallyImplyLeading: false,
      // title: Image(
      //   image: AssetImage('assets/images/applogo.png'),
      //   height: 40,
      //   width: 40,
      // ),
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Check if the device width is less than 600 (considered as phone screen)
          if (constraints.maxWidth < 50) {
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
        /*InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Plan_screen()));
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 50,
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                  child: Text(
                "Buy",
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),*/
        const SizedBox(
          width: 10,
        ),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.isLoading) {
              return Center(
                child: FaIcon(
                  FontAwesomeIcons.bell,
                  size: 20,
                  color: blueColor,
                ),
              );
            } else if (notificationProvider.notifications.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const notifications(),
                  ));
                },
                child: Center(
                  child: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -4, end: -3),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.red,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.bell,
                      size: 20,
                      color: blueColor,
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: FaIcon(
                  FontAwesomeIcons.bell,
                  size: 20,
                  color: blueColor,
                ),
              );
            }
          },
        ),
        // InkWell(
        //   onTap: (){
        //     Navigator.of(context).push(MaterialPageRoute(
        //         builder: (context) => const notifications()));
        //   },
        //   child:  Padding(
        //     padding: const EdgeInsets.only(top: 15.0),
        //     child: FaIcon(
        //       FontAwesomeIcons.solidBell,
        //       size: 25,
        //       color: blueColor,
        //     ),
        //   ),
        // ),
        //   FaIcon(
        //     FontAwesomeIcons.bell,
        //     size: 20,
        //     color: blueColor,
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
                    color: blueColor,
                    borderRadius: BorderRadius.circular(2),
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
                      PopupMenuItem(
                        child: Text(
                          "WELCOME",
                          style: TextStyle(color: blueColor),
                        ),
                      ),
                      /*   PopupMenuItem(
                          child: Row(
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Profile_screen()));
                          },
                        ),*/
                      PopupMenuItem(
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.key,
                              size: 20,
                              color: blueColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Change Password",
                              style: TextStyle(color: blueColor),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Change_password()));
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_run_rounded,
                              color: blueColor,
                            ),
                            //  FaIcon(
                            //    FontAwesomeIcons,
                            //    size: 20,
                            //    color: Colors.black,
                            //  ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(color: blueColor),
                            ),
                          ],
                        ),
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          // Preserve Remember Me credentials
                          bool? rememberMe = prefs.getBool('rememberMe');
                          String? savedEmail = prefs.getString('savedEmail');
                          String? savedPassword =
                              prefs.getString('savedPassword');

                          // Clear all preferences
                          prefs.clear();

                          // Restore Remember Me credentials if they exist
                          if (rememberMe == true &&
                              savedEmail != null &&
                              savedPassword != null) {
                            await prefs.setBool('rememberMe', true);
                            await prefs.setString('savedEmail', savedEmail);
                            await prefs.setString(
                                'savedPassword', savedPassword);
                          }

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login_Screen()),
                              (route) => false);
                        },
                      ),
                      PopupMenuItem(
                        height: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FutureBuilder<PackageInfo>(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    "v${snapshot.data!.version}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ],
                        ),
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
