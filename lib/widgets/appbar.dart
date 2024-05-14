import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/plan_screen.dart';

import '../screens/add_staffmember.dart';
import '../screens/property_table.dart';

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
            // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Plan_screen()));
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DataTableDemo()));
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
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color.fromRGBO(21, 43, 81, 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
                child: Text(
              "L",
              style: TextStyle(color: Colors.white),
            )),
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
