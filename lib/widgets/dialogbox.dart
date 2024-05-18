import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text('Blur Dialog Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomBlurDialog();
                },
              );
            },
            child: Text('Show Dialog'),
          ),
        ),

    );
  }
}

class CustomBlurDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: AlertDialog(
        backgroundColor: Colors.white,
        //surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Set your desired border radius here
        ),
        title: Image.asset("assets/check.png",height: 36,width: 36,),
        content: SizedBox(
          height: 160,
          child: Column(
            children: [
              Text('Your trial account is being ready !',style: TextStyle(fontSize: 14,fontFamily: 'mulish'),),
              SizedBox(height: 20,),
              Text('Feel free to access the trial account.Once you sign u, we’ll start you with a fresh account',textAlign: TextAlign.center,style: TextStyle(fontSize: 14,fontFamily: 'mulish'),),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  width: 134,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:BorderRadius.circular(6)
                  ),
                  child: Center(child: Text("Get Started",style: TextStyle(color: Colors.white,fontFamily: 'mulish'),),),
                ),
              )
            ],
          ),
        ),

      ),
    );
  }
}
