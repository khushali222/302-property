import 'package:flutter/material.dart';

import '../constant/constant.dart';

class titleBar extends StatelessWidget {
  final String title;
  final double width;
  final double size;
  titleBar({required this.title, required this.width, this.size = 21});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        height: (MediaQuery.of(context).size.width < 768) ? 50 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: width,
        margin: EdgeInsets.zero,
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
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
