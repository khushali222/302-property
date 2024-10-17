import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/profile.dart';


import '../../constant/constant.dart';
import '../../repository/profile_repository.dart';
import '../widgets/drawer_tiles.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_drawer.dart';
import '../../widgets/titleBar.dart';

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

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  profile? _profile;
  Map<String,dynamic> profiledata = {};
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    _fetchProfile();
  }
  ConnectivityResult? _connectivityResult ;
  void checkInternet()async{

    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });

  }
  Future<void> fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    //  String? token = prefs.getString('token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/staffmember/staffmember_profile/$id";
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
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(currentpage: 'Profile',dropdown: false,),
      body: _connectivityResult !=ConnectivityResult.none ?
      _isLoading
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
          :LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
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
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(3),
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Name',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Designation',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Phone Number',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Email',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),

                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${profiledata['staffmember_name']}",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['staffmember_designation'],style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['staffmember_phoneNumber'],style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['staffmember_email'],style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
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
              return SingleChildScrollView(
                      child: Column(
              children: [
                SizedBox(height: 20),
                titleBar(title: 'Personal Details', width: MediaQuery.of(context).size.width * 0.91,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: blueColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildWidget( 'Name',  profiledata['staffmember_name']),
                          buildWidget( 'Designation',  profiledata['staffmember_designation']),
                          buildWidget( 'Phone Number',  profiledata['staffmember_phoneNumber']),
                          buildWidget( 'Email',  profiledata['staffmember_email']),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
                      ),
                    );
            }
          ): SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/no_internet.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            Text(
              'No Internet',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Check your internet connection',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
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
                color: blueColor)),
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
