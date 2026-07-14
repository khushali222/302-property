import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '../../../../provider/dateProvider.dart';
import '../../../model/staffpermission.dart';
import '../../../repository/staffpermission_provider.dart';
import '../../../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import '../../../../Model/RentalOwnersData.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';
import 'Edit_RentalOwners.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../../widgets/custom_history_table.dart';
import '../../../../enums/history_type.dart';

class ResponsiveRentalSummary extends StatefulWidget {
  RentalOwnerData? rentalowners;
  String rentalOwnersid;
  ResponsiveRentalSummary(
      {super.key, required this.rentalOwnersid, this.rentalowners});
  @override
  State<ResponsiveRentalSummary> createState() =>
      _ResponsiveRentalSummaryState();
}

class _ResponsiveRentalSummaryState extends State<ResponsiveRentalSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return RentalownersSummeryForTablet(
              rentalowners: widget.rentalowners,
              rentalOwnersid: widget.rentalOwnersid,
            );
          } else {
            return RentalownersSummeryForMobile(
              rentalowners: widget.rentalowners,
              rentalOwnersid: widget.rentalOwnersid,
            );
          }
        },
      ),
    );
  }
}

class RentalownersSummeryForMobile extends StatefulWidget {
  RentalOwnerData? rentalowners;
  String rentalOwnersid;
  RentalownersSummeryForMobile(
      {super.key, required this.rentalOwnersid, this.rentalowners});
  @override
  State<RentalownersSummeryForMobile> createState() =>
      _RentalownersSummeryForMobileState();
}

