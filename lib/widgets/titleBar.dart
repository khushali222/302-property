import 'package:flutter/material.dart';

import '../constant/constant.dart';

class titleBar extends StatelessWidget {
  final String title;
  final double width;
   double size;
  titleBar({required this.title, required this.width,this.size=21});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 13),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child:
        Container(
          // height: 50.0,
          height: (MediaQuery.of(context).size.width < 500) ? 50 : 60,
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.width < 500 ? 9 :5, left: 10),
          width: width,
          margin: const EdgeInsets.only(bottom: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: blueColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "${title}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:   MediaQuery.of(context).size.width <
                          500
                          ? 16
                          : 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
