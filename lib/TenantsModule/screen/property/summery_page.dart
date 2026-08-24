import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:three_zero_two_property/widgets/no_internet_view.dart';
import 'package:three_zero_two_property/provider/network_retry_state.dart';

class summery_page extends StatefulWidget {
  final String? lease_id;
  summery_page({super.key, this.lease_id});

  @override
  State<summery_page> createState() => _summery_pageState();
}

class _summery_pageState extends State<summery_page>
    with NetworkRetryState {
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
      final response = await apiGet(Uri.parse('$apiUrl'),
          headers: {"authorization": "CRM $token", "id": "CRM $id"});
      final response_Data = jsonDecode(response.body);
      if (response_Data["statusCode"] == 200) {
        setState(() {
          profiledata =
              summery_property.fromJson(jsonDecode(response.body)["data"]);
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
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  /// Required by [NetworkRetryState]: re-issue this screen's own load.
  /// These are the data calls `initState` makes; nothing that sets up
  /// controllers, filters or defaults is repeated, so a reload cannot
  /// reset what the user is looking at.
  @override
  Future<void> reloadData() async {
    if (!mounted) return;
    setState(() {
      fetchProfile();;
    });
  }

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!mounted) return;
      // The event is only a trigger: checkInternet() verifies
      // against the network before deciding, so a stale `none`
      // from the plugin cannot strand this screen offline.
      checkInternet();
    });
    checkInternet();
    fetchProfile();
  }

  void checkInternet() async {
    var connectiondata = await Connectivity().checkConnectivity();
    // connectivity_plus can report a stale `none` after the
    // connection is back; confirm before believing it.
    if (connectiondata == ConnectivityResult.none &&
        await hasNetworkNow()) {
      connectiondata = ConnectivityResult.wifi;
    }
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
      backgroundColor: Color(0xFFF5F7FA),
      drawer: CustomDrawer(currentpage: 'Property'),
      body: !isOffline
          ? _isLoading
              ? Center(
                  child: SpinKitFadingCircle(
                    color: blueColor,
                    size: 50.0,
                  ),
                )
              : _hasError
                  ? Center(
                      child: Text('Error: $_errorMessage'),
                    )
                  : profiledata == null
                      ? Center(child: Text('No data available'))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return _buildTabletLayout();
                            }
                            return _buildMobileLayout();
                          },
                        )
          : NoInternetView(onRetry: retryNow),
    );
  }

  // ── MOBILE LAYOUT ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: titleBar(
              width: double.infinity,
              title: 'Property Details',
            ),
          ),
          const SizedBox(height: 12),

          // ── Card 1: image + property name + address + staff ──
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property image
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: profiledata!.rentalImage != null &&
                            profiledata!.rentalImage!.isNotEmpty
                        ? Image.network(
                            '$image_url${profiledata!.rentalImage}',
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgPlaceholder(),
                          )
                        : _imgPlaceholder(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldItem('Name', profiledata!.propertysubType ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem(
                        'Address',
                        [
                          profiledata!.rentalAdress,
                          profiledata!.rentalCity,
                          profiledata!.rentalCountry,
                          profiledata!.rentalPostcode,
                        ]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(', '),
                      ),
                      const Divider(height: 28, color: Color(0xFFE5E7EB)),
                      Text(
                        'Staff Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: blueColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _fieldItem('Name', profiledata!.staffmember_name ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Card 2: Rental Owner Details ──
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental Owner Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: blueColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _innerFieldBox(
                    children: [
                      _fieldItem('Contact Name',
                          profiledata!.rentalOwnerName ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem('Company Name',
                          profiledata!.rentalOwnerCompanyName ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem('Email',
                          profiledata!.rentalOwnerPrimaryEmail ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem('Phone No',
                          profiledata!.rentalOwnerPhoneNumber ?? 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Card 3: Unit Details ──
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: blueColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _innerFieldBox(
                    children: [
                      _fieldItem('Unit', profiledata!.rentalUnit ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem('Unit Address',
                          profiledata!.rentalUnitAdress ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem('Bed', profiledata!.rental_bed ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem('Bath', profiledata!.rental_bath ?? 'N/A'),
                      const SizedBox(height: 12),
                      _fieldItem(
                          'Square Feet', profiledata!.rentalSqft ?? 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: blueColor.withOpacity(0.18)),
      ),
      child: child,
    );
  }

  Widget _innerFieldBox({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: blueColor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _fieldItem(String label, String value) {
    final display = (value.trim().isEmpty) ? 'N/A' : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: blueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          display,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _imgPlaceholder() {
    return Image.asset(
      'assets/images/noimage.png',
      width: double.infinity,
      height: 160,
      fit: BoxFit.cover,
    );
  }

  // ── TABLET LAYOUT ──────────────────────────────────────────────────────────

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            titleBar(
              width: MediaQuery.of(context).size.width * 0.9,
              title: 'Property Details',
            ),
            SizedBox(height: 30),
            _buildPropertyDetailsCard(),
            SizedBox(height: 20),
            _buildRentalOwnerCard(),
            SizedBox(height: 20),
            _buildStaffDetailsCard(),
            SizedBox(height: 20),
            _buildUnitDetailsCard(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Property Details",
                style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        'Property Type', profiledata!.propertysubType!, Icons.home)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard(
                        'Address', profiledata!.rentalAdress!, Icons.location_on)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        'City', profiledata!.rentalCity!, Icons.location_city)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard(
                        'Country', profiledata!.rentalCountry!, Icons.public)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard(
                        'Post Code', profiledata!.rentalPostcode!, Icons.mail)),
              ],
            ),
            SizedBox(height: 20),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rental Owner Details",
                style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        'Contact Name', profiledata!.rentalOwnerName!, Icons.person)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard('Company Name',
                        profiledata!.rentalOwnerCompanyName!, Icons.business)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        'Email', profiledata!.rentalOwnerPrimaryEmail!, Icons.email)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard('Phone Number',
                        profiledata!.rentalOwnerPhoneNumber!, Icons.phone)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Staff Details",
                style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            SizedBox(height: 20),
            _buildInfoCard(
                'Staff Member', profiledata!.staffmember_name!, Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitDetailsCard() {
    if (profiledata == null) return SizedBox.shrink();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Unit Details",
                style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        'Unit', profiledata!.rentalUnit!, Icons.home_work)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard('Unit Address',
                        profiledata!.rentalUnitAdress!, Icons.location_on)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        'Bedrooms', profiledata!.rental_bed!, Icons.bed)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard(
                        'Bathrooms', profiledata!.rental_bath!, Icons.bathtub)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildInfoCard(
                        'Square Feet', profiledata!.rentalSqft!, Icons.square_foot)),
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
                child: Text(label,
                    style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    overflow: TextOverflow.visible),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
              overflow: TextOverflow.visible),
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
            child: Text('$label',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Text(":  "),
          Expanded(
            flex: 2,
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
