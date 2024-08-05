import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Profile/Profile_screen.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Profile/Profile_screen.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:three_zero_two_property/screens/Plans/plan_screen.dart';
import 'package:three_zero_two_property/screens/Profile/Settings_screen.dart';
import 'package:three_zero_two_property/widgets/test.dart';

import '../screen/change_password.dart';

class widget_302  {
    static App_Bar({
      var suffixIcon,
      required VoidCallback onDrawerIconPressed,
      var leading,
      var fontweight,
      List<Widget>? actions,
      var arrowNearText,
      required BuildContext context,
    }) {
      return AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 3,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing:05,
        leading: GestureDetector(
          onTap: onDrawerIconPressed,
          child:Padding(
            padding: const EdgeInsets.all(15.0),
            child: SvgPicture.asset("assets/images/tenants/drawer.svg",height: 20,width: 30,fit: BoxFit.fill,),
          ),
        ),
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
          /*InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Plan_screen()));
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 50,
              decoration: BoxDecoration(
                color: Color.fromRGBO(21, 43, 81, 1),
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
          Icon(
            Icons.notifications_outlined,
            color: Color.fromRGBO(21, 43, 81, 1),
          ),
          //   FaIcon(
          //     FontAwesomeIcons.bell,
          //     size: 20,
          //     color: Color.fromRGBO(21, 43, 81, 1),
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
                      color: Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.circular(2),
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
                                FontAwesomeIcons.cog,
                                size: 20,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Change Password"),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Change_password()));
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
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
                                    builder: (context) => Login_Screen()),
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
