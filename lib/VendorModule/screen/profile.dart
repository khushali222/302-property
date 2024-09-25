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
                              buildWidget('Name',"${profiledata['vendor_name']}"),
                              //  buildWidget('Designation',profiledata['staffmember_designation']),
                              buildWidget('Phone Number',profiledata['vendor_phoneNumber'].toString()),

                              buildWidget('Email',profiledata['vendor_email']),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              );
            }

            }
          ),
    );
  }
  buildWidget(String label,String value){

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
        const SizedBox(
          height: 5,
        ),
        Material(
          //elevation: 3,
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(
                horizontal: 12.0, vertical: 0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    offset: Offset(1.0,
                        1.0), // Shadow offset to the bottom right
                    blurRadius:
                    8.0, // How much to blur the shadow
                    spreadRadius:
                    0.0, // How much the shadow should spread
                  ),
                ],
                border: Border.all(
                    width: 0, color: Colors.white),
                borderRadius: BorderRadius.circular(6.0)),
            child: TextFormField(
              style: const TextStyle(
                color: Color(0xFF8898aa), // Text color
                fontSize: 16.0, // Text size
                fontWeight: FontWeight.w400, // Text weight
              ),
              //  controller: _dateController,
              initialValue: value,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xFFb0b6c3)),
                border: InputBorder.none,
                // labelText: 'Select Date',
                hintText: 'dd-mm-yyyy',

              ),
              readOnly: true,
              onTap: () {
                //_selectDate(context);
              },
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }




}
