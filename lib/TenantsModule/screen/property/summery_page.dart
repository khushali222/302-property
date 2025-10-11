import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/constant.dart';
import '../../../widgets/titleBar.dart';
import '../../model/sumery_model.dart';
import '../../widgets/appbar.dart';
import '../../widgets/custom_drawer.dart';
import 'package:http/http.dart' as http;

class summery_page extends StatefulWidget {
  final String? lease_id;
  summery_page({super.key, this.lease_id});

  @override
  State<summery_page> createState() => _summery_pageState();
}

class _summery_pageState extends State<summery_page> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  summery_property? profiledata;

  Future<void> fetchProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? token = prefs.getString('token');
      final String apiUrl =
          "${Api_url}/api/leases/lease_summary/${widget.lease_id}";
      final response = await http.get(Uri.parse('$apiUrl'),
          headers: {"authorization": "CRM $token", "id": "CRM $id"});
      print('hello$apiUrl');
      final response_Data = jsonDecode(response.body);
      if (response_Data["statusCode"] == 200) {
        print("hello");
        setState(() {
          profiledata =
              summery_property.fromJson(jsonDecode(response.body)["data"]);
          print(profiledata!.rentalAdress);
          _isLoading = false;
        });
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

  ConnectivityResult? _connectivityResult;

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
    fetchProfile();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(
          context: context,
          onDrawerIconPressed: () {
            key.currentState!.openDrawer();
          }),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(currentpage: 'Properties'),
      body: _connectivityResult != ConnectivityResult.none
          ? _isLoading
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
          if (constraints.maxWidth > 600) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    titleBar(
                      width:
                      MediaQuery.of(context).size.width * 0.9,
                      title: 'Property Details',
                    ),
                    SizedBox(height: 30),

                    // Property Details Section
                    _buildPropertyDetailsCard(),
                    SizedBox(height: 20),

                    // Rental Owner Details Section
                    _buildRentalOwnerCard(),
                    SizedBox(height: 20),

                    // Staff Details Section
                    _buildStaffDetailsCard(),
                    SizedBox(height: 20),

                    // Unit Details Section
                    _buildUnitDetailsCard(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  titleBar(
                    width:
                    MediaQuery.of(context).size.width * 0.9,
                    title: 'Property Details',
                  ),
                  SizedBox(height: 20),

                  // Property Details Section
                  _buildMobilePropertyDetailsCard(),
                  SizedBox(height: 16),

                  // Rental Owner Details Section
                  _buildMobileRentalOwnerCard(),
                  SizedBox(height: 16),

                  // Staff Details Section
                  _buildMobileStaffDetailsCard(),
                  SizedBox(height: 16),

                  // Unit Details Section
                  _buildMobileUnitDetailsCard(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      )
          : SizedBox(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Check your internet connection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for tablet layout
  Widget _buildPropertyDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Property Details",
              style: TextStyle(
                color: blueColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            // Property Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Property Type',
                    profiledata!.propertysubType!,
                    Icons.home,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Address',
                    profiledata!.rentalAdress!,
                    Icons.location_on,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'City',
                    profiledata!.rentalCity!,
                    Icons.location_city,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Country',
                    profiledata!.rentalCountry!,
                    Icons.public,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Post Code',
                    profiledata!.rentalPostcode!,
                    Icons.mail,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Property Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "$image_url${profiledata!.rentalImage}",
                  height: 200,
                  width: 400,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalOwnerCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rental Owner Details",
              style: TextStyle(
                color: blueColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Contact Name',
                    profiledata!.rentalOwnerName!,
                    Icons.person,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Company Name',
                    profiledata!.rentalOwnerCompanyName!,
                    Icons.business,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Email',
                    profiledata!.rentalOwnerPrimaryEmail!,
                    Icons.email,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Phone Number',
                    profiledata!.rentalOwnerPhoneNumber!,
                    Icons.phone,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Staff Details",
              style: TextStyle(
                color: blueColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              'Staff Member',
              profiledata!.staffmember_name!,
              Icons.person_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Unit Details",
              style: TextStyle(
                color: blueColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Unit',
                    profiledata!.rentalUnit!,
                    Icons.home_work,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Unit Address',
                    profiledata!.rentalUnitAdress!,
                    Icons.location_on,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Bedrooms',
                    profiledata!.rental_bed!,
                    Icons.bed,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Bathrooms',
                    profiledata!.rental_bath!,
                    Icons.bathtub,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Square Feet',
                    profiledata!.rentalSqft!,
                    Icons.square_foot,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: blueColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: blueColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  // Mobile helper methods
  Widget _buildMobilePropertyDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home, color: blueColor, size: 24),
                SizedBox(width: 12),
                Text(
                  "Property Details",
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildMobileInfoRow(
                'Property Type', profiledata!.propertysubType!, Icons.home),
            _buildMobileInfoRow(
                'Address', profiledata!.rentalAdress!, Icons.location_on),
            _buildMobileInfoRow(
                'City', profiledata!.rentalCity!, Icons.location_city),
            _buildMobileInfoRow(
                'Country', profiledata!.rentalCountry!, Icons.public),
            _buildMobileInfoRow(
                'Post Code', profiledata!.rentalPostcode!, Icons.mail),
            SizedBox(height: 20),
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "$image_url${profiledata!.rentalImage}",
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileRentalOwnerCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: blueColor, size: 24),
                SizedBox(width: 12),
                Text(
                  "Rental Owner Details",
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildMobileInfoRow(
                'Contact Name', profiledata!.rentalOwnerName!, Icons.person),
            _buildMobileInfoRow('Company Name',
                profiledata!.rentalOwnerCompanyName!, Icons.business),
            _buildMobileInfoRow(
                'Email', profiledata!.rentalOwnerPrimaryEmail!, Icons.email),
            _buildMobileInfoRow('Phone Number',
                profiledata!.rentalOwnerPhoneNumber!, Icons.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStaffDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: blueColor, size: 24),
                SizedBox(width: 12),
                Text(
                  "Staff Details",
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildMobileInfoRow('Staff Member', profiledata!.staffmember_name!,
                Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileUnitDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_work, color: blueColor, size: 24),
                SizedBox(width: 12),
                Text(
                  "Unit Details",
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildMobileInfoRow(
                'Unit', profiledata!.rentalUnit!, Icons.home_work),
            _buildMobileInfoRow('Unit Address', profiledata!.rentalUnitAdress!,
                Icons.location_on),
            _buildMobileInfoRow(
                'Bedrooms', profiledata!.rental_bed!, Icons.bed),
            _buildMobileInfoRow(
                'Bathrooms', profiledata!.rental_bath!, Icons.bathtub),
            _buildMobileInfoRow(
                'Square Feet', profiledata!.rentalSqft!, Icons.square_foot),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: blueColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: blueColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
