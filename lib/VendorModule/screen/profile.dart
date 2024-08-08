import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/profile.dart';


import '../../constant/constant.dart';
import '../../repository/profile_repository.dart';
import '../widgets/drawer_tiles.dart';
import '../../widgets/titleBar.dart';
import '../widgets/appbar.dart';

class Profile_screen extends StatefulWidget {
  const Profile_screen({Key? key}) : super(key: key);

  @override
  State<Profile_screen> createState() => _Profile_screenState();
}

class _Profile_screenState extends State<Profile_screen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  profile? _profile;
  Map<String,dynamic> profiledata = {};
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }
  Future<void> fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    //  String? token = prefs.getString('token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("vendor_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/vendor/get_vendor/$id";
    final response = await http.get(Uri.parse('$apiUrl'), headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    print('hello$apiUrl');
    print(response.body);
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      print("hello");
      setState(() {
        profiledata = response_Data["data"];
        _isLoading = false;
      });
     // return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load profile');

    }
  }
  Future<void> _fetchProfile() async {
    try {
      await fetchProfile();
     /* final profileData = await fetchProfile();
      setState(() {
        _profile = profileData;
        _firstNameController.text = profileData.firstName ?? '';
        _lastNameController.text = profileData.lastName ?? '';
        _emailController.text = profileData.email ?? '';
        _phoneNumberController.text = profileData.phoneNumber?.toString() ?? '';
        _companyNameController.text = profileData.companyName ?? '';
        _isLoading = false;
      });*/
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: () {
        print("calling appbar");
        key.currentState!.openDrawer();
      },),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/dashboard.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/admin2.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Profile",
                  true),
             /* buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/Property.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Properties",
                  false),
              buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/Financial.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Financial",
                  false),*/
              buildListTile(
                  context,
                  SvgPicture.asset(
                    "assets/images/tenants/Work.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Work Order",
                  false),
              /* buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),*/
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: SpinKitFadingCircle(
          color: Colors.black,
          size: 50.0,
        ),
      )
          : _hasError
          ? Center(
        child: Text('Error: $_errorMessage'),
      )
          : LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              // Horizontal layout for tablet screens
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    titleBar(title: 'Personal Details', width: MediaQuery.of(context).size.width * 0.90),
                    Padding(
                      padding:  EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width * 0.04,vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Table(
                          border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(3),
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Name',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Phone Number',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Email',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),

                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${profiledata['vendor_name']}",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata['vendor_phoneNumber'].toString(),style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['vendor_email'],style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                   /* titleBar(title: 'Lease Details', width: MediaQuery.of(context).size.width * 0.90),
                    Padding(
                      padding:  EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width * 0.04,vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Lease Type',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor))),),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Property',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Start Date',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('End Date',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Rent Cycle',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Rent Amount',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Next Due Date',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),

                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${profiledata['leaseData']['lease_type']}",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['rental_adress'] ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['start_date'] ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['end_date'] ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['rent_cycle'] ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['amount'].toString(),style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),

                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['date'] ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),*/
                  ],
                ),
              );

            }
            else{
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    titleBar(title: 'Personal Details', width: MediaQuery.of(context).size.width * 0.91,),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: blueColor),
                            borderRadius: BorderRadius.circular(6)
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InfoRow(label: 'Name', value: "${profiledata['vendor_name']}"),
                              //  InfoRow(label: 'Designation', value: profiledata['staffmember_designation']),
                              InfoRow(label: 'Phone Number', value: profiledata['vendor_phoneNumber'].toString()),

                              InfoRow(label: 'Email', value: profiledata['vendor_email']),
                            ],
                          ),
                        ),
                      ),
                    ),
                    /*  titleBar(title: 'Lease Details', width: MediaQuery.of(context).size.width * 0.91,),*/
                    /* Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow(label: 'Lease Type', value: "${profiledata['lease_type']}"),
                          //  InfoRow(label: 'Designation', value: profiledata['staffmember_designation']),
                          InfoRow(label: 'Property', value: profiledata['rental_adress']),
                          InfoRow(label: 'Start Date', value: profiledata['start_date']),
                          InfoRow(label: 'End Date', value: profiledata['end_date']),
                          InfoRow(label: 'Rent Cycle', value: profiledata['rent_cycle']),
                          InfoRow(label: 'Rent Amount', value: profiledata['amount'].toString()),
                          InfoRow(label: 'Next Due Date', value: profiledata['date']),
                        ],
                      ),
                    ),
                  ),
                ),*/
                    /*  SizedBox(height: 20),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 220,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: Color.fromRGBO(21, 43, 81, 1),
                              child: Center(
                                child: Text(
                                  '${_profile?.firstName?[0].toUpperCase() ?? ''}${_profile?.lastName?[0].toUpperCase() ?? ''}',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '${_profile?.firstName} ${_profile?.lastName}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '${_profile?.email}',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '${_profile?.adminId}',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  height: 50.0,
                                  padding:
                                  EdgeInsets.only(top: 8, left: 10),
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(
                                      bottom:
                                      6.0), //Same as `blurRadius` i guess
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "My Account",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                "User information",
                                style: TextStyle(fontSize: 17,color:Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold ),
                              ),
                              SizedBox(height: 16.0),
                              Text('First Name',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                              SizedBox(
                                height: 5,
                              ),
                              buildTextField('First Name',
                                  _firstNameController, _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Last Name',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                              SizedBox(
                                height: 5,
                              ),
                              buildTextField('Last Name',
                                  _lastNameController, _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Email Address',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                              SizedBox(
                                height: 5,
                              ),
                              buildTextField('Email Address',
                                  _emailController, _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Phone Number',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                              SizedBox(
                                height: 5,
                              ),
                              buildTextField(
                                  'Phone Number',
                                  _phoneNumberController,
                                  _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Company Name',style: TextStyle(color:Color(0xFF8A95A8),fontWeight: FontWeight.bold),),
                              SizedBox(
                                height: 5,
                              ),
                              buildTextField(
                                  'Company Name',
                                  _companyNameController,
                                  _validateFirstName),
                              SizedBox(height: 16.0),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     if (_formKey.currentState!.validate()) {
                              //       // If the form is valid, proceed with form submission
                              //       _formKey.currentState!.save();
                              //       ProfileRepository().Edit_profile({
                              //         "first_name": _firstNameController.text,
                              //         "last_name": _lastNameController.text,
                              //         "email": _emailController.text,
                              //         "company_name": _companyNameController.text,
                              //         "phone_number": int.parse(_phoneNumberController.text),
                              //       });
                              //     }
                              //     // Implement save functionality
                              //   },
                              //   child: Text('Update'),
                              // ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!
                                          .validate()) {
                                        // If the form is valid, proceed with form submission
                                        _formKey.currentState!.save();
                                        ProfileRepository().Edit_profile({
                                          "first_name":
                                          _firstNameController.text,
                                          "last_name":
                                          _lastNameController.text,
                                          "email": _emailController.text,
                                          "company_name":
                                          _companyNameController.text,
                                          "phone_number": int.parse(
                                              _phoneNumberController.text),
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: MediaQuery.of(context)
                                          .size
                                          .height *
                                          0.05,
                                      width: MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.25,
                                      decoration: BoxDecoration(
                                        color:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Update",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    0.04,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),*/
                  ],
                ),
              );
            }

            }
          ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            // hintStyle: TextStyle(color: Color(0xFF8A95A8)),
          ),
        ),
      ),
    );
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid name';
    }
    return null;
  }

}
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label',
              style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),
            ),
          ),
          Text(":  "),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
              //overflow: TextOverflow.,
            ),
          ),
        ],
      ),
    );
  }
}
class InfoRows extends StatelessWidget {
  final String label;
  final String value;

  InfoRows({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(":  "),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
              //overflow: TextOverflow.,
            ),
          ),
        ],
      ),
    );
  }
}
