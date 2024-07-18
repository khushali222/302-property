import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/constant.dart';
import '../../../widgets/titleBar.dart';
import '../../model/sumery_model.dart';
import '../../widgets/appbar.dart';
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
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person,
                    color: Colors.black,
                  ),
                  "Profile",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.home,
                    color: Colors.white,
                  ),
                  "Properties",
                  true),
              buildListTile(
                  context,
                  const Icon(
                    Icons.bar_chart,
                    color: Colors.black,
                  ),
                  "Financial",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.square_list,
                    color: Colors.black,
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
          :SingleChildScrollView(
        child: Column(
          children: [
            titleBar(
              width: MediaQuery.of(context).size.width * .91,
              title: 'Property Details',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(

                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
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
                        border: TableBorder.all(),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
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
                        border: TableBorder.all(),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
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
            style: TextStyle(fontWeight: FontWeight.bold),
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
