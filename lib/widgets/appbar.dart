// import 'package:flutter/material.dart';
// import 'package:three_zero_two_property/screens/plan_screen.dart';
//
// import '../screens/add_staffmember.dart';
// import '../screens/property_table.dart';
//
// class widget_302 {
//   static App_Bar(
//       {var suffixIcon,
//       var leading,
//       var fontweight,
//       List<Widget>? actions,
//       var arrowNearText,
//       required BuildContext context,
//       }) {
//     return AppBar(
//       elevation: 5,
//       backgroundColor: Colors.white,
//       //automaticallyImplyLeading: false,
//       // title: Image(
//       //   image: AssetImage('assets/images/applogo.png'),
//       //   height: 40,
//       //   width: 40,
//       // ),
//       title: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           // Check if the device width is less than 600 (considered as phone screen)
//           if (constraints.maxWidth < 500) {
//             return Image.asset(
//               'assets/images/applogo.png',
//               height: 40,
//               width: 40,
//             );
//           } else {
//             return Image.asset(
//               'assets/images/logo.png',
//               // Adjust height and width accordingly for tablet
//             );
//           }
//         },
//       ),
//       // leading: GestureDetector(
//       //   onTap: () {},
//       //   child: Icon(Icons.menu),
//       // ),
//       actions: [
//         InkWell(
//           onTap: (){
//             // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Plan_screen()));
//             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DataTableDemo()));
//           },
//           child: Material(
//             elevation: 3,
//             borderRadius: BorderRadius.circular(5),
//             child: Container(
//               width: 50,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: Color.fromRGBO(21, 43, 81, 1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: Center(
//                   child: Text(
//                 "Buy",
//                 style: TextStyle(color: Colors.white),
//               )),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//         Icon(Icons.notifications_outlined),
//         SizedBox(
//           width: 10,
//         ),
//         Material(
//           elevation: 3,
//           borderRadius: BorderRadius.circular(6),
//           child: Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(21, 43, 81, 1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Center(
//                 child: Text(
//               "L",
//               style: TextStyle(color: Colors.white),
//             )),
//           ),
//         ),
//         SizedBox(
//           width: 20,
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Profile_screen.dart';
import 'package:three_zero_two_property/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Profile_screen.dart';
import 'package:three_zero_two_property/screens/login_screen.dart';
import 'package:three_zero_two_property/screens/plan_screen.dart';

class widget_302 {
  static App_Bar(
      {var suffixIcon,
        var leading,
        var fontweight,
        List<Widget>? actions,
        var arrowNearText,
        required BuildContext context,

      }) {
    return AppBar(
      elevation: 5,
      backgroundColor: Colors.white,
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
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Plan_screen()));
          },
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: 50,
              height: 30,
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
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Icon(Icons.notifications_outlined),
        SizedBox(
          width: 10,
        ),
        FutureBuilder<String>(
          future: _getNameFromSharedPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:  PopupMenuButton(
                      position: PopupMenuPosition.under,
                      child:  Center(
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
                        PopupMenuItem(child: Text("WELCOME",),
                        ),
                        PopupMenuItem(child: Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 10,),
                            Text("My Profile"),
                          ],
                        ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Profile_screen()));
                          },
                        ),
                        PopupMenuItem(child: Row(
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 10,),
                            Text("Settings"),
                          ],
                        ),
                        ),

                        PopupMenuItem(child: Row(
                          children: [
                            Icon(Icons.directions_run_rounded),
                            SizedBox(width: 10,),
                            Text("Logout"),
                          ],
                        ),
                          onTap: ()async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Login_Screen()), (route) => false);
                          },
                        ),
                      ],
                    )
                ),
              );
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
