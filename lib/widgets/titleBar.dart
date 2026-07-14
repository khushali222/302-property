import 'package:flutter/material.dart';

import '../constant/constant.dart';

class titleBar extends StatelessWidget {
  final String title;
  final double width;
  final double size;
  final double radius;
  titleBar(
      {required this.title,
      required this.width,
      this.size = 21,
      this.radius = 5.0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: (MediaQuery.of(context).size.width < 768) ? 50 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: width,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: blueColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              "${title}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
