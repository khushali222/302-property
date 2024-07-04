import 'dart:convert';
import 'dart:ui';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant.dart';
import '../Dashboard/dashboard_one.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;

import '../../widgets/dialogbox.dart';


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
  TextEditingController confirmpassword = TextEditingController();
  bool isChecked = false;
  //bool isChecked = false;
  bool companynameerror = false;
  bool phoneerror = false;
  bool passworderror = false;
  bool confirmpassworderror = false;
  bool loading = false;
  String companynamemessage = "";
  String confirmpasswordmessage = "";
  String phonemessage = "";
  String passwordmessage = "";
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
        backgroundColor: Colors.white,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.013),
                  Text(
                    "Signup for free trial account",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: 50,
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
                                  child: TextField(

                                    enabled: false,
                                    controller: firstname,
                                    cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(14),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Image.asset(
                                          'assets/icons/user.png',
                                        ),
                                      ),
                                      hintText: "First Name",
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
                          height: 50,
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
                                      enabled: false,
                                      controller: lastname,
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(14),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                              'assets/icons/user.png'),
                                        ),
                                        hintText: "Last Name",
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
                          height:50,
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
                                      keyboardType: TextInputType.emailAddress,
                                      controller: email,
                                      enabled: false,
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(14),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Image.asset(
                                              'assets/icons/email.png'),
                                        ),
                                        hintText: "Business Email",
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
                          height:50,
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
                                      controller: companyname,
                                      onChanged: (value) {
                                        setState(() {
                                          companynameerror = false;
                                        });
                                      },
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        enabledBorder: companynameerror
                                            ? OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .red), // Set border color here
                                        )
                                            : InputBorder.none,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15),
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
                  companynameerror
                      ? Center(
                      child: Text(
                        companynamemessage,
                        style: TextStyle(color: Colors.red),
                      ))
                      : Container(),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height: 50,
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

                                      onChanged: (value) {
                                        setState(() {
                                          phoneerror = false;
                                        });
                                      },
                                      controller: phonenumber,
                                      keyboardType: TextInputType.number,
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        enabledBorder: phoneerror
                                            ? OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .red), // Set border color here
                                        )
                                            : InputBorder.none,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15),
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
                  phoneerror
                      ? Center(
                      child: Text(
                        phonemessage,
                        style: TextStyle(color: Colors.red),
                      ))
                      : Container(),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height:50,
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
                                      onChanged: (value) {
                                        setState(() {
                                          passworderror = false;
                                        });
                                      },
                                      obscureText: true,
                                      controller: password,
                                      cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15),
                                        enabledBorder: passworderror
                                            ? OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .red), // Set border color here
                                        )
                                            : InputBorder.none,
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
                  passworderror
                      ? Center(
                      child: Text(
                        passwordmessage,
                        style: TextStyle(color: Colors.red),
                      ))
                      : Container(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: Container(
                          height:50,
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
                                      onChanged: (value) {
                                        setState(() {
                                          confirmpassworderror = false;
                                        });
                                      },
                                      obscureText: true,
                                      controller: confirmpassword,
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(14),
                                        enabledBorder: confirmpassworderror
                                            ? OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .red), // Set border color here
                                        )
                                            : InputBorder.none,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                              'assets/icons/pasword.png'),

                                        ),
                                        hintText: "Confirm Password",
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
                  confirmpassworderror
                      ? Center(
                      child: Text(
                        confirmpasswordmessage,
                        style: TextStyle(color: Colors.red),
                      ))
                      : Container(),
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
                        ),
                        child: Checkbox(
                          activeColor: isChecked ? Colors.black : Colors.white,
                          checkColor: Colors.white,
                          value: isChecked, // assuming _isChecked is a boolean variable indicating whether the checkbox is checked or not
                          onChanged: ( value) {
                            setState(() {
                              isChecked = value ?? false; // ensure value is not null
                            });
                          },
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Text(
                        "I have read and accept 302 properties terms and condition ",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.024,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  GestureDetector(
                    onTap: () {
                     if(companyname.text.isEmpty){
                      setState(() {
                        companynameerror = true;
                        companynamemessage = "Company name is required";
                      });
                     }
                     else {
                       setState(() {
                         companynameerror = false;
                       });
                     }
                     if(phonenumber.text.isEmpty){
                       setState(() {
                         phoneerror = true;
                         phonemessage = "Phone number is required";
                       });
                     }
                     else if(phonenumber.text.length < 9){
                       setState(() {
                         phoneerror = true;
                         phonemessage = "Phone number is atleast 10 digit";
                       });
                     }
                     else {
                       setState(() {
                         phoneerror = false;
                       });
                     }
                     if(password.text.isEmpty){
                       setState(() {
                         passworderror = true;
                         passwordmessage = "Password is required";
                       });
                     }
                     else if(password.text.length < 8){
                       setState(() {
                         passworderror = true;
                         passwordmessage = "Password must have 8 Characters";
                       });
                     }
                     else if (!RegExp(r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(password.text)) {
                      setState(() {
                        passworderror = true;
                        passwordmessage =  'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';

                      });

                     }
                     else {
                       setState(() {
                         passworderror = false;
                       });
                     }
                     if(confirmpassword.text.isEmpty){
                       setState(() {
                         confirmpassworderror = true;
                         confirmpasswordmessage = "Confirm password is required";
                       });
                     }
                     else if(confirmpassword.text != password.text){
                       setState(() {
                         confirmpassworderror = true;
                         confirmpasswordmessage ="Both password is not match";
                       });
                     }
                     else{
                       setState(() {
                         confirmpassworderror = false;
                       });
                     }
                     if(companynameerror==false && passworderror == false && confirmpassworderror == false && phoneerror ==false){
                       if(isChecked){
                         loginsubmit();
                       }
                       else {
                         Fluttertoast.showToast(
                             msg: "Please check the Terms & Condition",
                             toastLength: Toast.LENGTH_SHORT,
                             gravity: ToastGravity.CENTER,
                             timeInSecForIosWeb: 1,
                             backgroundColor: Colors.red,
                             textColor: Colors.white,
                             fontSize: 16.0
                         );
                       }

                     }


                    /*  setState(() {
                        showdialog = true;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return dialogbox();
                        },
                      );*/
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
                        child: loading?
                        SpinKitFadingCircle(
                          color: Colors.white,
                          size: 50.0,
                        )
                            : Row(
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


  Future<void> loginsubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loading = true;
    });

    final response = await http.post(
        Uri.parse('${Api_url}/api/admin/register'),
        body: {"email": email.text,
          "password": password.text,"first_name":firstname.text,"last_name":lastname.text,"company_name":companyname.text,"phone_number":phonenumber.text});
    final jsonData = json.decode(response.body);

    if (jsonData["statusCode"] == 200) {

      prefs.setString('first_name', jsonData['data']['first_name']);
      prefs.setString('last_name', jsonData['data']['last_name']);
      setState(() {
        loading = false;
        showdialog = true;

      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialogbox();
        },
      );

      /*final List<dynamic> data = jsonData['data'];
      List<String> urls = [];
      List<String> banners = [];
      List<bool> banner_status = [];
      for (var item in data) {
        urls.add(item['url']);
        banners.add(item['id']);
        banner_status.add(item['status']);
      }
      for (var i = 0 ; i < banner_status.length;i++){
        setState(() {
          if(banner_status[i])
            selectedIndex = i;
        });
      }
      setState(() {
        imageUrls = urls;
        bannerid = banners;
        bannerstatus = banner_status;
        isLoading = false;
      });
      print(imageUrls);*/
    } else {
      Fluttertoast.showToast(msg: jsonData["message"]);
      setState(() {
        loading = false;
      });
    }
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
                 // Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
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
