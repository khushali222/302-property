import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/constant.dart';
import '../../../widgets/titleBar.dart';
import '../../model/sumery_model.dart';
import '../../widgets/appbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/drawer_tiles.dart';
import 'package:http/http.dart' as http;
class summery_page extends StatefulWidget {
  String? lease_id;
   summery_page({super.key,this.lease_id});

  @override
  State<summery_page> createState() => _summery_pageState();
}

class _summery_pageState extends State<summery_page> {
  bool _isLoading = false;
//  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  summery_property? profiledata ;

  Future<void> fetchProfile() async {

    try {
    setState(() {
      _isLoading = true;
    });
    //  String? token = prefs.getString('token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/leases/lease_summary/${widget.lease_id}";
    final response = await http.get(Uri.parse('$apiUrl'), headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    print('hello$apiUrl');
  //  log(response.body);
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      print("hello");
      setState(() {
        profiledata = summery_property.fromJson(jsonDecode(response.body)["data"]);
        print(profiledata!.rentalAdress);
        _isLoading = false;
      });
      // return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {

      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load profile');

    }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfile();
  }
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: () {
       key.currentState!.openDrawer();
      },),
      backgroundColor: Colors.white,
      drawer:  CustomDrawer(currentpage: 'Properties',),
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
          :LayoutBuilder(
          builder: (context, constraints) {

            if (constraints.maxWidth > 600){
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    titleBar(
                      width: MediaQuery.of(context).size.width * .91,
                      title: 'Property Details',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Property Details",
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23),
                              ),
                              SizedBox(height: 10),
                              Table(
                                border: TableBorder.all(),
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Property Details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Address',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('City',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Country',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Post Code',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),

                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${profiledata!.propertysubType!} ",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalAdress!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata!.rentalCity!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata!.rentalCountry!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalPostcode!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    ],
                                  ),

                                ],
                              ),
                             /* Table(
                                border: TableBorder.all(color: blueColor),
                                columnWidths: {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  _buildTableRow('Property Details', profiledata!.propertysubType!),
                                  _buildTableRow('Address', profiledata!.rentalAdress!),
                                  _buildTableRow('City', profiledata!.rentalCity!),
                                  _buildTableRow('Country', profiledata!.rentalCountry!),
                                  _buildTableRow('Post Code', profiledata!.rentalPostcode!),
                                ],
                              ),*/
                              SizedBox(height: 10,),
                              Image.network("$image_url${profiledata! .rentalImage}",height: 150,width: 300,),


                            ],
                          ),
                        ),
                      ),
                    ), SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rental Owner Details",
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23),
                              ),
                              SizedBox(height: 10,),
                              Table(
                                border: TableBorder.all(color: blueColor),
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(3),
                                  3: FlexColumnWidth(2),
                                //  4: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Contact Name',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Company Name',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Email',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Phone No',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                     // TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Post Code',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),

                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${profiledata!.rentalOwnerName} ",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalOwnerCompanyName!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalOwnerPrimaryEmail!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata!.rentalOwnerPhoneNumber!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    //  TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalPostcode!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    ],
                                  ),

                                ],
                              ),
                            /*  Table(
                                border: TableBorder.all(color: blueColor),
                                columnWidths: {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  _buildTableRow('Contact Name', profiledata!.rentalOwnerName!),
                                  _buildTableRow('Company Name', profiledata!.rentalOwnerCompanyName!),
                                  _buildTableRow('Email', profiledata!.rentalOwnerPrimaryEmail!),
                                  _buildTableRow('Phone No', profiledata!.rentalOwnerPhoneNumber!),
                                ],
                              ),*/
                            ],
                          ),
                        ),
                      ),
                    ), SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Staff Details",
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23),
                              ),
                              SizedBox(height: 10,),
                              Table(
                                border: TableBorder.all(color: blueColor),
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(3),
                                  3: FlexColumnWidth(2),
                                  //  4: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Staff Member',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                     // TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Company Name',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                   //   TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Email',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                 //     TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Phone No',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                      // TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Post Code',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),

                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${ profiledata!.staffmember_name} ",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    //  TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalOwnerCompanyName!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    //  TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalOwnerPrimaryEmail!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    //  TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata!.rentalOwnerPhoneNumber!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      //  TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalPostcode!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    ],
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Unit Details",
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23),
                              ),
                              SizedBox(height: 10,),

                              Table(
                                border: TableBorder.all(color: blueColor),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(3),
                                  3: FlexColumnWidth(2),
                                    4: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Unit',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Unit Address',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Bed',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor),))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Bath',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),
                                       TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Square Fit',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:blueColor)))),

                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("${profiledata!.rentalUnit!} ",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalUnitAdress!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rental_bed!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(profiledata!.rental_bath!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                       TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text( profiledata!.rentalSqft!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20,color:greyColor)))),
                                    ],
                                  ),

                                ],
                              ),
                              /*Table(
                                border: TableBorder.all(),
                                columnWidths: {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  _buildTableRow('Unit', profiledata!.rentalUnit!),
                                  _buildTableRow('Unit Address', profiledata!.rentalUnitAdress!),
                                  _buildTableRow('Bed', profiledata!.rental_bed!),
                                  _buildTableRow('Bath', profiledata!.rental_bath!),
                                  _buildTableRow('Square Fit', profiledata!.rentalSqft!),
                                ],
                              ),*/

                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,)
                  ],
                ),
              );
            }
              return SingleChildScrollView(
                      child: Column(
              children: [
                SizedBox(height: 20,),
                titleBar(
                  width: MediaQuery.of(context).size.width * .91,
                  title: 'Property Details',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Property Details",
                            style: TextStyle(
                                color: Color.fromRGBO(21, 43, 83, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(height: 10,),
                          Table(
                            border: TableBorder.all(color: blueColor),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            children: [
                              _buildTableRow('Property Details', profiledata!.propertysubType!),
                              _buildTableRow('Address', profiledata!.rentalAdress!),
                              _buildTableRow('City', profiledata!.rentalCity!),
                              _buildTableRow('Country', profiledata!.rentalCountry!),
                              _buildTableRow('Post Code', profiledata!.rentalPostcode!),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Image.network("$image_url${profiledata!.rentalImage}")
                        ],
                      ),
                    ),
                  ),
                ), SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rental Owner Details",
                            style: TextStyle(
                                color: Color.fromRGBO(21, 43, 83, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(height: 10,),
                          Table(
                            border: TableBorder.all(color: blueColor),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            children: [
                              _buildTableRow('Contact Name', profiledata!.rentalOwnerName!),
                              _buildTableRow('Company Name', profiledata!.rentalOwnerCompanyName!),
                              _buildTableRow('Email', profiledata!.rentalOwnerPrimaryEmail!),
                              _buildTableRow('Phone No', profiledata!.rentalOwnerPhoneNumber!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ), SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Staff Details",
                            style: TextStyle(
                                color: Color.fromRGBO(21, 43, 83, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(height: 10,),
                          Table(

                            border: TableBorder.all(),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            children: [
                              _buildTableRow('Staff Member', profiledata!.staffmember_name!),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unit Details",
                            style: TextStyle(
                                color: Color.fromRGBO(21, 43, 83, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(height: 10,),
                          Table(
                            border: TableBorder.all(),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            children: [
                              _buildTableRow('Unit', profiledata!.rentalUnit!),
                              _buildTableRow('Unit Address', profiledata!.rentalUnitAdress!),
                              _buildTableRow('Bed', profiledata!.rental_bed!),
                              _buildTableRow('Bath', profiledata!.rental_bath!),
                              _buildTableRow('Square Fit', profiledata!.rentalSqft!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
                      ),
                    );
            }
          ),
    );
  }
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
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