class _RentalownersSummeryForMobileState
    extends State<RentalownersSummeryForMobile> {
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    fetchPaymentSettings();
  }

  ConnectivityResult? _connectivityResult;
  int _historyRefreshKey = 0;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      print(connectiondata);
      _connectivityResult = connectiondata;
    });
  }
  //for card payment

  bool creditcard = true;
  bool achaccepted = false;
  bool debitcard = true;

  Future<void> fetchPaymentSettings() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");
    final response = await apiGet(
      Uri.parse(
          '${Api_url}/api/payment/rental_owner/setting/${widget.rentalowners?.rentalownerId}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffid",
      },
    );
    final jsonData = json.decode(response.body);
    print(' rental added ${jsonData}');
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      print(creditcard);
      print(creditcard);
      setState(() {
        creditcard = jsonData['data']['creditCardAccepted'] ?? true;
        achaccepted = jsonData['data']['achAccepted'] ?? false;
        debitcard = jsonData['data']['debitCardAccepted'] ?? true;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  bool isLoading = false;
  Future<void> fetchRentalOwner() async {
    setState(() => isLoading = true);
    List<RentalOwnerData> data =
        await RentalOwnerService().fetchRentalOwners("");
    RentalOwnerData? matchedOwner = data.firstWhere(
      (owner) => owner.rentalownerId == widget.rentalOwnersid,
      // orElse: () => null, // fallback if not found
    );

    setState(() {
      widget.rentalowners = matchedOwner;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Rental Owner",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? Center(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_sharp,
                            size: 30,
                          )),
                      const SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.rentalowners?.rentalOwnername}',
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'RentalOwner',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8A95A8)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.065),
                          GestureDetector(
                            onTap: () async {
                              var check = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Edit_rentalowners(
                                          rentalOwner: widget.rentalowners!)));

                              if (check == true) {
                                await fetchRentalOwner();
                                await fetchPaymentSettings();
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .045,
                                width: MediaQuery.of(context).size.width * .15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: blueColor,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .034),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.only(top: 6, left: 10),
                        width: MediaQuery.of(context).size.width * .91,
                        margin: const EdgeInsets.only(bottom: 6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: blueColor,
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Summary",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                  //Personal information
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Material(
                      // elevation: 2,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Personal Information",
                                style: TextStyle(
                                  color: Color(0xFF101828),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Contact Name Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Contact Name',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.rentalOwnername ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnername}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Company Name',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.rentalOwnerCompanyName ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerCompanyName}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Street Address Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Street Address',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.streetAddress ?? '').isEmpty ? 'N/A' : widget.rentalowners?.streetAddress}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'City',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.city ?? '').isEmpty ? 'N/A' : widget.rentalowners?.city}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // State Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'State',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.state ?? '').isEmpty ? 'N/A' : widget.rentalowners?.state}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Country',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.country ?? '').isEmpty ? 'N/A' : widget.rentalowners?.country}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Zipcode
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Zipcode',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.postalCode ?? '').isEmpty ? 'N/A' : widget.rentalowners?.postalCode}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                      flex: 1,
                                      child:
                                          SizedBox()), // Empty space for alignment
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Contact Information
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Material(
                      //  elevation: 2,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Contact Information",
                                style: TextStyle(
                                  color: Color(0xFF101828),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Phone Number Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Phone Number',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatPhoneNumber(
                                              '${widget.rentalowners?.rentalOwnerPhoneNumber}'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Home Number',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatPhoneNumber(
                                              '${widget.rentalowners?.rentalOwnerHomeNumber}'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Business Number Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Business Number',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatPhoneNumber(
                                              '${widget.rentalowners?.rentalOwnerBusinessNumber}'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Email',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.rentalOwnerPrimaryEmail ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerPrimaryEmail}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Alternate Email
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Alternate Email',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.rentalOwnerAlternateEmail ?? '').isEmpty ? 'N/A' : widget.rentalowners?.rentalOwnerAlternateEmail}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                      flex: 1,
                                      child:
                                          SizedBox()), // Empty space for alignment
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Management Agreement Details
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Material(
                      // elevation: 2,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Management Agreement Details",
                                style: TextStyle(
                                  color: Color(0xFF101828),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Start Date',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateProvider
                                                  .formatCurrentDate(
                                                      '${widget.rentalowners?.startDate}')
                                                  .isEmpty
                                              ? 'N/A'
                                              : dateProvider.formatCurrentDate(
                                                  '${widget.rentalowners?.startDate}'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'End Date',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateProvider
                                                  .formatCurrentDate(
                                                      '${widget.rentalowners?.endDate}')
                                                  .isEmpty
                                              ? 'N/A'
                                              : dateProvider.formatCurrentDate(
                                                  '${widget.rentalowners?.endDate}'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
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

                  const SizedBox(height: 20),

                  // 1099 - NEC Tax Filing Information
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Material(
                      //  elevation: 2,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "1099 - NEC Tax Filing Information",
                                style: TextStyle(
                                  color: Color(0xFF101828),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tax ID Type',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.textIdentityType ?? '').isEmpty ? 'N/A' : widget.rentalowners?.textIdentityType}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Taxpayer ID',
                                          style: TextStyle(
                                            color: Color(0xFF101828),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(widget.rentalowners?.texpayerId ?? '').isEmpty ? 'N/A' : widget.rentalowners?.texpayerId}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF636363),
                                          ),
                                        ),
                                      ],
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

                  const SizedBox(height: 20),

                  // Card Transaction Type Settings
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Material(
                      // elevation: 2,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Card Transaction Type Settings",
                                style: TextStyle(
                                  color: Color(0xFF101828),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Allowed card types for rental transactions",
                                style: TextStyle(
                                  color: Color(0xFF8A95A8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Credit Card Row
                              Row(
                                children: [
                                  Icon(
                                    creditcard ? Icons.check : Icons.close,
                                    color:
                                        creditcard ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Credit Card",
                                    style: TextStyle(
                                      color: Color(0xFF101828),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Debit Card Row
                              Row(
                                children: [
                                  Icon(
                                    debitcard ? Icons.check : Icons.close,
                                    color:
                                        debitcard ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Debit Card",
                                    style: TextStyle(
                                      color: Color(0xFF101828),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ach  Row
                              Row(
                                children: [
                                  Icon(
                                    achaccepted ? Icons.check : Icons.close,
                                    color: achaccepted ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "ACH",
                                    style: TextStyle(
                                      color: Color(0xFF101828),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
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

                  // const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    child: CustomHistoryTable(
                      key: ValueKey(_historyRefreshKey),
                      historyType: HistoryType.rentalOwner,
                      entityId: widget.rentalOwnersid,
                      title: 'History',
                      blueColor: blueColor,
                      itemsPerPage: 10,
                    ),
                  ),
                ],
              ),
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
                  const Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }
}

class RentalownersSummeryForTablet extends StatefulWidget {
  RentalOwnerData? rentalowners;
  String rentalOwnersid;
  RentalownersSummeryForTablet(
      {super.key, required this.rentalOwnersid, this.rentalowners});
  @override
  State<RentalownersSummeryForTablet> createState() =>
      _RentalownersSummeryForTabletState();
}

class _RentalownersSummeryForTabletState
    extends State<RentalownersSummeryForTablet> {
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
  }

  ConnectivityResult? _connectivityResult;
  int _historyRefreshKey = 0;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      print(connectiondata);
      _connectivityResult = connectiondata;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Rental Owner",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? Center(
              child: FutureBuilder<List<RentalOwnerData>>(
                future: RentalOwnerService()
                    .fetchRentalOwnerssummery(widget.rentalOwnersid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Center(
                          child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 40.0,
                      )),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<RentalOwnerData> rentalownersummery =
                        snapshot.data ?? [];
                    print(snapshot.data!.length);
                    //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
                    return ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${rentalownersummery.first.rentalOwnername}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: blueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  'RentalOwner',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8A95A8)),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.065),
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Edit_rentalowners(
                                                    rentalOwner:
                                                        rentalownersummery
                                                            .first)));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      height: 50,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: blueColor,
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 21),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      height: 50,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: blueColor,
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Back",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 21),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Container(
                              height: 50.0,
                              padding: const EdgeInsets.only(top: 8, left: 10),
                              width: MediaQuery.of(context).size.width * .91,
                              margin: const EdgeInsets.only(bottom: 6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: blueColor,
                                boxShadow: [
                                  const BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: const Text(
                                "Summary",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                        //Personal information
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, right: 25),
                              child: Material(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: screenWidth * 0.45,

                                  // width: 350,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: blueColor),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 25,
                                        top: 20,
                                        bottom: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              "Personal Information",
                                              style: TextStyle(
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold,
                                                  // fontSize: 18
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color: blueColor,
                                        ),
                                        //phonenumber
                                        Table(
                                          children: [
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Name',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  '${(rentalownersummery.first.rentalOwnername ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnername}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Company Name',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  '${(rentalownersummery.first.rentalOwnerCompanyName ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerCompanyName}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Street Address',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  '${(rentalownersummery.first.streetAddress ?? '').isEmpty ? 'N/A' : rentalownersummery.first.streetAddress}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'City',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  '${(rentalownersummery.first.city ?? '').isEmpty ? 'N/A' : rentalownersummery.first.city}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'State',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  '${(rentalownersummery.first.state ?? '').isEmpty ? 'N/A' : rentalownersummery.first.state}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Country',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  '${(rentalownersummery.first.country ?? '').isEmpty ? 'N/A' : rentalownersummery.first.country}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Zip Code ',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  '${(rentalownersummery.first.postalCode ?? '').isEmpty ? 'N/A' : rentalownersummery.first.postalCode}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                          ],
                                        ),
                                        //primary email
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //Personal information
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: screenWidth * 0.45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: blueColor),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25,
                                          right: 25,
                                          top: 20,
                                          bottom: 30),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                "Contact Information",
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    // fontSize: 18
                                                    fontSize: 21),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            color: blueColor,
                                          ),
                                          //first name
                                          Table(
                                            children: [
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'Phone Number',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                    formatPhoneNumber(
                                                        '${rentalownersummery.first.rentalOwnerPhoneNumber}'),
                                                    //'${(rentalownersummery.first.rentalOwnerPhoneNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerPhoneNumber}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor),
                                                  ),
                                                )),
                                              ]),
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'Home Number',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                    formatPhoneNumber(
                                                        '${rentalownersummery.first.rentalOwnerHomeNumber}'),
                                                    // '${(rentalownersummery.first.rentalOwnerHomeNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerHomeNumber}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor),
                                                  ),
                                                )),
                                              ]),
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'Business Number',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                    formatPhoneNumber(
                                                        '${rentalownersummery.first.rentalOwnerBusinessNumber}'),
                                                    //'${(rentalownersummery.first.rentalOwnerBusinessNumber ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerBusinessNumber}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor),
                                                  ),
                                                )),
                                              ]),
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'Email',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                    '${(rentalownersummery.first.rentalOwnerPrimaryEmail ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerPrimaryEmail}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor),
                                                  ),
                                                )),
                                              ]),
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'Alternative Email',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                    '${(rentalownersummery.first.rentalOwnerAlternateEmail ?? '').isEmpty ? 'N/A' : rentalownersummery.first.rentalOwnerAlternateEmail}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor),
                                                  ),
                                                )),
                                              ]),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, right: 25),
                              child: Material(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: screenWidth * 0.45,
                                  // width: 350,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: blueColor),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 25,
                                        top: 20,
                                        bottom: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              "Management Agreement",
                                              style: TextStyle(
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold,
                                                  // fontSize: 18
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color: blueColor,
                                        ),
                                        //phonenumber
                                        Table(
                                          children: [
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Start Date',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  formatDate(
                                                      '${(rentalownersummery.first.startDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.startDate}'),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                            TableRow(children: [
                                              const TableCell(
                                                  child: Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'End Date',
                                                  style: TextStyle(
                                                      color: Color(0xFF8A95A8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              )),
                                              TableCell(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Text(
                                                  formatDate3(
                                                      '${(rentalownersummery.first.endDate ?? '').isEmpty ? 'N/A' : rentalownersummery.first.endDate}'),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                            ]),
                                          ],
                                        ),
                                        //primary email
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //Personal information
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: screenWidth * 0.45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: blueColor),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25,
                                          right: 10,
                                          top: 20,
                                          bottom: 30),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                "1099-NEC Tax Filling Information",
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    // fontSize: 18
                                                    fontSize: 21),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            color: blueColor,
                                          ),
                                          //first name
                                          Table(
                                            children: [
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'Tax Identify Type',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                    '${(rentalownersummery.first.textIdentityType ?? '').isEmpty ? 'N/A' : rentalownersummery.first.textIdentityType}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor),
                                                  ),
                                                )),
                                              ]),
                                              TableRow(children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Text(
                                                    'Tax PayerId',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                    '${(rentalownersummery.first.texpayerId ?? '').isEmpty ? 'N/A' : rentalownersummery.first.texpayerId}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor),
                                                  ),
                                                )),
                                              ]),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        child: CustomHistoryTable(
                          key: ValueKey(_historyRefreshKey),
                          historyType: HistoryType.rentalOwner,
                          entityId: widget.rentalOwnersid,
                          title: 'History',
                          blueColor: blueColor,
                          itemsPerPage: 10,
                        ),
                      ),
                      ],
                    );
                  }
                },
              ),
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
                  const Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }
}
