import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../model/tenants.dart';
import '../../../repository/tenants.dart';

class AddTenant extends StatefulWidget {
  @override
  State<AddTenant> createState() => _AddTenantState();
}

class _AddTenantState extends State<AddTenant> {
  final TextEditingController firstName = TextEditingController();

  final TextEditingController lastName = TextEditingController();

  final TextEditingController phoneNumber = TextEditingController();
  bool obsecure = true;
  final TextEditingController workNumber = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController alterEmail = TextEditingController();

  final TextEditingController passWord = TextEditingController();

  final TextEditingController dob = TextEditingController();

  final TextEditingController taxPayerId = TextEditingController();

  final TextEditingController comments = TextEditingController();

  final TextEditingController contactName = TextEditingController();

  final TextEditingController relationToTenant = TextEditingController();

  final TextEditingController emergencyEmail = TextEditingController();

  final TextEditingController emergencyPhoneNumber = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1), // header background color
              onPrimary: Colors.white, // header text color
              // onSurface: Colors.blue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromRGBO(21, 43, 83, 1), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
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
        body: Form(
          key: _formkey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  titleBar(
                    width: MediaQuery.of(context).size.width * .91,
                    title: 'Add Tenant',
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      // height: !form_valid ? 860 : 830,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('First Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter first name',
                              controller: firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the first name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
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
                            ),
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
                            SizedBox(
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
                            ),
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
                            SizedBox(
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
                            ),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      // height: 410,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Personal Information',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(21, 43, 103, 1))),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Date of Birth',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.2,
                                          1.2), // Shadow offset to the bottom right
                                      blurRadius:
                                          3.0, // How much to blur the shadow
                                      spreadRadius:
                                          1.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF8898aa), // Text color
                                  fontSize: 16.0, // Text size
                                  fontWeight: FontWeight.w400, // Text weight
                                ),
                                controller: _dateController,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Color(0xFFb0b6c3)),
                                  border: InputBorder.none,
                                  // labelText: 'Select Date',
                                  hintText: 'Select Date',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () {
                                      _selectDate(context);
                                    },
                                  ),
                                ),
                                readOnly: true,
                                onTap: () {
                                  _selectDate(context);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('TaxPayer ID',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter contact name',
                              controller: taxPayerId,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Comments',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 90,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.2,
                                          1.2), // Shadow offset to the bottom right
                                      blurRadius:
                                          3.0, // How much to blur the shadow
                                      spreadRadius:
                                          1.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: comments,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 13, color: Color(0xFFb0b6c3)),
                                    hintText: 'Enter the comment',
                                  )),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      // height: form_valid ? 520 : 430,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 103, 1),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Emergency Contact',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(21, 43, 103, 1))),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Contact Name',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter contact name',
                              controller: contactName,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Relationship to Tenant',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter relationship to tenant',
                              controller: relationToTenant,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('E-Mail',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter email',
                              controller: emergencyEmail,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Phone Number',
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
                              controller: emergencyPhoneNumber,
                            ),
                          ],
                        ),
                      ),
                    ),
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
                              } else {
                                print('Form is invalid');
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
                                    'Add Tenant',
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
        ),
      ),
    );
  }

  bool isLoading = false;
  bool formValid = true;

  Future<void> addTenant() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString("adminId")!;
    EmergencyContact emergencyContact = EmergencyContact(
      name: contactName.text,
      relation: relationToTenant.text,
      email: emergencyEmail.text,
      phoneNumber: emergencyPhoneNumber.text,
    );

    Tenant tenant = Tenant(
      adminId: adminId,
      tenantFirstName: firstName.text,
      tenantLastName: lastName.text,
      tenantPhoneNumber: phoneNumber.text,
      tenantAlternativeNumber: workNumber.text,
      tenantEmail: email.text,
      tenantAlternativeEmail: alterEmail.text,
      tenantPassword: passWord.text,
      tenantBirthDate: _dateController.text,
      taxPayerId: taxPayerId.text,
      comments: comments.text,
      emergencyContact: emergencyContact,
    );

    bool success = await TenantsRepository().addTenant(tenant);

    setState(() {
      isLoading = false;
    });

    if (success) {
      print('Form is valid');
      Fluttertoast.showToast(msg: "Tenant added successfully");
      Navigator.of(context).pop(true);
    } else {
      print('Form is invalid');
    }
  }
}

// class CustomTextField extends StatefulWidget {
//   final String hintText;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final bool obscureText;
//
//   final Widget? suffixIcon;
//   final IconData? prefixIcon;
//   final void Function()? onSuffixIconPressed;
//   final void Function()? onTap;
//   final bool readOnnly;
//
//   CustomTextField({
//     Key? key,
//     this.controller,
//     required this.hintText,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.emailAddress,
//     this.readOnnly = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.onSuffixIconPressed,
//     this.onTap, // Initialize onTap
//   }) : super(key: key);
//
//   @override
//   CustomTextFieldState createState() => CustomTextFieldState();
// }
//
// class CustomTextFieldState extends State<CustomTextField> {
//   String? _errorMessage;
//   TextEditingController _textController =
//       TextEditingController(); // Add this line
//
//   @override
//   void dispose() {
//     _textController.dispose(); // Dispose the controller when not needed anymore
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: <Widget>[
//         FormField<String>(
//           validator: (value) {
//             if (widget.controller!.text.isEmpty) {
//               setState(() {
//                 _errorMessage = 'Please ${widget.hintText}';
//               });
//               return '';
//             }
//             setState(() {
//               _errorMessage = null;
//             });
//             return null;
//           },
//           builder: (FormFieldState<String> state) {
//             return Column(
//               children: <Widget>[
//                 Material(
//                   elevation:2,
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Container(
//                     height: 50,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.0),
//                       //border: Border.all(color: blueColor),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           offset: Offset(4, 4),
//                           blurRadius: 3,
//                         ),
//                       ],
//                     ),
//                     child: TextFormField(
//                       onTap: widget.onTap,
//                       obscureText: widget.obscureText,
//                       readOnly: widget.readOnnly,
//                       keyboardType: widget.keyboardType,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           state.validate();
//                         }
//                         return null;
//                       },
//                       controller: widget.controller,
//                       decoration: InputDecoration(
//                         suffixIcon: widget.suffixIcon,
//                         hintStyle:
//                             TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
//                         border: InputBorder.none,
//                         hintText: widget.hintText,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (state.hasError)
//                   SizedBox(height: 24), // Reserve space for error message
//               ],
//             );
//           },
//         ),
//         if (_errorMessage != null)
//           Positioned(
//             top: 60,
//             left: 8,
//             child: Text(
//               _errorMessage!,
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 12.0,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }


class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;

  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final bool readOnnly;

  CustomTextField({
    Key? key,
    this.onChanged,
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
                  elevation:2,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      //border: Border.all(color: blueColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(4, 4),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      onChanged: widget.onChanged,
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
