import 'package:flutter/material.dart';

class widget_302 {
  static App_Bar(
      {var suffixIcon,
      var leading,
      var fontweight,
      List<Widget>? actions,
      var arrowNearText}) {
    return AppBar(
         elevation: 0,
        backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Image(
        image: AssetImage('assets/images/applogo.png'),
        height: 40,
        width: 40,
      ),
      leading: GestureDetector(
        onTap: () {},
        child: Icon(Icons.menu),
      ),
      actions: [
        Material(
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
        SizedBox(
          width: 10,
        ),
        Image(
          image: AssetImage('assets/icons/notification.png'),
          height: 20,
          width: 20,
        ),
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
