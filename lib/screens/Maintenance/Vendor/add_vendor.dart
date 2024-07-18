
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

import '../../../Model/vendor.dart';
import '../../../repository/vendor_repository.dart';
import '../../../widgets/titleBar.dart';
class Add_vendor extends StatefulWidget {
  const Add_vendor({super.key});

  @override
  State<Add_vendor> createState() => _Add_vendorState();
}

class _Add_vendorState extends State<Add_vendor> {
  final TextEditingController firstName = TextEditingController();

  final TextEditingController lastName = TextEditingController();

  final TextEditingController phoneNumber = TextEditingController();
  bool obsecure = true;
  final TextEditingController workNumber = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController alterEmail = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController passWord = TextEditingController();
  bool isLoading = false;
  bool formValid = false;
  final VendorRepository vendorRepository = VendorRepository(baseUrl: 'https://yourapiurl.com');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
      ),
      body:  Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 25,
              ),
              titleBar(
                width: MediaQuery.of(context).size.width * .91,
                title: 'Add Vendor',
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                   height: !formValid ?  460 : 555,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Color.fromRGBO(21, 43, 103, 1),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vendor Name *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        hintText: 'Enter vendor name',
                        controller: firstName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter the vendor name';
                          }
                          return null;
                        },
                      ),
                     /* SizedBox(
                        height: 10,
                      ),
                      Text('Last Name *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        hintText: 'Enter last name',
                        controller: lastName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter the last name';
                          }
                          return null;
                        },
                      ),*/
                      SizedBox(
                        height: 10,
                      ),
                      Text('Phone Number *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.number,
                        hintText: 'Enter phone number',
                        controller: phoneNumber,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter the phone number';
                          }
                          return null;
                        },
                      ),
                    /*  SizedBox(
                        height: 10,
                      ),
                      Text('Work Number',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.number,
                        hintText: 'Enter work number',
                        controller: workNumber,
                      ),*/
                      SizedBox(
                        height: 10,
                      ),
                      Text('Email *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter Email',
                        controller: email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter email';
                          }
                          return null;
                        },
                      ),
                     /* SizedBox(
                        height: 10,
                      ),
                      Text('Alternative Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter alternative email',
                        controller: alterEmail,
                      ),*/
                      SizedBox(
                        height: 10,
                      ),
                      Text('Password *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              keyboardType: TextInputType.text,
                              obscureText: obsecure,
                              hintText: 'Enter password',
                              controller: passWord,
                              validator: (value) {
                                if (value == null) {
                                  return 'please enter password';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                              width:
                              10), // Add some space between the widgets
                          InkWell(
                            onTap: () {
                              setState(() {
                                obsecure = !obsecure;
                              });
                            },
                            child: Container(
                              width: 38,
                              height: 50,
                              child: Center(
                                child: FaIcon(
                                  !obsecure
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(1.2, 1.2),
                                    blurRadius: 3.0,
                                    spreadRadius: 1.0,
                                  ),
                                ],
                                border: Border.all(
                                    width: 0, color: Colors.white),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(21, 43, 83, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    formValid = true;
                                  });
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      formValid = false;
                                    });

                                    await addTenant();
                                  }
                                },
                                child: isLoading
                                    ? Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 55.0,
                                  ),
                                )
                                    : Text(
                                  'Add Vendor',
                                  style: TextStyle(color: Color(0xFFf7f8f9)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFffffff),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.0))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Color(0xFF748097)),
                                    )))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> addTenant() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString("adminId")!;



    final vendor = Vendor(
      adminId:adminId,
      vendorName: firstName.text,
      vendorPhoneNumber: phoneNumber.text,
      vendorEmail: email.text,
      vendorPassword: passWord.text,
    );

    final success = await vendorRepository.addVendor(vendor);
    if (success) {
   //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vendor added successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add vendor')));
    }
    setState(() {
      isLoading = false;
    });

    if (success) {
      print('Form is valid');
      Fluttertoast.showToast(msg: "Vendor added successfully");
      Navigator.of(context).pop(true);
    } else {
      print('Form is invalid');
    }
  }
}

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final bool readOnnly;

  CustomTextField({
    Key? key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
    this.readOnnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSuffixIconPressed,
    this.onTap, // Initialize onTap
  }) : super(key: key);

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  TextEditingController _textController =
  TextEditingController(); // Add this line

  @override
  void dispose() {
    _textController.dispose(); // Dispose the controller when not needed anymore
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: (value) {
            if (widget.controller!.text.isEmpty) {
              setState(() {
                _errorMessage = 'Please ${widget.hintText}';
              });
              return '';
            }
            setState(() {
              _errorMessage = null;
            });
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                Material(
                  elevation:3,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      //border: Border.all(color: blueColor),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.2),
                      //     offset: Offset(4, 4),
                      //     blurRadius: 3,
                      //   ),
                      // ],
                    ),
                    child: TextFormField(
                      onTap: widget.onTap,
                      obscureText: widget.obscureText,
                      readOnly: widget.readOnnly,
                      keyboardType: widget.keyboardType,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          state.validate();
                        }
                        return null;
                      },
                      controller: widget.controller,
                      decoration: InputDecoration(
                        suffixIcon: widget.suffixIcon,
                        hintStyle:
                        TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                        border: InputBorder.none,
                        hintText: widget.hintText,
                      ),
                    ),
                  ),
                ),
                if (state.hasError)
                  SizedBox(height: 24), // Reserve space for error message
              ],
            );
          },
        ),
        if (_errorMessage != null)
          Positioned(
            top: 60,
            left: 8,
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}
