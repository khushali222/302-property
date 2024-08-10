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
import '../widgets/custom_drawer.dart';
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
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/tenant/tenant_profile/$id";
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
      drawer:  CustomDrawer(currentpage: 'Profile',),
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
          : SingleChildScrollView(
        child: LayoutBuilder(
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
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${profiledata['tenant_firstName']} ${profiledata['tenant_lastName']}",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['tenant_phoneNumber'],style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['tenant_email'],style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    titleBar(title: 'Lease Details', width: MediaQuery.of(context).size.width * 0.90),
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
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(formatDate4(profiledata['leaseData']['start_date']) ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(formatDate4(profiledata['leaseData']['end_date']) ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['rent_cycle'] ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['amount'].toString(),style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),

                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata['leaseData']['date'] ?? "N/A",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

            } else {
              // Vertical layout for phone screens
              return Column(
                children: [
                  SizedBox(height: 20,),
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
                            borderRadius: BorderRadius.circular(6)
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoRow(label: 'Name', value: "${profiledata['tenant_firstName']} ${profiledata['tenant_firstName']}"),
                            InfoRow(label: 'Phone Number', value: profiledata['tenant_phoneNumber']),
                            InfoRow(label: 'Email', value: profiledata['tenant_email']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  titleBar(title: 'Lease Details', width: MediaQuery.of(context).size.width * 0.91,),
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
                            borderRadius: BorderRadius.circular(6)
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoRow(label: 'Lease Type', value: "${profiledata['leaseData']['lease_type']}"),
                            InfoRow(label: 'Property', value: profiledata['leaseData']['rental_adress'] ?? "N/A"),
                            InfoRow(label: 'Start Date', value: formatDate4(profiledata['leaseData']['start_date']) ?? "N/A"),
                            InfoRow(label: 'End Date', value: formatDate4(profiledata['leaseData']['end_date']) ?? "N/A"),
                            InfoRow(label: 'Rent Cycle', value: profiledata['leaseData']['rent_cycle'] ?? "N/A"),
                            InfoRow(label: 'Rent Amount', value: profiledata['leaseData']['amount'].toString()),
                            InfoRow(label: 'Next Due Date', value: formatDate4(profiledata['leaseData']['date']) ?? "N/A"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      )
      ,
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
          Text("  :     "),
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
              style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),
            ),
          ),
          Text(":    "),
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
