
import 'package:flutter/material.dart';

void main(){

  runApp(MaterialApp(
    home: unitScreen()
  ));
}

class unitScreen extends StatefulWidget {
  const unitScreen({Key? key}) : super(key: key);

  @override
  State<unitScreen> createState() => _unitScreenState();
}

class _unitScreenState extends State<unitScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight= MediaQuery.of(context).size.height;
   double screenWidth= MediaQuery.of(context).size.width;
    return Scaffold(

      body:Column(
        children: [
          Container(
            height: screenHeight*0.6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color.fromRGBO(21, 43, 83, 1),
            ),
          )
        ],
      )
    );
  }
}
