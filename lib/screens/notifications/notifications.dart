import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../constant/constant.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/titleBar.dart';
import 'package:http/http.dart' as http;

import '../Maintenance/Workorder/Edit_workorders.dart';
import '../Leasing/RentalRoll/SummeryPageLease.dart';
class notifications extends StatefulWidget {
  const notifications({super.key});

  @override
  State<notifications> createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {



  Future<List<Map<String,dynamic>>>? fetchNotifications() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/notification/admin/$id'),
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

  String formatDateTime(String dateTime) {
    DateTime parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDateTime);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:CustomDrawer(currentpage: "Dashboard",dropdown: false,),
      appBar: widget_302.App_Bar(context: context),
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
              child: FutureBuilder<List<Map<String,dynamic>>>(
                future: fetchNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                   // return ColabShimmerLoadingWidget();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return Container(
                        height: MediaQuery.of(context).size.height * .5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/no_data.jpg",height: 200,width: 200,),
                              SizedBox(height: 10,),
                              Text("No Data Available",style: TextStyle(fontWeight: FontWeight.bold,color:blueColor,fontSize: 16),)
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
                                 Text(
                                   notification['notification_title'],
                                   style: TextStyle(
                                     fontSize: 18.0,
                                     fontWeight: FontWeight.bold,
                                     color: blueColor
                                   ),
                                 ),
                                 SizedBox(height: 4.0),
                                 Text(
                                   notification['notification_detail'],
                                   style: TextStyle(
                                     fontSize: 16.0,
                                     color: Colors.grey[700],
                                   ),
                                 ),
                                 SizedBox(height: 8.0),
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text(
                                       formatDateTime(notification['createdAt']),
                                       style: TextStyle(
                                         fontSize: 14.0,
                                         color:blueColor,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                     ElevatedButton(
                                       onPressed: () {
                                         if(notification['notification_title'] =="Workorder Created"){
                                           Navigator.of(context).push(MaterialPageRoute(
                                               builder: (context) =>  ResponsiveEditWorkOrder(workorderId: notification['notification_type']['workorder_id'],)));
                                         }else if(notification['notification_title'] =="New Payment"){
                                           Navigator.of(context).push(MaterialPageRoute(
                                               builder: (context) =>  SummeryPageLease(leaseId: notification['notification_type']['lease_id'],isredirectpayment: true,)));

                                         }

                                         // Handle view button press
                                       },
                                       child: Text('View'),
                                     ),
                                   ],
                                 ),
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
