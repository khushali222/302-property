import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/VendorModule/screen/notifications/notifications.dart';
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
import 'package:badges/badges.dart' as badges;

import '../../screens/Profile/ContactUsScreen.dart';
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
        .fetchNotificationsVendor(context);
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black87),
      elevation: 1,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 8,
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      // Title = logo only (like Staff): AppBar handles spacing, no overflow on small screens
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {

          if (constraints.maxWidth < 50) {
            return Image.asset(
              'assets/images/applogo.png',
              height: 35,
              width: 35,
            );
          } else {
            return Padding(padding: const EdgeInsets.only(right: 8,left: 5), child: Image.asset(
                'assets/images/logo.png',
               
              ),
            );
          }
          //   Image.asset(
          //   'assets/images/logo.png',
          //   height: 32,
          //   fit: BoxFit.contain,
          //   errorBuilder: (_, __, ___) => Image.asset(
          //     'assets/images/applogo.png',
          //     height: 32,
          //     fit: BoxFit.contain,
          //   ),
          // );
        },
      ),
      actions: [
        const SizedBox(width: 10),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.notifications.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const notifications(),
                  ));
                },
                child: Center(
                  child: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -4, end: -3),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.red,
                      padding: const EdgeInsets.all(4),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.bell,
                      size: 20,
                      color: blueColor,
                    ),
                  ),
                ),
              );
            }
            return Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const notifications(),
                  ));
                },
                child: FaIcon(
                  FontAwesomeIcons.bell,
                  size: 20,
                  color: blueColor,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        FutureBuilder<String>(
          future: _getNameFromSharedPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  position: PopupMenuPosition.under,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: blueColor,
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  itemBuilder: (ctx) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      value: '',
                      child: Text(
                        "WELCOME",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'password',
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.key,
                              size: 18, color: blueColor),
                          const SizedBox(width: 12),
                          Text("Change Password",
                              style: TextStyle(color: blueColor)),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Change_password()));
                      },
                    ),
                    PopupMenuItem<String>(
                      value: 'contact',
                      child: Row(
                        children: [
                          Icon(Icons.contact_mail, size: 20, color: blueColor),
                          const SizedBox(width: 12),
                          Text("Contact Us",
                              style: TextStyle(color: blueColor)),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ContactUsScreen()));
                      },
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 20),
                          SizedBox(width: 12),
                          Text("Logout"),
                        ],
                      ),
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        bool? rememberMe = prefs.getBool('rememberMe');
                        String? savedEmail = prefs.getString('savedEmail');
                        String? savedPassword =
                            prefs.getString('savedPassword');
                        prefs.clear();
                        if (rememberMe == true &&
                            savedEmail != null &&
                            savedPassword != null) {
                          await prefs.setBool('rememberMe', true);
                          await prefs.setString('savedEmail', savedEmail);
                          await prefs.setString('savedPassword', savedPassword);
                        }
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login_Screen()),
                            (route) => false);
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(width: 10),
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
    return combinationName.isEmpty ? "L" : combinationName;
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
