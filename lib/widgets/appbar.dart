import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/User%20Permission/UserPermissionScreen.dart';
import 'package:three_zero_two_property/provider/Plan%20Purchase/plancheckProvider.dart';
import 'package:three_zero_two_property/screens/Profile/Profile_screen.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:three_zero_two_property/screens/Plans/plan_screen.dart';
import 'package:three_zero_two_property/screens/Profile/Settings_screen.dart';

import '../constant/constant.dart';

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
      elevation: 1,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing:00,
      toolbarHeight: MediaQuery.of(context).size.width < 500 ? 60 : 80, // Adjust height for tablet
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 350) {
            return Image.asset(
              'assets/images/applogo.png',
              height: 40,
              width: 40,
            );
          } else {
            return Image.asset(
              'assets/images/logo.png',
              width: 350,
              fit: BoxFit.fill,
            );
          }
        },
      ),
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
            decoration: BoxDecoration(
              color: const Color.fromRGBO(21, 43, 81, 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Consumer<checkPlanPurchaseProiver>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return CircularProgressIndicator();
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize:MediaQuery.of(context).size.width > 500 ?18 :14)),
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
        Icon(
          Icons.notifications_outlined,
          size:  MediaQuery.of(context).size.width > 500 ?35 :25,
          color: Color.fromRGBO(21, 43, 81, 1),
        ),
        const SizedBox(
          width: 10,
        ),
        FutureBuilder<String>(
          future: _getNameFromSharedPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(21, 43, 81, 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: PopupMenuButton(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  position: PopupMenuPosition.under,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        _getDisplayName(context, snapshot.data!),
                        style:  TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width > 500 ?16 :14 ),
                      ),
                    ),
                  ),
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
                        style: TextStyle(
                          color: blueColor
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child:  Row(
                        children: [
                          Icon(Icons.person,color: blueColor,),
                          SizedBox(
                            width: 10,
                          ),
                          Text("My Profile", style: TextStyle(
                              color: blueColor
                          ),),
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
                      child:  Row(
                        children: [
                          Icon(Icons.note_alt_outlined,color: blueColor),
                          const SizedBox(
                            width: 10,
                          ),
                          Text("User Permission", style: TextStyle(
                              color: blueColor
                          ),),
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
                      child:  Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.cog,
                            size: 20,
                            color:blueColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Settings", style: TextStyle(
                              color: blueColor
                          ),),
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
                      child:  Row(
                        children: [
                          Icon(Icons.directions_run_rounded,color: blueColor,),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Logout", style: TextStyle(
                              color: blueColor
                          ),),
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
                ),
              );
            } else {
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
      combinationName += firstName;
    }

    if (lastName != null && lastName.isNotEmpty) {
      combinationName += ' $lastName';
    }
    return combinationName.isNotEmpty ? combinationName : "L";
  }
  static String _getDisplayName(BuildContext context, String fullName) {
    if (MediaQuery.of(context).size.width < 500) {
      List<String> nameParts = fullName.split(' ');
      String initials = '';
      if (nameParts.length > 1) {
        initials = nameParts[0][0] + nameParts[1][0];
      } else if (nameParts.isNotEmpty) {
        initials = nameParts[0][0];
      }
      return initials.toUpperCase();
    } else {
      return fullName;
    }
  }
}
