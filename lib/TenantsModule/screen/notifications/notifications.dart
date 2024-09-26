import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../../constant/constant.dart';
import '../../../widgets/titleBar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/appbar.dart';

import 'package:http/http.dart' as http;


class notifications extends StatefulWidget {
  const notifications({super.key});

  @override
  State<notifications> createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  late Future<List<Map<String,dynamic>>> fetchnoti;

  Future<List<Map<String,dynamic>>>? fetchNotifications() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/notification/tenant/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      List<Map<String, dynamic>> notifications = List<Map<String, dynamic>>.from(jsonData["data"]);
      return notifications;
    } else {

      throw Exception('Failed to load data');
    }
  }
  void initState() {
    super.initState();
    fetchnoti = fetchNotifications()!;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Dashboard"),
      appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: () {
        print("calling appbar");
        key.currentState!.openDrawer();
        // Scaffold.of(context).openDrawer();
      },),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
           // Center(child: Text("Notification",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,),)),

            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: titleBar(
                width: MediaQuery.of(context).size.width * .93,
                title: 'Notifications',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<List<Map<String,dynamic>>>(
                future: fetchnoti,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
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
                            SizedBox(height: 10,),
                            Text("No Notifications Yet",style: TextStyle(fontWeight: FontWeight.bold,color:blueColor,fontSize: 16),)
                          ],
                        ),
                      ),
                    );
                  } else
                 {
                   List<Map<String, dynamic>> notifications = snapshot.data!;

                   return SingleChildScrollView(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: notifications.map((notification) {
                           return Padding(
                             padding: const EdgeInsets.symmetric(vertical: 8.0),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(
                                   children: [
                             CircleAvatar(
                             radius: 20,
                                 backgroundColor: Colors.blue.shade100,

                                 child: FaIcon(FontAwesomeIcons.solidBell,size: 18,)),
                                     SizedBox(width: 14.0),

                                     Column(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           notification['notification_title'],
                                           style: TextStyle(
                                               fontSize: 18.0,
                                               fontWeight: FontWeight.bold,
                                               color: blueColor
                                           ),
                                         ),
                                         Text( formatNotificationDateTime(DateTime.parse(notification['createdAt'])), style: TextStyle(
                                             color: Colors.black.withOpacity(.7),
                                           fontSize: 14

                                         ),)
                                       ],
                                     ),
                                     Spacer(),
                                     Container(
                                         height: 40,
                                         width: 40,
                                         decoration: BoxDecoration(
                                           color: Colors.grey.shade200,
                                           borderRadius: BorderRadius.circular(6)
                                         ),
                                         child: Center(child: FaIcon(FontAwesomeIcons.solidEye,size: 22,)))
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
                                        *//* if(notification['notification_title'] =="Workorder Created"){
                                           Navigator.of(context).push(MaterialPageRoute(
                                               builder: (context) =>  ResponsiveEditWorkOrder(workorderId: notification['notification_type']['workorder_id'],)));
                                         }else if(notification['notification_title'] =="New Payment"){
                                           Navigator.of(context).push(MaterialPageRoute(
                                               builder: (context) =>  SummeryPageLease(leaseId: notification['notification_type']['lease_id'],isredirectpayment: true,)));

                                         }*//*

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
          /*  Column(
              children: [
                ListTile(
                  title: Text("New Payment",style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text("Today  |  05:32 PM"),
                  leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,

                      child: FaIcon(FontAwesomeIcons.solidBell,size: 18,)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text("Your credit card has been connected successfully. Enjoy our services",style: TextStyle(fontWeight: FontWeight.w600),),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2,),
            ),
            Column(
              children: [
                ListTile(
                  title: Text("New Payment",style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text("Today  |  05:32 PM"),
                  leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,

                      child: FaIcon(FontAwesomeIcons.solidBell,size: 18,)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text("Your credit card has been connected successfully. Enjoy our services",style: TextStyle(fontWeight: FontWeight.w600),),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2,),
            ),
            Column(
              children: [
                ListTile(
                  title: Text("New Payment",style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text("Today  |  05:32 PM"),
                  leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,

                      child: FaIcon(FontAwesomeIcons.solidBell,size: 18,)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text("Your credit card has been connected successfully. Enjoy our services",style: TextStyle(fontWeight: FontWeight.w600),),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2,),
            ),
            Column(
              children: [
                ListTile(
                  title: Text("New Payment",style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text("Today  |  05:32 PM"),
                  leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,

                      child: FaIcon(FontAwesomeIcons.solidBell,size: 18,)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text("Your credit card has been connected successfully. Enjoy our services",style: TextStyle(fontWeight: FontWeight.w600),),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2,),
            ),
            Column(
              children: [
                ListTile(
                  title: Text("New Payment",style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text("Today  |  05:32 PM"),
                  leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,

                      child: FaIcon(FontAwesomeIcons.solidBell,size: 18,)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text("Your credit card has been connected successfully. Enjoy our services",style: TextStyle(fontWeight: FontWeight.w600),),
                )
              ],
            ),*/


          ],
        ),
      ),
    );
  }
}
