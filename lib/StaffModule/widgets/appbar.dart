import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/screen/change_password.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:badges/badges.dart' as badges;
import '../../provider/notification_provider.dart';
import '../screen/profile.dart';
import '../model/staffpermission.dart';
import '../repository/staffpermission_provider.dart';
import '../screen/notifications/notifications.dart';

class widget_302_Staff {
  static App_Bar({
    var suffixIcon,
    var leading,
    var fontweight,
    List<Widget>? actions,
    var arrowNearText,
    required BuildContext context,
  }) {
    Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotificationsStaff(context);
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;
    return AppBar(
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 1,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing: 05,
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
        SizedBox(
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
                    badgeStyle: badges.BadgeStyle(
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
        // GestureDetector(
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
        SizedBox(
          width: 10,
        ),
        FutureBuilder<String>(
          future: _getNameFromSharedPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 30,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: PopupMenuButton(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    position: PopupMenuPosition.under,
                    child: Center(
                      child: Text(
                        snapshot.data!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    // offset: Offset(0.0, appBarHeight),
                    shape: RoundedRectangleBorder(
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
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: blueColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "My Profile",
                              style: TextStyle(color: blueColor),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile_screen()));
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.key,
                              color: blueColor,
                            ),
                            //  FaIcon(
                            //    FontAwesomeIcons.user,
                            //    size: 20,
                            //    color: Colors.black,
                            //  ),
                            SizedBox(
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
                              builder: (context) => Change_password()));
                        },
                      ),
                      // if(permissions!.settingView!)
                      // PopupMenuItem(
                      //    child: Row(
                      //      children: [
                      //        FaIcon(
                      //          FontAwesomeIcons.cog,
                      //          size: 20,
                      //          color: blueColor,
                      //        ),
                      //        SizedBox(
                      //          width: 10,
                      //        ),
                      //        Text("Settings",style: TextStyle(color: blueColor)),
                      //      ],
                      //    ),
                      //    onTap: () {
                      //      Navigator.of(context).push(MaterialPageRoute(
                      //          builder: (context) => TabBarExample()));
                      //    },
                      //  ),
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
                            SizedBox(
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
                          prefs.clear();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login_Screen()),
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
        SizedBox(
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
