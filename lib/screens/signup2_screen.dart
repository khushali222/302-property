import 'dart:ui';

import 'package:flutter/material.dart';

import 'dialogbox.dart';

class Signup2 extends StatefulWidget {
  String? firstname;
  String? lastname;
  String? email;
  Signup2({super.key, this.firstname, this.lastname, this.email});

  @override
  State<Signup2> createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController companyname = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool showdialog = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstname.text = widget.firstname!;
    lastname.text = widget.lastname!;
    email.text = widget.email!;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Image(
              image: AssetImage('assets/images/logo.png'),
              height: 40,
              width: width * .8,
              alignment: Alignment.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to 302 Rentals",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.05),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "Signup for free trial account",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                            color: Color.fromRGBO(196, 196, 196, 0.3),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.00),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                            'assets/icons/user.png',
                                          ),
                                        ),
                                        hintText: "Alex",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                            color: Color.fromRGBO(196, 196, 196, 0.3),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.00),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                              'assets/icons/user.png'),
                                        ),
                                        hintText: "Williams",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                            color: Color.fromRGBO(196, 196, 196, 0.3),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.00),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Image.asset(
                                              'assets/icons/email.png'),
                                        ),
                                        hintText: "Email",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                            color: Color.fromRGBO(196, 196, 196, 0.3),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.00),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                              'assets/icons/home.png'),
                                        ),
                                        hintText: "Company Name",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                            color: Color.fromRGBO(196, 196, 196, 0.3),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.00),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                              'assets/icons/phone.png'),
                                        ),
                                        hintText: "Phone Number",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                            color: Color.fromRGBO(196, 196, 196, 0.3),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.00),
                                  child: Center(
                                    child: TextField(
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                              'assets/icons/pasword.png'),
                                        ),
                                        hintText: "Password",
                                        //  suffixIcon: Icon(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.03,
                        width: MediaQuery.of(context).size.height * 0.03,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Text(
                        "I have read and accept 302 properties term and condition ",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.024,
                            color: Colors.black),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showdialog = true;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return dialogbox();
                        },
                      );
                      //  dialogbox();
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomBlurDialog()));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create your free trial",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.035),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                "1",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text('About you',
                              style: TextStyle(
                                  fontSize: 10, fontFamily: 'muslish')),
                        ],
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Column(
                        children: [
                          Container(
                            width: 50,
                            height: 2,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                "2",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Customize Trial',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 10, fontFamily: 'muslish'),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Container(
                            width: 50,
                            height: 2,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showdialog ? Colors.black : Colors.grey,
                            ),
                            child: Center(
                              child: Text(
                                "3",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text("Final",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: 'muslish'))
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  dialogbox() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              10.0), // Set your desired border radius here
        ),
        title: Image.asset(
          "assets/check.png",
          height: 36,
          width: 36,
        ),
        content: SizedBox(
          height: 160,
          child: Column(
            children: [
              Text(
                'Your trial account is being ready !',
                style: TextStyle(fontSize: 14, fontFamily: 'mulish'),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Feel free to access the trial account.Once you sign u, we’ll start you with a fresh account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontFamily: 'mulish'),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 134,
                  height: 34,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Text(
                      "Get Started",
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'mulish'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
