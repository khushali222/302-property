import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Workorder/workorder_summery.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Properties/summery_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../repository/properties.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/appbar.dart';
import '../../../widgets/titleBar.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

import '../Maintenance/Workorder/Edit_workorders.dart';
import '../Leasing/RentalRoll/SummeryPageLease.dart';

class notifications extends StatefulWidget {
  const notifications({super.key});

  @override
  State<notifications> createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {
  late Future<List<Map<String, dynamic>>> fetchnoti;
  void initState() {
    super.initState();
    // fetchnoti = fetchNotifications()!;
    loadNotifications();
  }

  void loadNotifications() {
    setState(() {
      fetchnoti = fetchNotifications()!;
    });
  }

  Future<List<Map<String, dynamic>>>? fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await apiGet(
      Uri.parse('${Api_url}/api/notification/staff/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      List<Map<String, dynamic>> notifications =
          List<Map<String, dynamic>>.from(jsonData["data"]);
      return notifications;
    } else {
      throw Exception('Failed to load data');
    }
  }

  String formatNotificationDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final difference = now.difference(dateTime);

    if (dateTime.isAfter(today)) {
      // For today
      return 'Today | ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (dateTime.isAfter(yesterday)) {
      // For yesterday
      return 'Yesterday | ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (difference.inDays < 31) {
      // For days ago (less than a month)
      return '${difference.inDays} days ago | ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (difference.inDays < 60) {
      // For more than a month ago
      return '${(difference.inDays / 30).floor()} month ago';
    } else if (difference.inDays < 365) {
      // For more than a month ago
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      // For more than a year ago
      return DateFormat('dd-MM-yyyy').format(dateTime);
    }
  }

  String formatDateTime(String dateTime) {
    DateTime parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDateTime);
  }

  Future<bool> fetchRentalDetails(String rentalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    try {
      final response = await apiGet(
        Uri.parse('${Api_url}/api/rentals/rental_summary/$rentalId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] != null && jsonData['data'].isNotEmpty) {
          return jsonData['data'][0]['is_multiunit'] ?? false;
        }
      }
      return false;
    } catch (e) {
      logError("Error fetching rental details: $e");
      return false;
    }
  }

  Future<void> handleNotificationTap(
      BuildContext context, bool isWorkOrder, String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    String apiUrl =
        '${Api_url}/api/notification/staff_notification/$notificationId';


    try {
      var response = await apiPut(
        Uri.parse(apiUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: json.encode({'is_workorder': isWorkOrder}),
      );

      final jsonData = json.decode(response.body);

      if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {

        final responseData = jsonData['data'];

        if (responseData['is_workorder'] == true) {
          String workOrderId =
              responseData['notification_type']['workorder_id'];
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Workorder_summery(workorder_id: workOrderId)));
        } else {
          String rentalId = responseData['rental_id'];

          // Fetch rental details to determine if it's multi-unit
          bool isMultiUnit = await fetchRentalDetails(rentalId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Summery_page(
                properties: Rentals(rentalId: rentalId),
                notification_redirect: true,
              ),
            ),
          );
        }
      } else {
      }
    } catch (e) {
      logError("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawerStaff(
        currentpage: "Dashboard",
        dropdown: false,
      ),
      appBar: widget_302_Staff.App_Bar(context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: titleBar(
                width: MediaQuery.of(context).size.width * .93,
                title: 'Notifications',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchnoti,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .7,
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: blueColor,
                          size: 50.0,
                        ),
                      ),
                    );
                    // return ColabShimmerLoadingWidget();
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/no_notification.jpg"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "No Notifications Yet",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    List<Map<String, dynamic>> notifications = snapshot.data!;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: notifications.map((notification) {
                            // print(formatNotificationDateTime(DateTime.parse(notification['createdAt'])));
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.blue.shade100,
                                          child: FaIcon(
                                            FontAwesomeIcons.solidBell,
                                            size: 18,
                                          )),
                                      SizedBox(width: 14.0),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification['notification_title'],
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                          Text(
                                            notification['createdAt']
                                                        ?.isEmpty ??
                                                    true
                                                ? 'No date available'
                                                : timeago.format(
                                                    DateTime.parse(notification[
                                                            'createdAt'])
                                                        .toLocal(),
                                                    locale: 'en_custom'),
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(.7),
                                                fontSize: 14),
                                          )
                                        ],
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          handleNotificationTap(
                                              context,
                                              notification['is_workorder'],
                                              notification['notification_id']);
                                          loadNotifications();
                                        },
                                        child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Center(
                                                child: FaIcon(
                                              FontAwesomeIcons.solidEye,
                                              size: 22,
                                            ))),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 14.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      notification['notification_detail'],
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  /* Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text(
                                       formatNotificationDateTime(notification['createdAt']),
                                       style: TextStyle(
                                         fontSize: 14.0,
                                         color:blueColor,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                     ElevatedButton(
                                       onPressed: () {
                                        */ /* if(notification['notification_title'] =="Workorder Created"){
                                           Navigator.of(context).push(MaterialPageRoute(
                                               builder: (context) =>  ResponsiveEditWorkOrder(workorderId: notification['notification_type']['workorder_id'],)));
                                         }else if(notification['notification_title'] =="New Payment"){
                                           Navigator.of(context).push(MaterialPageRoute(
                                               builder: (context) =>  SummeryPageLease(leaseId: notification['notification_type']['lease_id'],isredirectpayment: true,)));

                                         }*/ /*

                                         // Handle view button press
                                       },
                                       child: Text('View'),
                                     ),
                                   ],
                                 ),*/
                                  Divider(thickness: 1.0),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
